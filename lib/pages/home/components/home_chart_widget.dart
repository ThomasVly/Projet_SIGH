import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeChartWidget extends StatelessWidget {
  const HomeChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Design : Une carte blanche contenant le graphe
    return Container(
      height: 200, // Hauteur du graphe
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cette semaine (kWh)",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false), // Pas de grille pour le look épuré
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Simulation des jours (Lundi, Mardi...)
                        const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      interval: 1,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    // --- FAUSSES DONNÉES ICI (A remplacer par celles de l'analyse plus tard) ---
                    spots: const [
                      FlSpot(0, 3),   // Lundi
                      FlSpot(1, 1.5), // Mardi
                      FlSpot(2, 4),   // Mercredi
                      FlSpot(3, 2),   // Jeudi
                      FlSpot(4, 5),   // Vendredi
                      FlSpot(5, 3.5), // Samedi
                      FlSpot(6, 2),   // Dimanche
                    ],
                    isCurved: true, // Courbe lisse
                    color: const Color(0xFF264777), // Bleu du thème
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false), // Pas de points sur la ligne
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF264777).withOpacity(0.1), // Dégradé en dessous
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}