import 'dart:math' as math;

/// Representa a "tabela de investimento" configurada pelo usuário:
/// quanto guardar no primeiro dia, quanto aumenta a cada dia, e por
/// quantos dias o desafio vai.
class Plano {
  final int? id;
  final double valorInicial;
  final double incremento;
  final int totalDias;
  final DateTime dataCriacao;

  const Plano({
    this.id,
    required this.valorInicial,
    required this.incremento,
    required this.totalDias,
    required this.dataCriacao,
  });

  /// Valor previsto para o dia [numeroDia] (1-indexado).
  /// dia 1 = valorInicial; dia N = valorInicial + incremento * (N - 1).
  double valorDoDia(int numeroDia) =>
      valorInicial + incremento * (numeroDia - 1);

  /// Soma de todos os valores previstos do dia 1 até [totalDias].
  /// Fórmula fechada de progressão aritmética: n/2 * (2a + (n-1)d).
  /// Isso é só a META — o total efetivamente investido depende de quais
  /// dias o usuário marcou como concluído, e por isso vive no banco
  /// (ver PlanoRepository.calcularTotalInvestido).
  double get metaTotal =>
      totalDias / 2 * (2 * valorInicial + (totalDias - 1) * incremento);

  factory Plano.fromMap(Map<String, dynamic> map) => Plano(
        id: map['id'] as int?,
        valorInicial: (map['valor_inicial'] as num).toDouble(),
        incremento: (map['incremento'] as num).toDouble(),
        totalDias: map['total_dias'] as int,
        dataCriacao: DateTime.parse(map['data_criacao'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'valor_inicial': valorInicial,
        'incremento': incremento,
        'total_dias': totalDias,
        'data_criacao': dataCriacao.toIso8601String(),
      };

  Plano copyWith({int? id}) => Plano(
        id: id ?? this.id,
        valorInicial: valorInicial,
        incremento: incremento,
        totalDias: totalDias,
        dataCriacao: dataCriacao,
      );

  /// Calcula quantos dias são necessários pra chegar o mais perto possível
  /// de [metaDesejada], dado um valor inicial e incremento fixos.
  ///
  /// Resolve a progressão aritmética ao contrário: como
  /// `S = n/2 * (2a + (n-1)d)`, isolando n temos uma equação do 2º grau
  /// `d*n² + (2a-d)*n - 2S = 0`, resolvida pela fórmula de Bhaskara.
  ///
  /// Como o número de dias precisa ser inteiro, o resultado é arredondado
  /// pro inteiro mais próximo (pra cima ou pra baixo) — por isso a meta
  /// final pode ficar um pouco acima ou abaixo do valor pedido. Sempre
  /// recalcule a meta real com o total de dias retornado aqui.
  static int diasParaAtingirMeta({
    required double valorInicial,
    required double incremento,
    required double metaDesejada,
  }) {
    if (metaDesejada <= 0) return 0;

    double n;
    if (incremento == 0) {
      if (valorInicial <= 0) return 0;
      n = metaDesejada / valorInicial;
    } else {
      final a = incremento;
      final b = 2 * valorInicial - incremento;
      final c = -2 * metaDesejada;
      final delta = b * b - 4 * a * c;
      if (delta < 0) return 0;
      n = (-b + math.sqrt(delta)) / (2 * a);
    }

    final diasArredondado = n.round();
    return diasArredondado < 1 ? 1 : diasArredondado;
  }
}
