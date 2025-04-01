import 'package:flutter/material.dart';
import 'package:personal_expert/service/department_service.dart';
import 'package:personal_expert/service/education_service.dart';
import 'package:personal_expert/service/employee_service.dart';
import 'package:personal_expert/service/vacation_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final EmployeeService _employeeService = EmployeeService();
  final DepartmentService _departmentService = DepartmentService();
  final VacationService _vacationService = VacationService();
  final EducationService _educationService = EducationService();

  int totalEmployees = 0;
  int activeVacations = 0;
  int totalEducations = 0;
  Map<String, int> departmentStats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final employees = await _employeeService.getAllEmployees();
      final departments = await _departmentService.getAllDepartments();
      final vacations = await _vacationService.getAllVacations();
      final educations = await _educationService.getAllEducations();

      setState(() {
        totalEmployees = employees.length;
        activeVacations = vacations
            .where((vacation) => 
                vacation.startDate.isBefore(DateTime.now()) &&
                vacation.endDate.isAfter(DateTime.now()))
            .length;
        totalEducations = educations.length;
        
        departmentStats = {};
        for (var department in departments) {
          final deptEmployees = employees
              .where((emp) => emp.departmentId == department.id)
              .length;
          departmentStats[department.name] = deptEmployees;
        }
      });
    } catch (e) {
      print('Ошибка загрузки статистики: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6D3),
      appBar: AppBar(
        title: Text('ПерсоналЭксперт',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF8B4513),
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsCards(),
              SizedBox(height: 24),
              _buildDepartmentChart(),
              SizedBox(height: 24),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: [
        _statisticCard(
          'Сотрудники',
          totalEmployees.toString(),
          Icons.people,
          Color(0xFF8B4513),
        ),
        _statisticCard(
          'В отпуске',
          activeVacations.toString(),
          Icons.beach_access,
          Color(0xFF8B4513),
        ),
        _statisticCard(
          'Образование',
          totalEducations.toString(),
          Icons.school,
          Color(0xFF8B4513),
        ),
      ],
    );
  }

  Widget _statisticCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      color: Color(0xFFD2B48C),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color)),
            SizedBox(height: 4),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B4423))),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentChart() {
    return Card(
      elevation: 4,
      color: Color(0xFFD2B48C),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Распределение по отделам',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2F1A))),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: departmentStats.isEmpty 
                  ? Center(child: Text('Нет данных'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: departmentStats.values.reduce(max).toDouble(),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= departmentStats.keys.length) return const Text('');
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    departmentStats.keys.elementAt(value.toInt()),
                                    style: TextStyle(fontSize: 10, color: Color(0xFF6B4423)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          departmentStats.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: departmentStats.values.elementAt(index).toDouble(),
                                color: Color(0xFF8B4513),
                                width: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      color: Color(0xFFD2B48C),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Быстрые действия',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2F1A))),
            SizedBox(height: 26),
            Wrap(
              spacing: 26.0,
              runSpacing: 26.0,
              children: [
                _actionButton(
                  'Добавить сотрудника',
                  Icons.person_add,
                  () {},
                ),
                _actionButton(
                  'Управление отпусками',
                  Icons.calendar_today,
                  () {},
                ),
                _actionButton(
                  'Оценка персонала',
                  Icons.assessment,
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 26, vertical: 22),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Color(0xFFF5E6D3),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF8B4513),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'ПерсоналЭксперт',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Управление персоналом',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.people, color: Color(0xFF8B4513)),
            title: Text('Сотрудники', style: TextStyle(color: Color(0xFF4A2F1A))),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/employees');
            },
          ),
          ListTile(
            leading: Icon(Icons.business, color: Color(0xFF8B4513)),
            title: Text('Отделы', style: TextStyle(color: Color(0xFF4A2F1A))),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/departments');
            },
          ),
          ListTile(
            leading: Icon(Icons.work, color: Color(0xFF8B4513)),
            title: Text('Должности', style: TextStyle(color: Color(0xFF4A2F1A))),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/positions');
            },
          ),
          ListTile(
            leading: Icon(Icons.beach_access, color: Color(0xFF8B4513)),
            title: Text('Отпуска', style: TextStyle(color: Color(0xFF4A2F1A))),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/vacations');
            },
          ),
        ],
      ),
    );
  }
}