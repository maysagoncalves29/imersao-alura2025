<p align="center">
  <img width="264" alt="logonovaia" src="https://github.com/user-attachments/assets/cb50473a-7677-4a85-9e2a-c91fd605d462" height="96"/>
  <h3 align="center">IncluiAI</h3>
</p>

<p align="center">
  Ajudando idosos a se incluírem no mundo digital com dicas simples e personalizadas! 💡📱
</p>

<p align="center">
  <a href="https://github.com/maysagoncalves29/imersao-alura2025/tree/master/imersao-frontend/digitaliza_ia"><strong>App Flutter</strong></a> ·
  <a href="https://github.com/maysagoncalves29/imersao-alura2025/tree/master/imersao-backend/WebApplication1"><strong>API .NET</strong></a> ·
   <a href="https://maysas-organization.gitbook.io/maysas-organization-docs"><strong>Documentação Simples</strong></a>
</p>

---

## IncluiAI

O IncluiAI é um aplicativo que conecta idosos ao universo digital através de dicas acessíveis, personalizadas e geradas por IA. ✉️

O projeto utiliza a API do Gemini para interpretar perguntas em linguagem natural, como por exemplo: "Não sei como mandar áudio no WhatsApp". Em resposta, o sistema gera instruções claras, passo a passo, com recursos de voz e imagem.

---

## ✨ Motivação

Atualmente, estou desenvolvendo um aplicativo com um layout simples (front-end não é o meu forte), mas com funcionalidades pensadas para acessibilidade.

Minha avó tem problema de baixa visão e muitas vezes não consegue ler o que está no celular, usando-o principalmente para chamadas de vídeo com a família. Já meu avô tem dificuldades com tecnologia, mas com esforço e paciência, já consegue fazer um PIX sozinho.

Mas… e quem não tem esse apoio em casa?

Essas pessoas acabam excluídas digitalmente.

Pensando nisso, aproveitei a imersão da Alura e decidi desenvolver um app simples, acessível e inteligente. Meu objetivo é ajudar tanto pessoas com baixa visão quanto analfabetos digitais — que, diferente do que muitos pensam, não estão só entre os idosos.

---
## 🎨 Cores e Layout

As cores e o design foram escolhidos com foco na acessibilidade visual:

- Alto contraste: Fundo preto com textos e botões em amarelo para facilitar a visualização
- Botões grandes e bem espaçados: Facilitando o clique para pessoas com coordenação motora reduzida
- Opções de A+ e A-: Controle de tamanho da fonte visível na interface
- Microfone integrado: Entrada por voz para quem tem dificuldade de digitar
- Botão de acessibilidade: Ícone visível no canto inferior direito da tela
- Checkbox de "Resposta acessível": Para garantir conteúdo adaptado

<p align="center">
<img width="218" alt="inclui-ia(1)" src="https://github.com/user-attachments/assets/dc9ab92d-6f3f-460f-85a7-01c6fb593923" />
<img width="218" alt="inclui-ia(2)" src="https://github.com/user-attachments/assets/4003fa28-505e-40df-be30-fbbd2fcd2f63" />
</p>

---

## Contexto Social

Milhões de brasileiros acima de 60 anos enfrentam barreiras para acessar serviços digitais. O IncluiAI surge como ferramenta de inclusão, promovendo autonomia e bem-estar.

## ⚙️ Tecnologias Utilizadas

### Backend (.NET 8)

- ASP.NET Core Web API
- Integração com a API Gemini (Google AI)
- CORS liberado para o front-end
- Respostas acessíveis com passo a passo simples

### Frontend (Flutter)

- Interface com contraste alto (fundo preto e elementos amarelos)
- Botões grandes e bem espaçados
- Sugestões rápidas pré-definidas
- Suporte à leitura por voz (TTS)
- Funcionalidade de acessibilidade integrada
- Reconhecimento de fala (microfone visível na interface) - (Em desenvolvimento)
- Seção de emergência com acesso a contatos importantes (Hospitais, Delegacias, Abrigos)

