import 'dart:io';

import 'package:flutter/material.dart';

void main() => runApp(const HostsEditorApp());

class HostsEditorApp extends StatelessWidget {
  const HostsEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HostsEditorScreen(),
    );
  }
}

class HostsEditorScreen extends StatefulWidget {
  const HostsEditorScreen({super.key});

  @override
  State<HostsEditorScreen> createState() => _HostsEditorScreenState();
}

class _HostsEditorScreenState extends State<HostsEditorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _status = '';
  final String hostsPath = r'C:\Windows\System32\drivers\etc\hosts';

  @override
  void initState() {
    super.initState();
    _loadHostsFile();
  }

  void _loadHostsFile() async {
    try {
      final file = File(hostsPath);
      final contents = await file.readAsString();
      setState(() {
        _controller.text = contents;
        _status = 'Arquivo carregado com sucesso.';
      });
    } catch (e) {
      setState(() {
        _status = 'Erro ao carregar: $e';
      });
    }
  }

  void _saveHostsFile() async {
    try {
      final file = File(hostsPath);
      await file.writeAsString(_controller.text);
      setState(() {
        _status = 'Arquivo salvo com sucesso.';
      });
    } catch (e) {
      setState(() {
        _status = 'Erro ao salvar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor de Hosts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontFamily: 'Courier'),
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Conteúdo do arquivo hosts',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(_status),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loadHostsFile,
                  child: const Text('Recarregar'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _saveHostsFile,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
