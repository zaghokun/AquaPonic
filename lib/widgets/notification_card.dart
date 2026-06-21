import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationData notification;

  const NotificationCard({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    Color iconBgColor;
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.warning:
        iconBgColor = AppColors.statusWarning.withValues(alpha: 0.1);
        iconColor = AppColors.statusWarning;
        iconData = Icons.warning_rounded;
        break;
      case NotificationType.danger:
        iconBgColor = AppColors.statusDanger.withValues(alpha: 0.1);
        iconColor = AppColors.statusDanger;
        iconData = Icons.error_rounded;
        break;
      case NotificationType.info:
        iconBgColor = AppColors.primaryBlue.withValues(alpha: 0.1);
        iconColor = AppColors.primaryBlue;
        iconData = Icons.info_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: notification.isRead ? null : Border.all(color: AppColors.primaryBlue, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      notification.time,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
