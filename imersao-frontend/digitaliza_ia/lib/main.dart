import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Pacotes para voz
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

void main() {
  // Configurando acessibilidade para toda a aplicação
  WidgetsFlutterBinding.ensureInitialized();
  runApp(IncluiAIApp());
}

class IncluiAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
        // Aumentando tamanho das fontes e melhorando contraste
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber), // Aumentado e melhorado contraste
          bodyMedium: TextStyle(fontSize: 28, color: Colors.white), // Aumentado
          labelLarge: TextStyle(fontSize: 26, color: Colors.white), // Aumentado
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            textStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold), // Aumentado
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 28), // Maior área de toque
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white, width: 2), // Borda para melhor visibilidade
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 24), // Melhorado contraste do placeholder
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.amber, width: 2), // Borda mais visível
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.amber, width: 2), // Borda mais visível
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.amberAccent, width: 3), // Borda destacada quando em foco
          ),
        ),
        // Configurando tema de botões de ícone também
        iconTheme: IconThemeData(
          color: Colors.amber,
          size: 36, // Ícones maiores
        ),
      ),
      // Configurações globais de acessibilidade
      highContrastTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.yellowAccent),
          bodyMedium: TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
      home: IncluiAIHome(),
    );
  }
}

class IncluiAIHome extends StatefulWidget {
  @override
  State<IncluiAIHome> createState() => _IncluiAIHomeState();
}

