import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

import '../models/announcement_model.dart';
import '../widgets/appbar_widget.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: announcement.title),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (announcement.poster.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://7928-36-77-243-75.ngrok-free.app/storage/${announcement.poster}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                announcement.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(announcement.createdAt),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Html(
                data: announcement.body,
                style: {
                  "p": Style(
                    fontSize: FontSize(16),
                    lineHeight: LineHeight.em(1.5),
                  ),
                  "ol": Style(
                    margin: Margins.zero,
                  ),
                  "li": Style(
                    margin: Margins.zero,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
