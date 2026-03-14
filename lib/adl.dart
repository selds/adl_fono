import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'models/paciente_ficha.dart';
import 'profile_page.dart';

class FichaPacientePage extends StatefulWidget {
  final PacienteFicha? initialFicha;
  final void Function(PacienteFicha)? onSave;

  const FichaPacientePage({super.key, this.initialFicha, this.onSave});

  @override
  State<FichaPacientePage> createState() => _FichaPacientePageState();
}

class _FichaPacientePageState extends State<FichaPacientePage> {
  final TextEditingController _nomeCriancaController = TextEditingController();
  final TextEditingController _dataNascController = TextEditingController();
  String? _selectedSexo;
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _responsavelController = TextEditingController();
  final TextEditingController _dataAvaliacaoController =
      TextEditingController();
  final TextEditingController _avaliadorController = TextEditingController();
  final TextEditingController _especialidadeController =
      TextEditingController();
  final TextEditingController _atividadesController = TextEditingController();
  final TextEditingController _ambienteController = TextEditingController();
  final TextEditingController _demandaController = TextEditingController();

  final MaskTextInputFormatter _dateMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

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
    final initial = widget.initialFicha;
    if (initial != null) {
      _nomeCriancaController.text = initial.nomeCrianca;
      _dataNascController.text = initial.dataNascimento;
      _selectedSexo = initial.sexo.isEmpty ? null : initial.sexo;
      _diagnosticoController.text = initial.diagnostico;
      _responsavelController.text = initial.responsavel;
      _dataAvaliacaoController.text = initial.dataAvaliacao;
      _avaliadorController.text = initial.avaliador;
      _especialidadeController.text = initial.especialidade;
      _atividadesController.text = initial.atividades;
      _ambienteController.text = initial.ambienteFamiliar;
      _demandaController.text = initial.demandaFamiliar;

      // Tentativa de parse das datas para manter a seleção do DatePicker
      try {
        _dataNasc = initial.dataNascimento.isNotEmpty
            ? DateFormat('dd/MM/yyyy').parse(initial.dataNascimento)
            : null;
      } catch (_) {
        _dataNasc = null;
      }
      try {
        _dataAvaliacao = initial.dataAvaliacao.isNotEmpty
            ? DateFormat('dd/MM/yyyy').parse(initial.dataAvaliacao)
            : null;
      } catch (_) {
        _dataAvaliacao = null;
      }
    }
  }

  @override
  void dispose() {
    _nomeCriancaController.dispose();
    _dataNascController.dispose();
    _diagnosticoController.dispose();
    _responsavelController.dispose();
    _dataAvaliacaoController.dispose();
    _avaliadorController.dispose();
    _especialidadeController.dispose();
    _atividadesController.dispose();
    _ambienteController.dispose();
    _demandaController.dispose();
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

  Future<void> _saveFicha() async {
    final nome = _nomeCriancaController.text.trim();
    if (nome.isEmpty) {
      await _showAlert('Por favor, informe o nome da criança.');
      return;
    }

    final ficha = PacienteFicha(
      nomeCrianca: nome,
      dataNascimento: _dataNascController.text.trim(),
      sexo: _selectedSexo?.trim() ?? '',
      diagnostico: _diagnosticoController.text.trim(),
      responsavel: _responsavelController.text.trim(),
      dataAvaliacao: _dataAvaliacaoController.text.trim(),
      avaliador: _avaliadorController.text.trim(),
      especialidade: _especialidadeController.text.trim(),
      atividades: _atividadesController.text.trim(),
      ambienteFamiliar: _ambienteController.text.trim(),
      demandaFamiliar: _demandaController.text.trim(),
    );

    if (widget.onSave != null && widget.initialFicha != null) {
      final updatedFicha = PacienteFicha(
        nomeCrianca: ficha.nomeCrianca,
        dataNascimento: ficha.dataNascimento,
        sexo: ficha.sexo,
        diagnostico: ficha.diagnostico,
        responsavel: ficha.responsavel,
        dataAvaliacao: ficha.dataAvaliacao,
        avaliador: ficha.avaliador,
        especialidade: ficha.especialidade,
        atividades: ficha.atividades,
        ambienteFamiliar: ficha.ambienteFamiliar,
        demandaFamiliar: ficha.demandaFamiliar,
        savedAt: widget.initialFicha!.savedAt,
      );

      widget.onSave!(updatedFicha);
      Navigator.of(context).pop();
      return;
    }

    FichaRepository.add(ficha);

    await _showAlert('Ficha salva no histórico.');
    _clearForm();
  }

  String _calculateAge(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length != 3) return '';
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) return '';

      final birth = DateTime(year, month, day);
      final now = DateTime.now();
      if (birth.isAfter(now)) return '';

      final years =
          now.year -
          birth.year -
          ((now.month < birth.month ||
                  (now.month == birth.month && now.day < birth.day))
              ? 1
              : 0);
      if (years >= 1) {
        return '$years ano${years == 1 ? '' : 's'}';
      }

      final months =
          (now.year - birth.year) * 12 +
          (now.month - birth.month) -
          (now.day < birth.day ? 1 : 0);
      if (months < 0) return '';
      return '$months mes${months == 1 ? '' : 'es'}';
    } catch (_) {
      return '';
    }
  }

  void _clearForm() {
    _nomeCriancaController.clear();
    _dataNascController.clear();
    _diagnosticoController.clear();
    _responsavelController.clear();
    _dataAvaliacaoController.clear();
    _avaliadorController.clear();
    _especialidadeController.clear();
    _atividadesController.clear();
    _ambienteController.clear();
    _demandaController.clear();
    setState(() {
      _selectedSexo = null;
      _dataNasc = null;
      _dataAvaliacao = null;
    });
  }

  Future<void> _showAlert(String message) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    TextEditingController controller, {
    String? hintText,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      keyboardType: onTap != null ? TextInputType.datetime : TextInputType.text,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white.withAlpha((0.9 * 255).round()),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        suffixIcon: onTap != null
            ? IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: onTap,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu),
              tooltip: 'Menu',
              onSelected: (value) {
                switch (value) {
                  case 'history':
                    Navigator.of(context).pushNamed('/history');
                    break;
                  case 'settings':
                    _showAlert('Abrir configurações...');
                    break;
                  case 'help':
                    _showAlert('Abrir ajuda...');
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'history', child: Text('Histórico')),
                PopupMenuItem(value: 'settings', child: Text('Configurações')),
                PopupMenuItem(value: 'help', child: Text('Ajuda')),
              ],
            ),
            const SizedBox(width: 8),
            const Text('Menu', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
        ],
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
                            hintText: 'dd/MM/yyyy',
                            onTap: () =>
                                _selectDate(context, _dataNasc, (date) {
                                  setState(() {
                                    _dataNasc = date;
                                    _dataNascController.text = DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(date);
                                  });
                                }),
                            inputFormatters: [_dateMask],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Builder(
                          builder: (context) {
                            final age = _calculateAge(_dataNascController.text);
                            if (age.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 148.0,
                                bottom: 8,
                              ),
                              child: Text(
                                'Idade: $age',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            );
                          },
                        ),
                        _HeaderRow(
                          label: 'Sexo',
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedSexo,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withAlpha(
                                (0.9 * 255).round(),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Masculino',
                                child: Text('Masculino'),
                              ),
                              DropdownMenuItem(
                                value: 'Feminino',
                                child: Text('Feminino'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedSexo = value;
                              });
                            },
                          ),
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
                            hintText: 'dd/MM/yyyy',
                            onTap: () =>
                                _selectDate(context, _dataAvaliacao, (date) {
                                  setState(() {
                                    _dataAvaliacao = date;
                                    _dataAvaliacaoController.text = DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(date);
                                  });
                                }),
                            inputFormatters: [_dateMask],
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
                              controller: _atividadesController,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            _SectionField(
                              title: 'AMBIENTE FAMILIAR',
                              subtitle:
                                  'Quem mora na casa? Ex.: pai, mãe, irmãos...',
                              controller: _ambienteController,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),
                            _SectionField(
                              title: 'DEMANDA FAMILIAR',
                              subtitle:
                                  'Descreva as principais demandas da família. Ex.: atraso de linguagem...',
                              controller: _demandaController,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveFicha,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Salvar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/history');
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Histórico'),
                        ),
                      ),
                    ),
                  ],
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
  final TextEditingController controller;

  const _SectionField({
    required this.title,
    required this.subtitle,
    required this.controller,
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
          controller: controller,
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
