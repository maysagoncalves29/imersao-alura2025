using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseUrls("http://0.0.0.0:7064");

// Adiciona configuração do appsettings.json
builder.Configuration.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);

// Adiciona suporte ao Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configura o HttpClient para reutilização (melhor prática)
builder.Services.AddHttpClient("GeminiClient", client =>
{
    client.BaseAddress = new Uri("https://generativelanguage.googleapis.com/v1beta/");
    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
});

// Adiciona suporte a logging
builder.Services.AddLogging(loggingBuilder =>
{
    loggingBuilder.AddConsole();
    loggingBuilder.AddDebug();
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapPost("/api/ia/gerar-dica", async ([FromBody] EntradaModel entrada, IConfiguration config, IHttpClientFactory httpClientFactory, ILogger<Program> logger) =>
{
    var apiKey = config["Gemini:ApiKey"];
    if (string.IsNullOrEmpty(apiKey))
    {
        logger.LogError("A chave da API Gemini não foi configurada em appsettings.json.");
        return Results.Problem("A chave da API Gemini não foi configurada.");
    }

    string estilo = entrada.Estilo?.ToLowerInvariant().Trim() ?? "simples";

    string promptBase = $"Explique de forma clara, simples e gentil como ajudar uma pessoa idosa que tem dificuldade em: {entrada.Texto}.";

    if (entrada.Acessivel)
    {
        promptBase += " Responda de forma ainda mais simples, sem usar nomes próprios, e com explicações que sejam acessíveis para pessoas com baixa visão ou pouca familiaridade com tecnologia.";
    }

    string estiloExtra = estilo switch
    {
        "com imagens" => "Sugira imagens ou símbolos simples que possam ilustrar a explicação.",
        "com exemplos" => "Inclua um exemplo da vida real, como usar um celular para falar com o neto.",
        "com dicas de segurança" => "Inclua também uma dica de segurança digital para essa situação.",
        "detalhado" => "Dê um passo a passo com instruções curtas e diretas.",
        _ => "Use frases curtas, evite termos técnicos"
    };

    var prompt = $"{promptBase} {estiloExtra}";
    try
    {
        var client = httpClientFactory.CreateClient("GeminiClient");
        client.DefaultRequestHeaders.Add("x-goog-api-key", apiKey);

        var requestBody = JsonSerializer.Serialize(new
        {
            contents = new[]
            {
                new {
                    parts = new[] { new { text = prompt } }
                }
            }
        });
        logger.LogInformation($"Request Body para Gemini: {requestBody}");

        // Atualização da URL para usar o modelo gemini-2.0-flash-001
        var response = await client.PostAsync("models/gemini-2.0-flash-001:generateContent", new StringContent(requestBody, Encoding.UTF8, "application/json"));

        if (!response.IsSuccessStatusCode)
        {
            var errorContent = await response.Content.ReadAsStringAsync();
            logger.LogError($"Erro ao chamar Gemini. Status Code: {response.StatusCode}, Response Content: {errorContent}");
            return Results.Problem($"Erro ao chamar Gemini. Status Code: {response.StatusCode}, Detalhes: {errorContent}");
        }

        var resultJson = await response.Content.ReadAsStringAsync();
        logger.LogInformation($"Resposta da Gemini: {resultJson}");

        try
        {
            var respostaGemini = JsonDocument.Parse(resultJson);
            var dicaElement = respostaGemini.RootElement.GetProperty("candidates")[0].GetProperty("content").GetProperty("parts")[0];
            if (dicaElement.TryGetProperty("text", out var dicaProperty))
            {
                var dica = dicaProperty.GetString();
                return Results.Ok(new { resposta = dica });
            }
            else
            {
                logger.LogError($"Estrutura da resposta da Gemini inesperada: 'text' não encontrado.");
                return Results.Problem("Estrutura da resposta da Gemini inesperada.");
            }
        }
        catch (JsonException ex)
        {
            logger.LogError($"Erro ao deserializar a resposta da Gemini: {ex.Message}, Json: {resultJson}");
            return Results.Problem($"Erro ao processar a resposta da Gemini: {ex.Message}");
        }
    }
    catch (HttpRequestException ex)
    {
        logger.LogError($"Erro de requisição HTTP para a API Gemini: {ex.Message}");
        return Results.Problem($"Erro de comunicação com a API Gemini: {ex.Message}");
    }
    catch (Exception ex)
    {
        logger.LogError($"Erro inesperado ao chamar a API Gemini: {ex.Message}");
        return Results.Problem($"Erro inesperado ao chamar a API Gemini: {ex.Message}");
    }
});

app.Run();

record EntradaModel(string Texto, string? Estilo = null, bool Acessivel = false);
