import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/plano_provider.dart';
import '../utils/moeda_formatter.dart';

class CriarPlanoScreen extends StatefulWidget {
  const CriarPlanoScreen({super.key});

  @override
  State<CriarPlanoScreen> createState() => _CriarPlanoScreenState();
}

class _CriarPlanoScreenState extends State<CriarPlanoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorInicialController = TextEditingController(text: '1');
  final _incrementoController = TextEditingController(text: '1');
  final _totalDiasController = TextEditingController(text: '200');

  @override
  void dispose() {
    _valorInicialController.dispose();
    _incrementoController.dispose();
    _totalDiasController.dispose();
    super.dispose();
  }

  double get _valorInicialPreview =>
      double.tryParse(_valorInicialController.text.replaceAll(',', '.')) ?? 0;

  double get _incrementoPreview =>
      double.tryParse(_incrementoController.text.replaceAll(',', '.')) ?? 0;

  int get _totalDiasPreview => int.tryParse(_totalDiasController.text) ?? 0;

  double get _metaPreview {
    final n = _totalDiasPreview;
    if (n <= 0) return 0;
    return n / 2 * (2 * _valorInicialPreview + (n - 1) * _incrementoPreview);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Icon(
              Icons.savings_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Crie seu plano de investimento',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Defina o valor do primeiro dia, quanto aumenta por dia, '
              'e por quantos dias vai o desafio.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _valorInicialController,
              decoration: const InputDecoration(
                labelText: 'Valor do dia 1',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              validator: _validarValorPositivo,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _incrementoController,
              decoration: const InputDecoration(
                labelText: 'Incremento por dia',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              validator: _validarValorPositivo,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalDiasController,
              decoration: const InputDecoration(
                labelText: 'Total de dias',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: _validarTotalDias,
            ),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Meta ao final do plano',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatarMoeda(_metaPreview),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _salvar,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: const Text('Começar'),
            ),
          ],
        ),
      ),
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

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<PlanoProvider>().criarPlano(
          valorInicial: _valorInicialPreview,
          incremento: _incrementoPreview,
          totalDias: _totalDiasPreview,
        );
  }
}
