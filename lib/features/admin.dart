import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/router.dart';
import '../core/widgets/animated_background.dart';
import '../core/persistence.dart';
import 'attendance.dart';

// Ma'lumotlar ombori - LocalStorage orqali yuklanadi
final teachersProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  final defaultList = [
    {
      'id': '1',
      'name': 'Ali Valiyev',
      'subject': 'Matematika',
      'email': 'teacher@coin.uz',
      'password': '123',
      'icon': '👨‍🏫'
    },
    {
      'id': '2',
      'name': 'Olim Hoshimov',
      'subject': 'Fizika',
      'email': 'olim@coin.uz',
      'password': '123',
      'icon': '👨‍🏫'
    },
  ];
  return AppStorage.loadList('teachers', defaultList);
});

final groupsProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  final defaultList = [
    {'id': '1', 'name': 'Flutter Boot-1', 'teacherId': '1'},
    {'id': '2', 'name': 'Python Pro-2', 'teacherId': '2'},
    {'id': '3', 'name': 'Frontend Web-3', 'teacherId': '1'},
  ];
  return AppStorage.loadList('groups', defaultList);
});

final studentsProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  final defaultList = [
    {
      'id': '1',
      'name': 'Javohir Eshmatov',
      'group': 'Flutter Boot-1',
      'coins': 150,
      'icon': '👨‍💻',
      'email': 'student@coin.uz',
      'password': '123'
    },
    {
      'id': '2',
      'name': 'Madina Toshmatova',
      'group': 'Python Pro-2',
      'coins': 200,
      'icon': '👩‍💻',
      'email': 'madina@coin.uz',
      'password': '123'
    },
  ];
  return AppStorage.loadList('students', defaultList);
});

final transactionsProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  final defaultList = [
    {
      'studentId': '1',
      'title': 'Darsdagi faollik uchun',
      'amount': 10,
      'date': '20.05.2024',
      'type': 'plus',
      'awardedBy': '1'
    },
    {
      'studentId': '2',
      'title': 'Uy vazifasi uchun',
      'amount': 15,
      'date': '21.05.2024',
      'type': 'plus',
      'awardedBy': '2'
    },
  ];
  return AppStorage.loadList('transactions', defaultList);
});

