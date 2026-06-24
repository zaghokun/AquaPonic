import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/core/constants/app_text_styles.dart';
import 'package:aquaponic/routes/app_routes.dart';
import 'package:aquaponic/widgets/sensor_card.dart';
import 'package:aquaponic/widgets/gradient_background.dart';
import 'package:aquaponic/models/sensor_model.dart';
import 'package:aquaponic/services/device_service.dart';

class SensorMainScreen extends StatefulWidget {
  const SensorMainScreen({super.key});

  @override
  State<SensorMainScreen> createState() => _SensorMainScreenState();
}

class _SensorMainScreenState extends State<SensorMainScreen> {
  late Future<List<Kolam>> _kolamFuture;

  @override
  void initState() {
    super.initState();
    _kolamFuture = _fetchDevices();
  }

  Future<List<Kolam>> _fetchDevices() async {
    final devices = await DeviceService.getDevices();
    return devices.map((d) => _mapDeviceToKolam(d)).toList();
  }

  /// Maps API response to the existing Kolam model.
  Kolam _mapDeviceToKolam(Map<String, dynamic> device) {
    final reading = device['reading'] as Map<String, dynamic>?;
    final threshold = device['threshold'] as Map<String, dynamic>?;

    final double suhu = (reading?['temperature'] as num?)?.toDouble() ?? 0.0;
    final double ph = (reading?['ph'] as num?)?.toDouble() ?? 0.0;

    // Determine status based on threshold
    final double phMin = (threshold?['ph_min'] as num?)?.toDouble() ?? 0;
    final double phMax = (threshold?['ph_max'] as num?)?.toDouble() ?? 14;
    final double tempMin = (threshold?['temp_min'] as num?)?.toDouble() ?? 0;
    final double tempMax = (threshold?['temp_max'] as num?)?.toDouble() ?? 50;

    SensorStatus suhuStatus = SensorStatus.baik;
    if (suhu < tempMin || suhu > tempMax) {
      suhuStatus = SensorStatus.bahaya;
    } else if ((suhu - tempMin) < 2 || (tempMax - suhu) < 2) {
      suhuStatus = SensorStatus.peringatan;
    }

    SensorStatus phStatus = SensorStatus.baik;
    if (ph < phMin || ph > phMax) {
      phStatus = SensorStatus.bahaya;
    } else if ((ph - phMin) < 0.5 || (phMax - ph) < 0.5) {
      phStatus = SensorStatus.peringatan;
    }

    // Determine overall status from API "status" field
    final String apiStatus = (device['status'] as String?) ?? 'offline';
    SensorStatus overallStatus;
    if (apiStatus == 'danger') {
      overallStatus = SensorStatus.bahaya;
    } else if (apiStatus == 'offline') {
      overallStatus = SensorStatus.peringatan;
    } else {
      overallStatus = (suhuStatus == SensorStatus.bahaya || phStatus == SensorStatus.bahaya)
          ? SensorStatus.bahaya
          : (suhuStatus == SensorStatus.peringatan || phStatus == SensorStatus.peringatan)
              ? SensorStatus.peringatan
              : SensorStatus.baik;
    }

    final String deviceId = device['device'] ?? 'unknown';
    final String label = device['label'] ?? deviceId;

    return Kolam(
      id: deviceId,
      name: label,
      controllerCode: deviceId.toUpperCase(),
      sensorData: SensorData(
        suhu: suhu,
        pH: ph,
        suhuStatus: suhuStatus,
        pHStatus: phStatus,
        suhuHistory: [],
        pHHistory: [],
      ),
      overallStatus: overallStatus,
    );
  }

  void _refresh() {
    setState(() {
      _kolamFuture = _fetchDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
          // Custom AppBar area
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sensor',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.addSensor);
                        },
                        icon: const Icon(Icons.add, size: 28),
                        color: AppColors.textPrimary,
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.textPrimary,
                          size: 28,
                        ),
                        onSelected: (value) {
                          if (value == 'refresh') _refresh();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'refresh',
                            child: Text('Segarkan'),
                          ),
                          const PopupMenuItem(
                            value: 'sort',
                            child: Text('Urutkan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Content with gradient background
          Expanded(
            child: GradientBackground(
              child: FutureBuilder<List<Kolam>>(
                future: _kolamFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.white),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, color: AppColors.white, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal memuat data sensor',
                            style: TextStyle(color: AppColors.white.withValues(alpha: 0.9), fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh, color: AppColors.white),
                            label: const Text('Coba Lagi', style: TextStyle(color: AppColors.white)),
                          ),
                        ],
                      ),
                    );
                  }

                  final kolamList = snapshot.data ?? [];

                  if (kolamList.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada perangkat yang terdeteksi.',
                        style: TextStyle(color: AppColors.white.withValues(alpha: 0.9)),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: kolamList.length,
                      itemBuilder: (context, index) {
                        final kolam = kolamList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SensorCard(
                            kolam: kolam,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.sensorDetail,
                                arguments: kolam,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
