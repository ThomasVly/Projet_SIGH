import 'package:flutter/material.dart';
import 'package:projet_sigh_grp1/common-widget/header/header_widget.dart';
import 'package:projet_sigh_grp1/pages/equipments/equipments_page.dart';
import 'package:fl_chart/fl_chart.dart';

class ConsumptionPage extends StatefulWidget {
  const ConsumptionPage({Key? key}) : super(key: key);

  @override
  State<ConsumptionPage> createState() => _ConsumptionPageState();
}

class _ConsumptionPageState extends State<ConsumptionPage> {
  // Structure pour stocker les données avec mois et année
  Map<String, double> consumptionData = {
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

  int? touchedIndex;

  // Période affichée
  String startPeriod = '2025-06';
  String endPeriod = '2026-01';

  // Pour l'ajout de données
  int selectedMonth = 1;
  int selectedYear = 2026;
  final TextEditingController consumptionController = TextEditingController();

  @override
  void dispose() {
    consumptionController.dispose();
    super.dispose();
  }

  List<MapEntry<String, double>> getFilteredData() {
    var entries = consumptionData.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    return entries.where((entry) {
      return entry.key.compareTo(startPeriod) >= 0 &&
          entry.key.compareTo(endPeriod) <= 0;
    }).toList();
  }

  String formatMonthYear(String key) {
    var parts = key.split('-');
    var monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return monthNames[int.parse(parts[1]) - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  HeaderWidget(
                    title: 'Suivi de consommation',
                    isHomePage: false,
                    isCollapsed: false,
                    navigationContext: context,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildPeriodSelector(),
                        const SizedBox(height: 20),
                        _buildConsumptionChart(),
                        const SizedBox(height: 20),
                        _buildAddDataButton(context),
                        const SizedBox(height: 30),
                        const Text(
                          'Statistiques mensuelles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildStatsCards(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 100,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EquipmentsPage()),
                  );
                },
                child: const Text('Equipements'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    var allPeriods = consumptionData.keys.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sélectionner la période',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Du', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: startPeriod,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: allPeriods.map((period) {
                        var parts = period.split('-');
                        return DropdownMenuItem(
                          value: period,
                          child: Text('${formatMonthYear(period)} ${parts[0]}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            startPeriod = value;
                            _validatePeriodRange();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Au', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: endPeriod,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: allPeriods.map((period) {
                        var parts = period.split('-');
                        return DropdownMenuItem(
                          value: period,
                          child: Text('${formatMonthYear(period)} ${parts[0]}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            endPeriod = value;
                            _validatePeriodRange();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _validatePeriodRange() {
    var filtered = getFilteredData();
    if (filtered.length > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous ne pouvez pas afficher plus de 12 mois'),
          backgroundColor: Colors.red,
        ),
      );
      // Réinitialiser à la dernière période valide
      setState(() {
        var sortedKeys = consumptionData.keys.toList()..sort();
        endPeriod = sortedKeys.last;
        var endIndex = sortedKeys.indexOf(endPeriod);
        startPeriod = sortedKeys[endIndex - 7 < 0 ? 0 : endIndex - 7];
      });
    }
  }

  Widget _buildConsumptionChart() {
    var filteredData = getFilteredData();

    if (filteredData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text('Aucune donnée pour cette période'),
      );
    }

    var values = filteredData.map((e) => e.value).toList();
    double minY = values.reduce((a, b) => a < b ? a : b) - 20;
    double maxY = values.reduce((a, b) => a > b ? a : b) + 20;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
              color: Color(0xFF1E3A5F),
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
                    getTooltipColor: (touchedSpot) => const Color(0xFF1E3A5F),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        final consumption = touchedSpot.y;
                        final period = filteredData[index].key;
                        var parts = period.split('-');
                        return LineTooltipItem(
                          '${formatMonthYear(period)} ${parts[0]}\n${consumption.toStringAsFixed(0)}W',
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
                      if (touchResponse == null || touchResponse.lineBarSpots == null) {
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
                          '${value.toInt()}W',
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
                    color: const Color(0xFF1E3A5F),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: touchedIndex == index ? 6 : 4,
                          color: touchedIndex == index
                              ? Colors.orange
                              : const Color(0xFF1E3A5F),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF1E3A5F).withOpacity(0.1),
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

  Widget _buildAddDataButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _showAddDataDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une consommation'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A5F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _showAddDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Ajouter une consommation'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Mois',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(12, (index) {
                        var monthNames = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
                          'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(monthNames[index]),
                        );
                      }),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedMonth = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Année',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(5, (index) {
                        int year = 2024 + index;
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedYear = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: consumptionController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Consommation (W)',
                        border: OutlineInputBorder(),
                        suffixText: 'W',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addConsumption();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addConsumption() {
    if (consumptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une valeur')),
      );
      return;
    }

    double? consumption = double.tryParse(consumptionController.text);
    if (consumption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valeur invalide')),
      );
      return;
    }

    String monthStr = selectedMonth.toString().padLeft(2, '0');
    String key = '$selectedYear-$monthStr';

    setState(() {
      consumptionData[key] = consumption;
    });

    consumptionController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Consommation ajoutée pour $key')),
    );
  }

  Widget _buildStatsCards() {
    var filteredData = getFilteredData();
    if (filteredData.isEmpty) return const SizedBox();

    var values = filteredData.map((e) => e.value).toList();
    double average = values.reduce((a, b) => a + b) / values.length;
    double max = values.reduce((a, b) => a > b ? a : b);
    double current = values.last;

    return Column(
      children: [
        _buildStatCard('Consommation moyenne', '${average.toStringAsFixed(0)}W', Colors.blue),
        const SizedBox(height: 10),
        _buildStatCard('Consommation maximale', '${max.toStringAsFixed(0)}W', Colors.orange),
        const SizedBox(height: 10),
        _buildStatCard('Consommation actuelle', '${current.toStringAsFixed(0)}W', Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
