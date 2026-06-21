import 'package:flutter/material.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/core/constants/app_text_styles.dart';
import 'package:aquaponic/routes/app_routes.dart';
import 'package:aquaponic/widgets/sensor_card.dart';
import 'package:aquaponic/widgets/gradient_background.dart';
import 'package:aquaponic/data/dummy_data.dart';

class SensorMainScreen extends StatelessWidget {
  const SensorMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kolamList = DummyData.kolamList;

    return Scaffold(
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
                          // Handle menu actions
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
            ),
          ),
        ],
      ),
    );
  }
}
