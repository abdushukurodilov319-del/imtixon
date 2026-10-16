import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/router.dart';
import '../core/persistence.dart';
import 'admin.dart'; // providers ni ishlatish uchun
import 'attendance.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends ConsumerState<TeacherDashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 6; // "Baholash" is the 7th item (index 6)
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(studentsProvider, (prev, next) => AppStorage.saveList('students', next));
    ref.listen(transactionsProvider, (prev, next) => AppStorage.saveList('transactions', next));

    final bool isMobile = MediaQuery.of(context).size.width < 1000;

    final Widget sidebar = Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Image.network(
                  'https://codial.uz/img/logo.png',
                  height: 40,
                  errorBuilder: (c, e, s) => const Icon(Icons.code, color: Color(0xFF6366F1), size: 40),
                ),
                const SizedBox(width: 10),
                const Text(
                  'codial',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(1, Icons.newspaper_outlined, 'Yangiliklar'),
                _buildNavItem(2, Icons.person_outline, 'Profil'),
                _buildNavItem(3, Icons.groups_outlined, 'Guruhlarim'),
                _buildNavItem(4, Icons.bar_chart_outlined, 'Reyting'),
                _buildNavItem(5, Icons.gavel_outlined, 'Auksion'),
                _buildNavItem(6, Icons.menu_book_outlined, 'Baholash'),
                _buildNavItem(7, Icons.rule_outlined, 'Baholash Nizomi'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE0E7FF),
                      child: Text(
                        (currentTeacher['name'] ?? 'U')[0],
                        style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTeacher['name'] ?? 'Ustoz',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Ustoz',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    ref.read(manualRoleProvider.notifier).state = null;
                    ref.read(loggedInUserEmailProvider.notifier).state = null;
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  label: const Text('Chiqish', style: TextStyle(color: Colors.redAccent)),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: isMobile
          ? AppBar(
              title: const Text('Codial Teacher', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF6366F1)),
            )
          : null,
      drawer: isMobile ? Drawer(child: sidebar) : null,
      body: Row(
        children: [
          if (!isMobile) sidebar,
          Expanded(
            child: FadeTransition(
              opacity: _fadeController,
              child: pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
            _fadeController.reset();
            _fadeController.forward();
          });
          if (MediaQuery.of(context).size.width < 1000) {
            Navigator.pop(context); // Close drawer on mobile
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade600,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
}

class TeacherGroupsView extends ConsumerWidget {
  const TeacherGroupsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allGroups = ref.watch(groupsProvider);
    final teachers = ref.watch(teachersProvider);
    final userEmail = ref.watch(loggedInUserEmailProvider);

    final currentTeacher = teachers.firstWhere(
      (t) => t['email'] == userEmail,
      orElse: () => teachers.isNotEmpty ? teachers.first : <String, dynamic>{},
    );

    final groups = allGroups.where((g) {
      final tId = g['teacherId']?.toString();
      final currentId = currentTeacher['id']?.toString();
      return tId != null && tId == currentId;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guruhlarim',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: groups.isEmpty
                ? const Center(child: Text('Sizga biriktirilgan guruhlar topilmadi'))
                : ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF6366F1).withAlpha(25),
                            child: const Icon(Icons.groups, color: Color(0xFF6366F1)),
                          ),
                          title: Text(group['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Haftada 3 kun | 14:00 - 16:00'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => AttendanceScreen(groupId: group['name']),
                              ),
                            );
                          },
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

class TeacherAssessmentView extends ConsumerStatefulWidget {
  const TeacherAssessmentView({super.key});

  @override
  ConsumerState<TeacherAssessmentView> createState() => _TeacherAssessmentViewState();
}

class _TeacherAssessmentViewState extends ConsumerState<TeacherAssessmentView> {
  String? selectedGroup;
  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Hulq', 'value': 10, 'color': Colors.blue},
    {'name': 'Imtihon', 'value': 500, 'color': Colors.indigo},
    {'name': 'Vazifa', 'value': 100, 'color': Colors.green},
    {'name': 'Qatnashdi', 'value': 25, 'color': Colors.red},
    {'name': 'Vaqtida', 'value': 25, 'color': Colors.orange},
    {'name': 'Faollik', 'value': 30, 'color': Colors.teal},
    {'name': 'O\'rganish', 'value': 100, 'color': Colors.blueAccent},
    {'name': 'Kitob', 'value': 100, 'color': Colors.pink},
    {'name': 'Tozalik', 'value': 25, 'color': Colors.greenAccent},
    {'name': 'Podcast', 'value': 50, 'color': Colors.lightBlue},
  ];

  @override
  Widget build(BuildContext context) {
    final allStudents = ref.watch(studentsProvider);
    final allGroups = ref.watch(groupsProvider);
    final teachers = ref.watch(teachersProvider);
    final userEmail = ref.watch(loggedInUserEmailProvider);

    final currentTeacher = teachers.firstWhere(
      (t) => t['email'] == userEmail,
      orElse: () => teachers.isNotEmpty ? teachers.first : <String, dynamic>{},
    );

    final myGroups = allGroups
        .where((g) => g['teacherId']?.toString() == currentTeacher['id']?.toString())
        .toList();

    if (selectedGroup == null && myGroups.isNotEmpty) {
      selectedGroup = myGroups.first['name'];
    }

    final students = allStudents.where((s) {
      return s['group']?.toString() == selectedGroup;
    }).toList();

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Baholash',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  Text(
                    'O\'quvchilarni baholash va coin berish',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ma\'lumotlar saqlandi!')),
                  );
                },
                icon: const Icon(Icons.save_outlined, size: 20),
                label: const Text('Saqlash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),

        // Filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('GURUH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedGroup,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: myGroups.map((g) => DropdownMenuItem(value: g['name'] as String, child: Text(g['name'] as String))).toList(),
                        onChanged: (val) => setState(() => selectedGroup = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BUGUN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('${selectedDate.day}.${selectedDate.month}.${selectedDate.year}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DARS KUNLARI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Dushanba', 'Chorshanba', 'Juma'].map((day) {
                          bool isJuma = day == 'Juma';
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isJuma ? const Color(0xFFDCFCE7) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isJuma ? const Color(0xFF22C55E) : Colors.transparent),
                            ),
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 12,
                                color: isJuma ? const Color(0xFF166534) : Colors.grey.shade600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // BARCHAGA QO'LLASH
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BARCHAGA QO\'LLASH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  return InkWell(
                    onTap: () => _applyCoinToAll(ref, students, cat['value'], cat['name']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: (cat['color'] as Color).withAlpha(75)),
                      ),
                      child: Text(
                        '${cat['name']} +${cat['value']}',
                        style: TextStyle(color: cat['color'], fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Table with Horizontal Scroll
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1200, // Fixed width for horizontal scrolling
              child: Column(
                children: [
                  // Table Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 40, child: Text('O\'quvchi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          const Expanded(flex: 3, child: SizedBox()),
                          ...categories.map((cat) => Expanded(
                            child: Text(
                              cat['name'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey),
                            ),
                          )),
                          const Expanded(child: Text('Jami', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                        ],
                      ),
                    ),
                  ),

                  // Student List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.orange.shade100,
                                child: Text(student['icon'] ?? '👤', style: const TextStyle(fontSize: 18)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(student['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('@${student['id']?.toString().substring(0, 4)}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                              ),
                              ...categories.map((cat) => Expanded(
                                child: Center(
                                  child: InkWell(
                                    onTap: () => _applyCoin(ref, student, cat['value'], cat['name']),
                                    child: Container(
                                      width: 40,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: const Text('0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    ),
                                  ),
                                ),
                              )),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '${student['coins']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _applyCoinToAll(WidgetRef ref, List<Map<String, dynamic>> targetStudents, int amount, String reason) {
    if (targetStudents.isEmpty) return;
    
    final allStudents = ref.read(studentsProvider);
    final targetIds = targetStudents.map((s) => s['id'].toString()).toSet();
    
    ref.read(studentsProvider.notifier).state = allStudents.map((s) {
      if (targetIds.contains(s['id'].toString())) {
        return {...s, 'coins': (s['coins'] as int) + amount};
      }
      return s;
    }).toList();

    final userEmail = ref.read(loggedInUserEmailProvider);
    final teachersList = ref.read(teachersProvider);
    final currentTeacher = teachersList.firstWhere(
      (t) => t['email'] == userEmail,
      orElse: () => teachersList.isNotEmpty ? teachersList.first : <String, dynamic>{},
    );
    final awardedBy = currentTeacher.isNotEmpty ? currentTeacher['id'] : 'teacher';
    final date = '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}';

    final newTransactions = targetStudents.map((s) => {
      'studentId': s['id'],
      'title': reason,
      'amount': amount,
      'date': date,
      'type': amount >= 0 ? 'plus' : 'minus',
      'awardedBy': awardedBy,
    }).toList();

    final txs = ref.read(transactionsProvider);
    ref.read(transactionsProvider.notifier).state = [...newTransactions, ...txs];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Barcha o\'quvchilarga "$reason" uchun $amount coin berildi')),
    );
  }
}
