import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsTab extends StatefulWidget {
  final dynamic eventoId;
  const StatsTab({super.key, required this.eventoId});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: const Color(0xFF00B2FF),
            child: const TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'Località'),
                Tab(text: 'Tipologia'),
                Tab(text: 'Gruppi'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildChartSection('localita', 'Località'),
            _buildChartSection('tipologia', 'Tipologia'),
            _buildChartSection('gruppo_nome', 'Gruppi'),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(String groupByField, String labelTitolo) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchChartDataWithCurrency(groupByField),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || (snapshot.data!['data'] as List).isEmpty) {
          return const Center(child: Text("Nessun dato disponibile"));
        }

        final data = snapshot.data!['data'] as List<Map<String, dynamic>>;
        final String valuta = snapshot.data!['valuta'] ?? '';
        const double labelSpace = 80; 

        // Calcolo del valore massimo e dell'intervallo per avere esattamente 5 linee
        final double maxValue = data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);
        final double chartMaxY = maxValue * 1.2;
        final double dynamicInterval = chartMaxY / 5;

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelTitolo,
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF00B2FF)
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: chartMaxY,
                      barGroups: _generateGroups(data),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade400, width: 1),
                          right: BorderSide(color: Colors.grey.shade400, width: 1),
                          left: BorderSide(color: Colors.transparent), 
                          top: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true, 
                        drawHorizontalLine: true, 
                        drawVerticalLine: false,
                        horizontalInterval: dynamicInterval,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: labelSpace, 
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < data.length) {
                                return RotatedBox(
                                  quarterTurns: 3,
                                  child: Container(
                                    width: labelSpace,
                                    alignment: Alignment.centerRight, 
                                    padding: const EdgeInsets.only(right: 8), 
                                    child: Text(
                                      data[index]['label'],
                                      style: const TextStyle(
                                        fontSize: 12, 
                                        fontWeight: FontWeight.bold
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: dynamicInterval, 
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              return RotatedBox(
                                quarterTurns: 3,
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    "Valuta: $valuta",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchChartDataWithCurrency(String field) async {
    final eventoRes = await _supabase.from('eventi').select('valuta_target').eq('id', widget.eventoId).single();
    final String valuta = eventoRes['valuta_target'] ?? '';

    var query;
    if (field == 'gruppo_nome') {
      query = _supabase.from('spese').select('importo, gruppi(gruppo)').eq('evento_id', widget.eventoId);
    } else {
      query = _supabase.from('spese').select('importo, $field').eq('evento_id', widget.eventoId);
    }

    final List<dynamic> res = await query;
    Map<String, double> totals = {};

    for (var spesa in res) {
      String key = 'N/D';
      if (field == 'gruppo_nome') {
        key = spesa['gruppi']?['gruppo']?.toString() ?? 'N/D';
      } else {
        key = spesa[field]?.toString() ?? 'N/D';
      }
      totals[key] = (totals[key] ?? 0) + (spesa['importo'] ?? 0).toDouble();
    }
    
    final formattedData = totals.entries.map((e) => {'label': e.key, 'value': e.value}).toList();
    
    return {
      'data': formattedData,
      'valuta': valuta
    };
  }

  List<BarChartGroupData> _generateGroups(List<Map<String, dynamic>> data) {
    return List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[i]['value'],
            color: const Color(0xFF00B2FF),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          )
        ],
      );
    });
  }
}