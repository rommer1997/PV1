import 'package:flutter/material.dart';

/// Content definitions for each screen's help page.
/// Key = route/screen identifier, Value = HelpContent
class HelpContent {
  final String title;
  final String intro;
  final List<HelpSection> sections;

  const HelpContent({
    required this.title,
    required this.intro,
    required this.sections,
  });
}

class HelpSection {
  final IconData icon;
  final String heading;
  final String body;

  const HelpSection({
    required this.icon,
    required this.heading,
    required this.body,
  });
}

/// Static registry of all help content per context
class HelpRegistry {
  static const Map<String, HelpContent> _entries = {
    'athletic_cv': HelpContent(
      title: 'Tu Athletic CV',
      intro:
          'Esta es tu carta de presentación digital. Los scouts, periodistas y marcas la consultan para conocer tu nivel real.',
      sections: [
        HelpSection(
          icon: Icons.style,
          heading: 'Carta FIFA',
          body:
              'El OVR (Overall) es la media de tus 6 stats certificadas. Súbelo participando en torneos donde el árbitro te evalúe directamente en campo.',
        ),
        HelpSection(
          icon: Icons.radar,
          heading: 'Gráfico Radar',
          body:
              'Visualiza tus 6 dimensiones: TEC (Técnica), VEL (Velocidad), RES (Resistencia), FUE (Fuerza), TÁC (Táctica) y FPL (Fair Play).',
        ),
        HelpSection(
          icon: Icons.person_add,
          heading: 'Seguidores',
          body:
              'Puedes ver cuántos usuarios te siguen, pero por privacidad no verás sus nombres. Esto te protege de presiones externas y te permite centrarte en tu juego.',
        ),
        HelpSection(
          icon: Icons.qr_code_2,
          heading: 'Pase QR',
          body:
              'Genera tu pase digital para entrar a torneos Fase 0. Muéstralo en la puerta del evento para que el staff valide tu presencia.',
        ),
        HelpSection(
          icon: Icons.share,
          heading: 'Compartir',
          body:
              'Exporta tu carta como imagen para Instagram Stories o WhatsApp. Tu carta tiene un ID único que permite verificarla a cualquier club.',
        ),
      ],
    ),

    'media_feed': HelpContent(
      title: 'SportLink Reels',
      intro:
          'El feed de contenido es tu escaparate público. Sube clips de tus mejores jugadas para ganar visibilidad con scouts y periodistas.',
      sections: [
        HelpSection(
          icon: Icons.swipe_vertical,
          heading: 'Cómo navegar',
          body:
              'Desliza hacia arriba para ver el siguiente reel. Cada vídeo mostrado está priorizado por las evaluaciones de los árbitros, no por popularidad.',
        ),
        HelpSection(
          icon: Icons.favorite,
          heading: 'Me gusta',
          body:
              'Toca el corazón para dar like. Los likes ayudan al algoritmo a mostrar ese contenido a scouts y medios.',
        ),
        HelpSection(
          icon: Icons.add_circle,
          heading: 'Publicar contenido',
          body:
              'Toca el botón "+" para subir un reel. Añade hashtags relacionados con tu posición y equipo para aumentar tu alcance.',
        ),
      ],
    ),

    'wallet': HelpContent(
      title: 'Tu Wallet de SportCoins',
      intro:
          'Las SportCoins (SC) son la moneda del ecosistema. Se ganan, no se compran.',
      sections: [
        HelpSection(
          icon: Icons.emoji_events,
          heading: 'Cómo ganar SC',
          body:
              'Ganas SportCoins participando en torneos Fase 0. El bote inteligente (Smart Escrow) distribuye automáticamente al ganador y su entrenador al finalizar el torneo.',
        ),
        HelpSection(
          icon: Icons.lock,
          heading: 'Smart Escrow',
          body:
              'El dinero del bote está bloqueado en depósito desde el inicio del torneo. Solo se desbloquea cuando el staff certifica al ganador. Nadie puede manipularlo.',
        ),
        HelpSection(
          icon: Icons.history,
          heading: 'Historial',
          body:
              'Consulta tu historial de movimientos. Cada entrada/salida de SC tiene fecha, concepto y firma del partido al que corresponde.',
        ),
      ],
    ),

    'staff_dashboard': HelpContent(
      title: 'Panel de Staff',
      intro:
          'Como miembro del staff, tienes acceso a las herramientas de gestión de torneos, usuarios y validaciones.',
      sections: [
        HelpSection(
          icon: Icons.sports,
          heading: 'Gestión de Torneos',
          body:
              'Crea torneos Fase 0, gestiona el bote y finaliza la competición cuando tengas un ganador. El Smart Escrow distribuye automáticamente.',
        ),
        HelpSection(
          icon: Icons.people,
          heading: 'Gestión de Usuarios',
          body:
              'Consulta el listado de usuarios registrados, sus roles y estados. Puedes banear temporalmente a usuarios que incumplan las normas de la comunidad.',
        ),
        HelpSection(
          icon: Icons.verified_user,
          heading: 'Validaciones',
          body:
              'Revisa las firmas de exención de menores presentadas por tutores. Todos los menores que participen en torneos deben tener su tutor verificado.',
        ),
      ],
    ),

    'referee_terminal': HelpContent(
      title: 'Terminal del Árbitro',
      intro:
          'Tu evaluación vale 60% de la calificación total de cada jugador. Úsala con criterio: es la herramienta más poderosa del ecosistema.',
      sections: [
        HelpSection(
          icon: Icons.how_to_vote,
          heading: 'Evaluar jugadores',
          body:
              'Puedes nominar hasta 3 jugadores por partido. Valora TEC, FPL y RES en una escala del 1 al 10. Estos valores alimentan directamente el OVR de la carta del jugador.',
        ),
        HelpSection(
          icon: Icons.visibility_off,
          heading: 'Evaluaciones privadas',
          body:
              'Los jugadores solo ven su resultado final, nunca quién los evaluó ni qué nota individual pusiste. Esto protege tu independencia como árbitro.',
        ),
        HelpSection(
          icon: Icons.star,
          heading: 'Tus seguidores',
          body:
              'Los árbitros también construyen reputación en SportLink. Los jugadores, managers y fans pueden seguirte. Tu follower count aumenta con evaluaciones justas y consistentes.',
        ),
      ],
    ),

    'journalist': HelpContent(
      title: 'Panel del Periodista',
      intro:
          'Tienes acceso a datos certificados de jugadores que ningún otro medio tiene: estadísticas validadas por árbitros independientes.',
      sections: [
        HelpSection(
          icon: Icons.article,
          heading: 'Perfiles verificados',
          body:
              'Accedes a los Athletic CV de todos los jugadores con datos reales y firmados digitalmente. Puedes referenciar un perfil por su ID único (SLP-XXXX) en tus artículos.',
        ),
        HelpSection(
          icon: Icons.trending_up,
          heading: 'Tus seguidores',
          body:
              'Los periodistas con cobertura de fútbol base acumulan seguidores de jugadores, scouts y fans. Tu audiencia crece cuanto más generoso seas en descubrir talento oculto.',
        ),
        HelpSection(
          icon: Icons.privacy_tip,
          heading: 'Privacidad de fuentes',
          body:
              'Cuando accedes a un perfil de menor, los datos de contacto están protegidos. Solo ves las métricas deportivas. Toda investigación periodística debe seguir el protocolo de privacidad de SportLink.',
        ),
      ],
    ),

    'coach_dashboard': HelpContent(
      title: 'Panel del Entrenador',
      intro:
          'Gestiona tu plantilla, evalúa a tus jugadores en privado y comunícate con los tutores de los menores bajo tu responsabilidad.',
      sections: [
        HelpSection(
          icon: Icons.group,
          heading: 'Tu Plantilla',
          body:
              'Añade jugadores a tu equipo por su ID único (SLP-XXXX). Una vez en tu plantilla, puedes evaluarlos en entrenamientos (estas evaluaciones valen 20% de su OVR).',
        ),
        HelpSection(
          icon: Icons.rate_review,
          heading: 'Evaluaciones Privadas',
          body:
              'Tus evaluaciones de entrenamiento son confidenciales: solo tú y la app las ven. El jugador ve el resultado en su OVR pero no sabe qué nota le puso su entrenador.',
        ),
        HelpSection(
          icon: Icons.store,
          heading: 'Marketplace',
          body:
              'Busca jugadores por posición, edad y rango de OVR. Puedes enviar solicitudes de interés a jugadores o sus tutores (si son menores).',
        ),
      ],
    ),

    'fan': HelpContent(
      title: 'Tu Experiencia Fan',
      intro:
          'Como fan eres el único rol que sabe exactamente a quién sigues. Los jugadores y árbitros que sigues NO saben que eres tú.',
      sections: [
        HelpSection(
          icon: Icons.favorite,
          heading: 'Seguir en anonimato',
          body:
              'Cuando sigues a un jugador, árbitro o periodista, ellos solo ven que su número de seguidores ha subido. Jamás verán tu nombre ni tu perfil en su lista.',
        ),
        HelpSection(
          icon: Icons.stadium,
          heading: 'Stadium Feed',
          body:
              'Consulta los resultados de torneos Fase 0 en tiempo real. Verás los ganadores, los SportCoins repartidos y las evaluaciones públicas de los árbitros.',
        ),
        HelpSection(
          icon: Icons.camera_alt,
          heading: 'Interactuar con contenido',
          body:
              'Da like y comenta en los reels de los jugadores. Tu interacción ayuda al algoritmo a mostrar ese talento a scouts y medios.',
        ),
      ],
    ),

    'scout': HelpContent(
      title: 'Panel del Scout',
      intro:
          'Bienvenido a la base de datos de talento más transparente y certificada del fútbol base.',
      sections: [
        HelpSection(
          icon: Icons.search,
          heading: 'Búsqueda de Talentos',
          body:
              'Filtra jugadores por posición, edad, ciudad y rango de OVR. Todos los datos provienen de evaluaciones certificadas de árbitros, no de declaraciones del propio jugador.',
        ),
        HelpSection(
          icon: Icons.verified,
          heading: 'Tu firma de evaluación',
          body:
              'Cuando accedes a un perfil, queda registro cifrado de tu visita (que el jugador no ve). Si contactas al jugador o su tutor, el jugador recibe una notificación genérica de "Contacto Profesional".',
        ),
        HelpSection(
          icon: Icons.shield,
          heading: 'Protocolo de menores',
          body:
              'Para jugadores menores de 18 años, toda la comunicación debe ir a través del tutor registrado. No puedes contactar directamente al jugador si es menor.',
        ),
      ],
    ),
  };

