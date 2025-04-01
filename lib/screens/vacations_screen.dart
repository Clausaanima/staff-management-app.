import 'package:flutter/material.dart';
import 'package:personal_expert/models/vacation_model.dart';
import 'package:personal_expert/service/vacation_service.dart';
import 'package:intl/intl.dart';
import 'package:personal_expert/widgets/employee_dropdown_field.dart';
import 'package:personal_expert/widgets/loading_indicator.dart';
import 'package:table_calendar/table_calendar.dart';

class VacationsScreen extends StatefulWidget {
  const VacationsScreen({Key? key}) : super(key: key);

  @override
  _VacationsScreenState createState() => _VacationsScreenState();
}

class _VacationsScreenState extends State<VacationsScreen> {
  final VacationService _vacationService = VacationService();
  List<Vacation> _vacations = [];
  List<Vacation> _filteredVacations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _loadVacations();
  }

  Future<void> _loadVacations() async {
    try {
      setState(() => _isLoading = true);
      final vacations = await _vacationService.getAllVacations();
      setState(() {
        _vacations = vacations;
        _filterVacations();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Ошибка загрузки отпусков');
    }
  }

  void _filterVacations() {
    if (_searchQuery.isEmpty) {
      _filteredVacations = List.from(_vacations);
    } else {
      _filteredVacations = _vacations.where((vacation) {
        final employee = vacation.employee;
        if (employee == null) return false;
        
        return employee.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               employee.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               vacation.type.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<void> _showVacationDialog([Vacation? vacation]) async {
    final isEditing = vacation != null;
    final result = await showDialog(
      context: context,
      builder: (context) => VacationDialog(vacation: vacation),
    );

    if (result == true) {
      _loadVacations();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6D3),
      appBar: AppBar(
        title: Text('Отпуска'),
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month
                    ? CalendarFormat.week
                    : CalendarFormat.month;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterVacations();
                });
              },
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) {
              return _vacations.where((v) =>
                day.isAfter(v.startDate.subtract(Duration(days: 1))) &&
                day.isBefore(v.endDate.add(Duration(days: 1)))
              ).toList();
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(color: Color(0xFF4A2F1A)),
              weekendTextStyle: TextStyle(color: Color(0xFF6B4423)),
              todayDecoration: BoxDecoration(
                color: Color(0xFF8B4513),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? LoadingIndicator()
                : ListView.builder(
                    itemCount: _filteredVacations.length,
                    itemBuilder: (context, index) {
                      final vacation = _filteredVacations[index];
                      return VacationCard(
                        vacation: vacation,
                        onEdit: () => _showVacationDialog(vacation),
                        onDelete: () async {
                          try {
                            await _vacationService.deleteVacation(vacation.id);
                            _loadVacations();
                          } catch (e) {
                            _showErrorSnackBar('Ошибка удаления отпуска');
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVacationDialog(),
        backgroundColor: Color(0xFF8B4513),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class VacationCard extends StatelessWidget {
  final Vacation vacation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VacationCard({
    Key? key,
    required this.vacation,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy', 'ru');
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Color(0xFFD2B48C),
      child: ListTile(
        title: Text('${vacation.employee?.lastName} ${vacation.employee?.firstName}',
            style: TextStyle(color: Color(0xFF4A2F1A))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${dateFormat.format(vacation.startDate)} - ${dateFormat.format(vacation.endDate)}',
                style: TextStyle(color: Color(0xFF6B4423))),
            Text('Тип: ${vacation.type}',
                style: TextStyle(color: Color(0xFF6B4423))),
            Text('Статус: ${vacation.status}',
                style: TextStyle(color: Color(0xFF6B4423))),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF8B4513)),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Color(0xFFF5E6D3),
                    title: Text('Подтверждение'),
                    content: Text('Вы действительно хотите удалить этот отпуск?'),
                    actions: [
                      TextButton(
                        child: Text('Отмена'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text('Удалить'),
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class VacationDialog extends StatefulWidget {
  final Vacation? vacation;

  const VacationDialog({Key? key, this.vacation}) : super(key: key);

  @override
  _VacationDialogState createState() => _VacationDialogState();
}

class _VacationDialogState extends State<VacationDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedEmployeeId;
  String? _selectedType;
  String? _selectedStatus;

  final List<String> _vacationTypes = ['Очередной', 'Без содержания', 'По болезни'];
  final List<String> _vacationStatuses = ['Запланирован', 'Утвержден', 'Завершен'];

  @override
  void initState() {
    super.initState();
    _startDate = widget.vacation?.startDate ?? DateTime.now();
    _endDate = widget.vacation?.endDate ?? DateTime.now().add(Duration(days: 14));
    _selectedEmployeeId = widget.vacation?.employeeId;
    _selectedType = widget.vacation?.type;
    _selectedStatus = widget.vacation?.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFFF5E6D3),
      title: Text(widget.vacation == null ? 'Новый отпуск' : 'Редактировать отпуск'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmployeeDropdownField(
                value: _selectedEmployeeId,
                onChanged: (value) {
                  setState(() => _selectedEmployeeId = value);
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Дата начала'),
                      readOnly: true,
                      controller: TextEditingController(
                        text: DateFormat('dd.MM.yyyy', 'ru').format(_startDate),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Дата окончания'),
                      readOnly: true,
                      controller: TextEditingController(
                        text: DateFormat('dd.MM.yyyy', 'ru').format(_endDate),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(labelText: 'Тип отпуска'),
                items: _vacationTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value);
                },
                validator: (value) {
                  if (value == null) return 'Выберите тип отпуска';
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(labelText: 'Статус'),
                items: _vacationStatuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedStatus = value);
                },
                validator: (value) {
                  if (value == null) return 'Выберите статус';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Отмена'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text('Сохранить'),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B4513)),
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              try {
                final vacationService = VacationService();
                
                final vacation = Vacation(
                  id: widget.vacation?.id ?? '',
                  employeeId: _selectedEmployeeId!,
                  startDate: _startDate,
                  endDate: _endDate,
                  type: _selectedType!,
                  status: _selectedStatus!,
                  createdAt: widget.vacation?.createdAt ?? DateTime.now(),
                );

                if (widget.vacation == null) {
                  await vacationService.createVacation(vacation);
                } else {
                  await vacationService.updateVacation(vacation);
                }

                Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка сохранения отпуска'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }
}