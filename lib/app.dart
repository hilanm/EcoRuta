import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/providers.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/eco_card.dart';
import 'features/home/screens/home_screen.dart';
import 'features/map/screens/recycling_map_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/recycling/screens/recycle_screen.dart';
import 'features/streak/screens/streak_screen.dart';

class EcoRutaApp extends StatelessWidget {
  const EcoRutaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'EcoRuta',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainShell(),
      );
}

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);
    return Scaffold(
      body: IndexedStack(index: index, children: [
        const HomeScreen(),
        LazyTab(active: index == 1, builder: () => const RecyclingMapScreen()),
        const RecycleScreen(),
        LazyTab(active: index == 3, builder: () => const StreakScreen()),
        LazyTab(active: index == 4, builder: () => const ProfileScreen()),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(tabIndexProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.recycling_outlined), selectedIcon: Icon(Icons.recycling), label: 'Reciclar'),
          NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), selectedIcon: Icon(Icons.local_fire_department), label: 'Racha'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
