import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/plano_provider.dart';
import '../widgets/dia_card.dart';
import '../widgets/plano_formulario.dart';
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
                icon: const Icon(Icons.restart_alt),
                onPressed: () => _confirmarReinicio(context, provider),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Consumer<PlanoProvider>(
        builder: (context, provider, _) {
          if (!provider.temPlanoAtivo) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _abrirSimulador(context),
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Simular plano'),
          );
        },
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
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 10,
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

  /// Abre um formulário de simulação num bottom sheet. É o mesmo
  /// PlanoFormulario usado pra criar o plano de verdade, mas aqui
  /// o "onConfirmar" só fecha a folha — nada é salvo, então o plano
  /// ativo do usuário não é afetado.
  void _abrirSimulador(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              PlanoFormulario(
                icone: Icons.calculate_outlined,
                titulo: 'Simular um plano',
                subtitulo: 'Veja quantos dias esse desafio levaria pra uma '
                    'meta diferente, sem mexer no seu plano atual.',
                textoBotao: 'Fechar simulação',
                onConfirmar: (_, __, ___) async =>
                    Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
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
