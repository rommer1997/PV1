import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import 'dart:math';

// ----------------------------------------------------------------------
// NLP CORE: Algoritmo de Distancia de Levenshtein + Normalización Fonética
// ----------------------------------------------------------------------

int _levenshtein(String s, String t) {
  if (s == t) return 0;
  if (s.isEmpty) return t.length;
  if (t.isEmpty) return s.length;

  List<int> v0 = List<int>.filled(t.length + 1, 0);
  List<int> v1 = List<int>.filled(t.length + 1, 0);

  for (int i = 0; i <= t.length; i++) v0[i] = i;

  for (int i = 0; i < s.length; i++) {
    v1[0] = i + 1;
    for (int j = 0; j < t.length; j++) {
      int cost = (s[i] == t[j]) ? 0 : 1;
      v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
    }
    for (int j = 0; j <= t.length; j++) v0[j] = v1[j];
  }
  return v1[t.length];
}

String _normalize(String input) {
  var s = input.toLowerCase();
  const diacritics = 'áéíóúüñ';
  const nonDiacritics = 'aeiouun';
  for (int i = 0; i < diacritics.length; i++) {
    s = s.replaceAll(diacritics[i], nonDiacritics[i]);
  }
  
  // Normalizaciones fonéticas para ortografía extrema
  s = s.replaceAll(RegExp(r'h'), '');          // Quitar H
  s = s.replaceAll(RegExp(r'v'), 'b');          // v -> b
  s = s.replaceAll(RegExp(r'z'), 's');          // z -> s
  s = s.replaceAll(RegExp(r'c(?=[ei])'), 's');  // ce, ci -> se, si
  s = s.replaceAll(RegExp(r'll'), 'y');         // ll -> y
  s = s.replaceAll(RegExp(r'qu'), 'k');         // qu -> k
  s = s.replaceAll(RegExp(r'c'), 'k');          // resto de c -> k (ok/kasa)
  s = s.replaceAll(RegExp(r'[^\w\s]'), '');     // Quitar puntuación
  
  // Quitar letras repetidas seguidas (holaaaa -> hola)
  s = s.replaceAllMapped(RegExp(r'(.)\1+'), (match) => match.group(1)!);
  
  return s.trim();
}

class _Intent {
  final String id;
  final List<String> keywords;
  final String response;
  _Intent(this.id, this.keywords, this.response);
}

final List<_Intent> _knowledgeBase = [
  _Intent('sportcoins', ['sportcoin', 'moneda', 'dinero', 'pagar', 'sc', 'cobrar', 'ficha', 'kripto'], 
    'Las SportCoins (SC) son la moneda oficial del ecosistema Cantera. Se ganan únicamente compitiendo en torneos oficiales y NUNCA se pueden comprar con dinero real. Están blindadas en nuestro servidor inmutable.'),
  
  _Intent('escrow', ['escrow', 'bote', 'premio', 'intelijente', 'reparto', 'deposito', 'skrow', 'contrato'], 
    'El Smart Escrow es un bote blindado. Bloquea las SportCoins al iniciar un torneo y, una vez que el staff y el árbitro validan el resultado final, reparte automáticamente el premio al equipo ganador. Ni siquiera Cantera puede tocar esos fondos, garantizando zero corrupción.'),
  
  _Intent('referee', ['arbitro', 'juez', 'evaluar', 'notas', 'calificar', 'ovr', 'referi', 'refery'], 
    'Los árbitros son la columna vertebral de nuestra transparencia. Su evaluación vale el 60% del OVR de un jugador. Miden Técnica, Resistencia y Fair Play. Nadie sabe qué nota puso el árbitro a quién, asegurando independencia total y sin presiones.'),
  
  _Intent('scout', ['scout', 'ojeador', 'representante', 'contratar', 'agente', 'skout', 'casa', 'talentos'], 
    'Los Scouts filtran talentos por OVR real, edad y posición. Cualquier búsqueda que hacen deja una "huella digital" en la plataforma. Ojo: Para contactar y negociar con menores de edad (Sub-18), deben pasar OBLIGATORIAMENTE a través del Tutor Legal validado en la app.'),
  
  _Intent('tutor', ['padre', 'madre', 'tutor', 'hijo', 'menor', 'niño', 'registrar', 'validacion'], 
    'Los menores de 18 años requieren aprobación. El tutor legal debe registrarse primero, generar un "Código de Enlace" matemático único, y pasárselo al menor. Al introducirlo en su app de jugador, la cuenta del menor queda vinculada y firmada digitalmente para competir de forma segura.'),
  
  _Intent('crisis', ['escudo', 'bloqueo', 'crisis', 'salud', 'mental', 'odio', 'presion', 'ansiedad', 'bulling'], 
    'Pensando en la salud mental, el "Modo Crisis" (botón de escudo rojo) bloquea las estadísticas de un jugador al instante. Oculta todo el perfil al público, scouts y periodistas, aislando al deportista y dando acceso exclusivo a su tutor o psicólogo deportivo para tratar la situación.'),
  
  _Intent('qr', ['qr', 'pase', 'dijital', 'bip', 'entrar', 'puerta', 'estadio', 'q'], 
    '¡El Pase VIP! Es el código QR en la parte superior derecha o en tu Fish Card. Sirve como tu acreditación. Al llegar al estadio de un torneo, el Staff lo escanea y el Escrow sabe automáticamente que ya te presentaste para jugar.'),
  
  _Intent('cv', ['cv', 'curriculum', 'carta', 'perfil', 'estadisticas', 'radar', 'fifa', 'ovr'], 
    'El Fish Card es tú carta de vida deportiva. Reúne tus estadísticas, OVR dinámico validado por árbitros reales y tu gráfico de impacto (radar). Se actualiza autónomamente; ¡ningún jugador puede editar o inventarse sus propios números!'),
  
  _Intent('ia', ['ia', 'intelijencia', 'robot', 'bot', 'cantera', 'quien', 'eres'], 
    'Soy Scout AI, la primera inteligencia deportiva 100% offline implantada en Cantera. Conozco todos los protocolos de seguridad, desde el algoritmo del Smart Escrow hasta la salud mental de los jugadores.'),
  
  _Intent('saludo', ['hola', 'buenas', 'ey', 'que', 'tal', 'alluda', 'ola', 'hl'], 
    '¡Hola! Soy Scout AI, tu asistente experto en Cantera. ¿Tienes dudas sobre cómo funcionan nuestros Árbitros, Tutores, el Smart Escrow o el Modo Crisis? ¡Pregunta lo que sea!'),
];

