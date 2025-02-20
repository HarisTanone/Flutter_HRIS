import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/attendance_type.dart';
import '../models/time_off_request.dart';
import '../services/time_off_service.dart';
import '../widgets/appbar_widget.dart';

class TimeOffRequestScreen extends StatefulWidget {
  final int employeeId;

  const TimeOffRequestScreen({super.key, required this.employeeId});

  @override
  _TimeOffRequestScreenState createState() => _TimeOffRequestScreenState();
}

class _TimeOffRequestScreenState extends State<TimeOffRequestScreen> {
  final TimeOffService _service = TimeOffService();
  final _formKey = GlobalKey<FormState>();

  DateTime? _startDate;
  DateTime? _endDate;
  AttendanceType? _selectedType;
  String? _reason;
  String? _documentPath;
  String? _fileName;
  List<AttendanceType> _attendanceTypes = [];
  List<TimeOffRequest> _timeOffHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final types = await _service.getAttendanceTypes();
      final history = await _service.getEmployeeTimeOffs(widget.employeeId);
      setState(() {
        _attendanceTypes = types;
        _timeOffHistory = history;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load data: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _documentPath = result.files.single.path;
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error picking file: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_startDate == null ||
        _endDate == null ||
        _selectedType == null ||
        _reason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap lengkapi semua data sebelum mengajukan cuti',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF900C0C),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _service.createTimeOffRequest(
        employeeId: widget.employeeId,
        startDate: _startDate!,
        endDate: _endDate!,
        attendanceTypeId: _selectedType!.id,
        reason: _reason!,
        documentPath: _documentPath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Time off request submitted successfully')),
        );
      }
      setState(() {
        _selectedType = null;
      });

      // Wait a moment for the UI to update
      await Future.delayed(const Duration(milliseconds: 50));

      // Now fetch new data and reset other form fields
      final history = await _service.getEmployeeTimeOffs(widget.employeeId);

      if (mounted) {
        setState(() {
          _timeOffHistory = history;
          _startDate = null;
          _endDate = null;
          _reason = null;
          _documentPath = null;
          _fileName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit request: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Time Off'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'New Request',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<AttendanceType>(
                                key: ValueKey(_selectedType
                                    ?.id), // Add this key to force rebuild
                                value: _selectedType,
                                decoration: InputDecoration(
                                  labelText: 'Time Off Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                isExpanded: true,
                                hint: const Text('Select Time Off Type'),
                                items: _attendanceTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type.typeName,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedType = value);
                                },
                                validator: (value) {
                                  if (value == null)
                                    return 'Please select a type';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Start Date',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        suffixIcon:
                                            const Icon(Icons.calendar_today),
                                      ),
                                      readOnly: true,
                                      controller: TextEditingController(
                                        text: _startDate != null
                                            ? _formatDate(_startDate!)
                                            : '',
                                      ),
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                        );
                                        if (date != null) {
                                          setState(() => _startDate = date);
                                        }
                                      },
                                      validator: (value) {
                                        if (_startDate == null)
                                          return 'Required';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'End Date',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        suffixIcon:
                                            const Icon(Icons.calendar_today),
                                      ),
                                      readOnly: true,
                                      controller: TextEditingController(
                                        text: _endDate != null
                                            ? _formatDate(_endDate!)
                                            : '',
                                      ),
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _startDate ?? DateTime.now(),
                                          firstDate:
                                              _startDate ?? DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                        );
                                        if (date != null) {
                                          setState(() => _endDate = date);
                                        }
                                      },
                                      validator: (value) {
                                        if (_endDate == null) return 'Required';
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Reason',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 3,
                                onSaved: (value) => _reason = value,
                                validator: (value) {
                                  if (value?.isEmpty ?? true)
                                    return 'Please enter a reason';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _pickDocument,
                                icon: const Icon(Icons.attach_file),
                                label: Text(_fileName ?? 'Attach Document'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              if (_fileName != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _fileName!,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submitRequest,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF900C0C),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text(
                                          'Submit Request',
                                          style: TextStyle(color: Colors.white),
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
                      'Time Off History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _timeOffHistory.length,
                      itemBuilder: (context, index) {
                        final request = _timeOffHistory[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Baris pertama: Tanggal
                                Text(
                                  '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Baris kedua: Reason dan Icon Status
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Reason
                                    Text(
                                      request.reason,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    // Icon Status
                                    Icon(
                                      request.status == 'Disetujui'
                                          ? Icons.check_circle
                                          : request.status == 'Menunggu'
                                              ? Icons.access_time
                                              : Icons.cancel,
                                      color: request.status == 'Disetujui'
                                          ? Colors.green
                                          : request.status == 'Menunggu'
                                              ? Colors.orange
                                              : Colors.red,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24), // Bottom padding
                  ],
                ),
              ),
            ),
    );
  }
}