final adminSelectedIndexProvider = StateProvider<int>((ref) => 0);

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
  }

  void _onItemTapped(int index) {
    ref.read(adminSelectedIndexProvider.notifier).state = index;
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Ma'lumotlarni avtomatik saqlash (Har bir o'zgarishda)
    ref.listen(teachersProvider, (prev, next) => AppStorage.saveList('teachers', next));
    ref.listen(groupsProvider, (prev, next) => AppStorage.saveList('groups', next));
    ref.listen(studentsProvider, (prev, next) => AppStorage.saveList('students', next));
    ref.listen(transactionsProvider, (prev, next) => AppStorage.saveList('transactions', next));

    final selectedIndex = ref.watch(adminSelectedIndexProvider);
    final List<Widget> pages = [
      const AdminStatsView(),
      const GenericManagementView(title: 'O\'qituvchilar', icon: Icons.person_add),
      const GenericManagementView(title: 'O\'quvchilar', icon: Icons.school),
      const GenericManagementView(title: 'Guruhlar', icon: Icons.group_work),
      const AdminReportsView(),
      const AttendanceScreen(groupId: 'Barcha Guruhlar', canEdit: true),
    ];

    return Scaffold(
      body: AnimatedBackground(
        child: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.white.withAlpha(217),
              extended: MediaQuery.of(context).size.width > 1000,
              selectedIndex: selectedIndex,
              onDestinationSelected: _onItemTapped,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircleAvatar(
                  radius: 28, 
                  backgroundColor: Color(0xFF6366F1), 
                  child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30)
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), label: Text('O\'qituvchilar')),
                NavigationRailDestination(icon: Icon(Icons.school_outlined), label: Text('O\'quvchilar')),
                NavigationRailDestination(icon: Icon(Icons.groups_outlined), label: Text('Guruhlar')),
                NavigationRailDestination(icon: Icon(Icons.analytics_outlined), label: Text('Hisobotlar')),
                NavigationRailDestination(icon: Icon(Icons.event_available_outlined), label: Text('Davomat')),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.redAccent), 
                      onPressed: () {
                        ref.read(manualRoleProvider.notifier).state = null;
                        ref.read(loggedInUserEmailProvider.notifier).state = null;
                        context.go('/login');
                      }
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1, color: Colors.black12),
            Expanded(
              child: Container(
                color: Colors.white.withAlpha(76),
                child: FadeTransition(opacity: _fadeController, child: pages[selectedIndex]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminStatsView extends ConsumerWidget {
  const AdminStatsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersCount = ref.watch(teachersProvider).length;
    final studentsCount = ref.watch(studentsProvider).length;
    final groupsCount = ref.watch(groupsProvider).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Tizim Statistikasi'), backgroundColor: Colors.transparent, elevation: 0),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
        children: [
          StatCard(
            title: 'Jami O\'quvchilar', 
            value: '$studentsCount', 
            icon: Icons.people, 
            color: Colors.blue,
            onTap: () => ref.read(adminSelectedIndexProvider.notifier).state = 2,
          ),
          StatCard(
            title: 'Faol Guruhlar', 
            value: '$groupsCount', 
            icon: Icons.group, 
            color: Colors.orange,
            onTap: () => ref.read(adminSelectedIndexProvider.notifier).state = 3,
          ),
          StatCard(
            title: 'O\'qituvchilar', 
            value: '$teachersCount', 
            icon: Icons.assignment_ind, 
            color: Colors.green,
            onTap: () => ref.read(adminSelectedIndexProvider.notifier).state = 1,
          ),
          StatCard(
            title: 'Jami Coinlar', 
            value: '1,250', 
            icon: Icons.monetization_on, 
            color: Colors.amber,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white.withAlpha(230),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title, 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenericManagementView extends ConsumerWidget {
  final String title;
  final IconData icon;
  const GenericManagementView({super.key, required this.title, required this.icon});

  void _showForm(BuildContext context, WidgetRef ref, {Map<String, dynamic>? item}) {
    final nameController = TextEditingController(text: item?['name'] ?? '');
    final extraController = TextEditingController(text: item?[title == 'O\'qituvchilar' ? 'subject' : 'group'] ?? '');
    final emailController = TextEditingController(text: item?['email'] ?? '');
    final passwordController = TextEditingController(text: item?['password'] ?? '');
    
    // Guruhlar uchun o'qituvchi tanlash
    String? selectedTeacherId = item?['teacherId'];
    final teachers = ref.read(teachersProvider);
    
    String selectedIcon = item?['icon'] ?? (title == 'O\'qituvchilar' ? '👨‍🏫' : '👤');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(item == null ? '$title qo\'shish' : 'Tahrirlash'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title == 'O\'quvchilar' || title == 'O\'qituvchilar') ...[
                  const Text('Icon tanlang:'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: (title == 'O\'quvchilar' 
                      ? ['👤', '👨‍💻', '👩‍💻', '🌟', '🚀', '🎓', '🏆', '🔥']
                      : ['👨‍🏫', '👩‍🏫', '🎓', '👨‍💻', '👩‍💻']).map((e) => GestureDetector(
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
                ],
                TextField(
                  controller: nameController, 
                  decoration: InputDecoration(
                    labelText: title == 'Guruhlar' ? 'Guruh nomi' : 'Ism sharif',
                    border: const OutlineInputBorder()
                  )
                ),
                if (title == 'Guruhlar') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTeacherId,
                    decoration: const InputDecoration(labelText: 'O\'qituvchi tanlang', border: OutlineInputBorder()),
                    items: teachers.map((t) => DropdownMenuItem(
                      value: t['id'].toString(),
                      child: Text(t['name']),
                    )).toList(),
                    onChanged: (val) => setDialogState(() => selectedTeacherId = val),
                  ),
                ],
                if (title == 'O\'qituvchilar' || title == 'O\'quvchilar') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: extraController,
                    decoration: InputDecoration(
                      labelText: title == 'O\'qituvchilar' ? 'Mutaxassislik (Fan)' : 'Guruh nomi',
                      border: const OutlineInputBorder(),
                      helperText: title == 'O\'quvchilar' ? 'Agar guruh bo\'lmasa, avtomatik yaratiladi' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Login (Email)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Parol',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final extra = extraController.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                if (name.isEmpty) return;

                if (title == 'O\'qituvchilar') {
                  final list = ref.read(teachersProvider);
                  final newItem = {
                    'id': item?['id'] ?? DateTime.now().toString(), 
                    'name': name, 
                    'subject': extra,
                    'email': email,
                    'password': password,
                    'icon': selectedIcon,
                  };
                  ref.read(teachersProvider.notifier).state = item == null ? [...list, newItem] : list.map((e) => e['id'] == item['id'] ? newItem : e).toList();
                } 
                else if (title == 'Guruhlar') {
                  final list = ref.read(groupsProvider);
                  final newItem = {
                    'id': item?['id'] ?? DateTime.now().toString(), 
                    'name': name,
                    'teacherId': selectedTeacherId
                  };
                  ref.read(groupsProvider.notifier).state = item == null ? [...list, newItem] : list.map((e) => e['id'] == item['id'] ? newItem : e).toList();
                } 
                else {
                  // O'quvchilar
                  if (extra.isNotEmpty) {
                    final groups = ref.read(groupsProvider);
                    final groupExists = groups.any((g) => g['name'].toString().toLowerCase() == extra.toLowerCase());
                    if (!groupExists) {
                      ref.read(groupsProvider.notifier).state = [...groups, {'id': DateTime.now().toString(), 'name': extra}];
                    }
                  }

                  final list = ref.read(studentsProvider);
                  final newItem = {
                    'id': item?['id'] ?? DateTime.now().toString(), 
                    'name': name, 
                    'group': extra, 
                    'coins': item?['coins'] ?? 0,
                    'icon': selectedIcon,
                    'email': email,
                    'password': password,
                  };
                  ref.read(studentsProvider.notifier).state = item == null ? [...list, newItem] : list.map((e) => e['id'] == item['id'] ? newItem : e).toList();
                }
                Navigator.pop(context);
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
    final list = title == 'O\'qituvchilar' 
        ? ref.watch(teachersProvider) 
        : title == 'Guruhlar' 
            ? ref.watch(groupsProvider) 
            : ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showForm(context, ref),
            icon: const Icon(Icons.add_circle, color: Color(0xFF6366F1), size: 30),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: list.isEmpty 
        ? Center(child: Text('Hozircha $title mavjud emas', style: const TextStyle(fontSize: 16, color: Colors.black54)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                elevation: 1,
                color: Colors.white.withAlpha(230),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  onTap: title == 'Guruhlar' ? () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => GroupStudentsScreen(groupName: item['name'])));
                  } : null,
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: Text(item['icon'] ?? (title == 'O\'qituvchilar' ? '👨‍🏫' : (title == 'Guruhlar' ? '📚' : '👤')), style: const TextStyle(fontSize: 20)),
                  ),
                  title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title == 'Guruhlar' ? 'O\'quvchilarni ko\'rish uchun bosing' : (item[title == 'O\'qituvchilar' ? 'subject' : 'group']?.toString() ?? '')),
                      if (title == 'O\'quvchilar' || title == 'O\'qituvchilar')
                        Text('L: ${item['email'] ?? '-'} | P: ${item['password'] ?? '-'}', 
                          style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.w500)),
                      if (title == 'Guruhlar' && item['teacherId'] != null) ...[
                        Builder(
                          builder: (context) {
                            final teachers = ref.read(teachersProvider);
                            final teacher = teachers.firstWhere((t) => t['id'] == item['teacherId'], orElse: () => {'name': 'Noma\'lum'});
                            return Text('O\'qituvchi: ${teacher['name']}',
                              style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500));
                          }
                        ),
                      ]
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(context, ref, item: item)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (title == 'O\'qituvchilar') {
                            ref.read(teachersProvider.notifier).state = ref.read(teachersProvider).where((e) => e['id'] != item['id']).toList();
                          } else if (title == 'Guruhlar') {
                            ref.read(groupsProvider.notifier).state = ref.read(groupsProvider).where((e) => e['id'] != item['id']).toList();
                          } else {
                            ref.read(studentsProvider.notifier).state = ref.read(studentsProvider).where((e) => e['id'] != item['id']).toList();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}

class AdminReportsView extends ConsumerWidget {
  const AdminReportsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachers = ref.watch(teachersProvider);
    final transactions = ref.watch(transactionsProvider);
    final students = ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('O\'qituvchilar faoliyati hisoboti'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          final teacher = teachers[index];
          final teacherTxs = transactions.where((tx) => tx['awardedBy'] == teacher['id']).toList();
          final totalAwarded = teacherTxs.fold<int>(0, (sum, tx) => sum + (tx['amount'] as int));

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade50,
                child: Text(teacher['icon'] ?? '👨‍🏫'),
              ),
              title: Text(teacher['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${teacher['subject']} | Berilgan coinlar: $totalAwarded 🪙'),
              children: [
                if (teacherTxs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Bu o\'qituvchi hali coin bermagan'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: teacherTxs.length,
                    itemBuilder: (context, txIndex) {
                      final tx = teacherTxs[txIndex];
                      final student = students.firstWhere((s) => s['id'] == tx['studentId'], orElse: () => {'name': 'Noma\'lum'});
                      return ListTile(
                        dense: true,
                        title: Text('${student['name']} - ${tx['title']}'),
                        subtitle: Text(tx['date']),
                        trailing: Text('+${tx['amount']} 🪙', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GroupStudentsScreen extends ConsumerWidget {
  final String groupName;
  const GroupStudentsScreen({super.key, required this.groupName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider).where((s) => s['group'] == groupName).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('$groupName o\'quvchilari', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AnimatedBackground(
        child: students.isEmpty 
          ? const Center(child: Text('Bu guruhda o\'quvchilar yo\'q', style: TextStyle(color: Colors.white, fontSize: 18)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];
                return Card(
                  color: Colors.white.withAlpha(230),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.indigo.shade50, child: Text(s['icon'] ?? '👤', style: const TextStyle(fontSize: 22))),
                    title: Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Balans: ${s['coins']} 🪙', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
      ),
    );
  }
}
