import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/services/device_service.dart';
import 'package:aquaponic/widgets/gradient_background.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = DeviceService.getNotifications(limit: 50);
  }

  void _refresh() {
    setState(() {
      _future = DeviceService.getNotifications(limit: 50);
    });
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      return DateFormat('d MMM HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Color _severityColor(String? severity) {
    switch (severity) {
      case 'danger':
      case 'error':
        return AppColors.statusDanger;
      case 'warning':
        return AppColors.statusWarning;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _severityIcon(String? severity) {
    switch (severity) {
      case 'danger':
      case 'error':
        return Icons.error_rounded;
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _actionLabel(String? action) {
    if (action == null) return 'Peristiwa';
    if (action.contains('offline')) return 'Perangkat Offline';
    if (action.contains('temp') || action.contains('temperature')) return 'Suhu Tidak Normal';
    if (action.contains('ph')) return 'pH Tidak Normal';
    if (action.contains('login_failed')) return 'Percobaan Login Gagal';
    if (action.contains('api_key')) return 'Kunci API Tidak Valid';
    return action.replaceAll('_', ' ').replaceAll('.', ' › ');
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifikasi',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh, color: AppColors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi_off, size: 48, color: AppColors.textHint),
                              const SizedBox(height: 16),
                              Text(
                                'Gagal memuat notifikasi',
                                style: GoogleFonts.poppins(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              TextButton(onPressed: _refresh, child: const Text('Coba lagi')),
                            ],
                          ),
                        ),
                      );
                    }

                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.notifications_none, size: 64, color: AppColors.textHint),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada notifikasi',
                              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Semua sistem berjalan normal',
                              style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final severity = item['severity'] as String?;
                        final color = _severityColor(severity);
                        final timeStr = _formatTime(item['created_at'] as String?);
                        final label = _actionLabel(item['action'] as String?);
                        final targetId = item['target_id'] as String?;
                        final meta = item['metadata'] as Map<String, dynamic>?;

                        String subtitle = '';
                        if (targetId != null) subtitle += targetId;
                        if (meta != null && meta['detail'] != null) {
                          subtitle += (subtitle.isNotEmpty ? ' — ' : '') + meta['detail'].toString();
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_severityIcon(severity), color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            label,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          timeStr,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: AppColors.textHint,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (subtitle.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        subtitle,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
