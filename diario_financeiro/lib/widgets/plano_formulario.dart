import 'package:flutter/material.dart';

import '../models/plano.dart';

/// Progressão fixa: dia 1 = R$1, aumenta R$1 por dia. O único dado que o
/// usuário controla é a meta que quer alcançar.
const double _valorInicialPadrao = 1;
const double _incrementoPadrao = 1;

/// Formulário de definição do plano: pede só a meta desejada e calcula
/// automaticamente quantos dias o desafio vai durar.
///
/// Usado tanto pra criar um plano de verdade quanto pra simular um plano
/// hipotético sem salvar nada — quem decide o efeito é o [onConfirmar]
/// passado por quem usa o widget.
class PlanoFormulario extends StatefulWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final String textoBotao;
  final Future<void> Function(
    double valorInicial,
    double incremento,
    int totalDias,
  ) onConfirmar;

  const PlanoFormulario({
    super.key,
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.textoBotao,
    required this.onConfirmar,
  });

  @override
  State<PlanoFormulario> createState() => _PlanoFormularioState();
}

class _PlanoFormularioState extends State<PlanoFormulario> {
  final _formKey = GlobalKey<FormState>();
  final _metaDesejadaController = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _metaDesejadaController.dispose();
    super.dispose();
  }

  double get _metaDesejadaPreview =>
      double.tryParse(_metaDesejadaController.text.replaceAll(',', '.')) ?? 0;

  int get _totalDiasEfetivo => Plano.diasParaAtingirMeta(
        valorInicial: _valorInicialPadrao,
        incremento: _incrementoPadrao,
        metaDesejada: _metaDesejadaPreview,
      );

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final totalDias = _totalDiasEfetivo;
    final temDados = totalDias > 0;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(widget.icone, size: 56, color: cores.primary),
          const SizedBox(height: 16),
          Text(
            widget.titulo,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitulo,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _metaDesejadaController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Quanto você quer alcançar',
              prefixIcon: const Icon(Icons.flag_outlined, size: 20),
              prefixText: 'R\$ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            validator: _validarMetaDesejada,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cores.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'Você vai precisar de',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cores.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  temDados ? '$totalDias dias' : '—',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cores.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _enviando ? null : _confirmar,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _enviando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.textoBotao),
          ),
        ],
      ),
    );
  }

  String? _validarMetaDesejada(String? valor) {
    final numero = double.tryParse((valor ?? '').replaceAll(',', '.'));
    if (numero == null || numero <= 0) {
      return 'Informe uma meta maior que zero';
    }
    return null;
  }

  Future<void> _confirmar() async {
    if (!_formKey.currentState!.validate()) return;

    final totalDias = _totalDiasEfetivo;
    if (totalDias <= 0) {
      _mostrarErro('Não foi possível calcular os dias necessários.');
      return;
    }
    if (totalDias > 3650) {
      _mostrarErro(
        'Isso levaria mais de 3650 dias (10 anos). Tente uma meta menor.',
      );
      return;
    }

    setState(() => _enviando = true);
    await widget.onConfirmar(_valorInicialPadrao, _incrementoPadrao, totalDias);
    if (mounted) setState(() => _enviando = false);
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }
}
