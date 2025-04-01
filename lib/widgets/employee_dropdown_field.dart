import 'package:flutter/material.dart';
import 'package:personal_expert/models/employee_model.dart';
import 'package:personal_expert/service/employee_service.dart';

class EmployeeDropdownField extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const EmployeeDropdownField({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<EmployeeDropdownField> createState() => _EmployeeDropdownFieldState();
}

class _EmployeeDropdownFieldState extends State<EmployeeDropdownField> {
  final EmployeeService _employeeService = EmployeeService();
  List<Employee> _employees = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final employees = await _employeeService.getAllEmployees();
      
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки сотрудников: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_error != null) {
      return Text(_error!, style: const TextStyle(color: Colors.red));
    }

    return DropdownButtonFormField<String>(
      value: widget.value,
      decoration: const InputDecoration(
        labelText: 'Сотрудник',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: _employees.map((employee) {
        return DropdownMenuItem<String>(
          value: employee.id,
          child: Text('${employee.firstName} ${employee.lastName}'),
        );
      }).toList(),
      onChanged: widget.onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Пожалуйста, выберите сотрудника';
        }
        return null;
      },
    );
  }
}