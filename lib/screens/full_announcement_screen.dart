import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../widgets/appbar_widget.dart';
import 'announcement_screen.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  late Future<List<Announcement>> _announcementsFuture;

  @override
  // void initState() {
  //   super.initState();
  //   _announcementsFuture = AnnouncementService().getAnnouncements();
  //   //  final data = await AnnouncementService().getAnnouncements();
  //   // setState(() {
  //   //   announcements = data..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  //   //   announcements = announcements.take(3).toList();
  //   //   isLoading = false;
  //   // });
  // }
  @override
  void initState() {
    super.initState();
    _announcementsFuture =
        AnnouncementService().getAnnouncements().then((data) {
      data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return data;
    });
  }

  String truncateHtmlString(String htmlString, int maxLength) {
    String plainText = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    if (plainText.length <= maxLength) return htmlString;
    String truncated = plainText.substring(0, maxLength);
    return '<p>$truncated...</p>';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Announcements'),
      body: FutureBuilder<List<Announcement>>(
        future: _announcementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No announcements available"));
          }

          final announcements = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnnouncementDetailScreen(
                            announcement: announcement),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster Image
                      if (announcement.poster.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 180,
                            child: Image.network(
                              'https://7928-36-77-243-75.ngrok-free.app/storage/${announcement.poster}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      // Content Container
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              announcement.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),

                            // Date
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                DateFormat('dd MMMM yyyy, HH:mm')
                                    .format(announcement.createdAt),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),

                            // Divider
                            Divider(color: Colors.grey[300]),

                            // Body with truncation
                            Html(
                              data: truncateHtmlString(announcement.body, 200),
                              style: {
                                "p": Style(
                                  fontSize: FontSize(15),
                                  color: const Color(0xFF666666),
                                  lineHeight: LineHeight.em(1.4),
                                  margin: Margins.zero,
                                ),
                                "ol": Style(
                                  margin: Margins.only(left: 8.0),
                                ),
                                "li": Style(
                                  margin: Margins.only(bottom: 4.0),
                                ),
                              },
                            ),
                            // Read more
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AnnouncementDetailScreen(
                                              announcement: announcement),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.arrow_forward, size: 18),
                                label: const Text('Read more'),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
