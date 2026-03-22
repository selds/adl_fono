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
  // RECEPTIVA – pontuações por questão
  late final TextEditingController _q5Score;
  late final TextEditingController _q6Score;
  late final TextEditingController _q7Score;
  late final TextEditingController _q8Score;

  // Q5 sub-respostas
  bool? _q5a, _q5b, _q5c;
  late final TextEditingController _q5aText;
  late final TextEditingController _q5bText;
  // Q6 sub-respostas
  bool? _q6a, _q6b, _q6c, _q6d, _q6e, _q6f;
  late final TextEditingController _q6aText;
  late final TextEditingController _q6bText;
  // Q7 sub-respostas
  bool? _q7a, _q7b, _q7c, _q7d, _q7e, _q7f, _q7g;
  // Q8 sub-respostas
  bool? _q8a, _q8b, _q8c;

  // EXPRESSIVA - campos de digitacao por questao
  late final TextEditingController _q1ExpScore;
  late final TextEditingController _q1ExpText;
  bool? _q1ExpMet;
  late final TextEditingController _q2ExpScore;
  late final TextEditingController _q2ExpText;
  bool? _q2ExpMet;
  late final TextEditingController _q3ExpScore;
  late final TextEditingController _q3ExpText;
  bool? _q3ExpMet;
  late final TextEditingController _q4ExpScore;
  late final TextEditingController _q4ExpText;

  final _formKey = GlobalKey<FormState>();

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

  // ── helpers de UI ──────────────────────────────────────────────────────────

  int _scoreToInt(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    return parsed?.round() ?? 0;
  }

  int _countSim(Iterable<bool?> values) {
    return values.where((v) => v == true).length;
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

  Widget _buildScoreField(
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return SizedBox(
      width: 56,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        readOnly: readOnly,
        onChanged: readOnly ? null : (_) => setState(() {}),
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          hintText: '__',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 13)),
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
              decoration: const InputDecoration(
                labelText: 'Resposta',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 6),
          ...items,
          const SizedBox(height: 4),
          Text(
            scoreInfo,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const Divider(height: 20),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Atende ao critério?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
            decoration: InputDecoration(
              labelText: inputLabel,
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
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }

  Widget _buildYesNoToggle(
    bool? value,
    void Function(bool?) onChange, {
    VoidCallback? onAfterChange,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value == true,
              onChanged: (_) => setState(() {
                onChange(value == true ? null : true);
                onAfterChange?.call();
              }),
            ),
            const Text('Sim'),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value == false,
              onChanged: (_) => setState(() {
                onChange(value == false ? null : false);
                onAfterChange?.call();
              }),
            ),
            const Text('Não'),
          ],
        ),
      ],
    );
  }

  Widget _buildColumnCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF667eea),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    final receptivaContent = _buildColumnCard(
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
              (v) => setState(() => _q5a = v),
              _q5aText,
            ),
            _buildSubItem(
              'b. aguarda um minuto, fala o nome da criança, mostra o recipiente com o sabão e assopra as bolinhas de sabão, observando se ela acompanha com o olhar as bolinhas.',
              _q5b,
              (v) => setState(() => _q5b = v),
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
              (v) => setState(() => _q6a = v),
              _q6aText,
            ),
            _buildSubItem(
              'b. aguarda um minuto, depois bate palma atrás da criança, do lado direito, e, por último, do lado esquerdo, observando se ela procura a fonte sonora.',
              _q6b,
              (v) => setState(() => _q6b = v),
              _q6bText,
            ),
          ],
          scoreInfo:
              '1 ponto: quando a criança responde ao item a ou b (cada procedimento poderá ser repetido duas vezes).',
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Pontuação total da linguagem receptiva',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$_receptivaTotal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final expressivaContent = _buildColumnCard(
      title: 'LINGUAGEM EXPRESSIVA',
      children: [
        _buildExpressivaQuestion(
          title:
              '1. Participa de brincadeiras com outra pessoa pelo período de 1 a 2 minutos.',
          score: _q1ExpScore,
          meetsCriteria: _q1ExpMet,
          onMeetsCriteriaChanged: (v) => _q1ExpMet = v,
          description:
              'Material: um marcador de tempo (ex.: celular), paninho e brinquedos.\n'
              'Procedimento: solicitar ao acompanhante que brinque com a criança como faria em casa. O examinador poderá observar e anotar o interesse da criança pelos brinquedos.',
          inputLabel: 'Anotações da observação',
          inputController: _q1ExpText,
          scoreInfo:
              '1 ponto: quando a criança mantém o contato do olhar e demonstra prazer com a brincadeira. Quando este comportamento é observado em outro momento na sessão de avaliação ou o cuidador relata este comportamento no contexto.',
        ),
        _buildExpressivaQuestion(
          title: '2. Comunica-se de forma gestual.',
          score: _q2ExpScore,
          meetsCriteria: _q2ExpMet,
          onMeetsCriteriaChanged: (v) => _q2ExpMet = v,
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
          onMeetsCriteriaChanged: (v) => _q3ExpMet = v,
          description:
              'Material: brinquedos.\n'
              'Procedimento: o cuidador ou o examinador se posiciona frente à criança, de forma que esta possa ver o seu rosto, sorri e verbaliza, imitando os sons que fez durante a sessão de avaliação ou que têm sido observados em casa.',
          inputLabel: 'Vocalizações observadas',
          inputController: _q3ExpText,
          scoreInfo:
              '1 ponto: quando o examinador ou o cuidador fala com a criança e esta responde vocalizando sem movimentos do corpo.',
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Pontuação total da linguagem expressiva',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$_expressivaTotal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.protocol == null
              ? 'Novo Protocolo ADL'
              : 'Editar Protocolo ADL',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecalho
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: const Column(
                      children: [
                        Text(
                          'FONOAUDIOLOGIA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ADL\nPROTOCOLO DE APLICAÇÃO E PONTUAÇÃO',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // Faixa etaria
                  Container(
                    color: const Color(0xFFf0f0f0),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: const Text(
                      '1 ano a 1 ano e 5 meses',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // Colunas
                  if (isWide)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: receptivaContent),
                          const SizedBox(width: 12),
                          Expanded(child: expressivaContent),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        receptivaContent,
                        const SizedBox(height: 12),
                        expressivaContent,
                      ],
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Salvar Protocolo'),
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
