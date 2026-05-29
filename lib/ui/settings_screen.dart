import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _cloudDirectory;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _cloudDirectory = prefs.getString('cloudDirectory'));
  }

  Future<void> _pickDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Cloud-Ordner auswählen',
    );
    if (path != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cloudDirectory', path);
      setState(() => _cloudDirectory = path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud-Ordner gespeichert. App neu starten.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen'), centerTitle: false),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Cloud-Ordner (Dropbox / OneDrive)'),
            subtitle: Text(
              _cloudDirectory ?? 'Noch nicht konfiguriert – App-Dokumente werden verwendet',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDirectory,
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0+1'),
          ),
        ],
      ),
    );
  }
}
