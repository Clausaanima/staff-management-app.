import 'package:flutter/material.dart';
import 'package:personal_expert/models/employee_model.dart';
import 'package:personal_expert/service/employee_service.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({Key? key}) : super(key: key);

  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final EmployeeService _employeeService = EmployeeService();
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDepartment = 'Все';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      setState(() => _isLoading = true);
      final employees = await _employeeService.getAllEmployees();
      setState(() {
        _employees = employees;
        _filteredEmployees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Не удалось загрузить сотрудников');
    }
  }

  void _filterEmployees() {
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        final matchesSearch = employee.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            employee.email.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesDepartment = _selectedDepartment == 'Все' ||
            employee.department?.name == _selectedDepartment;

        return matchesSearch && matchesDepartment;
      }).toList();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6D3),
      appBar: AppBar(
        title: const Text('Сотрудники'),
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)))
          : Column(
              children: [
                _buildSearchAndFilter(),
                Expanded(
                  child: _filteredEmployees.isEmpty
                      ? const Center(child: Text('Сотрудники не найдены'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _filteredEmployees.length,
                          itemBuilder: (context, index) {
                            return _buildEmployeeCard(_filteredEmployees[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFF8B4513),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Color(0xFFD2B48C),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Поиск сотрудников...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filterEmployees();
              });
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Все'),
                  selected: _selectedDepartment == 'Все',
                  backgroundColor: Colors.white,
                  selectedColor: Color(0xFF8B4513),
                  labelStyle: TextStyle(
                    color: _selectedDepartment == 'Все' ? Colors.white : Color(0xFF4A2F1A),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedDepartment = 'Все';
                      _filterEmployees();
                    });
                  },
                ),
                ...Set.from(_employees.map((e) => e.department?.name))
                    .where((name) => name != null)
                    .map((name) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: FilterChip(
                            label: Text(name!),
                            selected: _selectedDepartment == name,
                            backgroundColor: Colors.white,
                            selectedColor: Color(0xFF8B4513),
                            labelStyle: TextStyle(
                              color: _selectedDepartment == name ? Colors.white : Color(0xFF4A2F1A),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedDepartment = name;
                                _filterEmployees();
                              });
                            },
                          ),
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      elevation: 4,
      color: Color(0xFFD2B48C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFF8B4513),
                    child: Text(
                      employee.firstName[0] + employee.lastName[0],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A2F1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (employee.position != null)
                          Text(
                            employee.position!.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B4423),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.email, employee.email),
              if (employee.phone != null)
                _buildInfoRow(Icons.phone, employee.phone!),
              if (employee.department != null)
                _buildInfoRow(Icons.business, employee.department!.name),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Color(0xFF6B4423)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4A2F1A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}