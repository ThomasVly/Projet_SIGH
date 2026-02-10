import 'package:flutter/material.dart';
import 'package:projet_sigh_grp1/common-widget/header/header_widget.dart';
import 'package:projet_sigh_grp1/pages/equipments/equipments_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:projet_sigh_grp1/pages/equipments/services/equipment_service.dart'; // Adapte le chemin
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet_sigh_grp1/shared/local_database/db-creator.dart'; // Ajuste le chemin selon ton projet

class ConsumptionPage extends StatefulWidget {
  const ConsumptionPage({Key? key}) : super(key: key);

  @override
  State<ConsumptionPage> createState() => _ConsumptionPageState();
}

class _ConsumptionPageState extends State<ConsumptionPage> {
  // Structure pour stocker les données avec mois et année
  Map<String, double> consumptionData = {

  };

  Map<String, double> kwhPricePerMonth = {

  };

  int? touchedIndex;

  // Période affichée
  String startPeriod = '2025-06';
  String endPeriod = '2026-01';

  // Pour l'ajout de données
  int selectedMonth = 1;
  int selectedYear = 2026;
  final TextEditingController consumptionController = TextEditingController();

  final TextEditingController kwhPriceController = TextEditingController(text: '0.20');
  final TextEditingController pricePerKwhController = TextEditingController();
  double kwhPrice = 0.20;

