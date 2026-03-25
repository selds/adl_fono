import 'package:flutter/material.dart';

import 'models/adl_protocol.dart';

class AdlProtocolPage extends StatefulWidget {
  const AdlProtocolPage({super.key, required this.pacienteId, this.protocol});

  final String pacienteId;
  final AdlProtocol? protocol;

  @override
  State<AdlProtocolPage> createState() => _AdlProtocolPageState();
}

class _AdlProtocolPageState extends State<AdlProtocolPage> {
  static const _ageBandLabel = '1 ano a 1 ano e 5 meses';

  late final TextEditingController _q5Score;
  late final TextEditingController _q6Score;
  late final TextEditingController _q7Score;
  late final TextEditingController _q8Score;

  bool? _q5a, _q5b;
  bool? _q5c; // TODO: pergunta futura — sem UI implementada
  late final TextEditingController _q5aText;
  late final TextEditingController _q5bText;

  bool? _q6a, _q6b;
  bool? _q6c, _q6d, _q6e, _q6f; // TODO: perguntas futuras — sem UI implementada
  late final TextEditingController _q6aText;
  late final TextEditingController _q6bText;

  // TODO: Q7 e Q8 — perguntas futuras declaradas e persistidas, sem UI implementada
  bool? _q7a, _q7b, _q7c, _q7d, _q7e, _q7f, _q7g;
  bool? _q8a, _q8b, _q8c;

  late final TextEditingController _q1ExpScore;
  late final TextEditingController _q1ExpText;
  bool? _q1ExpMet;
  late final TextEditingController _q2ExpScore;
  late final TextEditingController _q2ExpText;
  bool? _q2ExpMet;
  late final TextEditingController _q3ExpScore;
  late final TextEditingController _q3ExpText;
  bool? _q3ExpMet;
  // TODO: Q4 expressiva — persistida mas sem UI implementada
  late final TextEditingController _q4ExpScore;
  late final TextEditingController _q4ExpText;

  final _formKey = GlobalKey<FormState>();
  int _selectedStepIndex = 0;

  List<_AdlStepMeta> get _steps => const [
    _AdlStepMeta(
      title: 'Visão geral',
      subtitle: 'Introdução da faixa etária e orientação do protocolo.',
      icon: Icons.fact_check_outlined,
    ),
    _AdlStepMeta(
      title: 'Compreensiva',
      subtitle: 'Perguntas 1 e 2 com pontuação automática.',
      icon: Icons.hearing_outlined,
    ),
    _AdlStepMeta(
      title: 'Expressiva 1',
      subtitle: 'Participação em brincadeiras.',
      icon: Icons.groups_2_outlined,
    ),
    _AdlStepMeta(
      title: 'Expressiva 2',
      subtitle: 'Gestos e vocalizações.',
      icon: Icons.record_voice_over_outlined,
    ),
    _AdlStepMeta(
      title: 'Resumo',
      subtitle: 'Conferência final e salvamento do protocolo.',
      icon: Icons.summarize_outlined,
    ),
  ];

