/// Representa uma linha da "planilha": um dia específico do plano,
/// com o valor previsto e se o usuário já marcou como depositado.
class DiaInvestimento {
  final int? id;
  final int planoId;
  final int numeroDia;
  final double valor;
  final bool concluido;
  final DateTime? dataConclusao;

  const DiaInvestimento({
    this.id,
    required this.planoId,
    required this.numeroDia,
    required this.valor,
    this.concluido = false,
    this.dataConclusao,
  });

  /// Retorna uma cópia com o estado de conclusão invertido.
  /// Como o usuário pode marcar os dias fora de ordem, essa ação
  /// não depende de nenhum outro dia estar concluído.
  DiaInvestimento alternarConclusao() => DiaInvestimento(
        id: id,
        planoId: planoId,
        numeroDia: numeroDia,
        valor: valor,
        concluido: !concluido,
        dataConclusao: !concluido ? DateTime.now() : null,
      );

  factory DiaInvestimento.fromMap(Map<String, dynamic> map) =>
      DiaInvestimento(
        id: map['id'] as int?,
        planoId: map['plano_id'] as int,
        numeroDia: map['numero_dia'] as int,
        valor: (map['valor'] as num).toDouble(),
        concluido: (map['concluido'] as int) == 1,
        dataConclusao: map['data_conclusao'] != null
            ? DateTime.parse(map['data_conclusao'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'plano_id': planoId,
        'numero_dia': numeroDia,
        'valor': valor,
        'concluido': concluido ? 1 : 0,
        'data_conclusao': dataConclusao?.toIso8601String(),
      };
}
