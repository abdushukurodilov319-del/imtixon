import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/persistence.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local Storage-ni yuklash
  try {
    await AppStorage.init();
  } catch (e) {
    debugPrint('AppStorage error: $e');
  }

  // Supabase ni initsializatsiya qilish
  try {
    await Supabase.initialize(
      url: 'https://YOUR_SUPABASE_PROJECT.supabase.co',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
  } catch (e) {
    // Demo rejimda Supabase bo'lmasa ham dastur ishlashi uchun
    debugPrint('Supabase initialize skip: $e');
  }

  runApp(
    const ProviderScope(
      child: CoinManagementApp(),
    ),
  );
}

class CoinManagementApp extends ConsumerWidget {
  const CoinManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Coin Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
