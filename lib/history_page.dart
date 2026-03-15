import 'package:flutter/material.dart';

import 'models/adl_protocol.dart';
import 'models/paciente_ficha.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _searchQuery = '';

  String _formatAge(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length != 3) return '';
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) return '';

      final birthDate = DateTime(year, month, day);
      final now = DateTime.now();
      if (birthDate.isAfter(now)) return '';

      final years =
          now.year -
          birthDate.year -
          ((now.month < birthDate.month ||
                  (now.month == birthDate.month && now.day < birthDate.day))
              ? 1
              : 0);

      if (years >= 1) {
        return '$years ano${years == 1 ? '' : 's'}';
      }

      final months =
          (now.year - birthDate.year) * 12 +
          (now.month - birthDate.month) -
          (now.day < birthDate.day ? 1 : 0);

      if (months < 0) return '';
      return '$months mes${months == 1 ? '' : 'es'}';
    } catch (_) {
      return '';
    }
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente remover este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (!mounted) return false;

    return result == true;
  }

  Future<void> _removeEntry(PacienteFicha ficha) async {
    await FichaRepository.remove(ficha);

    if (!mounted) return;

    setState(() {});
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registro removido'),
        content: const Text('O registro foi removido do histórico.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showProtocolsForPaciente(String pacienteId, String nome) async {
    final protocols = AdlProtocolRepository.forPaciente(pacienteId);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Protocolos de $nome'),
        content: SizedBox(
          width: double.maxFinite,
          child: protocols.isEmpty
              ? const Text('Nenhum protocolo registrado para este paciente.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: protocols.length,
                  itemBuilder: (context, index) {
                    final protocol = protocols[index];
                    return ListTile(
                      title: Text(protocol.createdAt.toLocal().toString()),
                      subtitle: Text(
                        'Data: ${protocol.createdAt.toLocal().toString().substring(0, 10)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed(
                                '/adl',
                                arguments: {
                                  'pacienteId': pacienteId,
                                  'protocolId': protocol.id,
                                },
                              )
                              .then((_) {
                                if (!mounted) return;
                                setState(() {});
                              });
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushNamed('/adl', arguments: {'pacienteId': pacienteId})
                  .then((_) {
                    if (!mounted) return;
                    setState(() {});
                  });
            },
            child: const Text('Novo protocolo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = FichaRepository.all;

    final grouped = <String, List<PacienteFicha>>{};
    for (final e in entries) {
      grouped.putIfAbsent(e.nomeCrianca, () => []).add(e);
    }

    final names = grouped.keys.toList()..sort();
    final filteredNames = names
        .where(
          (name) => name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: entries.isEmpty
          ? const Center(
              child: Text(
                'Nenhum registro encontrado.\nSalve um formulário para iniciar o histórico.',
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nome',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredNames.length,
                    itemBuilder: (context, index) {
                      final name = filteredNames[index];
                      final items = grouped[name]!;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          title: Text(name),
                          subtitle: Text('Registros: ${items.length}'),
                          children: items
                              .map(
                                (item) => Dismissible(
                                  key: ValueKey(
                                    '${item.nomeCrianca}_${item.savedAt.toIso8601String()}',
                                  ),
                                  direction: DismissDirection.horizontal,
                                  background: Container(
                                    color: Colors.green,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                  secondaryBackground: Container(
                                    color: Colors.redAccent,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (direction ==
                                        DismissDirection.startToEnd) {
                                      await Navigator.of(
                                        context,
                                      ).pushNamed('/edit', arguments: item);
                                      setState(() {});
                                      return false;
                                    }

                                    if (direction ==
                                        DismissDirection.endToStart) {
                                      return await _confirmDelete();
                                    }

                                    return false;
                                  },
                                  onDismissed: (_) async =>
                                      await _removeEntry(item),
                                  child: Builder(
                                    builder: (context) {
                                      final protocols =
                                          AdlProtocolRepository.forPaciente(
                                            item.id,
                                          );
                                      return ListTile(
                                        title: Text(
                                          item.dataAvaliacao.isEmpty
                                              ? 'Sem data'
                                              : '${item.dataAvaliacao} • ${_formatAge(item.dataNascimento)}',
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sexo: ${item.sexo} | Diagnóstico: ${item.diagnostico}',
                                            ),
                                            Text(
                                              'Responsável: ${item.responsavel}',
                                            ),
                                            Text(
                                              'Avaliador: ${item.avaliador} | Especialidade: ${item.especialidade}',
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Atividades: ${item.atividades}',
                                            ),
                                            Text(
                                              'Ambiente: ${item.ambienteFamiliar}',
                                            ),
                                            Text(
                                              'Demanda: ${item.demandaFamiliar}',
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Protocolos ADL: ${protocols.length}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        isThreeLine: true,
                                        onTap: () => _showProtocolsForPaciente(
                                          item.id,
                                          name,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                              .toList(),
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
