# Diário Financeiro

App de controle manual do desafio de poupança progressiva:
dia 1 = R$1, dia 2 = R$2, dia 3 = R$3... (valor inicial e incremento configuráveis).

O app não integra com banco nenhum — é um controle "de honestidade", tipo
uma planilha: você deposita de fato por fora, e marca o dia como concluído
no app pra acompanhar o total investido em relação à meta.

## Stack

- Flutter + Provider (gerenciamento de estado)
- SQLite via `sqflite` (mobile/macOS) e `sqflite_common_ffi` (Windows/Linux)

## Rodando o projeto

```bash
flutter pub get
flutter run
```

Funciona em qualquer plataforma habilitada (Android, iOS, macOS, Linux,
Windows) sem nenhuma configuração manual — a troca de driver do SQLite pra
desktop é feita automaticamente em `lib/data/database_helper.dart`.

## Estrutura

```text
lib/
  data/            acesso a dados: DatabaseHelper (schema/conexão) e PlanoRepository
  models/          entidades de domínio: Plano e DiaInvestimento
  providers/       PlanoProvider (ChangeNotifier) — estado da tela principal
  screens/         HomeScreen e CriarPlanoScreen
  widgets/         DiaCard e ProgressoHeader
  utils/           formatação de moeda (BRL)
```

## Regras de negócio

- Valor do dia N = `valorInicial + incremento * (N - 1)`.
- Meta total = soma de todos os dias previstos (progressão aritmética).
- Total investido = soma dos dias **marcados como concluídos** (pode ser
  fora de ordem — por isso é uma soma no banco, não uma fórmula fechada).