  InventoryStats? nextMonthPrediction;     // ← AJOUTE ÇA
  bool isLoadingPrediction = false;        // ← ET ÇA

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _loadPrediction();
  }

  Future<void> _loadAllData() async {
    await _loadConsumptionData();
    await _loadKwhPricesPerMonth();
  }

  Future<void> _loadConsumptionData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('consumption_data');
    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        if (mounted) {
          setState(() {
            consumptionData = decoded.map((key, value) => MapEntry(
              key,
              (value as num).toDouble(),
            ));
          });
        }
      } catch (e) {
        print('Erreur chargement consumptionData: $e');
      }
    }
  }

  @override
  void dispose() {
    consumptionController.dispose();
    pricePerKwhController.dispose();
    super.dispose();
  }

  // Charger le prix du kWh depuis SharedPreferences
  Future<void> _loadKwhPrice() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPrice = prefs.getDouble('kwh_price') ?? 0.20;
    setState(() {
      kwhPrice = savedPrice;
      kwhPriceController.text = savedPrice.toString();
    });
  }

  Future<void> _loadPrediction() async {
    setState(() => isLoadingPrediction = true);
    try {
      final prediction = await EquipmentService().getInventoryStats();
      if (mounted) setState(() => nextMonthPrediction = prediction);
    } catch (e) {
      print('Erreur: $e');
    } finally {
      if (mounted) setState(() => isLoadingPrediction = false);
    }
  }


  // Sauvegarder le prix du kWh dans SharedPreferences
  Future<void> _saveKwhPrice(double price) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('kwh_price', price);
  }

  Future<void> _loadKwhPricesPerMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('kwh_price_per_month');
    if (jsonString != null) {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      setState(() {
        kwhPricePerMonth = decoded.map((key, value) => MapEntry(
          key,
          (value as num).toDouble(),
        ));
      });
    }
  }

  Future<void> _saveKwhPricesPerMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(kwhPricePerMonth);
    await prefs.setString('kwh_price_per_month', jsonString);
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EquipmentsPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A5F),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Equipements'),
                          ),
                        ),
                        const SizedBox(height: 10),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    var allPeriods = consumptionData.keys.toList()..sort();

    // 🔥 VALIDATION ROBUSTE DES PÉRIODES
    if (allPeriods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text('Aucune période disponible'),
      );
    }

    // Corriger startPeriod si invalide
    if (!allPeriods.contains(startPeriod)) {
      startPeriod = allPeriods.first;
    }

    // Corriger endPeriod si invalide (doit être >= startPeriod)
    if (!allPeriods.contains(endPeriod) || endPeriod.compareTo(startPeriod) < 0) {
      endPeriod = allPeriods.last;
    }

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
          const SizedBox(height: 20),
          const SizedBox(height: 5),
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

    // AJOUT : Inclure la prédiction dans min/max Y
    if (nextMonthPrediction != null) {
      minY = minY < 0 ? minY : 0;
      maxY = (maxY > nextMonthPrediction!.monthlyConsumption)
          ? maxY
          : nextMonthPrediction!.monthlyConsumption + 20;
    }

    // Calcul min et max pour le gradient de couleur
    double minConsumption = values.reduce((a, b) => a < b ? a : b);
    double maxConsumption = values.reduce((a, b) => a > b ? a : b);

    // Fonction pour obtenir la couleur en fonction de la consommation
    Color getColorForConsumption(double consumption) {
      if (maxConsumption == minConsumption) {
        return Colors.orange; // Si toutes les valeurs sont identiques
      }

      // Normaliser la valeur entre 0 et 1
      double normalized = (consumption - minConsumption) /
          (maxConsumption - minConsumption);

      // Interpolation du rouge (haute conso) au vert (basse conso)
      // Rouge pour normalized proche de 1, vert pour normalized proche de 0
      return Color.lerp(
        Colors.green, // Basse consommation
        Colors.red, // Haute consommation
        normalized,
      )!;
    }

      List<FlSpot> predictionSpot = [];
      if (nextMonthPrediction != null && filteredData.isNotEmpty) {
        predictionSpot = [
          FlSpot(filteredData.length.toDouble(), nextMonthPrediction!.monthlyConsumption)
        ];
    }

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
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {

                      if (touchedSpots.isEmpty) return [];

                      // 🔥 On prend UN seul spot
                      // priorité à la ligne principale (barIndex 0)
                      final touchedSpot = touchedSpots.reduce(
                            (a, b) => a.x > b.x ? a : b,
                      );

                      final index = touchedSpot.x.toInt();
                      final consumption = touchedSpot.y;

                      // 🔥 POINT PRÉDICTION
                      if (index >= filteredData.length) {
                        return [
                          LineTooltipItem(
                            'Prévision mois suivant\n'
                                '${consumption.toStringAsFixed(0)} kWh',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        ];
                      }

                      // 🔥 POINT NORMAL
                      final period = filteredData[index].key;
                      var parts = period.split('-');

                      final priceForMonth = kwhPricePerMonth[period];
                      final cost = priceForMonth != null ? consumption * priceForMonth : null;

                      String tooltipText =
                          '${formatMonthYear(period)} ${parts[0]}\n'
                          '${consumption.toStringAsFixed(0)} kWh';

                      if (priceForMonth != null) {
                        tooltipText += '\n${priceForMonth.toStringAsFixed(3)} €/kWh'
                            '\n${cost!.toStringAsFixed(2)} €';
                      } else {
                        tooltipText += '\nPrix kWh: N/A';
                      }

                      return [
                        LineTooltipItem(
                          tooltipText,
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      ];
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
                      interval: null,
                      reservedSize: 50,
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
                maxX: predictionSpot.isNotEmpty
                    ? filteredData.length.toDouble()
                    : (filteredData.length - 1).toDouble(),
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
                      color: const Color(0xFF1E3A5F).withOpacity(0.1),
                    ),
                  ),
                  if (predictionSpot.isNotEmpty)
                    LineChartBarData(
                      spots: predictionSpot,
                      isCurved: true,
                      dashArray: [6, 4], // ligne en pointillés
                      color: Colors.orange,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
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
                        labelText: 'Consommation (kWh)',
                        border: OutlineInputBorder(),
                        suffixText: 'kWh',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: pricePerKwhController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Prix du kWh',
                        border: OutlineInputBorder(),
                        suffixText: '€/kWh',
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

  Future<void> _addConsumption() async {
    if (consumptionController.text.isEmpty || pricePerKwhController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une consommation et un prix du kWh')),
      );
      return;
    }

    final consumption = double.tryParse(
      consumptionController.text.replaceAll(',', '.'),
    );
    final pricePerKwh = double.tryParse(
      pricePerKwhController.text.replaceAll(',', '.'),
    );

    if (consumption == null || pricePerKwh == null || pricePerKwh <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valeurs invalides')),
      );
      return;
    }

    String monthStr = selectedMonth.toString().padLeft(2, '0');
    String key = '$selectedYear-$monthStr';

    setState(() {
      consumptionData[key] = consumption;
      kwhPricePerMonth[key] = pricePerKwh;
    });

    await _saveConsumptionData();
    await _saveKwhPricesPerMonth();

    _saveKwhPricesPerMonth();

    consumptionController.clear();
    pricePerKwhController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Consommation ajoutée pour $key')),
    );
  }

  Future<void> _saveConsumptionData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(consumptionData);
    await prefs.setString('consumption_data', jsonString);
  }

  Widget _buildStatsCards() {
    var filteredData = getFilteredData();
    if (filteredData.isEmpty) return const SizedBox();

    var values = filteredData.map((e) => e.value).toList();
    double average = values.reduce((a, b) => a + b) / values.length;
    double max = values.reduce((a, b) => a > b ? a : b);
    double current = values.last;

    // Calcul du pourcentage de variation par rapport à la moyenne
    double variationPercent = ((current - average) / average) * 100;
    String lastPeriod = filteredData.last.key;
    var parts = lastPeriod.split('-');
    String lastMonthFormatted = '${formatMonthYear(lastPeriod)} ${parts[0]}';
    bool isIncrease = variationPercent > 0;
    Color variationColor = isIncrease ? Colors.red : Colors.green;
    String variationText = '${isIncrease ? '+' : ''}${variationPercent.toStringAsFixed(1)}%';
    IconData variationIcon = isIncrease ? Icons.trending_up : Icons.trending_down;

    return Column(
      children: [
        // Cadre unique pour les statistiques
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Consommation moyenne
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Consommation moyenne',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${average.toStringAsFixed(0)} kWh',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey.withOpacity(0.3)),
              const SizedBox(height: 12),

              // Consommation maximale
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Consommation maximale',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${max.toStringAsFixed(0)} kWh',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey.withOpacity(0.3)),
              const SizedBox(height: 12),

              // Consommation pour le mois X avec la valeur
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Consommation pour $lastMonthFormatted',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${current.toStringAsFixed(0)} kWh',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Petit espacement sans divider

              // Variation par rapport à la période (même row, sans séparation)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Par rapport au reste de la période',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(
                        variationIcon,
                        color: variationColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        variationText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: variationColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Texte augmentation/diminution aligné à droite
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    isIncrease ? 'Augmentation' : 'Diminution',
                    style: TextStyle(
                      fontSize: 11,
                      color: variationColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }




  Widget _buildVariationCard(String title, String value, Color color, IconData icon, bool isIncrease) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isIncrease ? 'Augmentation' : 'Diminution',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
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
