import 'package:flutter/material.dart';

import '../utils/moeda_formatter.dart';

class ProgressoHeader extends StatelessWidget {
  final double totalInvestido;
  final double metaTotal;
  final double progresso;

  const ProgressoHeader({
    super.key,
    required this.totalInvestido,
    required this.metaTotal,
    required this.progresso,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: cores.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Investido até agora',
            style: TextStyle(color: cores.onPrimary.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatarMoeda(totalInvestido),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: cores.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${formatarMoeda(metaTotal)}',
                style: TextStyle(color: cores.onPrimary.withValues(alpha: 0.85)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 10,
              backgroundColor: cores.onPrimary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(cores.onPrimary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progresso * 100).toStringAsFixed(1)}% concluído',
            style: TextStyle(
              color: cores.onPrimary.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
