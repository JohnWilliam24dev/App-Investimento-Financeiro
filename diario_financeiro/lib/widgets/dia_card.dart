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

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: concluido ? cores.primary : cores.surfaceContainerHighest,
              boxShadow: concluido
                  ? [
                      BoxShadow(
                        color: cores.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${dia.numeroDia}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: concluido
                            ? cores.onPrimary.withValues(alpha: 0.85)
                            : cores.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      formatarMoedaCompacta(dia.valor),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: concluido ? cores.onPrimary : cores.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (concluido)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cores.onPrimary,
                ),
                child: Icon(Icons.check, size: 10, color: cores.primary),
              ),
            ),
        ],
      ),
    );
  }
}
