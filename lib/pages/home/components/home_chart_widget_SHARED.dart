import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Widget réutilisable du graphique de consommation
/// Version AMÉLIORÉE : Partage les données avec consumption_page via SharedPreferences
class HomeChartWidget extends StatefulWidget {
  const HomeChartWidget({super.key});

  @override
  State<HomeChartWidget> createState() => _HomeChartWidgetState();
}

class _HomeChartWidgetState extends State<HomeChartWidget> {
  // Données de consommation (chargées depuis SharedPreferences)
  Map<String, double> consumptionData = {};
  
  int? touchedIndex;
  double kwhPrice = 0.20;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Charger les données et le prix depuis SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Charger le prix du kWh
    final savedPrice = prefs.getDouble('kwh_price') ?? 0.20;
    
    // Charger les données de consommation
    final String? consumptionJson = prefs.getString('consumption_data');
    Map<String, double> loadedData = {};
    
    if (consumptionJson != null && consumptionJson.isNotEmpty) {
      try {
        // Décoder le JSON
        final Map<String, dynamic> decoded = jsonDecode(consumptionJson);
        // Convertir en Map<String, double>
        loadedData = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
        debugPrint('✅ Données chargées: ${loadedData.length} mois');
      } catch (e) {
        debugPrint('❌ Erreur chargement données: $e');
      }
    }
    
    // Si aucune donnée chargée, utiliser les données par défaut
    if (loadedData.isEmpty) {
      debugPrint('⚠️ Aucune donnée sauvegardée, utilisation des données par défaut');
      loadedData = {
        '2025-01': 150,
        '2025-02': 180,
        '2025-03': 170,
        '2025-04': 190,
        '2025-05': 200,
        '2025-06': 220,
        '2025-07': 210,
        '2025-08': 230,
        '2025-09': 215,
        '2025-10': 205,
        '2025-11': 195,
        '2025-12': 185,
        '2026-01': 175,
      };
    }
    
    if (mounted) {
      setState(() {
        consumptionData = loadedData;
        kwhPrice = savedPrice;
        isLoading = false;
      });
    }
  }

  /// Récupérer les 8 derniers mois pour l'affichage
  List<MapEntry<String, double>> getFilteredData() {
    var entries = consumptionData.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    // Prendre les 8 derniers mois
    if (entries.length > 8) {
      return entries.sublist(entries.length - 8);
    }
    return entries;
  }

  String formatMonthYear(String key) {
    var parts = key.split('-');
    var monthNames = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];
    return monthNames[int.parse(parts[1]) - 1];
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un loader pendant le chargement
    if (isLoading) {
      return Container(
        height: 260,
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
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    var filteredData = getFilteredData();

    if (filteredData.isEmpty) {
      return Container(
        height: 260,
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
        child: const Center(child: Text('Aucune donnée disponible')),
      );
    }

    var values = filteredData.map((e) => e.value).toList();
    double minY = values.reduce((a, b) => a < b ? a : b) - 20;
    double maxY = values.reduce((a, b) => a > b ? a : b) + 20;

    // Calcul min et max pour le gradient de couleur
    double minConsumption = values.reduce((a, b) => a < b ? a : b);
    double maxConsumption = values.reduce((a, b) => a > b ? a : b);

    // Fonction pour obtenir la couleur en fonction de la consommation
    Color getColorForConsumption(double consumption) {
      if (maxConsumption == minConsumption) {
        return Colors.orange;
      }

      double normalized =
          (consumption - minConsumption) / (maxConsumption - minConsumption);

      return Color.lerp(
        Colors.green, // Basse consommation
        Colors.red, // Haute consommation
        normalized,
      )!;
    }

    return Container(
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
            'Ton Suivi de consommation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF264777),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF264777),
                    tooltipRoundedRadius: 8,
                    tooltipPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        final consumption = touchedSpot.y;
                        final period = filteredData[index].key;
                        var parts = period.split('-');
                        final cost = consumption * kwhPrice;
                        return LineTooltipItem(
                          '${formatMonthYear(period)} ${parts[0]}\n${consumption.toStringAsFixed(0)} kWh\n${cost.toStringAsFixed(2)} €',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    setState(() {
                      if (touchResponse == null ||
                          touchResponse.lineBarSpots == null) {
                        touchedIndex = null;
                        return;
                      }
                      touchedIndex = touchResponse.lineBarSpots!.first.x.toInt();
                    });
                  },
                  handleBuiltInTouches: true,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < filteredData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              formatMonthYear(filteredData[index].key),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 50,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}kWh',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (filteredData.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      filteredData.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        filteredData[index].value,
                      ),
                    ),
                    isCurved: true,
                    color: const Color(0xFF264777),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final consumption = filteredData[index].value;
                        final dotColor = getColorForConsumption(consumption);
                        return FlDotCirclePainter(
                          radius: touchedIndex == index ? 6 : 4,
                          color: dotColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF264777).withOpacity(0.1),
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
