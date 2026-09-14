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
}
