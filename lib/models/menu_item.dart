import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}

final List<MenuItem> menuItems = [
  MenuItem(
    title: 'Reimbursement',
    icon: Icons.receipt_long,
    color: Colors.teal,
  ),
  MenuItem(
    title: 'Daftar Absensi',
    icon: Icons.assignment,
    color: Colors.orange,
  ),
  MenuItem(
    title: 'Kalender',
    icon: Icons.calendar_today,
    color: Colors.blue,
  ),
  MenuItem(
    title: 'Slip Gaji',
    icon: Icons.attach_money,
    color: Colors.green,
  ),
  MenuItem(
    title: 'Cuti',
    icon: Icons.access_time,
    color: Colors.blue,
  ),
  MenuItem(
    title: 'Absen',
    icon: Icons.location_on,
    color: Colors.orange,
  ),
  MenuItem(
    title: 'Lembur',
    icon: Icons.timer,
    color: Colors.orange,
  ),
  MenuItem(
    title: 'File saya',
    icon: Icons.folder,
    color: Colors.amber,
  ),
];
