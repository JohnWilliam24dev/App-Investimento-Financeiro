import 'package:flutter_test/flutter_test.dart';

import 'package:diario_financeiro/models/plano.dart';

void main() {
  group('Plano', () {
    test('valorDoDia calcula a progressão aritmética corretamente', () {
      final plano = Plano(
        valorInicial: 1,
        incremento: 1,
        totalDias: 200,
        dataCriacao: DateTime(2026, 1, 1),
      );

      expect(plano.valorDoDia(1), 1);
      expect(plano.valorDoDia(2), 2);
      expect(plano.valorDoDia(4), 4);
      expect(plano.valorDoDia(200), 200);
    });

    test('metaTotal bate com a soma de 1 até 200 (exemplo do enunciado)', () {
      final plano = Plano(
        valorInicial: 1,
        incremento: 1,
        totalDias: 200,
        dataCriacao: DateTime(2026, 1, 1),
      );

      // soma 1 + 2 + ... + 200 = 200 * 201 / 2 = 20.100
      expect(plano.metaTotal, 20100);
    });

    test('metaTotal funciona com valor inicial e incremento configuráveis',
        () {
      final plano = Plano(
        valorInicial: 5,
        incremento: 2,
        totalDias: 10,
        dataCriacao: DateTime(2026, 1, 1),
      );

      // dias: 5,7,9,11,13,15,17,19,21,23 -> soma = 140
      expect(plano.metaTotal, 140);
    });
  });

  group('Plano.diasParaAtingirMeta', () {
    test('encontra o dia mais próximo (pra mais) de uma meta de R\$10.000',
        () {
      // 1+2+...+140 = 9.870 (abaixo) | 1+2+...+141 = 10.011 (mais perto)
      final dias = Plano.diasParaAtingirMeta(
        valorInicial: 1,
        incremento: 1,
        metaDesejada: 10000,
      );

      expect(dias, 141);
    });

    test('bate exatamente quando a meta já é um valor alcançável', () {
      final dias = Plano.diasParaAtingirMeta(
        valorInicial: 1,
        incremento: 1,
        metaDesejada: 20100, // soma exata de 1 a 200
      );

      expect(dias, 200);
    });

    test('funciona com incremento zero (valor fixo por dia)', () {
      final dias = Plano.diasParaAtingirMeta(
        valorInicial: 50,
        incremento: 0,
        metaDesejada: 1000,
      );

      expect(dias, 20); // 50 * 20 = 1000
    });
  });
}