String _getAIResponse(String userInput) {
  final normInput = _normalize(userInput);
  final inputWords = normInput.split(' ');

  // Mantenemos una lista de matches
  List<Map<String, dynamic>> matches = [];

  for (var intent in _knowledgeBase) {
    for (var kw in intent.keywords) {
      final nk = _normalize(kw);
      
      for (var iw in inputWords) {
        if (iw.isEmpty) continue;
        
        int distance = _levenshtein(iw, nk);
        int threshold = nk.length > 5 ? 2 : (nk.length > 3 ? 1 : 0);
        
        // Exact o Levenshtein
        if (distance <= threshold || (iw.length >= 4 && nk.contains(iw))) {
          matches.add({
            'intent': intent.response,
            'score': distance,
          });
          break; // Next intent to avoid multiple triggers on same intent
        }
      }
    }
  }

  if (matches.isNotEmpty) {
    // Ordenar por menor distancia (mejor match fonético)
    matches.sort((a, b) => (a['score'] as int).compareTo(b['score'] as int));
    return matches.first['intent'] as String;
  }

  return "Uy, todavía estoy entrenando para la pretemporada. ¿Te refieres a las SportCoins, el Smart Escrow, o las valoraciones de los Árbitros? Recuerda que respondo hasta con errores de ortografía 😎.";
}

// ----------------------------------------------------------------------
// UI COMPONENT
// ----------------------------------------------------------------------

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class CanteraAIScreen extends ConsumerStatefulWidget {
  const CanteraAIScreen({super.key});

  @override
  ConsumerState<CanteraAIScreen> createState() => _CanteraAIScreenState();
}

class _CanteraAIScreenState extends ConsumerState<CanteraAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: '¡Mister! Soy Scout AI 🧠, el cerebro hiper-rápido corriendo localmente en tu app. Conozco las reglas de Cantera al pie de la letra, hasta si tienes mala ortografía.\n\nPrueba preguntarme sobre tutores, árbitros o el modo crisis.', 
      isUser: false
    ),
  ];
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isTyping = true;
    });
    
    _scrollToBottom();

    // Fake AI Latency mapping (500 - 1500 ms)
    final delay = 800 + Random().nextInt(1000);
    await Future.delayed(Duration(milliseconds: delay));

    final response = _getAIResponse(text);

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(text: response, isUser: false));
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final textPrimary = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final primaryAccent = Color(0xFFE2F163);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined, color: primaryAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              'Scout AI',
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Divider(color: border, height: 1),
          // Banner Offline
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.green.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, color: Colors.green, size: 14),
                const SizedBox(width: 6),
                const Text(
                  'ENGINE 100% OFFLINE / NLP NATIVO',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(
                  message: msg.text,
                  isUser: msg.isUser,
                  isDark: isDark,
                  primaryAccent: primaryAccent,
                );
              },
            ),
          ),
          
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 12, height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE2F163)),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Generando estrategia...',
                            style: TextStyle(color: muted, fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 12,
              top: 12,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: surface,
              border: Border(top: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: textPrimary, fontSize: 15),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ej. komo un arvitro evalua?',
                      hintStyle: TextStyle(color: muted.withValues(alpha: 0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: primaryAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isDark;
  final Color primaryAccent;

  const _ChatBubble({required this.message, required this.isUser, required this.isDark, required this.primaryAccent});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? primaryAccent : AppColors.surface(isDark),
          border: isUser ? null : Border.all(color: AppColors.border(isDark)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: isUser ? [
            BoxShadow(
              color: primaryAccent.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.black : AppColors.text(isDark),
            fontSize: 15,
            height: 1.4,
            fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
