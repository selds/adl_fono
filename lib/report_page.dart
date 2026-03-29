import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

import 'models/adl_protocol.dart';
import 'models/paciente_ficha.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  String _csvField(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _buildCsv({
    required List<PacienteFicha> fichas,
    required Map<String, int> protocolosPorPaciente,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Nome da criança,Data de nascimento,Data da avaliação,Avaliador,Especialidade,Protocolos ADL,Última atualização',
    );

    for (final ficha in fichas) {
      final quantidade = protocolosPorPaciente[ficha.id] ?? 0;
      buffer.writeln(
        [
          _csvField(ficha.nomeCrianca),
          _csvField(ficha.dataNascimento),
          _csvField(ficha.dataAvaliacao),
          _csvField(ficha.avaliador),
          _csvField(ficha.especialidade),
          _csvField('$quantidade'),
          _csvField(ficha.savedAt.toLocal().toString().substring(0, 16)),
        ].join(','),
      );
    }

    return buffer.toString();
  }

  Future<Uint8List> _buildPdfBytes({
    required List<PacienteFicha> fichas,
    required int totalProtocolos,
    required int semProtocolo,
    required Map<String, int> protocolosPorPaciente,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Header(level: 0, child: pw.Text('Relatório ADL')),
          pw.Text('Data de geração: ${DateTime.now().toLocal()}'),
          pw.SizedBox(height: 12),
          pw.Text('Pacientes cadastrados: ${fichas.length}'),
          pw.Text('Protocolos ADL: $totalProtocolos'),
          pw.Text('Pacientes sem protocolo: $semProtocolo'),
          pw.SizedBox(height: 16),
          pw.Text(
            'Pacientes e quantidade de protocolos',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Paciente',
              'Nascimento',
              'Avaliação',
              'Avaliador',
              'Protocolos',
            ],
            data: fichas
                .map(
                  (ficha) => [
                    ficha.nomeCrianca,
                    ficha.dataNascimento,
                    ficha.dataAvaliacao,
                    ficha.avaliador,
                    (protocolosPorPaciente[ficha.id] ?? 0).toString(),
                  ],
                )
                .toList(growable: false),
          ),
        ],
      ),
    );

    return Uint8List.fromList(await doc.save());
  }

  Future<void> _exportCsv(
    BuildContext context, {
    required List<PacienteFicha> fichas,
    required Map<String, int> protocolosPorPaciente,
  }) async {
    try {
      final csv = _buildCsv(
        fichas: fichas,
        protocolosPorPaciente: protocolosPorPaciente,
      );

      await FileSaver.instance.saveFile(
        name: 'relatorio_adl_${DateTime.now().millisecondsSinceEpoch}',
        bytes: Uint8List.fromList(utf8.encode(csv)),
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo CSV exportado com sucesso.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao exportar CSV: $e')));
    }
  }

  Future<void> _exportPdf(
    BuildContext context, {
    required List<PacienteFicha> fichas,
    required List<AdlProtocol> protocolos,
    required int semProtocolo,
    required Map<String, int> protocolosPorPaciente,
  }) async {
    try {
      final bytes = await _buildPdfBytes(
        fichas: fichas,
        totalProtocolos: protocolos.length,
        semProtocolo: semProtocolo,
        protocolosPorPaciente: protocolosPorPaciente,
      );

      await FileSaver.instance.saveFile(
        name: 'relatorio_adl_${DateTime.now().millisecondsSinceEpoch}',
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo PDF exportado com sucesso.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao exportar PDF: $e')));
    }
  }

  LinearGradient _primaryGradientFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        colors: [Color(0xFF3D4DA8), Color(0xFF5A3C86)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  LinearGradient _backgroundGradientFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        colors: [Color(0xFF11141C), Color(0xFF1A1F2B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFFF3F5FB), Color(0xFFEDEFF7)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryGradient = _primaryGradientFor(theme.brightness);
    final backgroundGradient = _backgroundGradientFor(theme.brightness);

    final fichas = [...FichaRepository.all]
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    final protocolos = [...AdlProtocolRepository.all]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final protocolosPorPaciente = <String, int>{};
    for (final protocolo in protocolos) {
      protocolosPorPaciente.update(
        protocolo.pacienteId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final semProtocolo = fichas
        .where((ficha) => (protocolosPorPaciente[ficha.id] ?? 0) == 0)
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Relatórios'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: primaryGradient),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 3,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(gradient: primaryGradient),
                      padding: const EdgeInsets.all(16),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumo de atendimento',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Painel rápido com volume de pacientes e protocolos ADL registrados.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricCard(
                        label: 'Pacientes cadastrados',
                        value: fichas.length.toString(),
                        icon: Icons.child_care,
                        colorScheme: colorScheme,
                      ),
                      _MetricCard(
                        label: 'Protocolos ADL',
                        value: protocolos.length.toString(),
                        icon: Icons.assignment_turned_in_outlined,
                        colorScheme: colorScheme,
                      ),
                      _MetricCard(
                        label: 'Pacientes sem protocolo',
                        value: semProtocolo.toString(),
                        icon: Icons.warning_amber_outlined,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: fichas.isEmpty
                            ? null
                            : () => _exportCsv(
                                context,
                                fichas: fichas,
                                protocolosPorPaciente: protocolosPorPaciente,
                              ),
                        icon: const Icon(Icons.table_view_outlined),
                        label: const Text('Exportar CSV'),
                      ),
                      OutlinedButton.icon(
                        onPressed: fichas.isEmpty
                            ? null
                            : () => _exportPdf(
                                context,
                                fichas: fichas,
                                protocolos: protocolos,
                                semProtocolo: semProtocolo,
                                protocolosPorPaciente: protocolosPorPaciente,
                              ),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Exportar PDF'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Card(
                    elevation: 2,
                    color: theme.brightness == Brightness.dark
                        ? colorScheme.surfaceContainerLow
                        : Colors.white.withAlpha((0.94 * 255).round()),
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          color: colorScheme.primaryContainer,
                          child: Text(
                            'Pacientes e quantidade de protocolos',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        fichas.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'Nenhum paciente cadastrado até o momento.',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(12),
                                itemCount: fichas.length,
                                separatorBuilder: (_, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final ficha = fichas[index];
                                  final quantidade =
                                      protocolosPorPaciente[ficha.id] ?? 0;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          colorScheme.secondaryContainer,
                                      foregroundColor:
                                          colorScheme.onSecondaryContainer,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      ficha.nomeCrianca,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Última atualização: ${ficha.savedAt.toLocal().toString().substring(0, 16)}',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: quantidade > 0
                                            ? colorScheme.tertiaryContainer
                                            : colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        quantidade > 0
                                            ? '$quantidade protocolo(s)'
                                            : 'Sem protocolo',
                                        style: TextStyle(
                                          color: quantidade > 0
                                              ? colorScheme.onTertiaryContainer
                                              : colorScheme.onErrorContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.colorScheme,
  });

  final String label;
  final String value;
  final IconData icon;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
