import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'screens/hosts_editor_screen.dart';

void main() => runApp(const HostsEditorApp());

class HostsEditorApp extends StatefulWidget {
  const HostsEditorApp({super.key});

  @override
  State<HostsEditorApp> createState() => _HostsEditorAppState();
}

class _HostsEditorAppState extends State<HostsEditorApp> {
  bool _isDarkMode = true; // Padrão dark mode

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: HostsEditorScreen(
          onThemeToggle: _toggleTheme,
          isDarkMode: _isDarkMode,
        ),
      ),
    );
  }
}
