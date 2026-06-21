import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/models/sensor_model.dart';
import 'package:aquaponic/widgets/gradient_background.dart';

class SensorDetailScreen extends StatefulWidget {
  final Kolam kolam;

  const SensorDetailScreen({super.key, required this.kolam});

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  String _selectedSuhuPeriod = 'Jam';
  String _selectedPHPeriod = 'Jam';
  final List<String> _periods = ['Menit', 'Jam', 'Hari', 'Minggu', 'Bulan'];

  @override
  Widget build(BuildContext context) {
    final k = widget.kolam;

    return GradientBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kembali',
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.file_download_outlined, color: AppColors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: AppColors.white), onPressed: () {}),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    k.name,
                    style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                _buildStatusBadge(k.overallStatus),
              ],
            ),
            const SizedBox(height: 32),
            _buildChartCard(
              title: 'Suhu',
              value: '${k.sensorData.suhu.toStringAsFixed(1)}° C',
              icon: Icons.thermostat,
              iconColor: Colors.redAccent,
              status: k.sensorData.suhuStatus,
              history: k.sensorData.suhuHistory,
              selectedPeriod: _selectedSuhuPeriod,
              onPeriodChanged: (p) => setState(() => _selectedSuhuPeriod = p),
              lineColor: Colors.purpleAccent,
              fillColor: Colors.purpleAccent.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            _buildChartCard(
              title: 'pH',
              value: k.sensorData.pH.toStringAsFixed(2),
              icon: Icons.science,
              iconColor: Colors.blueAccent,
              status: k.sensorData.pHStatus,
              history: k.sensorData.pHHistory,
              selectedPeriod: _selectedPHPeriod,
              onPeriodChanged: (p) => setState(() => _selectedPHPeriod = p),
              lineColor: Colors.blue,
              fillColor: Colors.blue.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SensorStatus status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case SensorStatus.baik: color = AppColors.statusGood; text = 'Baik'; icon = Icons.check_circle; break;
      case SensorStatus.peringatan: color = AppColors.statusWarning; text = 'Peringatan'; icon = Icons.warning; break;
      case SensorStatus.bahaya: color = AppColors.statusDanger; text = 'Bahaya'; icon = Icons.error; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required SensorStatus status,
    required List<SensorReading> history,
    required String selectedPeriod,
    required ValueChanged<String> onPeriodChanged,
    required Color lineColor,
    required Color fillColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 8),
                  Text(title, style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
              Row(
                children: [
                  if (status == SensorStatus.baik) const Icon(Icons.check_circle, color: AppColors.statusGood, size: 20),
                  const SizedBox(width: 8),
                  Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, meta) => Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('${v.toInt()}:00', style: const TextStyle(fontSize: 10, color: Colors.grey))))),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(1), style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: history.length.toDouble() - 1,
                minY: history.map((e) => e.value).reduce((a, b) => a < b ? a : b) - 2,
                maxY: history.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 2,
                lineBarsData: [
                  LineChartBarData(
                    spots: history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: fillColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _periods.map((p) => _buildPeriodChip(p, p == selectedPeriod, () => onPeriodChanged(p))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? AppColors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
