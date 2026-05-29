import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_state.dart';
import 'data/event_store.dart';
import 'ui/transactions_screen.dart';
import 'ui/capture_screen.dart';
import 'ui/reports_screen.dart';
import 'ui/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = await _initAppState();
  runApp(VereinApp(appState: appState));
}

Future<AppState> _initAppState() async {
  final prefs = await SharedPreferences.getInstance();
  String? cloudDir = prefs.getString('cloudDirectory');
  if (cloudDir == null || cloudDir.isEmpty) {
    final docDir = await getApplicationDocumentsDirectory();
    cloudDir = docDir.path;
  }
  final store = EventStore(baseDirectory: cloudDir);
  final state = AppState(store: store);
  await state.init();
  return state;
}

class VereinApp extends StatelessWidget {
  final AppState appState;
  const VereinApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vereinskasse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: HomeScreen(appState: appState),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final AppState appState;
  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TransactionsScreen(appState: widget.appState),
      CaptureScreen(appState: widget.appState),
      const ReportsScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Übersicht'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Erfassen'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Berichte'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Einstellungen'),
        ],
      ),
    );
  }
}
