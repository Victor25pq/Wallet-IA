import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:login_app/data/mock_data.dart';
import 'package:login_app/models/finance_models.dart';
import 'package:login_app/widgets/transaction_list.dart';
import '../widgets/pie_chart_legend.dart';

// 1. Enum para representar los filtros de tiempo de forma segura.
enum TimeFilter { lastDay, last7Days, last30Days, last90Days, allTime }

// 2. Función auxiliar para obtener el texto que verá el usuario para cada filtro.
String getTextForTimeFilter(TimeFilter filter) {
  switch (filter) {
    case TimeFilter.lastDay:
      return 'Último día';
    case TimeFilter.last7Days:
      return 'Últimos 7 días';
    case TimeFilter.last30Days:
      return 'Últimos 30 días';
    case TimeFilter.last90Days:
      return 'Últimos 90 días';
    case TimeFilter.allTime:
      return 'Desde siempre';
  }
}

// ... (los imports y el enum que definimos arriba)

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  String? _selectedCategoryTitle;
  String? _selectedAccountId;
  TimeFilter _selectedTimeFilter = TimeFilter.allTime;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE FILTRADO ---
    final List<Transaction> filteredTransactions = mockTransactions.where((
      transaction,
    ) {
      final accountFilterPassed =
          _selectedAccountId == null ||
          transaction.walletId == _selectedAccountId;
      if (!accountFilterPassed) return false;

      if (_selectedTimeFilter != TimeFilter.allTime) {
        final now = DateTime.now();
        DateTime startDate;
        switch (_selectedTimeFilter) {
          case TimeFilter.last7Days:
            startDate = now.subtract(const Duration(days: 7));
            break;
          case TimeFilter.last30Days:
            startDate = now.subtract(const Duration(days: 30));
            break;
          case TimeFilter.last90Days:
            startDate = now.subtract(const Duration(days: 90));
            break;
          default:
            startDate = DateTime(0);
        }
        if (transaction.date.isBefore(startDate)) return false;
      }

      if (_selectedCategoryTitle != null) {
        final category = mockCategories.firstWhere(
          (cat) => cat.title == _selectedCategoryTitle,
        );
        if (transaction.categoryId != category.id) return false;
      }

      return true;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      // 1. AÑADIMOS EL COLOR DE FONDO A TODA LA PANTALLA
      backgroundColor: Colors.blue[80], // Un azul muy claro y suave
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Mantenemos el AppBar transparente
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 2. PRIMER CONTENEDOR: GRÁFICOS
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Estadísticas",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    DropdownButton<TimeFilter>(
                      value: _selectedTimeFilter,
                      underline: const SizedBox(),
                      onChanged: (newValue) =>
                          setState(() => _selectedTimeFilter = newValue!),
                      items: TimeFilter.values
                          .map(
                            (filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(getTextForTimeFilter(filter)),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 220,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPageIndex = index),
                    children: [
                      _buildBalanceChart(filteredTransactions),
                      _buildPieChartAndLegend(filteredTransactions),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 2.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPageIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. SEGUNDO CONTENEDOR: HISTORIAL DE TRANSACCIONES
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historial de Transacciones',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TransactionList(transactions: filteredTransactions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceChart(List<Transaction> transactions) {
    // Llama a la función que prepara los datos y los envuelve en el widget
    return LineChart(_buildBalanceChartData(transactions));
  }

  // La función del gráfico no necesita cambios

  LineChartData _buildBalanceChartData(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return LineChartData();
    }

    final transactionsOldestToNewest = transactions.reversed.toList();
    double cumulativeAmount = 0.0;
    final List<FlSpot> spots = [];

    for (int i = 0; i < transactionsOldestToNewest.length; i++) {
      final transaction = transactionsOldestToNewest[i];
      if (transaction.status == TransactionStatus.Ingreso) {
        cumulativeAmount += transaction.amount;
      } else {
        cumulativeAmount -= transaction.amount;
      }
      spots.add(FlSpot(i.toDouble(), cumulativeAmount));
    }

    return LineChartData(
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),

      // --- INICIO DE LA NUEVA CONFIGURACIÓN DE TÍTULOS ---
      titlesData: FlTitlesData(
        // Ocultamos los títulos de los otros ejes para un look limpio
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

        // Configuramos los títulos del eje inferior (eje X)
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true, // ¡Mostramos los títulos!
            reservedSize: 22, // Espacio reservado para los títulos
            // Calculamos un intervalo para no sobrecargar el eje con fechas
            interval: transactionsOldestToNewest.length > 8
                ? (transactionsOldestToNewest.length / 4).floorToDouble()
                : 1,

            // Esta función construye el widget para cada título
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              // Nos aseguramos de que el índice esté dentro de los límites de la lista
              if (index < 0 || index >= transactionsOldestToNewest.length) {
                return const SizedBox();
              }

              // Obtenemos la fecha y la formateamos
              final date = transactionsOldestToNewest[index].date;
              final formattedDate = DateFormat('dd MMM').format(date);

              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4, // Espacio desde el eje
                child: Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),

      // --- FIN DE LA NUEVA CONFIGURACIÓN DE TÍTULOS ---
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.green,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.green.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartAndLegend(List<Transaction> transactions) {
    final expenses = transactions.where(
      (tx) => tx.status == TransactionStatus.Gasto,
    );
    if (expenses.isEmpty) {
      return const Center(child: Text('No hay gastos en este período.'));
    }

    final Map<String, double> categoryTotals = {};
    for (var tx in expenses) {
      categoryTotals.update(
        tx.categoryId,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    final double totalExpenses = expenses.fold(0, (sum, e) => sum + e.amount);
    final maxEntry = categoryTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              sections: categoryTotals.entries.map((entry) {
                final category = mockCategories.firstWhere(
                  (cat) => cat.id == entry.key,
                );
                final isMax = entry.key == maxEntry.key;
                final isSelected = category.title == _selectedCategoryTitle;
                return PieChartSectionData(
                  value: entry.value,
                  title: '',
                  radius: isSelected ? 25 : (isMax ? 25 : 20),
                  color: _getColorForCategory(category.title),
                );
              }).toList(),
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  setState(() {
                    // --- LA CORRECCIÓN ESTÁ AQUÍ ---
                    if (event is FlTapUpEvent) {
                      // 1. Guardamos la sección tocada en una variable local
                      final touchedSection = pieTouchResponse?.touchedSection;

                      // 2. Comprobamos si esa variable local no es nula
                      if (touchedSection != null) {
                        // 3. Ahora podemos acceder a sus propiedades de forma segura
                        final index = touchedSection.touchedSectionIndex;
                        final tappedCategoryId = categoryTotals.keys.elementAt(
                          index,
                        );
                        final tappedCategory = mockCategories.firstWhere(
                          (cat) => cat.id == tappedCategoryId,
                        );

                        _selectedCategoryTitle =
                            (_selectedCategoryTitle == tappedCategory.title)
                            ? null
                            : tappedCategory.title;
                      }
                    }
                  });
                },
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: PieChartLegend(
            categoryTotals: categoryTotals,
            totalExpenses: totalExpenses,
            onCategorySelected: (categoryTitle) {
              setState(
                () => _selectedCategoryTitle =
                    (_selectedCategoryTitle == categoryTitle)
                    ? null
                    : categoryTitle,
              );
            },
            selectedCategoryTitle: _selectedCategoryTitle,
          ),
        ),
      ],
    );
  }

  Color _getColorForCategory(String title) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[title.hashCode % colors.length];
  }
}
