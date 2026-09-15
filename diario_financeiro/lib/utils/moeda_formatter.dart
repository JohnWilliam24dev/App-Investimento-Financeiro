import 'package:intl/intl.dart';

final NumberFormat _formatador =
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

String formatarMoeda(double valor) => _formatador.format(valor);

/// Versão compacta pra caber em espaços pequenos (ex: círculos da grade).
/// Omite os centavos quando o valor é redondo (R$4 em vez de R$4,00),
/// mas mostra quando fazem diferença (R$4,50).
String formatarMoedaCompacta(double valor) {
  final semCentavos = valor == valor.roundToDouble();
  final formatador = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: semCentavos ? 0 : 2,
  );
  return formatador.format(valor);
}
