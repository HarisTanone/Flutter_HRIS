import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/overtime_model.dart';
import '../services/overtime_service.dart';
import '../widgets/appbar_widget.dart';

class OvertimeScreen extends StatefulWidget {
  final int employeeId;

  const OvertimeScreen({super.key, required this.employeeId});

  @override
  _OvertimeScreenState createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = OvertimeService();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _endTime = TimeOfDay.now();
  final _reasonController = TextEditingController();
  List<OvertimeModel> _overtimes = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadOvertimes();
  }

  Future<void> _loadOvertimes() async {
    setState(() => _isLoading = true);
    try {
      final overtimes =
          await _service.getOvertimesByEmployee(widget.employeeId);
      setState(() {
        _overtimes = overtimes..sort((a, b) => b.date.compareTo(a.date));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading overtimes: $e',
            style: const TextStyle(color: Colors.white), // Warna teks
          ),
          backgroundColor: Colors.red, // Warna latar belakang
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitOvertime() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final overtime = OvertimeModel(
          employeeId: widget.employeeId,
          date: DateFormat('yyyy-MM-dd').format(_selectedDate),
          startTime:
              '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:00',
          endTime:
              '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}:00',
          reason: _reasonController.text,
        );

        await _service.createOvertime(overtime);
        _reasonController.clear();
        await _loadOvertimes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Overtime request submitted successfully',
              style: TextStyle(color: Colors.white), // Warna teks
            ),
            backgroundColor: Colors.green, // Warna latar belakang
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error submitting overtime: $e',
              style: const TextStyle(color: Colors.white), // Warna teks
            ),
            backgroundColor: Colors.red, // Warna latar belakang
          ),
        );
      }
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    switch (status) {
      case 'Menunggu':
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case 'Disetujui':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'Ditolak':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }
    return Icon(icon, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Overtime'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOvertimes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Request Overtime',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                InkWell(
                                  onTap: _selectDate,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Date',
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(DateFormat('dd MMM yyyy')
                                        .format(_selectedDate)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _selectTime(true),
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                            labelText: 'Start Time',
                                            border: OutlineInputBorder(),
                                          ),
                                          child:
                                              Text(_startTime.format(context)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _selectTime(false),
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                            labelText: 'End Time',
                                            border: OutlineInputBorder(),
                                          ),
                                          child: Text(_endTime.format(context)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _reasonController,
                                  decoration: const InputDecoration(
                                    labelText: 'Reason',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a reason';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isSubmitting ? null : _submitOvertime,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF900C0C),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : const Text(
                                            'Submit Request',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Recent Requests',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _overtimes.length,
                        itemBuilder: (context, index) {
                          final overtime = _overtimes[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM yyyy').format(
                                            DateTime.parse(overtime.date)),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      _buildStatusIcon(overtime.status),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${overtime.startTime.substring(0, 5)} - ${overtime.endTime.substring(0, 5)}',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                      Text(
                                        '${overtime.totalHours} hours',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  Text(overtime.reason),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
