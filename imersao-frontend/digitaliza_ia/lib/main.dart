import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Pacotes para voz
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(IncluiAIApp());
}

class IncluiAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.black,
  textTheme: TextTheme(
    bodyLarge: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(fontSize: 22, color: Colors.white),
    labelLarge: TextStyle(fontSize: 20, color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.amber, // cor vibrante para botão
      foregroundColor: Colors.black, // texto preto no botão amarelo
      textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[900], // fundo escuro do campo
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
),

      home: IncluiAIHome(),
    );
  }
}

class IncluiAIHome extends StatefulWidget {
  @override
  _IncluiAIHomeState createState() => _IncluiAIHomeState();
}

class _IncluiAIHomeState extends State<IncluiAIHome> {
  final TextEditingController _controller = TextEditingController();
  String _resposta = '';
  bool _carregando = false;

  late stt.SpeechToText _speech;
  bool _escutando = false;

  final FlutterTts _flutterTts = FlutterTts();

  // Novo: variável para controlar se a resposta deve ser acessível
  bool _acessivel = false;

  final List<String> palavrasChave = [
    'Como usar o WhatsApp?',
    'Como consigo fazer pix?',
    'Como faço uma chamada?',
    'Onde fica o botão da câmera?',
    'Como faço para tirar uma foto?',
    'Como faço para enviar uma mensagem?',
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('pt-BR');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> _gerarDica() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _carregando = true);
    final texto = _controller.text;

    final uri = Uri.parse('http://10.0.2.2:7064/api/ia/gerar-dica');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'texto': texto,
        'acessivel': _acessivel, // Envia o campo acessível aqui
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() => _resposta = data['resposta']);
      await _falarResposta(_resposta);
    } else {
      setState(() => _resposta = 'Erro ao gerar dica.');
      await _falarResposta('Desculpe, ocorreu um erro ao gerar a dica.');
    }

    setState(() => _carregando = false);
  }

  Future<void> _falarResposta(String texto) async {
    String textoLimpo = texto.replaceAll('*', ''); // remove todos os asteriscos
    await _flutterTts.stop();
    await _flutterTts.speak(textoLimpo);
    
  }

  void _startListening() async {
    bool disponivel = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _escutando = false);
        }
      },
      onError: (error) {
        setState(() => _escutando = false);
      },
    );

    if (disponivel) {
      setState(() => _escutando = true);
      _speech.listen(
        localeId: 'pt_BR',
        onResult: (val) {
          if (val.finalResult) {
            setState(() {
              _controller.text = val.recognizedWords;
              _escutando = false;
            });
            _gerarDica();
          }
        },
      );
    }
  }

  void _usarPalavraChave(String palavra) {
    setState(() {
      _controller.text = palavra;
    });
    _gerarDica();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge!;
    final buttonTextStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

    return Scaffold(
  appBar: PreferredSize(
  preferredSize: Size.fromHeight(80),
  child: Container(
    color: Colors.black,
    padding: EdgeInsets.only(top: 24),
    child: Center(
      child: Image.asset(
        'assets/logonovaia.png',
        height: 40,
      ),
    ),
  ),
),
  body: Padding(
    padding: EdgeInsets.all(16),
    child: SingleChildScrollView(
      child: Column(
        children: [
          Text('Como posso te ajudar?', style: textStyle),
          SizedBox(height: 8),
          TextField(
            controller: _controller,
            style: TextStyle(fontSize: 24, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Digite ou fale sua dificuldade aqui...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 20),
              filled: true,
              fillColor: Colors.black87,
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_escutando ? Icons.mic : Icons.mic_none, color: Colors.white, size: 30),
                onPressed: _escutando ? null : _startListening,
              ),
            ),
            maxLines: 2,
          ),

          SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _acessivel,
                onChanged: (bool? valor) {
                  setState(() {
                    _acessivel = valor ?? false;
                  });
                },
                activeColor: Colors.amber,
              ),
              Text('Resposta acessível', style: TextStyle(fontSize: 20, color: Colors.white)),
            ],
          ),

          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Sugestões rápidas:', style: theme.textTheme.bodyMedium!.copyWith(fontSize: 20)),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: palavrasChave.map((palavra) {
              return ElevatedButton(
                onPressed: () => _usarPalavraChave(palavra),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(palavra, style: TextStyle(fontSize: 18)),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _carregando ? null : _gerarDica,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 70),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: _carregando
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Gerar dica', style: buttonTextStyle),
          ),
          SizedBox(height: 20),
          if (_resposta.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Dica personalizada:\n$_resposta', style: textStyle),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _falarResposta(_resposta),
                    icon: Icon(Icons.volume_up),
                    label: Text('Repetir', style: buttonTextStyle),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 50),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                  onPressed: () async {
                    await _flutterTts.stop(); // Interrompe a fala
                    setState(() {
                      _controller.clear();
                      _resposta = '';
                    });
                  },
                  icon: Icon(Icons.clear),
                  label: Text('Limpar', style: buttonTextStyle),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 50),
                  ),
                ),
              ),
              ],
            )
          ]
        ],
      ),
    ),
  ),
);

  }
}