  static HelpContent? get(String key) => _entries[key];
}

/// Floating help button that can be added to any screen.
class HelpButton extends StatelessWidget {
  final String screenKey;
  final Color? color;

  const HelpButton({super.key, required this.screenKey, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openHelp(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (color ?? const Color(0xFF007AFF)).withValues(alpha: 0.12),
          border: Border.all(
            color: (color ?? const Color(0xFF007AFF)).withValues(alpha: 0.4),
          ),
        ),
        child: Icon(
          Icons.help_outline,
          size: 18,
          color: color ?? const Color(0xFF007AFF),
        ),
      ),
    );
  }

  void _openHelp(BuildContext context) {
    final content = HelpRegistry.get(screenKey);
    if (content == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HelpSheet(content: content),
    );
  }
}

class _HelpSheet extends StatelessWidget {
  final HelpContent content;
  const _HelpSheet({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final mutedColor = isDark ? Colors.white54 : Colors.black45;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: mutedColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF007AFF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      content.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                content.intro,
                style: TextStyle(color: mutedColor, fontSize: 14, height: 1.5),
              ),
            ),

            const SizedBox(height: 20),
            Divider(
              color: mutedColor.withValues(alpha: 0.2),
              indent: 28,
              endIndent: 28,
            ),
            const SizedBox(height: 8),

            // Sections
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 8,
                ),
                itemCount: content.sections.length,
                itemBuilder: (_, i) {
                  final s = content.sections[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF007AFF,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            s.icon,
                            color: const Color(0xFF007AFF),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.heading,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.body,
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
