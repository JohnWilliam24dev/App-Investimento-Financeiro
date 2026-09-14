import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/plano_provider.dart';
import '../widgets/dia_card.dart';
import '../widgets/progresso_header.dart';
import 'criar_plano_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário Financeiro'),
        actions: [
          Consumer<PlanoProvider>(
            builder: (context, provider, _) {
              if (!provider.temPlanoAtivo) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Reiniciar plano',
                icon: const Icon(Icons.refresh),
                onPressed: () => _confirmarReinicio(context, provider),
              );
            },
          ),
        ],
      ),
      body: Consumer<PlanoProvider>(
        builder: (context, provider, _) {
          if (provider.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!provider.temPlanoAtivo) {
            return const CriarPlanoScreen();
          }

          return Column(
            children: [
              ProgressoHeader(
                totalInvestido: provider.totalInvestido,
                metaTotal: provider.metaTotal,
                progresso: provider.progresso,
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: provider.dias.length,
                  itemBuilder: (context, indice) {
                    final dia = provider.dias[indice];
                    return DiaCard(
                      dia: dia,
                      onTap: () => provider.alternarDia(dia),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmarReinicio(
    BuildContext context,
    PlanoProvider provider,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar plano?'),
        content: const Text(
          'Isso apaga o plano atual e todo o progresso marcado. '
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await provider.excluirPlanoAtual();
    }
  }
}
