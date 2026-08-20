import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final int id;
  final String title;
  final String body;
  final String time;
  final bool isDark;
  final bool isRead;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.isDark,
    required this.isRead,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isRead
              ? (isDark ? Colors.white.withOpacity(.05) : Colors.white)
              : (isDark ? Colors.white.withOpacity(.10) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? (isDark
                      ? Colors.white.withOpacity(.06)
                      : Colors.black.withOpacity(.05))
                : Colors.red.withOpacity(.25),
            width: isRead ? 1 : 1.2,
          ),
          boxShadow: [
            if (!isRead)
              BoxShadow(
                color: Colors.red.withOpacity(.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // ICON
            // =====================================================
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isRead
                        ? (isDark
                              ? Colors.white.withOpacity(.08)
                              : Colors.grey.withOpacity(.12))
                        : Colors.red.withOpacity(.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRead
                        ? Icons.notifications_none_rounded
                        : Icons.notifications_active_rounded,
                    color: isRead
                        ? (isDark ? Colors.white54 : Colors.grey)
                        : Colors.red,
                    size: 24,
                  ),
                ),

                // 🔴 نقطة الإشعار غير المقروء
                if (!isRead)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.black : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 13),

            // =====================================================
            // CONTENT
            // =====================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),

                      if (!isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  // BODY
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // TIME
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ),

                      const Spacer(),

                      if (!isRead)
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Unread',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
