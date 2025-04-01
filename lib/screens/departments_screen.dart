import 'package:flutter/material.dart';
import 'package:personal_expert/models/department_model.dart';
import 'package:personal_expert/service/department_service.dart';
import 'package:intl/intl.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({Key? key}) : super(key: key);

  @override
  _DepartmentsScreenState createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  final DepartmentService _departmentService = DepartmentService();
  List<Department> _departments = [];
  List<Department> _filteredDepartments = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      setState(() => _isLoading = true);
      final departments = await _departmentService.getAllDepartments();
      setState(() {
        _departments = departments;
        _filteredDepartments = departments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки отделов: $e')),
      );
    }
  }

  void _filterDepartments(String query) {
    setState(() {
      _searchQuery = query;
      _filteredDepartments = _departments.where((department) {
        return department.name.toLowerCase().contains(query.toLowerCase()) ||
               (department.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    });
  }

  Future<void> _showDepartmentDialog([Department? department]) async {
    final TextEditingController nameController = TextEditingController(text: department?.name);
    final TextEditingController descriptionController = TextEditingController(text: department?.description);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFF5E6D3),
        title: Text(department == null ? 'Добавить отдел' : 'Редактировать отдел'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'name': nameController.text,
                'description': descriptionController.text,
              });
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        if (department == null) {
          final newDepartment = Department(
            id: DateTime.now().toString(),
            name: result['name']!,
            description: result['description'],
            createdAt: DateTime.now(),
          );
          await _departmentService.createDepartment(newDepartment);
        } else {
          final updatedDepartment = Department(
            id: department.id,
            name: result['name']!,
            description: result['description'],
            managerId: department.managerId,
            createdAt: department.createdAt,
            manager: department.manager,
          );
          await _departmentService.updateDepartment(updatedDepartment);
        }
        _loadDepartments();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения отдела: $e')),
        );
      }
    }
  }

  Future<void> _deleteDepartment(Department department) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFF5E6D3),
        title: const Text('Подтвердить удаление'),
        content: Text('Вы уверены, что хотите удалить ${department.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _departmentService.deleteDepartment(department.id);
        _loadDepartments();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления отдела: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6D3), // Светлый бежевый фон
      appBar: AppBar(
        title: const Text('Отделы'),
        backgroundColor: Color(0xFF8B4513), // Коричневый
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showDepartmentDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterDepartments,
              decoration: InputDecoration(
                labelText: 'Поиск отделов',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredDepartments.length,
                    itemBuilder: (context, index) {
                      final department = _filteredDepartments[index];
                      return Card(
                        color: Color(0xFFD2B48C), // Темный бежевый
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            department.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A2F1A), // Темно-коричневый текст
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (department.description != null)
                                Text(
                                  department.description!,
                                  style: TextStyle(color: Color(0xFF6B4423)),
                                ),
                              Text(
                                'Создан: ${DateFormat('dd MMM yyyy', 'ru').format(department.createdAt)}',
                                style: TextStyle(
                                  color: Color(0xFF6B4423),
                                  fontSize: 12,
                                ),
                              ),
                              if (department.manager != null)
                                Text(
                                  'Руководитель: ${department.manager!.firstName} ${department.manager!.lastName}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF6B4423),
                                  ),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Редактировать'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Удалить'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showDepartmentDialog(department);
                              } else if (value == 'delete') {
                                _deleteDepartment(department);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}