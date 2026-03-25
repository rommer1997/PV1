# Cantera Pro

Cantera Pro es un ecosistema digital diseñado para profesionalizar el fútbol base y profesional mediante una experiencia conectada y gamificada.

## Características Principales
- **Sistema de Roles:** Interfaz y flujos que se adaptan automáticamente al perfil del usuario (Jugador, Entrenador, Ojeador, Árbitro, etc.).
- **Diseño Premium:** Uso de cartas estilo "FIFA TOTW", modo oscuro inmersivo y estadísticas de rendimiento.
- **Feed Comunitario y Multimedia:** Sistema de publicación vertical y feed de noticias del estadio.

## Arquitectura
La aplicación utiliza un enfoque modular avanzado en Flutter:
- **Gestión de Estado:** `Riverpod` (`hooks_riverpod`, `flutter_riverpod`).
- **Core Navigation:** Sistema `RoleShell` para cambiar de contexto e interfaz según los permisos del usuario.
- **Seguridad MVP:** Cifrado asimétrico de credenciales en local usando SHA-256.

## Cómo Empezar

1. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```
2. **Ejecutar pruebas unitarias (Testing):**
   ```bash
   flutter test
   ```
3. **Ejecutar la App:**
   ```bash
   flutter run
   ```

## Roles Soportados 
* ⚽ **Jugador**: Currículum Atlético estilo Carta, Estadísticas, Wallet.
* 📋 **Entrenador**: Dashboard de equipo, mercado, lesiones y asignación de capitanes.
* 🔍 **Ojeador (Scout)**: Mercado global, búsquedas avanzadas y lista de seguimiento.
* ⚖️ **Árbitro**: Terminal técnica aislada de interacciones sociales para máxima neutralidad.
* 🧑‍🍼 **Tutor**: Módulo de aprobación para cuentas de menores de 13 años.
* Otros perfiles en desarrollo: 🎙️ Periodista, 📢 Marca, 🏆 Aficionado, 🏢 Staff.
