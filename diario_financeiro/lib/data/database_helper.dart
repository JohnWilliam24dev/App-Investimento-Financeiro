import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

/// Responsável apenas por abrir/criar o banco SQLite e definir o schema.
/// Não conhece regras de negócio — quem faz isso é o PlanoRepository.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _nomeArquivo = 'diario_financeiro.db';
  static const _versao = 1;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _abrirBanco();
    return _database!;
  }

  /// Android, iOS e macOS já vêm com implementação nativa do sqflite.
  /// Windows e Linux (e testes via Dart VM) precisam do sqflite_common_ffi
  /// como implementação alternativa do databaseFactory.
  void _configurarFactoryDesktop() {
    if (kIsWeb) return;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> _abrirBanco() async {
    _configurarFactoryDesktop();

    final diretorio = await getDatabasesPath();
    final caminho = join(diretorio, _nomeArquivo);

    return openDatabase(
      caminho,
      version: _versao,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _criarTabelas,
    );
  }

  Future<void> _criarTabelas(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE plano (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        valor_inicial REAL NOT NULL,
        incremento REAL NOT NULL,
        total_dias INTEGER NOT NULL,
        data_criacao TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE dia_investimento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plano_id INTEGER NOT NULL REFERENCES plano(id) ON DELETE CASCADE,
        numero_dia INTEGER NOT NULL,
        valor REAL NOT NULL,
        concluido INTEGER NOT NULL DEFAULT 0,
        data_conclusao TEXT,
        UNIQUE(plano_id, numero_dia)
      )
    ''');
  }
}
