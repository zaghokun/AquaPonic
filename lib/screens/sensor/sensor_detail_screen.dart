import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/models/sensor_model.dart';
import 'package:aquaponic/widgets/gradient_background.dart';
import 'package:aquaponic/services/device_service.dart';

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

  // Data grafik terpisah untuk Suhu dan pH
  List<Map<String, dynamic>> _suhuSeriesData = [];
  List<Map<String, dynamic>> _phSeriesData = [];
  bool _isSuhuLoading = true;
  bool _isPhLoading = true;
  String? _suhuError;
  String? _phError;

  @override
  void initState() {
    super.initState();
    _loadSuhuSeries('hour');
    _loadPhSeries('hour');
  }

  String _periodToBucket(String period) {
    switch (period) {
      case 'Menit': return 'minute';
      case 'Jam': return 'hour';
      case 'Hari': return 'day';
      case 'Minggu': return 'day';
      case 'Bulan': return 'month';
      default: return 'hour';
    }
  }

  String? _periodToFrom(String bucket) {
    final now = DateTime.now().toUtc();
    switch (bucket) {
      case 'minute': return now.subtract(const Duration(hours: 1)).toIso8601String();
      case 'hour': return now.subtract(const Duration(hours: 24)).toIso8601String();
      case 'day': return now.subtract(const Duration(days: 7)).toIso8601String();
      case 'month': return now.subtract(const Duration(days: 365)).toIso8601String();
      default: return null;
    }
  }

  Future<void> _loadSuhuSeries(String bucket) async {
    setState(() { _isSuhuLoading = true; _suhuError = null; });
    try {
      final from = _periodToFrom(bucket);
      final data = await DeviceService.getDeviceSeries(
        widget.kolam.id,
        bucket: bucket,
        from: from,
        to: DateTime.now().toUtc().toIso8601String(),
      );
      setState(() { _suhuSeriesData = data; _isSuhuLoading = false; });
    } catch (e) {
      setState(() { _suhuError = 'Gagal memuat data grafik'; _isSuhuLoading = false; });
    }
  }

  Future<void> _loadPhSeries(String bucket) async {
    setState(() { _isPhLoading = true; _phError = null; });
    try {
      final from = _periodToFrom(bucket);
      final data = await DeviceService.getDeviceSeries(
        widget.kolam.id,
        bucket: bucket,
        from: from,
        to: DateTime.now().toUtc().toIso8601String(),
      );
      setState(() { _phSeriesData = data; _isPhLoading = false; });
    } catch (e) {
      setState(() { _phError = 'Gagal memuat data grafik'; _isPhLoading = false; });
    }
  }

  Future<void> _exportCsv() async {
    final exportData = _suhuSeriesData.isNotEmpty ? _suhuSeriesData : _phSeriesData;
    if (exportData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diexport')),
      );
      return;
    }
    try {
      final header = "Waktu,Suhu (C),pH\n";
      final rows = exportData.map((d) {
        final t = d['t'] ?? '';
        final temp = d['temp_avg'] ?? '';
        final ph = d['ph_avg'] ?? '';
        return "$t,$temp,$ph";
      }).join("\n");
      final csvData = header + rows;

      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/sensor_${widget.kolam.id}_$dateStr.csv');
      await file.writeAsString(csvData);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Export Data Sensor ${widget.kolam.name}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export data: $e')),
        );
      }
    }
  }

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
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.white),
            onPressed: _exportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      k.name,
                      style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
              dataKey: 'temp_avg',
              seriesData: _suhuSeriesData,
              isLoading: _isSuhuLoading,
              error: _suhuError,
              selectedPeriod: _selectedSuhuPeriod,
              onPeriodChanged: (p) {
                setState(() => _selectedSuhuPeriod = p);
                _loadSuhuSeries(_periodToBucket(p));
              },
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
              dataKey: 'ph_avg',
              seriesData: _phSeriesData,
              isLoading: _isPhLoading,
              error: _phError,
              selectedPeriod: _selectedPHPeriod,
              onPeriodChanged: (p) {
                setState(() => _selectedPHPeriod = p);
                _loadPhSeries(_periodToBucket(p));
              },
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
    required String dataKey,
    required List<Map<String, dynamic>> seriesData,
    required bool isLoading,
    required String? error,
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text(error, style: GoogleFonts.poppins(color: AppColors.textSecondary)))
                    : seriesData.isEmpty
                        ? Center(child: Text('Belum ada data', style: GoogleFonts.poppins(color: AppColors.textSecondary)))
                        : _buildLineChart(dataKey, lineColor, fillColor, selectedPeriod, seriesData),
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

  Widget _buildLineChart(String dataKey, Color lineColor, Color fillColor, String selectedPeriod, List<Map<String, dynamic>> seriesData) {
    final spots = <FlSpot>[];
    for (int i = 0; i < seriesData.length; i++) {
      final val = (seriesData[i][dataKey] as num?)?.toDouble();
      if (val != null) {
        spots.add(FlSpot(i.toDouble(), val));
      }
    }

    if (spots.isEmpty) {
      return Center(child: Text('Belum ada data', style: GoogleFonts.poppins(color: AppColors.textSecondary)));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (spots.length / 6).ceilToDouble().clamp(1, double.infinity),
            getTitlesWidget: (v, meta) {
              final idx = v.toInt();
              if (idx < 0 || idx >= seriesData.length) return const SizedBox.shrink();
              final t = seriesData[idx]['t'] ?? '';
              String timePart = '$idx';
              if (t is String && t.isNotEmpty) {
                try {
                  final dt = DateTime.parse(t).toLocal();
                  if (selectedPeriod == 'Menit' || selectedPeriod == 'Jam') {
                    timePart = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  } else {
                    timePart = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
                  }
                } catch (_) {}
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(timePart, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
              );
            },
          )),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(1), style: const TextStyle(fontSize: 10, color: Colors.grey)))),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: spots.length.toDouble() - 1,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: fillColor,
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

  // ─── PENGATURAN SENSOR (SETTINGS DIALOG) ───────────────────────────
  void _showSettingsDialog(BuildContext context) {
    final k = widget.kolam;
    final nameController = TextEditingController(text: k.name);

    final tempMinCtrl = TextEditingController(text: '25.0');
    final tempMaxCtrl = TextEditingController(text: '32.0');
    final phMinCtrl = TextEditingController(text: '6.5');
    final phMaxCtrl = TextEditingController(text: '8.5');

    // Load threshold aktual dari API
    DeviceService.getThresholds().then((thresholds) {
      for (final t in thresholds) {
        if (t['device'] == k.id) {
          if (mounted) {
            tempMinCtrl.text = (t['temp_min'] ?? 25.0).toString();
            tempMaxCtrl.text = (t['temp_max'] ?? 32.0).toString();
            phMinCtrl.text = (t['ph_min'] ?? 6.5).toString();
            phMaxCtrl.text = (t['ph_max'] ?? 8.5).toString();
            if (t['label'] != null) nameController.text = t['label'];
          }
          break;
        }
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Pengaturan Sensor', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('Perangkat: ${k.id}', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 20),

              // Nama sensor
              Text('Nama Sensor', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Kolam Lele',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Batas Suhu
              Text('Batas Suhu (°C)', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: tempMinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Min', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(
                    controller: tempMaxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Max', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  )),
                ],
              ),
              const SizedBox(height: 20),

              // Batas pH
              Text('Batas pH', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: phMinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Min', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(
                    controller: phMaxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Max', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  )),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _saveSettings(
                    ctx,
                    nameController.text.trim(),
                    double.tryParse(tempMinCtrl.text) ?? 25.0,
                    double.tryParse(tempMaxCtrl.text) ?? 32.0,
                    double.tryParse(phMinCtrl.text) ?? 6.5,
                    double.tryParse(phMaxCtrl.text) ?? 8.5,
                  ),
                  icon: const Icon(Icons.save, color: AppColors.white),
                  label: Text('Simpan Perubahan', style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Hapus Sensor
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(ctx),
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: Text('Hapus Sensor', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSettings(BuildContext ctx, String label, double tempMin, double tempMax, double phMin, double phMax) async {
    Navigator.pop(ctx);
    try {
      await DeviceService.updateDevice(
        widget.kolam.id,
        label: label,
        tempMin: tempMin,
        tempMax: tempMax,
        phMin: phMin,
        phMax: phMax,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengaturan sensor berhasil disimpan'),
            backgroundColor: AppColors.statusGood,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _confirmDelete(BuildContext sheetCtx) {
    showDialog(
      context: sheetCtx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text('Hapus Sensor', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda yakin ingin menghapus "${widget.kolam.name}" dari daftar sensor?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan Anda sudah mengunduh data CSV terlebih dahulu jika masih dibutuhkan. Data riwayat tidak akan dihapus dari server.',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              Navigator.pop(sheetCtx);
              await _deleteDevice();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Hapus', style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDevice() async {
    try {
      await DeviceService.deleteDevice(widget.kolam.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sensor "${widget.kolam.name}" berhasil dihapus'),
            backgroundColor: AppColors.statusGood,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus sensor: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