---

### 📦 Exemplo de uso no Swagger

Veja abaixo um exemplo real de uso do endpoint de geração de dica com IA:

![image](https://github.com/user-attachments/assets/5d3cd004-a925-4df0-90e8-f2af0b11ba5c)
![image](https://github.com/user-attachments/assets/4a681768-cd33-4f3f-8231-dff25704ba22)

---

### 📬 Exemplo de chamada via Python (Google Colab)

```python
import requests

url = "http://localhost:<sua-porta>/api/ia/gerar-dica"
entrada = {
    "texto": "mandar um áudio no WhatsApp",
    "acessivel": True,
    "estilo": "detalhado"
}

response = requests.post(url, json=entrada)
print(response.json())
```

---

## 🧠 Como Funciona

1. O usuário **digita ou fala** uma dúvida (ex: “como mandar áudio no WhatsApp?”)
2. O front-end envia a pergunta para a API
3. O back-end consulta a **API Gemini**
4. O modelo retorna um **passo a passo claro**
5. O app exibe a dica com:
   - **Texto ampliado**
   - **Áudio explicativo**
   - **(Em breve)** Imagens ilustrativas
  
<img width="266" alt="fluxo" src="https://github.com/user-attachments/assets/642446d3-a9a1-405c-b3c4-c971c84fcf50" />

---

## Como rodar o projeto

### Backend (.NET)

1. Acesse a pasta:

```bash
cd backend/WebApplication1
```

2. Configure sua API Key do Gemini no arquivo `appsettings.json`.

3. Rode a API:

```bash
dotnet run
```

A aplicação estará disponível em: `https://localhost:7064`

### Frontend (Flutter)

1. Acesse a pasta:

```bash
cd frontend/digitaliza_ia
```

2. Execute o app em um emulador ou dispositivo:

```bash
flutter run
```

---

## 🌱 Próximos Passos
✅ Comunicação entre front e back

🎙️ Entrada de voz com reconhecimento de fala

🧠 Geração de imagens ilustrativas via IA

🧪 Testes com idosos e familiares

## 💡 Visão de Futuro
O IncluiAI nasceu como um projeto de imersão, mas carrega um propósito maior: tornar a tecnologia mais humana e acessível para quem mais precisa.

A inclusão digital deve ser uma prioridade. Esse é só o começo.

## Diferenciais

* Linguagem simples, inclusiva e acessível
* Interface com alto contraste e elementos grandes
* Controle de tamanho de fonte integrado
* Suporte a entrada por voz
* Sugestões rápidas para dúvidas comuns
* Acesso rápido a contatos de emergência
* Gerador inteligente de dicas baseado em IA

---

## 🧭 Futuro do Projeto

Em versões futuras, este projeto pretende ir além das respostas geradas por IA. Entre as funcionalidades planejadas estão:

⏰ Lembretes inteligentes para tomar remédios e se hidratar, com notificações em horários programados.

🧘‍♀️ Orientações práticas para exercícios físicos simples e seguros, adaptados para o dia a dia de pessoas idosas.

🤝 Companhia virtual, oferecendo interações leves e motivacionais para reduzir o isolamento social e promover o bem-estar emocional.

Esses recursos terão como foco a acessibilidade digital real, promovendo autonomia, saúde e inclusão por meio da tecnologia.

---

## 👩‍💻 Desenvolvido por
Maysa Gonçalves

Desenvolvedora .NET em formação | Apaixonada por tecnologia com propósito

GitHub: @maysagoncalves29

<a href="https://www.linkedin.com/in/maysa-goncalves/">LinkedIn</a>

---
## Licença

Este projeto está sob a licença MIT. Sinta-se à vontade para contribuir, adaptar e compartilhar!

## Créditos

Logo criado com [Canva](https://www.canva.com).

---

Tecnologia só faz sentido se alcançar quem mais precisa dela. ✨
