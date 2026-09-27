import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/plano_provider.dart';
import '../widgets/plano_formulario.dart';

/// Tela cheia mostrada quando ainda não existe nenhum plano ativo.
class CriarPlanoScreen extends StatelessWidget {
  const CriarPlanoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: PlanoFormulario(
        icone: Icons.savings_outlined,
        titulo: 'Crie seu plano de investimento',
        subtitulo: 'O desafio segue a progressão: dia 1 = R\$1, dia 2 = '
            'R\$2, e assim sucessivamente. Informe a meta que deseja '
            'alcançar e o aplicativo calculará automaticamente a duração '
            'do plano.',
        textoBotao: 'Começar',
        onConfirmar: (valorInicial, incremento, totalDias) =>
            context.read<PlanoProvider>().criarPlano(
                  valorInicial: valorInicial,
                  incremento: incremento,
                  totalDias: totalDias,
                ),
      ),
    );
  }
}
