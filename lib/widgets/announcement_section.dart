import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

import '../models/announcement_model.dart';
import '../screens/announcement_screen.dart';
import '../screens/full_announcement_screen.dart';
import '../services/announcement_service.dart';

class AnnouncementSection extends StatefulWidget {
  const AnnouncementSection({super.key});

  @override
  _AnnouncementSectionState createState() => _AnnouncementSectionState();
}

class _AnnouncementSectionState extends State<AnnouncementSection> {
  List<Announcement> announcements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    final data = await AnnouncementService().getAnnouncements();
    setState(() {
      announcements = data..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      announcements = announcements.take(3).toList();
      isLoading = false;
    });
  }

  String truncateText(String text, int maxLength) {
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengumuman',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnnouncementScreen(),
                    ),
                  );
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : announcements.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Text('Belum ada pengumuman',
                              style: TextStyle(color: Colors.black54)),
                          Text('Your announcement will show here',
                              style: TextStyle(
                                  color: Colors.black38, fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: announcements.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final announcement = announcements[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnnouncementDetailScreen(
                                    announcement: announcement),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.grey[50],
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    announcement.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd MMM yyyy, HH:mm')
                                        .format(announcement.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Html(
                                    data: truncateText(announcement.body, 100),
                                    style: {
                                      "p": Style(
                                        fontSize: FontSize(14),
                                        color: Colors.black54,
                                        lineHeight: LineHeight.em(1.4),
                                        margin: Margins.zero,
                                      ),
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
        ],
      ),
    );
  }
}
