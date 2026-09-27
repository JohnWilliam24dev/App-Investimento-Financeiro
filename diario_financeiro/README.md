# Controle de Poupança

App de controle manual do desafio de poupança progressiva:
dia 1 = R$1, dia 2 = R$2, dia 3 = R$3... Você só informa a meta que quer
alcançar e o app calcula quantos dias o desafio vai durar.

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
  widgets/         PlanoFormulario (criação e simulação), DiaCard e ProgressoHeader
  utils/           formatação de moeda (BRL)
```

## Regras de negócio

- Valor do dia N = R$N (valor inicial R$1, incremento R$1 por dia — fixo).
- O usuário informa a **meta** que quer alcançar; `Plano.diasParaAtingirMeta`
  resolve a progressão aritmética ao contrário (equação do 2º grau) pra
  achar o dia inteiro mais próximo dessa meta, pra mais ou pra menos.
- Total investido = soma dos dias **marcados como concluídos** (pode ser
  fora de ordem — por isso é uma soma no banco, não uma fórmula fechada).
- "Simular plano" (bottom sheet na home) reusa o mesmo `PlanoFormulario`
  da criação, mas com um `onConfirmar` que só fecha a tela — nada é salvo.

## Ícone do app

Gerado a partir de `assets/icon/icon.png` via `flutter_launcher_icons`
(cobre Android, iOS, Web, Windows e macOS). Pra regenerar depois de trocar
a imagem:

```bash
flutter pub get
dart run flutter_launcher_icons
```

Linux não é coberto por esse pacote — o ícone da janela ali é uma
configuração manual separada (fora do escopo por enquanto).
