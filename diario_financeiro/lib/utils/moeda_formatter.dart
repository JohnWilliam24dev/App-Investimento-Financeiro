import 'package:intl/intl.dart';

final NumberFormat _formatador =
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

String formatarMoeda(double valor) => _formatador.format(valor);
