import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/plano.dart';
import '../utils/moeda_formatter.dart';

/// Progressão fixa: dia 1 = R$1, aumenta R$1 por dia. O único dado que o
/// usuário controla é a meta que quer alcançar.
const double _valorInicialPadrao = 1;
const double _incrementoPadrao = 1;

/// Formata o campo de meta com separador de milhar (padrão pt_BR) conforme
/// o usuário digita — ex: "20000" vira "20.000". Trabalha só com valores
/// inteiros de reais (sem centavos), o que é suficiente para uma meta
/// financeira deste tipo.
class _SeparadorDeMilharFormatter extends TextInputFormatter {
  static final NumberFormat _formatador = NumberFormat.decimalPattern('pt_BR');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final texto = _formatador.format(int.parse(digitos));
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

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
  final _metaDesejadaController = TextEditingController(text: '20.000');
  bool _enviando = false;

  @override
  void dispose() {
    _metaDesejadaController.dispose();
    super.dispose();
  }

  double get _metaDesejadaPreview {
    final digitos =
        _metaDesejadaController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return digitos.isEmpty ? 0 : double.parse(digitos);
  }

  int get _totalDiasEfetivo => Plano.diasParaAtingirMeta(
        valorInicial: _valorInicialPadrao,
        incremento: _incrementoPadrao,
        metaDesejada: _metaDesejadaPreview,
      );

  /// O valor real que o plano atinge com esse número (inteiro) de dias —
  /// quase nunca é exatamente igual à meta digitada, então é importante
  /// mostrar os dois lado a lado em vez de só o número de dias.
  double get _totalAlcancadoPreview {
    final n = _totalDiasEfetivo;
    if (n <= 0) return 0;
    return n / 2 * (2 * _valorInicialPadrao + (n - 1) * _incrementoPadrao);
  }

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
            keyboardType: TextInputType.number,
            inputFormatters: [_SeparadorDeMilharFormatter()],
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
                  'Para alcançar essa meta, você vai precisar de',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cores.onPrimaryContainer,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  temDados ? '$totalDias dias' : '—',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cores.onPrimaryContainer,
                      ),
                ),
                if (temDados) ...[
                  const SizedBox(height: 16),
                  Divider(color: cores.onPrimaryContainer.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  Text(
                    'Valor total ao final do plano',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: cores.onPrimaryContainer.withValues(alpha: 0.85),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatarMoeda(_totalAlcancadoPreview),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cores.onPrimaryContainer,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (temDados) ...[
            const SizedBox(height: 8),
            Text(
              'Como o número de dias é sempre inteiro, esse é o valor mais '
              'próximo — pra mais ou pra menos — da meta digitada.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cores.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
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
    final digitos = (valor ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.isEmpty || int.parse(digitos) <= 0) {
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