class _IncluiAIHomeState extends State<IncluiAIHome> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  final FocusNode _inputFocusNode = FocusNode(); // Focus para acessibilidade

  bool _carregando = false;
  bool _escutando = false;
  bool _acessivel = true; // Tornando acessível por padrão
  String _resposta = '';
  double _textScaleFactor = 1.0; // Para permitir zoom de texto

  Timer? _lembreteAgua;
  Timer? _lembreteExercicio;

  final List<String> palavrasChave = [
    'Como usar o WhatsApp?',
    'Como consigo fazer pix?',
    'Como faço uma chamada?',
    'Onde fica o botão da câmera?',
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTts();
    _iniciarLembretes();
    
    // Configurando TTS para melhor acessibilidade
    _configurarTTSAcessivel();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('pt-BR');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  // Configuração adicional para TTS mais acessível
  Future<void> _configurarTTSAcessivel() async {
    await _flutterTts.setPitch(1.0); // Tom normal
    // Fala inicial para orientar o usuário quando o app carrega
    Future.delayed(Duration(seconds: 1), () {
      _falarResposta('Aplicativo IncluiAI aberto. Toque na parte central da tela para digitar ou usar comando de voz.');
    });
  }

  void _iniciarLembretes() {
    _lembreteAgua = Timer.periodic(Duration(hours: 2), (_) {
      _falarResposta('Hora de beber água! Manter-se hidratado é muito importante.');
    });
    _lembreteExercicio = Timer.periodic(Duration(hours: 4), (_) {
      _falarResposta('Lembre-se de se alongar ou fazer um exercício leve.');
    });
  }

  Future<void> _gerarDica() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) {
      _falarResposta('Por favor, digite ou fale o que você precisa antes de gerar a dica.');
      return;
    }
    

    setState(() => _carregando = true);
    try {
      final uri = Uri.parse('http://10.0.2.2:7064/api/ia/gerar-dica');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'texto': texto, 'acessivel': _acessivel}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _resposta = data['resposta']);
        await _falarResposta(_resposta);
      } else {
        throw Exception('Erro na resposta da API');
      }
    } catch (e) {
      setState(() => _resposta = 'Erro ao gerar dica. Por favor, verifique sua conexão e tente novamente.');
      await _falarResposta('Desculpe, houve um erro ao gerar a dica. Verifique sua conexão com a internet e tente novamente.');
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _falarResposta(String texto) async {
    await _flutterTts.stop();
    await _flutterTts.speak(texto.replaceAll('*', ''));
  }

  void _startListening() async {
    await _flutterTts.stop(); // Para qualquer fala antes de começar a ouvir
    
    _falarResposta('Estou ouvindo, pode falar');
    
    final disponivel = await _speech.initialize(
      onStatus: (status) => setState(() => _escutando = status == 'listening'),
      onError: (error) {
        setState(() => _escutando = false);
        _falarResposta('Desculpe, não consegui entender. Tente novamente.');
      },
    );

    if (disponivel) {
      _speech.listen(
        localeId: 'pt_BR',
        onResult: (val) {
          if (val.finalResult) {
            setState(() {
              _controller.text = val.recognizedWords;
              _escutando = false;
            });
            _falarResposta('Você disse: ${val.recognizedWords}. Gerando resposta.');
            _gerarDica();
          }
        },
      );
    } else {
      _falarResposta('Não foi possível iniciar o reconhecimento de voz. Verifique as permissões do aplicativo.');
    }
  }

  void _usarPalavraChave(String palavra) {
    setState(() => _controller.text = palavra);
    _falarResposta('Selecionado: $palavra. Gerando resposta.');
    _gerarDica();
  }
  
  Future<void> _abrirMapaComBusca(String termo) async {
  _falarResposta('Abrindo mapa para buscar $termo');
  
  // Usando esquema geo que é melhor suportado em emuladores
  final String encodedTermo = Uri.encodeComponent(termo);
  
  // Tentativa 1: esquema geo (funciona melhor em emuladores)
  final geoUri = Uri.parse('geo:0,0?q=$encodedTermo');
  
  // Tentativa 2: URL do Google Maps (backup)
  final mapUrl = Uri.parse('https://www.google.com/maps/search/$encodedTermo');
  
  try {
    // Tenta primeiro com o esquema geo
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    }
    // Se falhar, tenta com a URL do Google Maps
    else if (await canLaunchUrl(mapUrl)) {
      await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
    } 
    else {
      // Se ambos falharem, informa o usuário
      await _falarResposta('Não foi possível abrir o mapa. Verifique se você tem um aplicativo de mapas instalado.');
    }
  } catch (e) {
    await _falarResposta('Ocorreu um erro ao tentar abrir o mapa: ${e.toString()}');
  }
}

  // Método para aumentar o tamanho do texto
  void _aumentarTexto() {
    setState(() {
      if (_textScaleFactor < 1.5) {
        _textScaleFactor += 0.1;
        _falarResposta('Tamanho de texto aumentado.');
      } else {
        _falarResposta('Tamanho máximo de texto atingido.');
      }
    });
  }

  // Método para diminuir o tamanho do texto
  void _diminuirTexto() {
    setState(() {
      if (_textScaleFactor > 0.8) {
        _textScaleFactor -= 0.1;
        _falarResposta('Tamanho de texto diminuído.');
      } else {
        _falarResposta('Tamanho mínimo de texto atingido.');
      }
    });
  }

  @override
  void dispose() {
    _lembreteAgua?.cancel();
    _lembreteExercicio?.cancel();
    _controller.dispose();
    _inputFocusNode.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Semantics(
            label: 'Logo do IncluiAI',
            child: Image.asset(
              'assets/logonovaia.png',
              height: 50, // Aumentado para melhor visibilidade
            ),
          ),
          actions: [
            // Adicionando botões de acessibilidade na barra
            IconButton(
              icon: Icon(Icons.text_increase, size: 36),
              onPressed: _aumentarTexto,
              tooltip: 'Aumentar texto',
            ),
            IconButton(
              icon: Icon(Icons.text_decrease, size: 36),
              onPressed: _diminuirTexto,
              tooltip: 'Diminuir texto',
            ),
          ],
        ),
        body: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: _textScaleFactor),
          child: Padding(
            padding: const EdgeInsets.all(20), // Aumentado o padding
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Como posso te ajudar?',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16), // Espaçamento aumentado
                  Semantics(
                    label: 'Campo para digitar sua dúvida',
                    hint: 'Toque duas vezes para digitar ou usar o botão de microfone à direita',
                    child: TextField(
                      controller: _controller,
                      focusNode: _inputFocusNode,
                      style: const TextStyle(fontSize: 30, color: Colors.white), // Fonte maior
                      decoration: InputDecoration(
                        hintText: 'Digite ou fale sua dificuldade aqui...',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _escutando ? Icons.mic : Icons.mic_none,
                            color: _escutando ? Colors.red : Colors.amber,
                            size: 40, // Aumentado para melhor alvo de toque
                          ),
                          onPressed: _escutando ? null : _startListening,
                          iconSize: 40, // Garantindo que o ícone fique maior
                          padding: EdgeInsets.all(12), // Área de toque maior
                          tooltip: _escutando ? 'Ouvindo sua voz' : 'Ativar reconhecimento de voz',
                        ),
                        contentPadding: EdgeInsets.all(20), // Campo de texto maior
                      ),
                      maxLines: 3, // Aumentado para comportar texto maior
                    ),
                  ),
                  const SizedBox(height: 20), // Espaçamento aumentado
                  
                  Semantics(
                    label: 'Botão para gerar dica',
                    hint: 'Toque duas vezes para gerar a resposta para sua dúvida',
                    child: ElevatedButton.icon(
                      onPressed: _carregando ? null : _gerarDica,
                      icon: _carregando
                          ? SizedBox(
                              width: 30, // Aumentado
                              height: 30, // Aumentado
                              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                            )
                          : const Icon(Icons.lightbulb_outline, size: 36), // Aumentado
                      label: Text(
                        _carregando ? 'Gerando...' : 'Gerar Dica',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), // Aumentado
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18), // Maior área de toque
                        minimumSize: Size(double.infinity, 65), // Botão maior
                      ),
                    ),
                  ),

                  const SizedBox(height: 24), // Espaçamento aumentado
                  Row(
                    children: [
                      // Checkbox maior e mais contrastante
                      Transform.scale(
                        scale: 1.5, // Aumentando o tamanho do checkbox
                        child: Checkbox(
                          value: _acessivel,
                          onChanged: (valor) => setState(() => _acessivel = valor ?? false),
                          activeColor: Colors.amber,
                          checkColor: Colors.black,
                          side: BorderSide(color: Colors.amber, width: 2), // Borda mais visível
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Resposta acessível',
                        style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24), // Espaçamento aumentado
                  Text('Sugestões rápidas:', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16), // Espaçamento aumentado
                  Wrap(
                    spacing: 12, // Aumentado espaçamento
                    runSpacing: 16, // Aumentado espaçamento
                    children: palavrasChave.map((palavra) {
                      return ElevatedButton(
                        onPressed: () => _usarPalavraChave(palavra),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Maior área de toque
                          textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Maior
                        ),
                        child: Text(palavra),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28), // Espaçamento aumentado
                  Text('Emergência:', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16), // Espaçamento aumentado
                  Wrap(
                    spacing: 16, // Aumentado espaçamento
                    runSpacing: 16, // Aumentado espaçamento
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _abrirMapaComBusca('hospitais perto de mim'),
                        icon: const Icon(Icons.local_hospital, color: Colors.white, size: 36), // Aumentado
                        label: const Text('Hospitais', style: TextStyle(fontSize: 24)), // Aumentado
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700], // Vermelho mais escuro para contraste
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Maior área de toque
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _abrirMapaComBusca('delegacias perto de mim'),
                        icon: const Icon(Icons.local_police, color: Colors.white, size: 36), // Aumentado
                        label: const Text('Delegacias', style: TextStyle(fontSize: 24)), // Aumentado
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700], // Azul mais escuro para contraste
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Maior área de toque
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _abrirMapaComBusca('ponto de abrigo perto de mim'),
                        icon: const Icon(Icons.house_siding, color: Colors.white, size: 36), // Aumentado
                        label: const Text('Abrigos', style: TextStyle(fontSize: 24)), // Aumentado
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700], // Verde mais escuro para contraste
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Maior área de toque
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32), // Espaçamento aumentado
                  if (_carregando)
                    Center(child: CircularProgressIndicator(
                      strokeWidth: 4, // Mais grosso para melhor visibilidade
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ))
                  else if (_resposta.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () => _falarResposta(_resposta),
                      child: Container(
                        padding: const EdgeInsets.all(20), // Padding maior
                        margin: const EdgeInsets.only(bottom: 24), // Margin maior
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber, width: 2), // Borda para destacar
                        ),
                        child: Text(
                          _resposta,
                          style: const TextStyle(fontSize: 28, color: Colors.white, height: 1.4), // Tamanho e altura de linha aumentados
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            button: true,
                            label: 'Limpar a conversa',
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _controller.clear();
                                  _resposta = '';
                                });
                                _falarResposta('Conversa limpa');
                              },
                              icon: Icon(Icons.clear, size: 32), // Aumentado
                              label: Text('Limpar', style: TextStyle(fontSize: 24)), // Aumentado
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700], // Vermelho mais escuro para contraste
                                padding: EdgeInsets.symmetric(vertical: 16), // Maior área de toque
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16), // Espaçamento aumentado
                        Expanded(
                          child: Semantics(
                            button: true,
                            label: 'Repetir a resposta em voz alta',
                            child: ElevatedButton.icon(
                              onPressed: _resposta.isNotEmpty ? () => _falarResposta(_resposta) : null,
                              icon: Icon(Icons.volume_up, size: 32), // Mudado para ícone de volume e aumentado
                              label: Text('Ouvir', style: TextStyle(fontSize: 24)), // Aumentado e renomeado para maior clareza
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700], // Verde mais escuro para contraste
                                padding: EdgeInsets.symmetric(vertical: 16), // Maior área de toque
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Adicionando botão de acessibilidade flutuante
        floatingActionButton: FloatingActionButton(
          onPressed: () => _falarResposta('Diga o que você precisa após o sinal sonoro, ou toque na tela para digitar'),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          tooltip: 'Ajuda por voz',
          child: Icon(Icons.accessibility_new, size: 36),
        ),
      ),
    );
  }
}