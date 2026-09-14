import 'package:flutter/material.dart';

import '../models/dia_investimento.dart';
import '../utils/moeda_formatter.dart';

class DiaCard extends StatelessWidget {
  final DiaInvestimento dia;
  final VoidCallback onTap;

  const DiaCard({super.key, required this.dia, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final concluido = dia.concluido;
    final cores = Theme.of(context).colorScheme;

    return Material(
      color: concluido ? cores.primary : cores.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Dia ${dia.numeroDia}',
                style: TextStyle(
                  fontSize: 12,
                  color: concluido
                      ? cores.onPrimary.withValues(alpha: 0.85)
                      : cores.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatarMoeda(dia.valor),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: concluido ? cores.onPrimary : cores.onSurface,
                ),
              ),
              if (concluido) ...[
                const SizedBox(height: 4),
                Icon(Icons.check_circle, size: 16, color: cores.onPrimary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