  bool get _isFirstStep => _selectedStepIndex == 0;
  bool get _isLastStep => _selectedStepIndex == _steps.length - 1;

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
  void initState() {
    super.initState();
    final r = widget.protocol?.receptiveAnswers ?? {};
    final e = widget.protocol?.expressiveAnswers ?? {};

    _q5Score = TextEditingController(text: r['q5Score'] as String? ?? '');
    _q5a = r['q5a'] as bool?;
    _q5b = r['q5b'] as bool?;
    _q5c = r['q5c'] as bool?;
    _q5aText = TextEditingController(text: r['q5aText'] as String? ?? '');
    _q5bText = TextEditingController(text: r['q5bText'] as String? ?? '');

    _q6Score = TextEditingController(text: r['q6Score'] as String? ?? '');
    _q6a = r['q6a'] as bool?;
    _q6b = r['q6b'] as bool?;
    _q6c = r['q6c'] as bool?;
    _q6d = r['q6d'] as bool?;
    _q6e = r['q6e'] as bool?;
    _q6f = r['q6f'] as bool?;
    _q6aText = TextEditingController(text: r['q6aText'] as String? ?? '');
    _q6bText = TextEditingController(text: r['q6bText'] as String? ?? '');

    _q7Score = TextEditingController(text: r['q7Score'] as String? ?? '');
    _q7a = r['q7a'] as bool?;
    _q7b = r['q7b'] as bool?;
    _q7c = r['q7c'] as bool?;
    _q7d = r['q7d'] as bool?;
    _q7e = r['q7e'] as bool?;
    _q7f = r['q7f'] as bool?;
    _q7g = r['q7g'] as bool?;

    _q8Score = TextEditingController(text: r['q8Score'] as String? ?? '');
    _q8a = r['q8a'] as bool?;
    _q8b = r['q8b'] as bool?;
    _q8c = r['q8c'] as bool?;

    _q1ExpScore = TextEditingController(text: e['q1Score'] as String? ?? '');
    _q1ExpText = TextEditingController(text: e['q1Text'] as String? ?? '');
    _q1ExpMet = e['q1Met'] as bool?;
    _q2ExpScore = TextEditingController(text: e['q2Score'] as String? ?? '');
    _q2ExpText = TextEditingController(text: e['q2Text'] as String? ?? '');
    _q2ExpMet = e['q2Met'] as bool?;
    _q3ExpScore = TextEditingController(text: e['q3Score'] as String? ?? '');
    _q3ExpText = TextEditingController(text: e['q3Text'] as String? ?? '');
    _q3ExpMet = e['q3Met'] as bool?;
    _q4ExpScore = TextEditingController(text: e['q4Score'] as String? ?? '');
    _q4ExpText = TextEditingController(text: e['q4Text'] as String? ?? '');

    _updateReceptivaScores();
    _updateExpressivaScores();
  }

  @override
  void dispose() {
    _q5Score.dispose();
    _q5aText.dispose();
    _q5bText.dispose();
    _q6Score.dispose();
    _q6aText.dispose();
    _q6bText.dispose();
    _q7Score.dispose();
    _q8Score.dispose();
    _q1ExpScore.dispose();
    _q1ExpText.dispose();
    _q2ExpScore.dispose();
    _q2ExpText.dispose();
    _q3ExpScore.dispose();
    _q3ExpText.dispose();
    _q4ExpScore.dispose();
    _q4ExpText.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final receptiveAnswers = {
      'q5Score': _q5Score.text.trim(),
      'q5a': _q5a,
      'q5b': _q5b,
      'q5c': _q5c,
      'q5aText': _q5aText.text.trim(),
      'q5bText': _q5bText.text.trim(),
      'q6Score': _q6Score.text.trim(),
      'q6a': _q6a,
      'q6b': _q6b,
      'q6c': _q6c,
      'q6d': _q6d,
      'q6e': _q6e,
      'q6f': _q6f,
      'q6aText': _q6aText.text.trim(),
      'q6bText': _q6bText.text.trim(),
      'q7Score': _q7Score.text.trim(),
      'q7a': _q7a,
      'q7b': _q7b,
      'q7c': _q7c,
      'q7d': _q7d,
      'q7e': _q7e,
      'q7f': _q7f,
      'q7g': _q7g,
      'q8Score': _q8Score.text.trim(),
      'q8a': _q8a,
      'q8b': _q8b,
      'q8c': _q8c,
    };

    final expressiveAnswers = {
      'q1Score': _q1ExpScore.text.trim(),
      'q1Text': _q1ExpText.text.trim(),
      'q1Met': _q1ExpMet,
      'q2Score': _q2ExpScore.text.trim(),
      'q2Text': _q2ExpText.text.trim(),
      'q2Met': _q2ExpMet,
      'q3Score': _q3ExpScore.text.trim(),
      'q3Text': _q3ExpText.text.trim(),
      'q3Met': _q3ExpMet,
      'q4Score': _q4ExpScore.text.trim(),
      'q4Text': _q4ExpText.text.trim(),
    };

    final protocol = AdlProtocol(
      pacienteId: widget.pacienteId,
      receptiveAnswers: receptiveAnswers,
      expressiveAnswers: expressiveAnswers,
      id: widget.protocol?.id,
      createdAt: widget.protocol?.createdAt,
    );

    if (widget.protocol == null) {
      await AdlProtocolRepository.add(protocol);
    } else {
      await AdlProtocolRepository.update(widget.protocol!, protocol);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Protocolo salvo com sucesso.')),
    );
    Navigator.of(context).pop();
  }

  int _scoreToInt(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    return parsed?.round() ?? 0;
  }

  int _countSim(Iterable<bool?> values) {
    return values.where((value) => value == true).length;
  }

