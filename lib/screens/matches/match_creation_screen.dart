import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../models/user_role.dart';
import '../../models/match_event.dart';
import '../../providers/matches_provider.dart';
import 'dart:math';

class MatchCreationScreen extends ConsumerStatefulWidget {
  const MatchCreationScreen({super.key});

  @override
  ConsumerState<MatchCreationScreen> createState() => _MatchCreationScreenState();
}

class _MatchCreationScreenState extends ConsumerState<MatchCreationScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController(text: '50');
  final _slotsController = TextEditingController(text: '14');
  
  String _format = '7v7';
  String _gender = 'Mixto';
  String _level = 'Amateur';
  DateTime _date = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(sessionProvider);
    final canCreateMatch = currentUser?.role == UserRole.staff || currentUser?.role == UserRole.brand;

    if (!canCreateMatch) {
      return Scaffold(
        appBar: AppBar(title: const Text('Crear Evento')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('🔒 Acceso Denegado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Solo Marcas certificadas o Staff pueden organizar Eventos.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizar Partido'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Título del Evento (Ej. Torneo Relámpago)')),
          const SizedBox(height: 12),
          TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Lugar / Instalación')),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(child: TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Precio (SportCoins)'), keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: TextField(controller: _slotsController, decoration: const InputDecoration(labelText: 'Max. Jugadores'), keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 20),
          
          DropdownButtonFormField<String>(
            value: _format,
            decoration: const InputDecoration(labelText: 'Formato'),
            items: ['5v5', '7v7', '11v11'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _format = val!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Categoría'),
            items: ['Masculino', 'Femenino', 'Mixto'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _gender = val!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _level,
            decoration: const InputDecoration(labelText: 'Nivel Requerido'),
            items: ['Principiante', 'Amateur', 'Competitivo'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _level = val!),
          ),
          
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue.shade700,
            ),
            onPressed: () {
              final match = MatchEvent(
                id: 'match_${Random().nextInt(10000)}',
                title: _titleController.text,
                locationName: _locationController.text,
                date: _date,
                matchFormat: _format,
                skillLevel: _level,
                genderCategory: _gender,
                priceInSportCoins: double.tryParse(_priceController.text) ?? 0,
                maxPlayers: int.tryParse(_slotsController.text) ?? 14,
                creatorId: currentUser!.id,
              );
              
              ref.read(matchesProvider.notifier).addMatch(match);
              Navigator.of(context).pop();
            },
            child: const Text('✅ Publicar Evento', style: TextStyle(fontSize: 16, color: Colors.white)),
          )
        ],
      ),
    );
  }
}
