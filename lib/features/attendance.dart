import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/router.dart';
import 'admin.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  final String groupId;
  final bool canEdit;
  const AttendanceScreen({super.key, required this.groupId, this.canEdit = true});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final Map<String, bool> _attendanceStatus = {};

  @override
  Widget build(BuildContext context) {
    final allStudents = ref.watch(studentsProvider);
    final students = widget.groupId == 'Barcha Guruhlar' 
        ? allStudents 
        : allStudents.where((s) => s['group'] == widget.groupId).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('${widget.groupId} - Davomat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.canEdit)
            IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Davomat saqlandi (Demo)')),
                );
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: students.isEmpty 
        ? const Center(child: Text('Ushbu guruhda o\'quvchilar yo\'q', style: TextStyle(color: Colors.white, fontSize: 18)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final studentId = student['id'].toString();
              
              if (!_attendanceStatus.containsKey(studentId)) {
                _attendanceStatus[studentId] = true;
              }

              final isPresent = _attendanceStatus[studentId]!;

              return Card(
                color: Colors.white.withAlpha(230),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.indigo.shade50,
                          child: Text(student['icon'] ?? '👤', style: const TextStyle(fontSize: 24)),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isPresent ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              isPresent ? Icons.check : Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(student['name'] ?? 'Ismsiz', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student['group'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${student['coins'] ?? 0} 🪙', 
                            style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                    trailing: widget.canEdit
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.amber, size: 30),
                                onPressed: () => _showAddCoinDialog(context, ref, student),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: isPresent,
                                activeColor: Colors.green,
                                onChanged: (val) => setState(() => _attendanceStatus[studentId] = val),
                              ),
                            ],
                          )
                        : Text(isPresent ? "Kelgan" : "Yo'q", 
                            style: TextStyle(color: isPresent ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          ),
    );
  }

  void _showAddCoinDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> student) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(student['icon'] ?? '👤'),
            const SizedBox(width: 10),
            Expanded(child: Text('${student['name']} ga Coin')),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Coin miqdori',
            suffixText: '🪙',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white),
            onPressed: () {
              final amount = int.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                final list = ref.read(studentsProvider);
                ref.read(studentsProvider.notifier).state = list.map((s) {
                  if (s['id'] == student['id']) {
                    return {...s, 'coins': (s['coins'] as int? ?? 0) + amount};
                  }
                  return s;
                }).toList();

                // Tranzaksiyani yozish
                final userEmail = ref.read(loggedInUserEmailProvider);
                final teachers = ref.read(teachersProvider);
                final currentTeacher = teachers.firstWhere(
                  (t) => t['email'] == userEmail,
                  orElse: () => teachers.isNotEmpty ? teachers.first : <String, dynamic>{},
                );
                final awardedBy = currentTeacher.isNotEmpty ? currentTeacher['id'] : 'admin';

                final txs = ref.read(transactionsProvider);
                ref.read(transactionsProvider.notifier).state = [
                  {
                    'studentId': student['id'],
                    'title': 'Darsdagi faollik (Davomat)',
                    'amount': amount,
                    'date': '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                    'type': 'plus',
                    'awardedBy': awardedBy,
                  },
                  ...txs,
                ];

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${student['name']} ga $amount coin berildi!')),
                );
              }
            },
            child: const Text('Berish'),
          ),
        ],
      ),
    );
  }
}