  int _scoreByThreshold({required int acertos, required int minAcertos}) {
    return acertos >= minAcertos ? 1 : 0;
  }

  void _updateReceptivaScores() {
    _q5Score.text = _scoreByThreshold(
      acertos: _countSim([_q5a, _q5b]),
      minAcertos: 1,
    ).toString();

    _q6Score.text = _scoreByThreshold(
      acertos: _countSim([_q6a, _q6b]),
      minAcertos: 1,
    ).toString();

    _q7Score.text = '0';
    _q8Score.text = '0';
  }

  void _updateExpressivaScores() {
    _q1ExpScore.text = (_q1ExpMet == true ? 1 : 0).toString();
    _q2ExpScore.text = (_q2ExpMet == true ? 1 : 0).toString();
    _q3ExpScore.text = (_q3ExpMet == true ? 1 : 0).toString();
    _q4ExpScore.text = '0';
  }

  int get _expressivaTotal {
    return _scoreToInt(_q1ExpScore.text) +
        _scoreToInt(_q2ExpScore.text) +
        _scoreToInt(_q3ExpScore.text);
  }

  int get _receptivaTotal {
    return _scoreToInt(_q5Score.text) +
        _scoreToInt(_q6Score.text) +
        _scoreToInt(_q7Score.text) +
        _scoreToInt(_q8Score.text);
  }

  void _goToStep(int index) {
    if (index < 0 || index >= _steps.length || index == _selectedStepIndex) {
      return;
    }

    setState(() => _selectedStepIndex = index);
  }

  void _goToPreviousStep() {
    if (_isFirstStep) return;
    setState(() => _selectedStepIndex -= 1);
  }

  void _goToNextStep() {
    if (_isLastStep) return;
    setState(() => _selectedStepIndex += 1);
  }

