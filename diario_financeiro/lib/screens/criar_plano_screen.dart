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
        subtitulo:
            'Defina o valor do primeiro dia, quanto aumenta por dia, e '
            'escolha se prefere informar a duração ou a meta que quer bater.',
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
