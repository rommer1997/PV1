import 'package:flutter/material.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/glow_button.dart';

class CreateConvocatoriaScreen extends StatefulWidget {
  const CreateConvocatoriaScreen({super.key});

  @override
  State<CreateConvocatoriaScreen> createState() => _CreateConvocatoriaScreenState();
}

class _CreateConvocatoriaScreenState extends State<CreateConvocatoriaScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  String _category = 'Pruebas Libres';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = AppColors.text(isDark);

    return Scaffold(
      backgroundColor: AppColors.bg(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Nueva Convocatoria',
          style: TextStyle(
            color: text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Título de la Oportunidad', text),
            _buildTextField(_titleController, 'Ej. Pruebas Sub-17 Manchester City Academy', isDark),
            const SizedBox(height: 24),
            
            _buildFieldLabel('Categoría', text),
            _buildDropdown(isDark),
            const SizedBox(height: 24),

            _buildFieldLabel('Ubicación / Ciudad', text),
            _buildTextField(_locationController, 'Ej. Madrid, España', isDark, icon: Icons.location_on_rounded),
            const SizedBox(height: 24),

            _buildFieldLabel('Descripción y Requisitos', text),
            _buildTextField(_descController, 'Detalla qué buscas, fechas, requisitos físicos...', isDark, maxLines: 5),
            
            const SizedBox(height: 48),
            
            Center(
              child: GlowCTAButton(
                label: 'PUBLICAR CONVOCATORIA',
                isDark: isDark,
                onTap: () {
                  // Simulate publication
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Convocatoria publicada con éxito!'),
                      behavior: SnackBarBehavior.floating,
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

  Widget _buildFieldLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isDark, {IconData? icon, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: AppColors.text(isDark), fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textMuted(isDark), fontSize: 14),
          prefixIcon: icon != null ? Icon(icon, color: AppColors.textMuted(isDark), size: 18) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          dropdownColor: AppColors.surface(isDark),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.text(isDark)),
          items: ['Pruebas Libres', 'Draft Profesional', 'Academia de Verano', 'Torneo de Captación']
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: TextStyle(color: AppColors.text(isDark), fontSize: 15)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _category = v!),
        ),
      ),
    );
  }
}
