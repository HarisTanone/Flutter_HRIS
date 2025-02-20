import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/employee_service.dart';
import '../widgets/appbar_widget.dart';

class EmployeeBirthday {
  final String name;
  final DateTime birthDate;

  EmployeeBirthday(this.name, this.birthDate);

  int getAge() {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

class BirthdayCalendar extends StatefulWidget {
  const BirthdayCalendar({super.key});

  @override
  _BirthdayCalendarState createState() => _BirthdayCalendarState();
}

class _BirthdayCalendarState extends State<BirthdayCalendar> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<EmployeeBirthday>> _birthdayEvents = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadBirthdays();
  }

  Future<void> _loadBirthdays() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final employeeResponse = await EmployeeService().getEmployees();

      final birthdays = employeeResponse.data.map((employee) {
        return EmployeeBirthday(
          employee.fullName,
          DateTime.parse(employee.birthdate),
        );
      }).toList();

      _initializeBirthdayEvents(birthdays);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat data: $e';
      });
    }
  }

  void _initializeBirthdayEvents(List<EmployeeBirthday> birthdays) {
    _birthdayEvents = {};
    for (var birthday in birthdays) {
      final thisYearBirthday = DateTime(
        DateTime.now().year,
        birthday.birthDate.month,
        birthday.birthDate.day,
      );

      _birthdayEvents[thisYearBirthday] =
          (_birthdayEvents[thisYearBirthday] ?? [])..add(birthday);
    }
  }

  List<EmployeeBirthday> _getEventsForDay(DateTime day) {
    return _birthdayEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _showBirthdayDialog(List<EmployeeBirthday> birthdays) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ulang Tahun Hari Ini'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: birthdays.map((birthday) {
              return ListTile(
                title: Text(birthday.name),
                subtitle: Text('Usia: ${birthday.getAge()} tahun'),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Calendar',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBirthdays,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Card(
                  margin: const EdgeInsets.all(8.0),
                  child: TableCalendar(
                    locale: 'id_ID',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      final events = _getEventsForDay(selectedDay);
                      if (events.isNotEmpty) {
                        _showBirthdayDialog(events);
                      }
                    },
                    eventLoader: _getEventsForDay,
                    calendarStyle: CalendarStyle(
                      markerDecoration: const BoxDecoration(
                        color: Color(0xFF900C0C), // Warna untuk ulang tahun
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.blue.shade300,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                    ),
                  ),
                ),
    );
  }
}
