import 'package:adl_fono/models/access_log_entry.dart';
import 'package:adl_fono/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccessLogsPage extends StatefulWidget {
  const AccessLogsPage({super.key});

  @override
  State<AccessLogsPage> createState() => _AccessLogsPageState();
}

class _AccessLogsPageState extends State<AccessLogsPage> {
  late Future<List<AccessLogEntry>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = AuthService.getAccessLogs();
  }

  String _formatDate(DateTime value) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(value.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs de Acesso')),
      body: FutureBuilder<List<AccessLogEntry>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Erro ao carregar logs: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _logsFuture = AuthService.getAccessLogs();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final logs = snapshot.data ?? const <AccessLogEntry>[];
          if (logs.isEmpty) {
            return const Center(child: Text('Nenhum login registrado ainda.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _logsFuture = AuthService.getAccessLogs();
              });
              await _logsFuture;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: logs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = logs[index];
                final roleLabel = log.role == 'admin'
                    ? 'Administrador'
                    : 'Fonoaudiólogo';

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        log.role == 'admin'
                            ? Icons.admin_panel_settings
                            : Icons.person,
                      ),
                    ),
                    title: Text(
                      log.displayName.isEmpty ? log.email : log.displayName,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.email),
                        const SizedBox(height: 4),
                        Text('Data/Hora: ${_formatDate(log.loginAt)}'),
                        Text('Perfil: $roleLabel'),
                        Text('UID: ${log.uid}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
