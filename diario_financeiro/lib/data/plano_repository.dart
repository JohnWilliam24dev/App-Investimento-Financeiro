import 'package:sqflite/sqflite.dart';

import '../models/dia_investimento.dart';
import '../models/plano.dart';
import 'database_helper.dart';

/// Única porta de acesso a dados do app. Quem usa esta classe (o provider)
/// não sabe que existe SQLite por trás — só conhece esses métodos.
/// Isso mantém a UI e a regra de estado independentes da tecnologia de
/// persistência (se um dia trocar para outro banco, só isso muda).
class PlanoRepository {
  final DatabaseHelper _databaseHelper;

  PlanoRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  /// O app trabalha com um único plano ativo por vez — é o mais recente
  /// criado. Se um dia for preciso guardar histórico de planos antigos,
  /// dá pra evoluir isso com uma coluna "arquivado_em" sem mudar o
  /// restante do app.
  Future<Plano?> buscarPlanoAtivo() async {
    final db = await _databaseHelper.database;
    final resultado = await db.query('plano', orderBy: 'id DESC', limit: 1);
    if (resultado.isEmpty) return null;
    return Plano.fromMap(resultado.first);
  }

  /// Cria o plano e já gera todas as linhas de dia_investimento
  /// correspondentes, numa única transação (tudo ou nada).
  Future<Plano> criarPlano(Plano plano) async {
    final db = await _databaseHelper.database;

    return db.transaction((txn) async {
      final planoId = await txn.insert('plano', plano.toMap());

      final batch = txn.batch();
      for (var dia = 1; dia <= plano.totalDias; dia++) {
        final diaInvestimento = DiaInvestimento(
          planoId: planoId,
          numeroDia: dia,
          valor: plano.valorDoDia(dia),
        );
        batch.insert('dia_investimento', diaInvestimento.toMap());
      }
      await batch.commit(noResult: true);

      return plano.copyWith(id: planoId);
    });
  }

  Future<List<DiaInvestimento>> buscarDias(int planoId) async {
    final db = await _databaseHelper.database;
    final resultado = await db.query(
      'dia_investimento',
      where: 'plano_id = ?',
      whereArgs: [planoId],
      orderBy: 'numero_dia ASC',
    );
    return resultado.map(DiaInvestimento.fromMap).toList();
  }

  Future<void> salvarDia(DiaInvestimento dia) async {
    final db = await _databaseHelper.database;
    await db.update(
      'dia_investimento',
      dia.toMap(),
      where: 'id = ?',
      whereArgs: [dia.id],
    );
  }

  /// Soma só o que já foi de fato marcado como concluído. É o SQL fazendo
  /// a agregação (SUM condicional) em vez de somar em Dart — como os dias
  /// podem ser concluídos fora de ordem, não dá pra usar uma fórmula
  /// fechada de progressão aritmética aqui, só pra a meta total.
  Future<double> calcularTotalInvestido(int planoId) async {
    final db = await _databaseHelper.database;
    final resultado = await db.rawQuery('''
      SELECT COALESCE(SUM(valor), 0) AS total
      FROM dia_investimento
      WHERE plano_id = ? AND concluido = 1
    ''', [planoId]);
    return (resultado.first['total'] as num).toDouble();
  }

  /// Apaga o plano e, em cascata (FK + PRAGMA foreign_keys = ON),
  /// todos os dias associados a ele.
  Future<void> excluirPlano(int planoId) async {
    final db = await _databaseHelper.database;
    await db.delete('plano', where: 'id = ?', whereArgs: [planoId]);
  }
}
