import 'package:flutter/material.dart';

import '../models/plano.dart';
import '../utils/moeda_formatter.dart';

enum _ModoDefinicao { porDias, porMeta }

/// Formulário de "valor inicial / incremento / duração" com preview ao
/// vivo da meta. Usado tanto para criar um plano de verdade quanto para
/// simular um plano hipotético sem salvar nada — quem decide o efeito é
/// o [onConfirmar] passado por quem usa o widget.
///
/// Tem dois modos de definir a duração:
/// - "Por dias": o usuário informa quantos dias o desafio vai ter.
/// - "Por meta": o usuário informa quanto quer alcançar, e o app calcula
///   o número de dias mais próximo (pra mais ou pra menos) que atinge isso.
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
  final _valorInicialController = TextEditingController(text: '1');
  final _incrementoController = TextEditingController(text: '1');
  final _totalDiasController = TextEditingController(text: '200');
  final _metaDesejadaController = TextEditingController();

  _ModoDefinicao _modo = _ModoDefinicao.porDias;
  bool _enviando = false;

  @override
  void dispose() {
    _valorInicialController.dispose();
    _incrementoController.dispose();
    _totalDiasController.dispose();
    _metaDesejadaController.dispose();
    super.dispose();
  }

  double get _valorInicialPreview =>
      double.tryParse(_valorInicialController.text.replaceAll(',', '.')) ?? 0;

  double get _incrementoPreview =>
      double.tryParse(_incrementoController.text.replaceAll(',', '.')) ?? 0;

  double get _metaDesejadaPreview =>
      double.tryParse(_metaDesejadaController.text.replaceAll(',', '.')) ?? 0;

  /// Número de dias efetivo, seja qual for o modo escolhido.
  int get _totalDiasEfetivo {
    if (_modo == _ModoDefinicao.porDias) {
      return int.tryParse(_totalDiasController.text) ?? 0;
    }
    return Plano.diasParaAtingirMeta(
      valorInicial: _valorInicialPreview,
      incremento: _incrementoPreview,
      metaDesejada: _metaDesejadaPreview,
    );
  }

  double get _metaPreview {
    final n = _totalDiasEfetivo;
    if (n <= 0) return 0;
    return n / 2 * (2 * _valorInicialPreview + (n - 1) * _incrementoPreview);
  }

  double get _valorUltimoDiaPreview {
    final n = _totalDiasEfetivo;
    if (n <= 0) return 0;
    return _valorInicialPreview + _incrementoPreview * (n - 1);
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

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
            controller: _valorInicialController,
            decoration: _decoracao(
              label: 'Valor do dia 1',
              icone: Icons.attach_money,
              prefixo: 'R\$ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            validator: _validarValorPositivo,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _incrementoController,
            decoration: _decoracao(
              label: 'Incremento por dia',
              icone: Icons.trending_up,
              prefixo: 'R\$ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            validator: _validarValorPositivo,
          ),
          const SizedBox(height: 24),
          SegmentedButton<_ModoDefinicao>(
            segments: const [
              ButtonSegment(
                value: _ModoDefinicao.porDias,
                label: Text('Por dias'),
                icon: Icon(Icons.calendar_month_outlined),
              ),
              ButtonSegment(
                value: _ModoDefinicao.porMeta,
                label: Text('Por meta'),
                icon: Icon(Icons.flag_outlined),
              ),
            ],
            selected: {_modo},
            onSelectionChanged: (selecao) =>
                setState(() => _modo = selecao.first),
          ),
          const SizedBox(height: 16),
          if (_modo == _ModoDefinicao.porDias)
            TextFormField(
              key: const ValueKey('campo_total_dias'),
              controller: _totalDiasController,
              decoration: _decoracao(
                label: 'Total de dias',
                icone: Icons.calendar_month_outlined,
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: _validarTotalDias,
            )
          else
            TextFormField(
              key: const ValueKey('campo_meta_desejada'),
              controller: _metaDesejadaController,
              decoration: _decoracao(
                label: 'Quanto você quer alcançar',
                icone: Icons.flag_outlined,
                prefixo: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              validator: _validarMetaDesejada,
            ),
          const SizedBox(height: 24),
          _ResumoPlano(
            metaTotal: _metaPreview,
            valorUltimoDia: _valorUltimoDiaPreview,
            totalDias: _totalDiasEfetivo,
          ),
          if (_modo == _ModoDefinicao.porMeta && _totalDiasEfetivo > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Como o número de dias é sempre inteiro, esse é o valor mais '
              'próximo (pra mais ou pra menos) de ${formatarMoeda(_metaDesejadaPreview)}.',
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

  InputDecoration _decoracao({
    required String label,
    required IconData icone,
    String? prefixo,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icone, size: 20),
      prefixText: prefixo,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      filled: true,
    );
  }

  String? _validarValorPositivo(String? valor) {
    final numero = double.tryParse((valor ?? '').replaceAll(',', '.'));
    if (numero == null || numero <= 0) {
      return 'Informe um valor maior que zero';
    }
    return null;
  }

  String? _validarTotalDias(String? valor) {
    final n = int.tryParse(valor ?? '');
    if (n == null || n <= 0) return 'Informe um número de dias válido';
    if (n > 3650) return 'Máximo de 3650 dias (10 anos)';
    return null;
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
        'Isso levaria mais de 3650 dias (10 anos). Ajuste os valores.',
      );
      return;
    }

    setState(() => _enviando = true);
    await widget.onConfirmar(
      _valorInicialPreview,
      _incrementoPreview,
      totalDias,
    );
    if (mounted) setState(() => _enviando = false);
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }
}

class _ResumoPlano extends StatelessWidget {
  final double metaTotal;
  final double valorUltimoDia;
  final int totalDias;

  const _ResumoPlano({
    required this.metaTotal,
    required this.valorUltimoDia,
    required this.totalDias,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final temDados = totalDias > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cores.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Meta ao final do plano',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cores.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            temDados ? formatarMoeda(metaTotal) : '—',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cores.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 16),
          Divider(color: cores.onPrimaryContainer.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _EstatisticaMini(
                label: 'Duração',
                valor: temDados ? '$totalDias dias' : '—',
              ),
              _EstatisticaMini(
                label: 'Último dia',
                valor: temDados ? formatarMoeda(valorUltimoDia) : '—',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EstatisticaMini extends StatelessWidget {
  final String label;
  final String valor;

  const _EstatisticaMini({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: cores.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cores.onPrimaryContainer.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
