import 'package:flutter/foundation.dart';

import '../data/plano_repository.dart';
import '../models/dia_investimento.dart';
import '../models/plano.dart';

/// Estado da tela principal. Não sabe nada de SQLite — só fala com o
/// repository através da interface pública dele (inversão de dependência:
/// se o repository mudar de implementação por dentro, este provider
/// continua igual).
class PlanoProvider extends ChangeNotifier {
  final PlanoRepository _repository;

  PlanoProvider({PlanoRepository? repository})
      : _repository = repository ?? PlanoRepository();

  Plano? _plano;
  List<DiaInvestimento> _dias = [];
  double _totalInvestido = 0;
  bool _carregando = true;

  Plano? get plano => _plano;
  List<DiaInvestimento> get dias => List.unmodifiable(_dias);
  double get totalInvestido => _totalInvestido;
  double get metaTotal => _plano?.metaTotal ?? 0;
  bool get carregando => _carregando;
  bool get temPlanoAtivo => _plano != null;

  double get progresso => metaTotal == 0
      ? 0
      : (totalInvestido / metaTotal).clamp(0, 1).toDouble();

  /// Chamado uma vez, ao abrir o app: busca o plano ativo (se existir)
  /// e os dias associados.
  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _plano = await _repository.buscarPlanoAtivo();
    if (_plano != null) {
      await _recarregarDiasETotal();
    }

    _carregando = false;
    notifyListeners();
  }

  Future<void> criarPlano({
    required double valorInicial,
    required double incremento,
    required int totalDias,
  }) async {
    final novoPlano = Plano(
      valorInicial: valorInicial,
      incremento: incremento,
      totalDias: totalDias,
      dataCriacao: DateTime.now(),
    );

    _plano = await _repository.criarPlano(novoPlano);
    await _recarregarDiasETotal();
    notifyListeners();
  }

  /// Marca/desmarca um dia. Atualiza a UI imediatamente (otimista) e só
  /// depois confirma com o banco — assim o toque do usuário parece
  /// instantâneo mesmo em aparelhos mais lentos.
  Future<void> alternarDia(DiaInvestimento dia) async {
    final diaAtualizado = dia.alternarConclusao();

    final indice = _dias.indexWhere((d) => d.id == dia.id);
    if (indice == -1) return;

    _dias[indice] = diaAtualizado;
    notifyListeners();

    await _repository.salvarDia(diaAtualizado);
    _totalInvestido = await _repository.calcularTotalInvestido(_plano!.id!);
    notifyListeners();
  }

  Future<void> excluirPlanoAtual() async {
    if (_plano?.id == null) return;
    await _repository.excluirPlano(_plano!.id!);
    _plano = null;
    _dias = [];
    _totalInvestido = 0;
    notifyListeners();
  }

  Future<void> _recarregarDiasETotal() async {
    if (_plano?.id == null) return;
    _dias = await _repository.buscarDias(_plano!.id!);
    _totalInvestido = await _repository.calcularTotalInvestido(_plano!.id!);
  }
}
