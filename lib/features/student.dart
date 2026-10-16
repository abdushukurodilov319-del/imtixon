import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/router.dart';
import '../core/widgets/animated_background.dart';
import 'admin.dart'; // studentsProvider uchun

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends ConsumerState<StudentDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const StudentHomeView(),
      const StudentProfileView(),
    ];

    return Scaffold(
      bottomNavigationBar: MediaQuery.of(context).size.width < 600 
        ? BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
          )
        : null,
      body: AnimatedBackground(
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 600)
              NavigationRail(
                backgroundColor: Colors.white.withAlpha(204),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                  NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profil')),
                ],
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: IconButton(
                        icon: const Icon(Icons.logout), 
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
            Expanded(
              child: Container(
                color: Colors.white.withAlpha(102),
                child: pages[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentHomeView extends ConsumerWidget {
  const StudentHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider);
    final userEmail = ref.watch(loggedInUserEmailProvider);
    
    final student = students.firstWhere(
      (s) => s['email'] == userEmail,
      orElse: () => {'name': 'Mehmon', 'coins': 0, 'icon': '👤'},
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Mening Yutuqlarim'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withAlpha(51),
              child: Text(student['icon'] ?? '👤'),
            ),
          ),
          if (MediaQuery.of(context).size.width < 600)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(manualRoleProvider.notifier).state = null;
                ref.read(loggedInUserEmailProvider.notifier).state = null;
                context.go('/login');
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Salom, ${student['name']}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                _StatItem(title: 'Jami Coinlar', value: '${student['coins']}', icon: Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 16),
                _StatItem(title: 'Guruh', value: '${student['group']}', icon: Icons.group, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Oxirgi tranzaksiyalar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TransactionHistoryList(),
          ],
        ),
      ),
    );
  }
}

class TransactionHistoryList extends ConsumerWidget {
  const TransactionHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final userEmail = ref.watch(loggedInUserEmailProvider);
    final students = ref.watch(studentsProvider);
    
    final student = students.firstWhere(
      (s) => s['email'] == userEmail,
      orElse: () => <String, dynamic>{},
    );

    if (student.isEmpty) return const SizedBox.shrink();

    final studentTransactions = transactions
        .where((t) => t['studentId'] == student['id'])
        .toList();

    if (studentTransactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Hozircha tranzaksiyalar yo\'q'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: studentTransactions.length,
      itemBuilder: (context, index) {
        final tx = studentTransactions[index];
        final isPlus = tx['type'] == 'plus';
        
        return Card(
          color: Colors.white.withAlpha(230),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPlus ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(
                isPlus ? Icons.add : Icons.remove,
                color: isPlus ? Colors.green : Colors.red,
              ),
            ),
            title: Text(tx['title'] ?? ''),
            subtitle: Text(tx['date'] ?? ''),
            trailing: Text(
              '${isPlus ? '+' : '-'}${tx['amount']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPlus ? Colors.green : Colors.red,
                fontSize: 18,
              ),
            ),
          ),
        );
      },
    );
  }
}


class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(76)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color.withAlpha(204))),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class StudentProfileView extends ConsumerStatefulWidget {
  const StudentProfileView({super.key});

  @override
  ConsumerState<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends ConsumerState<StudentProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(studentsProvider);
    final userEmail = ref.watch(loggedInUserEmailProvider);
    
    final student = students.firstWhere(
      (s) => s['email'] == userEmail,
      orElse: () => <String, dynamic>{},
    );

    if (student.isEmpty) return const Center(child: Text('Foydalanuvchi topilmadi'));

    if (!_initialized) {
      _nameController = TextEditingController(text: student['name']);
      _passwordController = TextEditingController(text: student['password']);
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Profilni tahrirlash'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Card(
            color: Colors.white.withAlpha(230),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 50, child: Text(student['icon'] ?? '👤', style: const TextStyle(fontSize: 40))),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'F.I.SH', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Email', 
                      hintText: student['email'],
                      border: const OutlineInputBorder(),
                      helperText: 'Emailni o\'zgartirib bo\'lmaydi',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Parol', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final updatedList = students.map((s) {
                          if (s['id'] == student['id']) {
                            return {
                              ...s,
                              'name': _nameController.text,
                              'password': _passwordController.text,
                            };
                          }
                          return s;
                        }).toList();
                        ref.read(studentsProvider.notifier).state = updatedList;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profil muvaffaqiyatli saqlandi!')),
                        );
                      },
                      child: const Text('SAQLASH'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