  Widget _buildScoreField(
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 56,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        readOnly: readOnly,
        onChanged: readOnly ? null : (_) => setState(() {}),
        textAlign: TextAlign.center,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: '__',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
        ),
      ),
    );
  }

  Widget _buildSubItem(
    String label,
    bool? value,
    void Function(bool?) onChange,
    TextEditingController? responseController,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                ),
              ),
              const SizedBox(width: 8),
              _buildYesNoToggle(
                value,
                onChange,
                onAfterChange: _updateReceptivaScores,
              ),
            ],
          ),
          if (responseController != null) ...[
            const SizedBox(height: 6),
            TextFormField(
              controller: responseController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Resposta',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestion({
    required String title,
    required TextEditingController score,
    bool readOnlyScore = false,
    String? description,
    required List<Widget> items,
    required String scoreInfo,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildScoreField(score, readOnly: readOnlyScore),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 6),
          ...items,
          const SizedBox(height: 4),
          Text(
            scoreInfo,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          Divider(height: 20, color: colorScheme.outlineVariant),
        ],
      ),
    );
  }

  Widget _buildExpressivaQuestion({
    required String title,
    required TextEditingController score,
    required bool? meetsCriteria,
    required void Function(bool?) onMeetsCriteriaChanged,
    String? description,
    required String inputLabel,
    required TextEditingController inputController,
    required String scoreInfo,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildScoreField(score, readOnly: true),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Atende ao critério?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildYesNoToggle(
                meetsCriteria,
                onMeetsCriteriaChanged,
                onAfterChange: _updateExpressivaScores,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: inputController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: inputLabel,
              labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
            minLines: 2,
            maxLines: 5,
          ),
          const SizedBox(height: 4),
          Text(
            scoreInfo,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          Divider(height: 20, color: colorScheme.outlineVariant),
        ],
      ),
    );
  }

  Widget _buildYesNoToggle(
    bool? value,
    void Function(bool?) onChange, {
    VoidCallback? onAfterChange,
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
              onChanged: (_) => setState(() {
                onChange(value == true ? null : true);
                onAfterChange?.call();
              }),
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
              onChanged: (_) => setState(() {
                onChange(value == false ? null : false);
                onAfterChange?.call();
              }),
            ),
            Text('Não', style: TextStyle(color: colorScheme.onSurface)),
          ],
        ),
      ],
    );
  }

  Widget _buildColumnCard({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryGradient = _primaryGradientFor(theme.brightness);

    return Card(
      elevation: 3,
      color: theme.brightness == Brightness.dark
          ? colorScheme.surfaceContainerLow
          : Colors.white.withAlpha((0.94 * 255).round()),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(gradient: primaryGradient),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    final theme = Theme.of(context);
    final primaryGradient = _primaryGradientFor(theme.brightness);
    return Container(
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.protocol == null
                ? 'Novo Protocolo ADL'
                : 'Editar Protocolo ADL',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Chip(
                avatar: const Icon(Icons.schedule, size: 18),
                label: const Text(_ageBandLabel),
                backgroundColor: Colors.white.withAlpha(46),
                labelStyle: const TextStyle(color: Colors.white),
                iconTheme: const IconThemeData(color: Colors.white),
                side: BorderSide.none,
              ),
              Chip(
                avatar: const Icon(Icons.folder_shared_outlined, size: 18),
                label: Text('Paciente ${widget.pacienteId.substring(0, 8)}'),
                backgroundColor: Colors.white.withAlpha(38),
                labelStyle: const TextStyle(color: Colors.white),
                iconTheme: const IconThemeData(color: Colors.white),
                side: BorderSide.none,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'A tela foi dividida em etapas curtas para evitar formulários extensos. Use o sumário para navegar entre as seções e acompanhar a faixa etária atual.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = theme.brightness == Brightness.dark
        ? colorScheme.surfaceContainerLow
        : Colors.white.withAlpha((0.92 * 255).round());
    final currentStep = _selectedStepIndex + 1;
    final progress = currentStep / _steps.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Etapa $currentStep de ${_steps.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                _steps[_selectedStepIndex].title,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryGradient = _primaryGradientFor(theme.brightness);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerLow
            : Colors.white.withAlpha((0.92 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sumário do protocolo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _ageBandLabel,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_steps.length, (index) {
            final step = _steps[index];
            final selected = index == _selectedStepIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _goToStep(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: selected ? primaryGradient : null,
                    color: selected
                        ? null
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: selected
                            ? Colors.white
                            : colorScheme.surface,
                        foregroundColor: selected
                            ? const Color(0xFF667eea)
                            : colorScheme.primary,
                        child: Icon(step.icon, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${step.title}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: selected
                                    ? Colors.white
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompactSummary() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerLow
            : Colors.white.withAlpha((0.92 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sumário',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_steps.length, (index) {
              return ChoiceChip(
                selected: index == _selectedStepIndex,
                label: Text('${index + 1}. ${_steps[index].title}'),
                onSelected: (_) => _goToStep(index),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepScaffold({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      key: ValueKey(_selectedStepIndex),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerLow
            : Colors.white.withAlpha((0.94 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildOverviewStep() {
    return _buildStepScaffold(
      title: 'Faixa etária $_ageBandLabel',
      subtitle:
          'Esta organização segue o protocolo em etapas menores. As perguntas foram agrupadas para reduzir rolagem excessiva e facilitar a navegação.',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 760;
            final metrics = [
              _buildMetricTile(
                label: 'Pontuação receptiva atual',
                value: '$_receptivaTotal',
                icon: Icons.hearing_outlined,
              ),
              _buildMetricTile(
                label: 'Pontuação expressiva atual',
                value: '$_expressivaTotal',
                icon: Icons.record_voice_over_outlined,
              ),
            ];

            if (isNarrow) {
              return Column(
                children: [metrics[0], const SizedBox(height: 12), metrics[1]],
              );
            }

            return Row(
              children: [
                Expanded(child: metrics[0]),
                const SizedBox(width: 12),
                Expanded(child: metrics[1]),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _buildColumnCard(
          title: 'Como usar esta tela',
          children: const [
            Text(
              '1. Use o sumário lateral para pular entre as etapas da faixa etária atual.',
            ),
            SizedBox(height: 8),
            Text(
              '2. Cada etapa agrupa poucas perguntas, como no protocolo impresso, para reduzir o tamanho da página.',
            ),
            SizedBox(height: 8),
            Text(
              '3. O resumo final consolida os totais antes do salvamento do protocolo.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompreensivaStep() {
    return _buildStepScaffold(
      title: 'Linguagem compreensiva',
      subtitle: 'Perguntas 1 e 2 desta faixa etária com pontuação automática.',
      children: [
        _buildColumnCard(
          title: 'LINGUAGEM COMPREENSIVA',
          children: [
            _buildQuestion(
              title: '1. Atenção visual.',
              score: _q5Score,
              readOnlyScore: true,
              description:
                  'Material: um brinquedo que a criança tenha demonstrado interesse ou bolhinhas de sabão.\n'
                  'Procedimento: inicialmente, o examinador ou cuidador brinca com a criança e, em seguida:',
              items: [
                _buildSubItem(
                  'a. movimenta o brinquedo que a criança demonstrou interesse da esquerda para a direita, observando se ela acompanha com o olhar o brinquedo em movimento.',
                  _q5a,
                  (value) => setState(() => _q5a = value),
                  _q5aText,
                ),
                _buildSubItem(
                  'b. aguarda um minuto, fala o nome da criança, mostra o recipiente com o sabão e assopra as bolinhas de sabão, observando se ela acompanha com o olhar as bolinhas.',
                  _q5b,
                  (value) => setState(() => _q5b = value),
                  _q5bText,
                ),
              ],
              scoreInfo:
                  '1 ponto: quando a criança acompanha com o olhar o brinquedo ou as bolinhas de sabão (cada procedimento poderá ser repetido duas vezes).',
            ),
            _buildQuestion(
              title: '2. Atenção auditiva.',
              score: _q6Score,
              readOnlyScore: true,
              description:
                  'Material: brinquedos.\n'
                  'Procedimento: inicialmente o examinador ou o cuidador brinca com a criança e, em seguida:',
              items: [
                _buildSubItem(
                  'a. chama a criança pelo nome e observa se ela olha na direção de quem a chamou.',
                  _q6a,
                  (value) => setState(() => _q6a = value),
                  _q6aText,
                ),
                _buildSubItem(
                  'b. aguarda um minuto, depois bate palma atrás da criança, do lado direito, e, por último, do lado esquerdo, observando se ela procura a fonte sonora.',
                  _q6b,
                  (value) => setState(() => _q6b = value),
                  _q6bText,
                ),
              ],
              scoreInfo:
                  '1 ponto: quando a criança responde ao item a ou b (cada procedimento poderá ser repetido duas vezes).',
            ),
            _buildMetricTile(
              label: 'Total da linguagem receptiva',
              value: '$_receptivaTotal',
              icon: Icons.calculate_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpressivaStepOne() {
    return _buildStepScaffold(
      title: 'Linguagem expressiva: interação',
      subtitle: 'Primeira etapa expressiva com foco em participação social.',
      children: [
        _buildColumnCard(
          title: 'LINGUAGEM EXPRESSIVA',
          children: [
            _buildExpressivaQuestion(
              title:
                  '1. Participa de brincadeiras com outra pessoa pelo período de 1 a 2 minutos.',
              score: _q1ExpScore,
              meetsCriteria: _q1ExpMet,
              onMeetsCriteriaChanged: (value) => _q1ExpMet = value,
              description:
                  'Material: um marcador de tempo (ex.: celular), paninho e brinquedos.\n'
                  'Procedimento: solicitar ao acompanhante que brinque com a criança como faria em casa. O examinador poderá observar e anotar o interesse da criança pelos brinquedos.',
              inputLabel: 'Anotações da observação',
              inputController: _q1ExpText,
              scoreInfo:
                  '1 ponto: quando a criança mantém o contato do olhar e demonstra prazer com a brincadeira. Quando este comportamento é observado em outro momento na sessão de avaliação ou o cuidador relata este comportamento no contexto.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpressivaStepTwo() {
    return _buildStepScaffold(
      title: 'Linguagem expressiva: gestos e vocalizações',
      subtitle: 'Segunda etapa expressiva com observações comportamentais.',
      children: [
        _buildColumnCard(
          title: 'LINGUAGEM EXPRESSIVA',
          children: [
            _buildExpressivaQuestion(
              title: '2. Comunica-se de forma gestual.',
              score: _q2ExpScore,
              meetsCriteria: _q2ExpMet,
              onMeetsCriteriaChanged: (value) => _q2ExpMet = value,
              description:
                  'Material: brinquedos.\n'
                  'Procedimento: o examinador ou o cuidador brinca com a criança. O examinador observa e anota a comunicação gestual da criança.',
              inputLabel: 'Gestos observados',
              inputController: _q2ExpText,
              scoreInfo:
                  '1 ponto: quando observado, no período de avaliação, um ou mais comportamentos da criança usando gestos com intenção de se comunicar (exemplos: estender um objeto para o examinador ou para o cuidador, apontar para um objeto ou para uma pessoa, balançar a mão dando adeus).',
            ),
            _buildExpressivaQuestion(
              title:
                  '3. A criança vocaliza sem que movimentos de pernas e de braços acompanhem a emissão dos sons.',
              score: _q3ExpScore,
              meetsCriteria: _q3ExpMet,
              onMeetsCriteriaChanged: (value) => _q3ExpMet = value,
              description:
                  'Material: brinquedos.\n'
                  'Procedimento: o cuidador ou o examinador se posiciona frente à criança, de forma que esta possa ver o seu rosto, sorri e verbaliza, imitando os sons que fez durante a sessão de avaliação ou que têm sido observados em casa.',
              inputLabel: 'Vocalizações observadas',
              inputController: _q3ExpText,
              scoreInfo:
                  '1 ponto: quando o examinador ou o cuidador fala com a criança e esta responde vocalizando sem movimentos do corpo.',
            ),
            _buildMetricTile(
              label: 'Total da linguagem expressiva',
              value: '$_expressivaTotal',
              icon: Icons.calculate_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResumoStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildStepScaffold(
      title: 'Resumo do protocolo',
      subtitle:
          'Conferência final das pontuações antes do salvamento. O formato está pronto para receber novas etapas e futuras faixas etárias.',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 760;
            final left = _buildMetricTile(
              label: 'Pontuação total receptiva',
              value: '$_receptivaTotal',
              icon: Icons.hearing_outlined,
            );
            final right = _buildMetricTile(
              label: 'Pontuação total expressiva',
              value: '$_expressivaTotal',
              icon: Icons.record_voice_over_outlined,
            );

            if (isNarrow) {
              return Column(
                children: [left, const SizedBox(height: 12), right],
              );
            }

            return Row(
              children: [
                Expanded(child: left),
                const SizedBox(width: 12),
                Expanded(child: right),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Itens preenchidos nesta faixa etária',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Compreensiva 1: ${_q5Score.text.isEmpty ? '0' : _q5Score.text} ponto(s)',
              ),
              Text(
                'Compreensiva 2: ${_q6Score.text.isEmpty ? '0' : _q6Score.text} ponto(s)',
              ),
              Text(
                'Expressiva 1: ${_q1ExpScore.text.isEmpty ? '0' : _q1ExpScore.text} ponto(s)',
              ),
              Text(
                'Expressiva 2: ${_q2ExpScore.text.isEmpty ? '0' : _q2ExpScore.text} ponto(s)',
              ),
              Text(
                'Expressiva 3: ${_q3ExpScore.text.isEmpty ? '0' : _q3ExpScore.text} ponto(s)',
              ),
              const SizedBox(height: 14),
              Text(
                'Use o botão Salvar protocolo para persistir as respostas no histórico do paciente.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_selectedStepIndex) {
      case 0:
        return _buildOverviewStep();
      case 1:
        return _buildCompreensivaStep();
      case 2:
        return _buildExpressivaStepOne();
      case 3:
        return _buildExpressivaStepTwo();
      case 4:
        return _buildResumoStep();
      default:
        return _buildOverviewStep();
    }
  }

  Widget _buildBottomNavigation() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 10,
      spacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: _isFirstStep ? null : _goToPreviousStep,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Anterior'),
        ),
        if (!_isLastStep)
          ElevatedButton.icon(
            onPressed: _goToNextStep,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Próxima etapa'),
          )
        else
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar protocolo'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryGradient = _primaryGradientFor(theme.brightness);
    final backgroundGradient = _backgroundGradientFor(theme.brightness);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          widget.protocol == null
              ? 'Novo Protocolo ADL'
              : 'Editar Protocolo ADL',
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: primaryGradient),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showSidebar = constraints.maxWidth >= 980;
                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPageHeader(),
                    const SizedBox(height: 16),
                    if (!showSidebar) ...[
                      _buildCompactSummary(),
                      const SizedBox(height: 16),
                    ],
                    _buildProgressCard(),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _buildCurrentStep(),
                    ),
                    const SizedBox(height: 16),
                    _buildBottomNavigation(),
                  ],
                );

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: showSidebar
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 310,
                                  child: SingleChildScrollView(
                                    child: _buildSidebar(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SingleChildScrollView(child: content),
                                ),
                              ],
                            )
                          : SingleChildScrollView(child: content),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AdlStepMeta {
  const _AdlStepMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
