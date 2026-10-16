import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/router.dart';
import '../core/persistence.dart';
import 'admin.dart'; // providers ni ishlatish uchun
import 'attendance.dart';

final teacherSelectedIndexProvider = StateProvider<int>((ref) => 0);

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(teachersProvider, (prev, next) => AppStorage.saveList('teachers', next));
    ref.listen(groupsProvider, (prev, next) => AppStorage.saveList('groups', next));
    ref.listen(studentsProvider, (prev, next) => AppStorage.saveList('students', next));
    ref.listen(transactionsProvider, (prev, next) => AppStorage.saveList('transactions', next));

    final selectedIndex = ref.watch(teacherSelectedIndexProvider);

    final List<Widget> pages = [
      const TeacherStatsView(),
      const TeacherNewsView(),
      const TeacherProfileView(),
      const TeacherGroupsView(),
      const TeacherRankingView(),
      const TeacherAuctionView(),
      const TeacherAssessmentView(),
      const Center(child: Text('Baholash Nizomi')),
    ];

    final userEmail = ref.watch(loggedInUserEmailProvider);
    final teachers = ref.watch(teachersProvider);
    
    // Email bo'yicha topolmasa, birinchi o'qituvchini oladi (Demo uchun)
    final currentTeacher = teachers.firstWhere(
      (t) => t['email'] == userEmail,
      orElse: () => teachers.isNotEmpty ? teachers.first : <String, dynamic>{'id': '1', 'name': 'Ustoz', 'icon': '👨‍🏫'},
    );

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
                _buildNavItem(context, ref, 0, Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(context, ref, 1, Icons.newspaper_outlined, 'Yangiliklar'),
                _buildNavItem(context, ref, 2, Icons.person_outline, 'Profil'),
                _buildNavItem(context, ref, 3, Icons.groups_outlined, 'Guruhlarim'),
                _buildNavItem(context, ref, 4, Icons.bar_chart_outlined, 'Reyting'),
                _buildNavItem(context, ref, 5, Icons.gavel_outlined, 'Auksion'),
                _buildNavItem(context, ref, 6, Icons.menu_book_outlined, 'Baholash'),
                _buildNavItem(context, ref, 7, Icons.rule_outlined, 'Baholash Nizomi'),
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
                        currentTeacher['icon'] ?? (currentTeacher['name'] ?? 'U')[0],
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: pages[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, int index, IconData icon, String label) {
    final selectedIndex = ref.watch(teacherSelectedIndexProvider);
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          ref.read(teacherSelectedIndexProvider.notifier).state = index;
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

    final myGroups = allGroups.where((g) {
      final tId = g['teacherId']?.toString();
      final cId = currentTeacher['id']?.toString();
      return cId != null && tId == cId;
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
            child: myGroups.isEmpty
                ? const Center(child: Text('Sizga biriktirilgan guruhlar topilmadi'))
                : ListView.builder(
                    itemCount: myGroups.length,
                    itemBuilder: (context, index) {
                      final group = myGroups[index];
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

    final myGroups = allGroups.where((g) {
      final tId = g['teacherId']?.toString();
      final cId = currentTeacher['id']?.toString();
      return cId != null && tId == cId;
    }).toList();

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
                        value: selectedGroup,
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
                          const SizedBox(width: 48),
                          const Expanded(flex: 3, child: Text('O\'quvchi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
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
                                    onTap: () => _applyCoin(ref, student, (cat['value'] as int), cat['name'] as String),
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

  void _applyCoin(WidgetRef ref, Map<String, dynamic> student, int amount, String reason) {
    _applyCoinToAll(ref, [student], amount, reason);
  }
}

class TeacherStatsView extends ConsumerWidget {
  const TeacherStatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStudents = ref.watch(studentsProvider);
    final allGroups = ref.watch(groupsProvider);
    final teachers = ref.watch(teachersProvider);
    final userEmail = ref.watch(loggedInUserEmailProvider);

    final currentTeacher = teachers.firstWhere(
      (t) => t['email'] == userEmail,
      orElse: () => teachers.isNotEmpty ? teachers.first : <String, dynamic>{'id': '1'},
    );

    final myGroups = allGroups.where((g) {
      final tId = g['teacherId']?.toString();
      final cId = currentTeacher['id']?.toString();
      return cId != null && tId == cId;
    }).toList();

    final myGroupNames = myGroups.map((g) => g['name'].toString()).toSet();
    final myStudents = allStudents.where((s) => myGroupNames.contains(s['group'].toString())).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O\'qituvchi Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatCard(
                title: 'Mening Guruhlarim',
                value: '${myGroups.length}',
                icon: Icons.groups,
                color: Colors.blue,
                onTap: () => ref.read(teacherSelectedIndexProvider.notifier).state = 3,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Mening O\'quvchilarim',
                value: '${myStudents.length}',
                icon: Icons.school,
                color: Colors.green,
                onTap: () => ref.read(teacherSelectedIndexProvider.notifier).state = 6,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'O\'quvchilar ro\'yxati',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: myStudents.isEmpty
                ? const Center(child: Text('Sizda hali o\'quvchilar yo\'q'))
                : ListView.builder(
                    itemCount: myStudents.length,
                    itemBuilder: (context, index) {
                      final s = myStudents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade50,
                            child: Text(s['icon'] ?? '👤'),
                          ),
                          title: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(s['group'] ?? ''),
                          trailing: Text('${s['coins']} 🪙', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
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

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherNewsView extends StatelessWidget {
  const TeacherNewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Yangiliklar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (c, i) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Container(height: 150, color: Colors.grey[200], child: const Center(child: Icon(Icons.image, size: 50))),
                    ListTile(
                      title: Text('Codial News #${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Bugun auksion kuni! Barcha talabalarni kutib qolamiz.'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherProfileView extends ConsumerWidget {
  const TeacherProfileView({super.key});

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> teacher) {
    final nameController = TextEditingController(text: teacher['name'] ?? '');
    final phoneController = TextEditingController(text: teacher['phone'] ?? '+998 90 123 45 67');
    String selectedIcon = teacher['icon'] ?? '👨‍🏫';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Profilni tahrirlash'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Icon tanlang:'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ['👨‍🏫', '👩‍🏫', '🎓', '👨‍💻', '👩‍💻', '🌟', '🔥'].map((e) => GestureDetector(
                    onTap: () => setDialogState(() => selectedIcon = e),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIcon == e ? Colors.indigo.withAlpha(25) : Colors.transparent,
                        border: Border.all(color: selectedIcon == e ? Colors.indigo : Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Ism sharif', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Telefon raqam', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
            ElevatedButton(
              onPressed: () {
                final teachers = ref.read(teachersProvider);
                ref.read(teachersProvider.notifier).state = teachers.map((t) {
                  if (t['id'] == teacher['id']) {
                    return {
                      ...t,
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'icon': selectedIcon,
                    };
                  }
                  return t;
                }).toList();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil yangilandi!')));
              },
              child: const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEmail = ref.watch(loggedInUserEmailProvider);
    final teachers = ref.watch(teachersProvider);
    final currentTeacher = teachers.firstWhere(
      (t) => t['email'] == userEmail,
      orElse: () => teachers.isNotEmpty ? teachers.first : <String, dynamic>{'name': 'Ustoz'},
    );

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(radius: 60, backgroundColor: const Color(0xFFEEF2FF), child: Text(currentTeacher['icon'] ?? '👨‍🏫', style: const TextStyle(fontSize: 50))),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF6366F1),
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                        onPressed: () => _showEditProfileDialog(context, ref, currentTeacher),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(currentTeacher['name'] ?? '', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text(userEmail ?? '', style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _ProfileInfoRow(icon: Icons.phone, label: 'Telefon', value: currentTeacher['phone'] ?? '+998 90 123 45 67'),
                    const Divider(height: 32),
                    _ProfileInfoRow(icon: Icons.work, label: 'Mutaxassislik', value: currentTeacher['subject'] ?? 'Senior Mentor'),
                    const Divider(height: 32),
                    _ProfileInfoRow(icon: Icons.badge, label: 'ID', value: '#${currentTeacher['id']?.toString().substring(0, 5)}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _showEditProfileDialog(context, ref, currentTeacher),
                icon: const Icon(Icons.edit_note),
                label: const Text('Profilni tahrirlash'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _showChangePasswordDialog(context),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Parolni o\'zgartirish'),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Parolni o\'zgartirish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Eski parol', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Yangi parol', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Yangi parolni tasdiqlang', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () {
              if (newPassController.text != confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parollar mos kelmadi!')));
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parol muvaffaqiyatli o\'zgartirildi!')));
            },
            child: const Text('O\'zgartirish'),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ProfileInfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ],
    );
  }
}

class TeacherRankingView extends ConsumerWidget {
  const TeacherRankingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider);
    final sortedStudents = [...students]..sort((a, b) => (b['coins'] as int).compareTo(a['coins'] as int));

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reyting', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: sortedStudents.length,
              itemBuilder: (c, i) {
                final s = sortedStudents[i];
                return ListTile(
                  leading: Text('#${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  title: Text(s['name'] ?? ''),
                  subtitle: Text(s['group'] ?? ''),
                  trailing: Text('${s['coins']} 🪙', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherAuctionView extends ConsumerWidget {
  const TeacherAuctionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> auctionItems = [
      {'name': 'Codial Hoodie', 'price': 1500, 'icon': Icons.checkroom, 'color': Colors.deepPurple, 'type': 'Kiyim'},
      {'name': 'Mechanical Keyboard', 'price': 2000, 'icon': Icons.keyboard, 'color': Colors.blue, 'type': 'Gadjet'},
      {'name': 'Mentorship (1 soat)', 'price': 3000, 'icon': Icons.psychology, 'color': Colors.amber, 'type': 'Ta\'lim'},
      {'name': 'Codial Backpack', 'price': 1000, 'icon': Icons.backpack, 'color': Colors.green, 'type': 'Aksesuar'},
      {'name': 'Wireless Earbuds', 'price': 1800, 'icon': Icons.headset, 'color': Colors.red, 'type': 'Gadjet'},
      {'name': 'VIP Kofe tanaffusi', 'price': 500, 'icon': Icons.coffee, 'color': Colors.brown, 'type': 'Tajriba'},
      {'name': 'Sticker Pack', 'price': 100, 'icon': Icons.auto_awesome, 'color': Colors.pink, 'type': 'Boshqa'},
      {'name': 'Dasturlash kitobi', 'price': 700, 'icon': Icons.menu_book, 'color': Colors.indigo, 'type': 'Kitob'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Auksion', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: auctionItems.length,
              itemBuilder: (c, i) {
                final item = auctionItems[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: (item['color'] as Color).withAlpha(20),
                          child: Icon(item['icon'] as IconData, size: 50, color: item['color'] as Color),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              item['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Boshlang\'ich: ${item['price']} 🪙',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                              ElevatedButton(
                              onPressed: () {
                                _startAuction(context, ref, item);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: item['color'] as Color,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Boshlash'),
                            ),
                          ],
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
    );
  }

  void _startAuction(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    int selectedDuration = 10;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${item['name']} auksionini boshlash'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Boshlang\'ich narx: ${item['price']} 🪙'),
              const SizedBox(height: 16),
              const Text('Auksion vaqti (daqiqa):'),
              const SizedBox(height: 8),
              Row(
                children: [5, 10, 15, 20].map((m) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$m m'),
                    selected: selectedDuration == m,
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() => selectedDuration = m);
                      }
                    },
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['name']} uchun $selectedDuration daqiqalik jonli auksion boshlandi!'),
                    backgroundColor: item['color'] as Color,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: item['color'] as Color),
              child: const Text('Jonli efirni boshlash'),
            ),
          ],
        ),
      ),
    );
  }
}
