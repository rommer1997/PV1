import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/match_event.dart';
import '../../providers/matches_provider.dart';
import '../../models/app_user.dart';

class MatchManagementDashboard extends ConsumerWidget {
  final String matchId;

  const MatchManagementDashboard({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchesProvider);
    final match = matches.firstWhere((m) => m.id == matchId, orElse: () => throw Exception('Match not found'));

    // En un sistema real, aquí buscaríamos los nombres reales en DB en base a p.userId.
    // Usaremos mocks o strings sencillas para la demo
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión del Partido'),
        backgroundColor: Colors.indigo.shade800,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${match.participants.length}/${match.maxPlayers} Inscritos', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Check-in List', style: TextStyle(color: Colors.indigo)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: match.participants.length,
              itemBuilder: (context, index) {
                final participant = match.participants[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: participant.hasCheckedIn ? Colors.green : Colors.grey.shade300,
                    child: Icon(participant.hasCheckedIn ? Icons.check : Icons.person, color: Colors.white),
                  ),
                  title: Text('Usuario ID: ${participant.userId}'),
                  subtitle: Text(participant.hasPaid ? 'Pago Confirmado' : 'Pendiente de Pago'),
                  trailing: participant.hasCheckedIn 
                      ? const Text('Asistió', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                      : ElevatedButton(
                          onPressed: () {
                            ref.read(matchesProvider.notifier).checkInParticipant(match.id, participant.userId);
                          },
                          child: const Text('Check-in'),
                        ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generando equipos pseudo-aleatorios (Petos vs Sin Petos)...')),
                    );
                  },
                  backgroundColor: Colors.indigo,
                  icon: const Icon(Icons.group, color: Colors.white),
                  label: const Text('Alinear Equipos Automáticamente', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
