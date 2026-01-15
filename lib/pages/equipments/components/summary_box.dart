import 'package:flutter/material.dart';

class SummaryBox extends StatelessWidget {
  final double monthlyConsumption;
  final double monthlyCost;
  final int equipmentCount;

  const SummaryBox({
    super.key,
    required this.monthlyConsumption,
    required this.monthlyCost,
    required this.equipmentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF003366),
            Color(0xFF0055AA),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                '${monthlyConsumption.toStringAsFixed(0)} kWh/mois',
                Icons.bolt,
                Colors.yellow,
              ),
              _buildStatItem(
                '${monthlyCost.toStringAsFixed(0)} €/mois',
                Icons.euro,
                Colors.orange,
              ),
              _buildStatItem(
                '$equipmentCount appareils',
                Icons.devices,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}