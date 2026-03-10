import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FichaPacientePage extends StatefulWidget {
  const FichaPacientePage({super.key});

  @override
  State<FichaPacientePage> createState() => _FichaPacientePageState();
}

class _FichaPacientePageState extends State<FichaPacientePage> {
  final TextEditingController _nomeCriancaController = TextEditingController();
  final TextEditingController _dataNascController = TextEditingController();
  final TextEditingController _sexoController = TextEditingController();
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _responsavelController = TextEditingController();
  final TextEditingController _dataAvaliacaoController =
      TextEditingController();
  final TextEditingController _avaliadorController = TextEditingController();
  final TextEditingController _especialidadeController =
      TextEditingController();

  DateTime? _dataNasc;
  DateTime? _dataAvaliacao;

  LinearGradient get _primaryGradient => const LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initState() {
    super.initState();
    // Limpar cache: todos os campos começam vazios
  }

  @override
  void dispose() {
    _nomeCriancaController.dispose();
    _dataNascController.dispose();
    _sexoController.dispose();
    _diagnosticoController.dispose();
    _responsavelController.dispose();
    _dataAvaliacaoController.dispose();
    _avaliadorController.dispose();
    _especialidadeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Widget _buildEditableField(
    TextEditingController controller, {
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withAlpha((0.9 * 255).round()),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        suffixIcon: onTap != null ? const Icon(Icons.calendar_today) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: const Text('Dados do Paciente'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: _primaryGradient),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho (faixa vermelha da planilha)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(gradient: _primaryGradient),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _HeaderRow(
                          label: 'Nome da Criança',
                          child: _buildEditableField(_nomeCriancaController),
                        ),
                        const SizedBox(height: 8),
                        _HeaderRow(
                          label: 'Data de Nascimento',
                          child: _buildEditableField(
                            _dataNascController,
                            onTap: () =>
                                _selectDate(context, _dataNasc, (date) {
                                  setState(() {
                                    _dataNasc = date;
                                    _dataNascController.text = DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(date);
                                  });
                                }),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _HeaderRow(
                          label: 'Sexo',
                          child: _buildEditableField(_sexoController),
                        ),
                        const SizedBox(height: 8),
                        _HeaderRow(
                          label: 'Diagnóstico',
                          child: _buildEditableField(_diagnosticoController),
                        ),
                        const SizedBox(height: 8),
                        _HeaderRow(
                          label: 'Responsável',
                          child: _buildEditableField(_responsavelController),
                        ),
                        const SizedBox(height: 8),
                        _HeaderRow(
                          label: 'Data da Avaliação',
                          child: _buildEditableField(
                            _dataAvaliacaoController,
                            onTap: () =>
                                _selectDate(context, _dataAvaliacao, (date) {
                                  setState(() {
                                    _dataAvaliacao = date;
                                    _dataAvaliacaoController.text = DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(date);
                                  });
                                }),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _HeaderRow(
                          label: 'Avaliador(a)',
                          child: _buildEditableField(_avaliadorController),
                        ),
                        const SizedBox(height: 8),
                        _HeaderRow(
                          label: 'Especialidade',
                          child: _buildEditableField(_especialidadeController),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Card de Anamnese
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título ANAMNESE com gradiente
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: _primaryGradient,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'ANAMNESE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SectionField(
                              title: 'ATIVIDADES',
                              subtitle:
                                  'Descreva as principais atividades que a criança executa atualmente...',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            _SectionField(
                              title: 'AMBIENTE FAMILIAR',
                              subtitle:
                                  'Quem mora na casa? Ex.: pai, mãe, irmãos...',
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),
                            _SectionField(
                              title: 'DEMANDA FAMILIAR',
                              subtitle:
                                  'Descreva as principais demandas da família. Ex.: atraso de linguagem...',
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _HeaderRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SectionField extends StatelessWidget {
  final String title;
  final String subtitle;
  final int maxLines;

  const _SectionField({
    required this.title,
    required this.subtitle,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextFormField(
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }
}
