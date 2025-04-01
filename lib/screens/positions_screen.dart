import 'package:flutter/material.dart';
import 'package:personal_expert/models/position.dart';
import 'package:personal_expert/service/position_service.dart';
import 'package:intl/intl.dart';

class PositionsScreen extends StatefulWidget {
  const PositionsScreen({Key? key}) : super(key: key);

  @override
  _PositionsScreenState createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen> {
  final PositionService _positionService = PositionService();
  List<Position> _positions = [];
  List<Position> _filteredPositions = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    try {
      setState(() => _isLoading = true);
      final positions = await _positionService.getAllPositions();
      setState(() {
        _positions = positions;
        _filteredPositions = positions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Ошибка загрузки должностей');
    }
  }

  void _filterPositions(String query) {
    setState(() {
      _searchQuery = query;
      _filteredPositions = _positions.where((position) {
        return position.title.toLowerCase().contains(query.toLowerCase()) ||
            (position.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    });
  }

  Future<void> _showPositionDialog([Position? position]) async {
    final titleController = TextEditingController(text: position?.title);
    final descriptionController = TextEditingController(text: position?.description);
    final salaryMinController = TextEditingController(
        text: position?.salaryMin?.toString() ?? '');
    final salaryMaxController = TextEditingController(
        text: position?.salaryMax?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFF5E6D3),
        title: Text(position == null ? 'Новая должность' : 'Редактировать должность'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Название*'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
              ),
              TextField(
                controller: salaryMinController,
                decoration: const InputDecoration(labelText: 'Минимальная зарплата'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: salaryMaxController,
                decoration: const InputDecoration(labelText: 'Максимальная зарплата'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                _showErrorSnackBar('Название должности обязательно');
                return;
              }

              final newPosition = Position(
                id: position?.id ?? '',
                title: titleController.text,
                description: descriptionController.text,
                salaryMin: double.tryParse(salaryMinController.text),
                salaryMax: double.tryParse(salaryMaxController.text),
                createdAt: position?.createdAt ?? DateTime.now(),
              );

              try {
                if (position == null) {
                  await _positionService.createPosition(newPosition);
                } else {
                  await _positionService.updatePosition(newPosition);
                }
                Navigator.pop(context);
                _loadPositions();
                _showSuccessSnackBar(
                  position == null ? 'Должность создана' : 'Должность обновлена',
                );
              } catch (e) {
                _showErrorSnackBar('Ошибка сохранения');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B4513)),
            child: Text(position == null ? 'Создать' : 'Сохранить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePosition(Position position) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFF5E6D3),
        title: const Text('Подтверждение'),
        content: Text('Удалить должность "${position.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _positionService.deletePosition(position.id);
        _loadPositions();
        _showSuccessSnackBar('Должность удалена');
      } catch (e) {
        _showErrorSnackBar('Ошибка удаления');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF8B4513),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6D3),
      appBar: AppBar(
        title: const Text('Должности'),
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showPositionDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterPositions,
              decoration: InputDecoration(
                labelText: 'Поиск',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _filterPositions(''),
                      )
                    : null,
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)))
                : _filteredPositions.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Нет должностей'
                              : 'Ничего не найдено',
                          style: TextStyle(color: Color(0xFF6B4423)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredPositions.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final position = _filteredPositions[index];
                          return Card(
                            elevation: 2,
                            color: Color(0xFFD2B48C),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(
                                position.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A2F1A),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (position.description != null)
                                    Text(
                                      position.description!,
                                      style: TextStyle(color: Color(0xFF6B4423)),
                                    ),
                                  if (position.salaryRange != null)
                                    Text(
                                      'Зарплата: ${position.salaryRange}',
                                      style: TextStyle(
                                        color: Color(0xFF8B4513),
                                      ),
                                    ),
                                  Text(
                                    'Создано: ${DateFormat('dd.MM.yyyy', 'ru').format(position.createdAt)}',
                                    style: TextStyle(color: Color(0xFF6B4423)),
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
                                    child: Text(
                                      'Удалить',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showPositionDialog(position);
                                  } else if (value == 'delete') {
                                    _deletePosition(position);
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