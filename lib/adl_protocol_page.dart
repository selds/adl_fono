import 'package:flutter/material.dart';

import 'models/adl_protocol.dart';
import 'models/paciente_ficha.dart';

class AdlProtocolPage extends StatefulWidget {
  const AdlProtocolPage({super.key, required this.pacienteId, this.protocol});

  final String pacienteId;
  final AdlProtocol? protocol;

  @override
  State<AdlProtocolPage> createState() => _AdlProtocolPageState();
}

class _AdlProtocolPageState extends State<AdlProtocolPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late final List<_AdlAgeGroup> _groups;
  late String _nomeCrianca;
  bool _showFab = true;
  double _lastScrollOffset = 0;

  final Map<String, bool?> _answers = <String, bool?>{};
  final Map<String, TextEditingController> _notesControllers =
      <String, TextEditingController>{};

  final TextEditingController _q1ExpText = TextEditingController();
  final TextEditingController _q2ExpText = TextEditingController();
  final TextEditingController _q3ExpText = TextEditingController();
  bool? _q1ExpMet;
  bool? _q2ExpMet;
  bool? _q3ExpMet;

  int _selectedGroupIndex = 0;
  _AdlSection _selectedSection = _AdlSection.compreensiva;

  LinearGradient _primaryGradientFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        colors: [Color(0xFF3D4DA8), Color(0xFF5A3C86)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
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
  void initState() {
    super.initState();
    _groups = _buildComprehensiveGroups();
    _loadExistingAnswers();
    _loadPacienteName();
    _scrollController.addListener(_handleFabVisibilityOnScroll);
  }

  void _loadPacienteName() {
    try {
      final fichas = FichaRepository.all;
      final ficha = fichas.firstWhere((f) => f.id == widget.pacienteId);
      _nomeCrianca = ficha.nomeCrianca;
    } catch (e) {
      _nomeCrianca = 'Paciente';
    }
  }

  void _loadExistingAnswers() {
    final receptive = widget.protocol?.receptiveAnswers ?? <String, dynamic>{};
    final expressive =
        widget.protocol?.expressiveAnswers ?? <String, dynamic>{};

    for (final group in _groups) {
      for (final question in group.questions) {
        for (final item in question.items) {
          final key = _answerKey(question.id, item.id);
          final value = receptive[key];
          _answers[key] = value is bool ? value : null;
        }

        final noteKey = _noteKey(question.id);
        final noteValue = receptive[noteKey] as String? ?? '';
        _notesControllers[noteKey] = TextEditingController(text: noteValue);
      }
    }

    _q1ExpText.text = expressive['q1Text'] as String? ?? '';
    _q2ExpText.text = expressive['q2Text'] as String? ?? '';
    _q3ExpText.text = expressive['q3Text'] as String? ?? '';
    _q1ExpMet = expressive['q1Met'] as bool?;
    _q2ExpMet = expressive['q2Met'] as bool?;
    _q3ExpMet = expressive['q3Met'] as bool?;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleFabVisibilityOnScroll);
    _scrollController.dispose();
    for (final controller in _notesControllers.values) {
      controller.dispose();
    }
    _q1ExpText.dispose();
    _q2ExpText.dispose();
    _q3ExpText.dispose();
    super.dispose();
  }

  void _handleFabVisibilityOnScroll() {
    if (!_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    final delta = currentOffset - _lastScrollOffset;

    if (currentOffset <= 4) {
      if (!_showFab) setState(() => _showFab = true);
      _lastScrollOffset = currentOffset;
      return;
    }

    if (delta > 8 && _showFab) {
      setState(() => _showFab = false);
    } else if (delta < -8 && !_showFab) {
      setState(() => _showFab = true);
    }

    _lastScrollOffset = currentOffset;
  }

  String _answerKey(int questionId, String itemId) =>
      'lc_q${questionId}_$itemId';

  String _noteKey(int questionId) => 'lc_q${questionId}_note';

  int _correctCount(_AdlQuestion question) {
    return question.items.where((item) {
      final key = _answerKey(question.id, item.id);
      return _answers[key] == true;
    }).length;
  }

  int _questionScore(_AdlQuestion question) {
    return _correctCount(question) >= question.minCorrect ? 1 : 0;
  }

  int _groupScore(_AdlAgeGroup group) {
    return group.questions.fold<int>(
      0,
      (total, question) => total + _questionScore(question),
    );
  }

  int get _comprehensiveTotal {
    return _groups.fold<int>(0, (total, group) => total + _groupScore(group));
  }

  int get _maxComprehensiveTotal {
    return _groups.fold<int>(
      0,
      (total, group) => total + group.questions.length,
    );
  }

  int get _expressivaTotal {
    final items = [_q1ExpMet, _q2ExpMet, _q3ExpMet];
    return items.where((v) => v == true).length;
  }

  bool _isCurrentGroupCompleted(_AdlAgeGroup group) {
    for (final question in group.questions) {
      for (final item in question.items) {
        final key = _answerKey(question.id, item.id);
        if (_answers[key] == null) return false;
      }
    }
    return true;
  }

  bool get _allComprehensiveCompleted {
    for (final group in _groups) {
      if (!_isCurrentGroupCompleted(group)) return false;
    }
    return true;
  }

  Future<void> _saveProtocol({required bool completedComprehensive}) async {
    if (!_formKey.currentState!.validate()) return;

    final previousReceptive = Map<String, dynamic>.from(
      widget.protocol?.receptiveAnswers ?? {},
    );

    final receptiveAnswers = <String, dynamic>{
      ...previousReceptive,
      'lcCompleted': completedComprehensive,
      'lcCompletedAt': completedComprehensive
          ? DateTime.now().toIso8601String()
          : previousReceptive['lcCompletedAt'],
      'lcCurrentBandIndex': _selectedGroupIndex,
      'lcTotal': _comprehensiveTotal,
      'lcMaxTotal': _maxComprehensiveTotal,
    };

    for (final group in _groups) {
      for (final question in group.questions) {
        receptiveAnswers['lc_q${question.id}_score'] = _questionScore(question);
        receptiveAnswers['lc_q${question.id}_acertos'] = _correctCount(
          question,
        );

        final noteKey = _noteKey(question.id);
        receptiveAnswers[noteKey] =
            _notesControllers[noteKey]?.text.trim() ?? '';

        for (final item in question.items) {
          final key = _answerKey(question.id, item.id);
          receptiveAnswers[key] = _answers[key];
        }
      }
    }

    final protocol = AdlProtocol(
      pacienteId: widget.pacienteId,
      receptiveAnswers: receptiveAnswers,
      expressiveAnswers: {
        ...Map<String, dynamic>.from(widget.protocol?.expressiveAnswers ?? {}),
        'q1Met': _q1ExpMet,
        'q2Met': _q2ExpMet,
        'q3Met': _q3ExpMet,
        'q1Text': _q1ExpText.text.trim(),
        'q2Text': _q2ExpText.text.trim(),
        'q3Text': _q3ExpText.text.trim(),
        'q1Score': _q1ExpMet == true ? '1' : '0',
        'q2Score': _q2ExpMet == true ? '1' : '0',
        'q3Score': _q3ExpMet == true ? '1' : '0',
      },
      id: widget.protocol?.id,
      createdAt: widget.protocol?.createdAt,
    );

    if (widget.protocol == null) {
      await AdlProtocolRepository.add(protocol);
    } else {
      await AdlProtocolRepository.update(widget.protocol!, protocol);
    }
  }

  Future<void> _onFinishComprehensive() async {
    if (!_allComprehensiveCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Responda todos os itens da linguagem compreensiva antes de concluir.',
          ),
        ),
      );
      return;
    }

    await _saveProtocol(completedComprehensive: true);
    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Linguagem compreensiva concluída'),
        content: const Text(
          'As respostas da parte compreensiva foram salvas. Deseja seguir para a linguagem expressiva agora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Depois'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ir para expressiva'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (result == true) {
      try {
        Navigator.of(context).pushNamed(
          '/adl-expressiva',
          arguments: {
            'pacienteId': widget.pacienteId,
            'protocolId': widget.protocol?.id,
          },
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Etapa de linguagem expressiva ainda não está disponível nesta versão.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _onSaveDraft() async {
    await _saveProtocol(completedComprehensive: false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rascunho da linguagem compreensiva salvo.'),
      ),
    );
  }

  void _goNextGroup() {
    if (_selectedGroupIndex >= _groups.length - 1) return;
    setState(() => _selectedGroupIndex += 1);
    _scrollToTop();
  }

  void _scrollToTop() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildScoreChip(_AdlQuestion question) {
    final score = _questionScore(question);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: score == 1
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: score == 1 ? colorScheme.primary : colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$score/1',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: score == 1
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(_AdlQuestion question) {
    final noteKey = _noteKey(question.id);
    final noteController = _notesControllers[noteKey]!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${question.id}',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildScoreChip(question),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Material: ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextSpan(
                          text: question.material,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Procedimento: ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextSpan(
                          text: question.procedure,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ...question.items.map((item) {
              final answerKey = _answerKey(question.id, item.id);
              final value = _answers[answerKey];
              return Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '(${item.id}) ${item.label}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildYesNoControl(
                      value: value,
                      onChanged: (newValue) {
                        setState(() {
                          _answers[answerKey] = newValue;
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
            TextFormField(
              controller: noteController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Observações da questão (opcional)',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Regra de pontuação: ${question.scoreRule}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYesNoControl({
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value == true,
              side: BorderSide(color: colorScheme.outline),
              onChanged: (_) => onChanged(value == true ? null : true),
            ),
            Text('Sim', style: TextStyle(color: colorScheme.onSurface)),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value == false,
              side: BorderSide(color: colorScheme.outline),
              onChanged: (_) => onChanged(value == false ? null : false),
            ),
            Text('Não', style: TextStyle(color: colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupView() {
    final group = _groups[_selectedGroupIndex];
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da faixa
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Linguagem Compreensiva',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                group.label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pontuação: ${_groupScore(group)}/${group.questions.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Perguntas
        ...group.questions.map(_buildQuestionCard),
      ],
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final currentGroup = _groups[_selectedGroupIndex];
    final progress = (_selectedGroupIndex + 1) / _groups.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.protocol == null
                ? 'Novo Protocolo ADL'
                : 'Editar Protocolo ADL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Responda uma faixa etária por vez. Ao finalizar toda a linguagem compreensiva, você poderá seguir para a linguagem expressiva.',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.format_list_numbered,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Faixa ${_selectedGroupIndex + 1} de ${_groups.length}: ${currentGroup.label}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(99),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedSection == _AdlSection.compreensiva
                            ? '$_comprehensiveTotal/$_maxComprehensiveTotal'
                            : '$_expressivaTotal/3',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paciente',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nomeCrianca,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return SegmentedButton<_AdlSection>(
      segments: const [
        ButtonSegment<_AdlSection>(
          value: _AdlSection.compreensiva,
          label: Text('2. Compreensiva'),
          icon: Icon(Icons.hearing_outlined),
        ),
        ButtonSegment<_AdlSection>(
          value: _AdlSection.expressiva,
          label: Text('3. Expressiva'),
          icon: Icon(Icons.record_voice_over_outlined),
        ),
      ],
      selected: {_selectedSection},
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surface;
        }),
      ),
      onSelectionChanged: (selection) {
        setState(() => _selectedSection = selection.first);
      },
    );
  }

  Widget _buildBandPicker() {
    return DropdownButtonFormField<int>(
      value: _selectedGroupIndex,
      decoration: InputDecoration(
        labelText: 'Tela por faixa etária',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: List.generate(
        _groups.length,
        (index) => DropdownMenuItem<int>(
          value: index,
          child: Text('${index + 1}. ${_groups[index].label}'),
        ),
      ),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedGroupIndex = value);
        _scrollToTop();
      },
    );
  }

  Widget _buildExpressivaQuestion({
    required String title,
    required bool? value,
    required ValueChanged<bool?> onChanged,
    required TextEditingController notes,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                FilterChip(
                  label: const Text('Critério atendido'),
                  selected: value == true,
                  onSelected: (_) => onChanged(value == true ? null : true),
                ),
                FilterChip(
                  label: const Text('Não atendido'),
                  selected: value == false,
                  onSelected: (_) => onChanged(value == false ? null : false),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: notes,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Observações',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpressivaView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildExpressivaQuestion(
          title:
              '1. Participa de brincadeiras com outra pessoa pelo período de 1 a 2 minutos.',
          value: _q1ExpMet,
          onChanged: (v) => setState(() => _q1ExpMet = v),
          notes: _q1ExpText,
        ),
        _buildExpressivaQuestion(
          title: '2. Comunica-se de forma gestual.',
          value: _q2ExpMet,
          onChanged: (v) => setState(() => _q2ExpMet = v),
          notes: _q2ExpText,
        ),
        _buildExpressivaQuestion(
          title:
              '3. Vocaliza sem que movimentos de pernas e braços acompanhem a emissão dos sons.',
          value: _q3ExpMet,
          onChanged: (v) => setState(() => _q3ExpMet = v),
          notes: _q3ExpText,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isLast = _selectedGroupIndex == _groups.length - 1;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SizedBox(
          height: 40,
          child: OutlinedButton.icon(
            onPressed: _onSaveDraft,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Salvar'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(120, 40)),
          ),
        ),
        SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            onPressed: isLast ? _onFinishComprehensive : _goNextGroup,
            icon: Icon(
              isLast ? Icons.check_circle_outline : Icons.navigate_next,
              size: 18,
            ),
            label: Text(isLast ? 'Concluir' : 'Avançar'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 40)),
          ),
        ),
      ],
    );
  }

  Widget _buildBandsProgressStrip() {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _groups.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final group = _groups[index];
          final isSelected = index == _selectedGroupIndex;
          final isCompleted = _isCurrentGroupCompleted(group);

          return ChoiceChip(
            selected: isSelected,
            onSelected: (_) {
              setState(() => _selectedGroupIndex = index);
              _scrollToTop();
            },
            label: Text('${index + 1}'),
            avatar: Icon(
              isCompleted ? Icons.task_alt : Icons.radio_button_unchecked,
              size: 16,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            selectedColor: colorScheme.primary,
            backgroundColor: colorScheme.surface,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          );
        },
      ),
    );
  }

  Future<void> _openQuickActionsMenu() async {
    final isLast = _selectedGroupIndex == _groups.length - 1;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Índice de faixas'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _openBandsMenu();
                },
              ),
              ListTile(
                leading: const Icon(Icons.save_outlined),
                title: const Text('Salvar rascunho'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _onSaveDraft();
                },
              ),
              ListTile(
                leading: Icon(
                  isLast ? Icons.check_circle_outline : Icons.navigate_next,
                ),
                title: Text(isLast ? 'Concluir' : 'Avançar faixa'),
                onTap: () async {
                  Navigator.of(context).pop();
                  if (isLast) {
                    await _onFinishComprehensive();
                  } else {
                    _goNextGroup();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openBandsMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Ir para faixa etária'),
                  subtitle: const Text('Selecione uma faixa para navegar'),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: _groups.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final group = _groups[index];
                      final isSelected = index == _selectedGroupIndex;
                      final isCompleted = _isCurrentGroupCompleted(group);

                      return ListTile(
                        selected: isSelected,
                        leading: CircleAvatar(
                          radius: 14,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(group.label),
                        subtitle: Text(
                          'Pontuação: ${_groupScore(group)}/${group.questions.length}',
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle)
                            : Icon(
                                isCompleted
                                    ? Icons.task_alt
                                    : Icons.radio_button_unchecked,
                              ),
                        onTap: () {
                          setState(() => _selectedGroupIndex = index);
                          Navigator.of(context).pop();
                          _scrollToTop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollableFormContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSectionSelector(),
          const SizedBox(height: 16),
          if (_selectedSection == _AdlSection.compreensiva) ...[
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildBandPicker(),
            const SizedBox(height: 12),
            _buildBandsProgressStrip(),
            const SizedBox(height: 12),
            _buildGroupView(),
          ] else ...[
            SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: _onSaveDraft,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Salvar'),
              ),
            ),
            const SizedBox(height: 12),
            _buildExpressivaView(),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final primaryGradient = _primaryGradientFor(theme.brightness);
    final backgroundGradient = _backgroundGradientFor(theme.brightness);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Protocolo ADL'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: primaryGradient),
        ),
        actions: [
          IconButton(
            tooltip: 'Ir para faixa',
            onPressed: _openBandsMenu,
            icon: const Icon(Icons.menu_book_outlined),
          ),
          IconButton(
            tooltip: 'Ações',
            onPressed: _openQuickActionsMenu,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        offset: _showFab ? Offset.zero : const Offset(0, 2.2),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _showFab ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: FloatingActionButton(
            onPressed: _openQuickActionsMenu,
            mini: true,
            tooltip: '',
            elevation: 0,
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.78,
            ),
            foregroundColor: colorScheme.onSurfaceVariant,
            child: const Icon(Icons.tune, size: 17),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: backgroundGradient),
          child: Form(
            key: _formKey,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _buildScrollableFormContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_AdlAgeGroup> _buildComprehensiveGroups() {
    return [
      _AdlAgeGroup(
        label: '1 ano a 1 ano e 5 meses',
        questions: [
          _AdlQuestion(
            id: 1,
            title: 'Atenção visual',
            material:
                'Brinquedo de interesse da criança ou bolhinhas de sabão.',
            procedure:
                'Mover brinquedo e depois soprar bolinhas, observando acompanhamento visual.',
            scoreRule: '1 ponto quando acompanha com o olhar em (a) ou (b).',
            minCorrect: 1,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Acompanha o brinquedo em movimento.',
              ),
              _AdlQuestionItem(
                id: 'b',
                label: 'Acompanha as bolinhas de sabão.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 2,
            title: 'Atenção auditiva',
            material: 'Brinquedos.',
            procedure:
                'Chamar pelo nome e bater palmas atras/lados para verificar busca da fonte sonora.',
            scoreRule: '1 ponto quando responde em (a) ou (b).',
            minCorrect: 1,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Olha na direcao de quem chamou o nome.',
              ),
              _AdlQuestionItem(
                id: 'b',
                label: 'Procura a fonte sonora ao bater palmas.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 3,
            title: 'Vocabulário compreensivo - objetos familiares',
            material: 'Cachorro, bola, boneca e carro/caminhao.',
            procedure:
                'Pedir para dar cada objeto nomeado pelo examinador/cuidador.',
            scoreRule:
                '1 ponto quando reconhece 3 objetos (ou cuidador confirma no contexto familiar).',
            minCorrect: 3,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Da o cachorro.'),
              _AdlQuestionItem(id: 'b', label: 'Da a bola.'),
              _AdlQuestionItem(id: 'c', label: 'Da a boneca/bebe.'),
              _AdlQuestionItem(id: 'd', label: 'Da o carro/caminhao.'),
            ],
          ),
          _AdlQuestion(
            id: 4,
            title: 'Pedidos verbais simples com pistas gestuais',
            material: 'Bola, cachorrinho e boneca.',
            procedure:
                'Treino e depois dois pedidos com gestos para entrega da bola.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Da a bola para o examinador/cuidador.',
              ),
              _AdlQuestionItem(id: 'b', label: 'Da a bola para a boneca.'),
            ],
          ),
        ],
      ),
      _AdlAgeGroup(
        label: '1 ano e 6 meses a 1 ano e 11 meses',
        questions: [
          _AdlQuestion(
            id: 5,
            title: 'Vocabulário receptivo - identifica figuras',
            material: 'Manual de Figuras, páginas 1 e 2.',
            procedure: 'Pedir para mostrar as figuras nomeadas.',
            scoreRule: '1 ponto com 5 respostas corretas.',
            minCorrect: 5,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Mostra o carro.'),
              _AdlQuestionItem(id: 'b', label: 'Mostra a banana.'),
              _AdlQuestionItem(id: 'c', label: 'Mostra o gato.'),
              _AdlQuestionItem(id: 'd', label: 'Mostra o tenis/sapato.'),
              _AdlQuestionItem(id: 'e', label: 'Mostra o pe.'),
              _AdlQuestionItem(id: 'f', label: 'Mostra a mao.'),
              _AdlQuestionItem(id: 'g', label: 'Mostra o biscoito/bolacha.'),
            ],
          ),
          _AdlQuestion(
            id: 6,
            title: 'Ordens simples com dois pedidos',
            material: 'Bolas.',
            procedure:
                'Dar ordens em duas etapas para pegar e entregar a bola.',
            scoreRule: '1 ponto com 1 resposta correta.',
            minCorrect: 1,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Pega a bola e entrega ao examinador.',
              ),
              _AdlQuestionItem(
                id: 'b',
                label: 'Pega a bola e entrega ao acompanhante.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 7,
            title: 'Compreende palavras inibitórias',
            material: '2 carros/caminhoes e 3 bolas.',
            procedure:
                'Ao tentar pegar o objeto, dizer: Não! Espere! E minha vez.',
            scoreRule: '1 ponto quando para pelo menos uma vez.',
            minCorrect: 1,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Interrompe a ação ao ouvir inibicao.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 8,
            title: 'Compreende verbos em contexto',
            material: 'Cachorro, pano, prato, colher e xicara.',
            procedure: 'Pedir para alimentar, dar agua e colocar para dormir.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Da comida para o cachorro.'),
              _AdlQuestionItem(id: 'b', label: 'Da agua para o cachorro.'),
              _AdlQuestionItem(
                id: 'c',
                label: 'Coloca o cachorro para dormir.',
              ),
            ],
          ),
        ],
      ),
      _AdlAgeGroup(
        label: '2 anos a 2 anos e 5 meses',
        questions: [
          _AdlQuestion(
            id: 9,
            title: 'Usa apropriadamente objetos familiares ao brincar',
            material: 'Cachorro, carro, bola, boneca, colher, prato e xicara.',
            procedure: 'Observar manipulação espontanea dos objetos.',
            scoreRule: '1 ponto quando manipula adequadamente 3 objetos.',
            minCorrect: 3,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Manipula bola adequadamente.'),
              _AdlQuestionItem(
                id: 'b',
                label: 'Manipula carro/caminhao adequadamente.',
              ),
              _AdlQuestionItem(
                id: 'c',
                label: 'Manipula cachorro adequadamente.',
              ),
              _AdlQuestionItem(
                id: 'd',
                label: 'Manipula boneca adequadamente.',
              ),
              _AdlQuestionItem(
                id: 'e',
                label: 'Manipula xicara adequadamente.',
              ),
              _AdlQuestionItem(
                id: 'f',
                label: 'Manipula colher adequadamente.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 10,
            title: 'Identifica partes do corpo em si ou na boneca',
            material: 'Boneca.',
            procedure: 'Pedir para mostrar cada parte do corpo.',
            scoreRule: '1 ponto quando aponta 5 partes corretamente.',
            minCorrect: 5,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Nariz.'),
              _AdlQuestionItem(id: 'b', label: 'Olhos.'),
              _AdlQuestionItem(id: 'c', label: 'Pe.'),
              _AdlQuestionItem(id: 'd', label: 'Mao.'),
              _AdlQuestionItem(id: 'e', label: 'Boca.'),
              _AdlQuestionItem(id: 'f', label: 'Barriga.'),
              _AdlQuestionItem(id: 'g', label: 'Orelhas.'),
              _AdlQuestionItem(id: 'h', label: 'Cabeca.'),
            ],
          ),
          _AdlQuestion(
            id: 11,
            title: 'Compreende relação espacial',
            material: 'Bolsa e tres bolas.',
            procedure: 'Dar ordens com dentro/fora/em cima.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Tira bolas de dentro da bolsa.',
              ),
              _AdlQuestionItem(id: 'b', label: 'Coloca bolas em cima da mesa.'),
              _AdlQuestionItem(id: 'c', label: 'Coloca bolas dentro da bolsa.'),
            ],
          ),
          _AdlQuestion(
            id: 12,
            title: 'Compreende alguns pronomes',
            material: 'Cachorro e bolas.',
            procedure: 'Usar comandos com sua/minha/mim/ele.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Mostra as suas bolas.'),
              _AdlQuestionItem(id: 'b', label: 'Da uma bola para mim.'),
              _AdlQuestionItem(id: 'c', label: 'Mostra minha bola.'),
              _AdlQuestionItem(
                id: 'd',
                label: 'Da uma bola para ele (cachorro).',
              ),
            ],
          ),
          _AdlQuestion(
            id: 13,
            title: 'Reconhece ação nas figuras',
            material: 'Manual de Figuras, páginas 3 e 4.',
            procedure: 'Pedir para identificar quem está realizando cada ação.',
            scoreRule: '1 ponto com 4 respostas corretas.',
            minCorrect: 4,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Bebendo.'),
              _AdlQuestionItem(id: 'b', label: 'Comendo.'),
              _AdlQuestionItem(id: 'c', label: 'Dormindo.'),
              _AdlQuestionItem(id: 'd', label: 'Correndo.'),
              _AdlQuestionItem(id: 'e', label: 'Tomando banho.'),
            ],
          ),
        ],
      ),
      _AdlAgeGroup(
        label: '2 anos e 6 meses a 2 anos e 11 meses',
        questions: [
          _AdlQuestion(
            id: 14,
            title: 'Compreende os pronomes mim, seu e minha',
            material: 'Cachorro e bolas.',
            procedure: 'Comandos e perguntas com pronomes.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Da uma bola para mim.'),
              _AdlQuestionItem(id: 'b', label: 'Mostra a minha bola.'),
              _AdlQuestionItem(id: 'c', label: 'Mostra a sua bola.'),
              _AdlQuestionItem(
                id: 'd',
                label: 'Da uma bola para ele (cachorro).',
              ),
            ],
          ),
          _AdlQuestion(
            id: 15,
            title: 'Compreende uso dos objetos',
            material: 'Manual de Figuras, página 5.',
            procedure: 'Pedir para apontar objeto conforme função.',
            scoreRule: '1 ponto com 3 respostas corretas.',
            minCorrect: 3,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Objeto para beber.'),
              _AdlQuestionItem(id: 'b', label: 'Objeto para pentear cabelo.'),
              _AdlQuestionItem(id: 'c', label: 'Objeto para cortar papel.'),
              _AdlQuestionItem(id: 'd', label: 'Objeto para comer.'),
            ],
          ),
          _AdlQuestion(
            id: 16,
            title: 'Compreende conceitos de adjetivos',
            material: 'Manual de Figuras, páginas 6, 7 e 8.',
            procedure: 'Pedir para apontar grande/pequeno/molhado/sujo.',
            scoreRule: '1 ponto com 3 respostas corretas.',
            minCorrect: 3,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'A vaca grande.'),
              _AdlQuestionItem(id: 'b', label: 'O peixe pequeno.'),
              _AdlQuestionItem(id: 'c', label: 'O menino molhado.'),
              _AdlQuestionItem(id: 'd', label: 'O menino sujo.'),
            ],
          ),
        ],
      ),
      _AdlAgeGroup(
        label: '3 anos a 3 anos e 5 meses',
        questions: [
          _AdlQuestion(
            id: 17,
            title: 'Compreende relacoes parte/todo',
            material: 'Manual de Figuras, página 9.',
            procedure: 'Pedir para apontar partes do caminhao e do menino.',
            scoreRule: '1 ponto com 3 respostas corretas.',
            minCorrect: 3,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Porta do caminhao.'),
              _AdlQuestionItem(id: 'b', label: 'Rodas do caminhao.'),
              _AdlQuestionItem(id: 'c', label: 'Mao do menino.'),
              _AdlQuestionItem(id: 'd', label: 'Perna do menino.'),
            ],
          ),
          _AdlQuestion(
            id: 18,
            title: 'Compreende conceitos de quantidade',
            material: 'Bolsa e tres bolas.',
            procedure: 'Comandos com só uma, resto e todas.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Da só uma bola.'),
              _AdlQuestionItem(
                id: 'b',
                label: 'Coloca o resto em cima da mesa.',
              ),
              _AdlQuestionItem(id: 'c', label: 'Coloca todas dentro da bolsa.'),
            ],
          ),
          _AdlQuestion(
            id: 19,
            title: 'Identifica cores',
            material: 'Manual de Figuras, página 10.',
            procedure: 'Pedir para mostrar bola de cada cor.',
            scoreRule: '1 ponto com 4 respostas corretas.',
            minCorrect: 4,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Vermelha.'),
              _AdlQuestionItem(id: 'b', label: 'Amarela.'),
              _AdlQuestionItem(id: 'c', label: 'Branca.'),
              _AdlQuestionItem(id: 'd', label: 'Verde.'),
              _AdlQuestionItem(id: 'e', label: 'Azul.'),
            ],
          ),
          _AdlQuestion(
            id: 20,
            title: 'Identifica categorias de objetos em figuras',
            material: 'Manual de Figuras, página 11.',
            procedure: 'Pedir para apontar conjuntos por categoria.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Todos os bichinhos.'),
              _AdlQuestionItem(id: 'b', label: 'Todas as coisas que comemos.'),
            ],
          ),
          _AdlQuestion(
            id: 21,
            title: 'Compreende conceito de quantidade',
            material: 'Manual de Figuras, páginas 12 e 13.',
            procedure: 'Pedir para indicar quem está com mais.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Quem está com mais balões.'),
              _AdlQuestionItem(id: 'b', label: 'Quem está com mais bonecas.'),
            ],
          ),
          _AdlQuestion(
            id: 22,
            title: 'Compreende pronomes pessoais',
            material: 'Manual de Figuras, páginas 14 e 15.',
            procedure: 'Pedir para apontar ELA e ELE.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'ELA está chorando.'),
              _AdlQuestionItem(id: 'b', label: 'ELE está tomando sorvete.'),
            ],
          ),
          _AdlQuestion(
            id: 23,
            title: 'Faz deducoes',
            material: 'Manual de Figuras, páginas 16, 17 e 18.',
            procedure: 'Ler situacoes e pedir inferencias.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Deducao da historia da boneca suja.',
              ),
              _AdlQuestionItem(
                id: 'b',
                label: 'Deducao de quem teve surpresa.',
              ),
              _AdlQuestionItem(id: 'c', label: 'Deducao do tempo la fora.'),
            ],
          ),
          _AdlQuestion(
            id: 24,
            title: 'Compreende conceito de subir',
            material: 'Manual de Figuras, página 19.',
            procedure: 'Apontar menina que está subindo.',
            scoreRule: '1 ponto se responder corretamente.',
            minCorrect: 1,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Aponta a menina que está subindo.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 25,
            title: 'Compreende perguntas com pronome interrogativo que',
            material: 'Manual de Figuras, páginas 20 e 21.',
            procedure: 'Pedir para mostrar item correspondente a cada ação.',
            scoreRule: '1 ponto com 6 respostas corretas.',
            minCorrect: 6,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'O que voa.'),
              _AdlQuestionItem(id: 'b', label: 'O que late.'),
              _AdlQuestionItem(id: 'c', label: 'O que nada.'),
              _AdlQuestionItem(id: 'd', label: 'O que corta.'),
              _AdlQuestionItem(id: 'e', label: 'O que queima.'),
              _AdlQuestionItem(id: 'f', label: 'O que derrete.'),
              _AdlQuestionItem(id: 'g', label: 'O que dorme.'),
            ],
          ),
        ],
      ),
      _AdlAgeGroup(
        label: '4 anos a 4 anos e 5 meses',
        questions: [
          _AdlQuestion(
            id: 26,
            title: 'Compreende perguntas negativas',
            material: 'Manual de Figuras, páginas 22 e 23.',
            procedure: 'Apontar figuras com negação.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Passarinho que não está voando.',
              ),
              _AdlQuestionItem(
                id: 'b',
                label: 'Menino que não está na piscina.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 27,
            title: 'Conceito de exclusao e inclusao',
            material: 'Manual de Figuras, páginas 24 e 25.',
            procedure: 'Apontar um dos peixes e todos os macacos.',
            scoreRule: '1 ponto com 1 resposta correta.',
            minCorrect: 1,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Aponta um dos peixes.'),
              _AdlQuestionItem(id: 'b', label: 'Aponta todos os macacos.'),
            ],
          ),
          _AdlQuestion(
            id: 28,
            title: 'Compreende conceitos de tempo',
            material: 'Manual de Figuras, páginas 26 e 27.',
            procedure: 'Apontar figura de dia e figura de noite.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Figura que está de dia.'),
              _AdlQuestionItem(id: 'b', label: 'Figura que está de noite.'),
            ],
          ),
          _AdlQuestion(
            id: 29,
            title: 'Compreende conceitos de adjetivos',
            material: 'Manual de Figuras, páginas 28, 29 e 30.',
            procedure: 'Apontar mais alta, vazia e mais pesado.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'A criança mais alta.'),
              _AdlQuestionItem(id: 'b', label: 'A garrafa vazia.'),
              _AdlQuestionItem(id: 'c', label: 'O objeto mais pesado.'),
            ],
          ),
          _AdlQuestion(
            id: 30,
            title: 'Compreende conceitos espaciais',
            material: 'Manual de Figuras, página 31.',
            procedure: 'Apontar cachorro em cima, embaixo e atras da cadeira.',
            scoreRule: '1 ponto com 3 respostas corretas.',
            minCorrect: 3,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Cachorro em cima da cadeira.'),
              _AdlQuestionItem(id: 'b', label: 'Cachorro embaixo da cadeira.'),
              _AdlQuestionItem(id: 'c', label: 'Cachorro atras da cadeira.'),
            ],
          ),
        ],
      ),
      _AdlAgeGroup(
        label: '4 anos e 6 meses a 4 anos e 11 meses',
        questions: [
          _AdlQuestion(
            id: 31,
            title: 'Compreende conceitos de adjetivos',
            material: 'Manual de Figuras, páginas 32 e 33.',
            procedure: 'Apontar figuras iguais e cobra mais comprida.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Aponta as duas figuras iguais.',
              ),
              _AdlQuestionItem(id: 'b', label: 'Aponta a cobra mais comprida.'),
            ],
          ),
          _AdlQuestion(
            id: 32,
            title: 'Compreende analogias',
            material: 'Manual de Figuras, páginas 34, 35 e 36.',
            procedure: 'Apontar resposta correta para analogias funcionais.',
            scoreRule: '1 ponto com 3 respostas corretas.',
            minCorrect: 3,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Escovar dentes com escova/pasta.',
              ),
              _AdlQuestionItem(id: 'b', label: 'Beber em copo.'),
              _AdlQuestionItem(id: 'c', label: 'Dormir em cama.'),
            ],
          ),
          _AdlQuestion(
            id: 33,
            title: 'Compreende oracoes com pronome relativo que',
            material: 'Manual de Figuras, página 37.',
            procedure: 'Apontar cachorro conforme descricao composta.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Cachorro preto que está dormindo.',
              ),
              _AdlQuestionItem(
                id: 'b',
                label: 'Cachorro branco com orelhas pretas.',
              ),
              _AdlQuestionItem(
                id: 'c',
                label: 'Cachorro malhado com uma orelha marrom.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 34,
            title: 'Compreende conceito de velocidade',
            material: 'Manual de Figuras, página 38.',
            procedure: 'Apontar transporte mais rápido e bicho mais devagar.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Transporte mais rápido.'),
              _AdlQuestionItem(id: 'b', label: 'Bicho mais devagar.'),
            ],
          ),
        ],
      ),
      _AdlAgeGroup(
        label: '5 anos a 5 anos e 5 meses',
        questions: [
          _AdlQuestion(
            id: 35,
            title: 'Compreende adjetivos comparativos',
            material: 'Manual de Figuras, páginas 39 e 40.',
            procedure: 'Apontar bola menor e cachorro maior.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Bola menor.'),
              _AdlQuestionItem(id: 'b', label: 'Cachorro maior.'),
            ],
          ),
          _AdlQuestion(
            id: 36,
            title: 'Compreende oracoes com adjetivos',
            material: 'Manual de Figuras, página 41.',
            procedure: 'Apontar gato pela combinação de adjetivos.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Gato branco e peludo.'),
              _AdlQuestionItem(id: 'b', label: 'Gato preto e grande.'),
              _AdlQuestionItem(id: 'c', label: 'Gato branco e pequeno.'),
            ],
          ),
          _AdlQuestion(
            id: 37,
            title: 'Compreende sufixos de genero',
            material: 'Manual de Figuras, páginas 42 e 43.',
            procedure: 'Apontar pintor e cantora.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Aponta o pintor.'),
              _AdlQuestionItem(id: 'b', label: 'Aponta a cantora.'),
            ],
          ),
          _AdlQuestion(
            id: 38,
            title: 'Compreende conceito de quantidade',
            material: 'Manual de Figuras, página 44.',
            procedure: 'Apontar copo e prato com menos.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Copo com menos suco.'),
              _AdlQuestionItem(id: 'b', label: 'Prato com menos pipoca.'),
            ],
          ),
        ],
      ),
      _AdlAgeGroup(
        label: '5 anos e 6 meses a 5 anos e 11 meses',
        questions: [
          _AdlQuestion(
            id: 39,
            title: 'Compreende conceitos de adjetivos',
            material: 'Manual de Figuras, páginas 45 e 46.',
            procedure: 'Apontar menina feliz e menino triste.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Menina feliz.'),
              _AdlQuestionItem(id: 'b', label: 'Menino triste.'),
            ],
          ),
          _AdlQuestion(
            id: 40,
            title: 'Compreende palavras de relação espacial',
            material: 'Lapis e cadeira com espaldar.',
            procedure: 'Pedir para colocar lapis em relacoes espaciais.',
            scoreRule: '1 ponto com 4 respostas corretas.',
            minCorrect: 4,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Em cima da cadeira.'),
              _AdlQuestionItem(id: 'b', label: 'Embaixo da cadeira.'),
              _AdlQuestionItem(id: 'c', label: 'Na frente da cadeira.'),
              _AdlQuestionItem(id: 'd', label: 'Atras da cadeira.'),
            ],
          ),
          _AdlQuestion(
            id: 41,
            title: 'Classificação semantica',
            material: 'Manual de Figuras, páginas 47, 48 e 49.',
            procedure: 'Apontar figura diferente em cada conjunto.',
            scoreRule: '1 ponto com 3 respostas corretas.',
            minCorrect: 3,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Diferente em conjunto com utensilios e tenis.',
              ),
              _AdlQuestionItem(
                id: 'b',
                label: 'Diferente em conjunto de bananas e carro.',
              ),
              _AdlQuestionItem(
                id: 'c',
                label: 'Diferente em conjunto de motos e cama.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 42,
            title: 'Compreende conceitos de quantidade',
            material: 'Manual de Figuras, páginas 50 e 51.',
            procedure: 'Apontar conjunto com tres e com cinco.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Copo com tres pirulitos.'),
              _AdlQuestionItem(id: 'b', label: 'Conjunto com cinco bolas.'),
            ],
          ),
        ],
      ),
      _AdlAgeGroup(
        label: '6 anos a 6 anos e 5 meses',
        questions: [
          _AdlQuestion(
            id: 43,
            title: 'Relação espacial/sequência',
            material: 'Manual de Figuras, páginas 52 e 53.',
            procedure: 'Apontar primeiro carro e primeira ação de se arrumar.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Identifica o primeiro carro.'),
              _AdlQuestionItem(
                id: 'b',
                label: 'Identifica o que vestiu primeiro.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 44,
            title: 'Relação espacial',
            material: 'Manual de Figuras, páginas 54, 55 e 56.',
            procedure: 'Apontar mais perto, mais longe e entre.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Macaco mais perto do leao.'),
              _AdlQuestionItem(id: 'b', label: 'Pipa mais longe do menino.'),
              _AdlQuestionItem(id: 'c', label: 'Bichinho entre os cachorros.'),
            ],
          ),
          _AdlQuestion(
            id: 45,
            title: 'Identifica sons iniciais das palavras',
            material: 'Manual de Figuras, páginas 57, 58 e 59.',
            procedure: 'Apontar figura que inicia com som indicado.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Som /a/.'),
              _AdlQuestionItem(id: 'b', label: 'Som /g/.'),
              _AdlQuestionItem(id: 'c', label: 'Som /v/.'),
            ],
          ),
          _AdlQuestion(
            id: 46,
            title: 'Relação temporal/sequência',
            material: 'Manual de Figuras, páginas 60 e 61.',
            procedure: 'Executar ação depois de apontar figura anterior.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Depois gato, aponta sapo.'),
              _AdlQuestionItem(
                id: 'b',
                label: 'Depois jacare, aponta elefante.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 47,
            title: 'Relação espacial/sequência',
            material: 'Manual de Figuras, páginas 62 e 63.',
            procedure: 'Apontar ultimo cachorro e ultimo boi.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Identifica ultimo cachorro.'),
              _AdlQuestionItem(id: 'b', label: 'Identifica ultimo boi.'),
            ],
          ),
        ],
      ),
      _AdlAgeGroup(
        label: '6 anos e 6 meses a 6 anos e 11 meses',
        questions: [
          _AdlQuestion(
            id: 48,
            title: 'Compreende conceitos de quantidade',
            material: 'Manual de Figuras, página 64.',
            procedure: 'Apontar laranja inteira e metade.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'Aponta a laranja inteira.'),
              _AdlQuestionItem(id: 'b', label: 'Aponta a metade da laranja.'),
            ],
          ),
          _AdlQuestion(
            id: 49,
            title: 'Compreende sentencas na voz passiva',
            material: 'Manual de Figuras, páginas 65 e 66.',
            procedure: 'Apontar figura alvo em estrutura passiva.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(
                id: 'a',
                label: 'Menina que foi beijada pelo menino.',
              ),
              _AdlQuestionItem(
                id: 'b',
                label: 'Menino que foi empurrado pela menina.',
              ),
            ],
          ),
          _AdlQuestion(
            id: 50,
            title: 'Aliteração - identificação de silabas iniciais',
            material: 'Manual de Figuras, páginas 67 e 68.',
            procedure:
                'Apontar duas palavras que comecam com o mesmo som em cada bloco.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'casa-carro-bola.'),
              _AdlQuestionItem(id: 'b', label: 'tenis-mola-moto.'),
              _AdlQuestionItem(id: 'c', label: 'chave-chapeu-faca.'),
              _AdlQuestionItem(id: 'd', label: 'bola-peixe-bota.'),
            ],
          ),
          _AdlQuestion(
            id: 51,
            title: 'Rima - identificação de silabas finais',
            material: 'Manual de Figuras, páginas 69 e 70.',
            procedure:
                'Apontar duas palavras que terminam com o mesmo som em cada bloco.',
            scoreRule: '1 ponto com 2 respostas corretas.',
            minCorrect: 2,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'mao-aviao-pa.'),
              _AdlQuestionItem(id: 'b', label: 'gato-peixe-rato.'),
              _AdlQuestionItem(id: 'c', label: 'boca-chapeu-foca.'),
              _AdlQuestionItem(id: 'd', label: 'panela-moto-janela.'),
            ],
          ),
          _AdlQuestion(
            id: 52,
            title: 'Combinação de sons (fonemas)',
            material: 'Manual de Figuras, páginas 71 e 72.',
            procedure: 'Combinar fonemas e apontar palavra resultante.',
            scoreRule: '1 ponto com 3 respostas corretas.',
            minCorrect: 3,
            items: const [
              _AdlQuestionItem(id: 'a', label: 'm-ao (mao).'),
              _AdlQuestionItem(id: 'b', label: 'p-a (pa).'),
              _AdlQuestionItem(id: 'c', label: 'u-v-a (uva).'),
              _AdlQuestionItem(id: 'd', label: 'm-o-t-o (moto).'),
              _AdlQuestionItem(id: 'e', label: 'f-a-c-a (faca).'),
              _AdlQuestionItem(id: 'f', label: 'g-a-t-o (gato).'),
              _AdlQuestionItem(id: 'g', label: 'f-o-c-a (foca).'),
            ],
          ),
        ],
      ),
    ];
  }
}

class _AdlAgeGroup {
  const _AdlAgeGroup({required this.label, required this.questions});

  final String label;
  final List<_AdlQuestion> questions;
}

class _AdlQuestion {
  const _AdlQuestion({
    required this.id,
    required this.title,
    required this.material,
    required this.procedure,
    required this.scoreRule,
    required this.minCorrect,
    required this.items,
  });

  final int id;
  final String title;
  final String material;
  final String procedure;
  final String scoreRule;
  final int minCorrect;
  final List<_AdlQuestionItem> items;
}

class _AdlQuestionItem {
  const _AdlQuestionItem({required this.id, required this.label});

  final String id;
  final String label;
}

enum _AdlSection { compreensiva, expressiva }
