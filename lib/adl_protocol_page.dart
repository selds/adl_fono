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
  // Q6 sub-respostas
  bool? _q6a, _q6b, _q6c, _q6d, _q6e, _q6f;
  // Q7 sub-respostas
  bool? _q7a, _q7b, _q7c, _q7d, _q7e, _q7f, _q7g;
  // Q8 sub-respostas
  bool? _q8a, _q8b, _q8c;

  // EXPRESSIVA - campos de digitacao por questao
  late final TextEditingController _q1ExpScore;
  late final TextEditingController _q1ExpText;
  late final TextEditingController _q2ExpScore;
  late final TextEditingController _q2ExpText;
  late final TextEditingController _q3ExpScore;
  late final TextEditingController _q3ExpText;
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

    _q6Score = TextEditingController(text: r['q6Score'] as String? ?? '');
    _q6a = r['q6a'] as bool?;
    _q6b = r['q6b'] as bool?;
    _q6c = r['q6c'] as bool?;
    _q6d = r['q6d'] as bool?;
    _q6e = r['q6e'] as bool?;
    _q6f = r['q6f'] as bool?;

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
    _q2ExpScore = TextEditingController(text: e['q2Score'] as String? ?? '');
    _q2ExpText = TextEditingController(text: e['q2Text'] as String? ?? '');
    _q3ExpScore = TextEditingController(text: e['q3Score'] as String? ?? '');
    _q3ExpText = TextEditingController(text: e['q3Text'] as String? ?? '');
    _q4ExpScore = TextEditingController(text: e['q4Score'] as String? ?? '');
    _q4ExpText = TextEditingController(text: e['q4Text'] as String? ?? '');

    _updateReceptivaScores();
  }

  @override
  void dispose() {
    _q5Score.dispose();
    _q6Score.dispose();
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
      'q6Score': _q6Score.text.trim(),
      'q6a': _q6a,
      'q6b': _q6b,
      'q6c': _q6c,
      'q6d': _q6d,
      'q6e': _q6e,
      'q6f': _q6f,
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
      'q2Score': _q2ExpScore.text.trim(),
      'q2Text': _q2ExpText.text.trim(),
      'q3Score': _q3ExpScore.text.trim(),
      'q3Text': _q3ExpText.text.trim(),
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
      acertos: _countSim([_q5a, _q5b, _q5c]),
      minAcertos: 2,
    ).toString();

    _q6Score.text = _scoreByThreshold(
      acertos: _countSim([_q6a, _q6b, _q6c, _q6d, _q6e, _q6f]),
      minAcertos: 4,
    ).toString();

    _q7Score.text = _scoreByThreshold(
      acertos: _countSim([_q7a, _q7b, _q7c, _q7d, _q7e, _q7f, _q7g]),
      minAcertos: 4,
    ).toString();

    _q8Score.text = _scoreByThreshold(
      acertos: _countSim([_q8a, _q8b, _q8c]),
      minAcertos: 2,
    ).toString();
  }

  int get _expressivaTotal {
    return _scoreToInt(_q1ExpScore.text) +
        _scoreToInt(_q2ExpScore.text) +
        _scoreToInt(_q3ExpScore.text) +
        _scoreToInt(_q4ExpScore.text);
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

  Widget _buildYesNoToggle(bool? value, void Function(bool?) onChange) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            onChange(value == true ? null : true);
            _updateReceptivaScores();
          }),
          child: Container(
            width: 34,
            height: 28,
            decoration: BoxDecoration(
              color: value == true ? Colors.green : Colors.transparent,
              border: Border.all(color: Colors.green, width: 1.5),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(4),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'S',
              style: TextStyle(
                color: value == true ? Colors.white : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() {
            onChange(value == false ? null : false);
            _updateReceptivaScores();
          }),
          child: Container(
            width: 34,
            height: 28,
            decoration: BoxDecoration(
              color: value == false ? Colors.red : Colors.transparent,
              border: Border.all(color: Colors.red, width: 1.5),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(4),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'N',
              style: TextStyle(
                color: value == false ? Colors.white : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubItem(
    String label,
    bool? value,
    void Function(bool?) onChange,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          const SizedBox(width: 8),
          _buildYesNoToggle(value, onChange),
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
              _buildScoreField(score),
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
      title: 'LINGUAGEM RECEPTIVA',
      children: [
        _buildQuestion(
          title: '5. Compreende ordens simples sem pistas gestuais',
          score: _q5Score,
          readOnlyScore: true,
          description: 'Ordem: Vamos ver as bolas que estao dentro da bolsa?',
          items: [
            _buildSubItem(
              'a. Tire as bolas de dentro da bolsa.',
              _q5a,
              (v) => setState(() => _q5a = v),
            ),
            _buildSubItem(
              'b. Agora me de uma bola.',
              _q5b,
              (v) => setState(() => _q5b = v),
            ),
            _buildSubItem(
              'c. Agora ponha as bolas dentro da bolsa.',
              _q5c,
              (v) => setState(() => _q5c = v),
            ),
          ],
          scoreInfo: '(1 ponto = 2 acertos)',
        ),
        _buildQuestion(
          title: '6. Identifica figuras.',
          score: _q6Score,
          readOnlyScore: true,
          description:
              'Material: Manual de Figuras, pagina 2.\nOlhe estas figuras. Mostre...',
          items: [
            _buildSubItem('a. a banana', _q6a, (v) => setState(() => _q6a = v)),
            _buildSubItem('b. o pe', _q6b, (v) => setState(() => _q6b = v)),
            _buildSubItem('c. o carro', _q6c, (v) => setState(() => _q6c = v)),
            _buildSubItem('d. o sapato', _q6d, (v) => setState(() => _q6d = v)),
            _buildSubItem('e. o gato', _q6e, (v) => setState(() => _q6e = v)),
            _buildSubItem('f. a mao', _q6f, (v) => setState(() => _q6f = v)),
          ],
          scoreInfo: '(1 ponto = 4 acertos)',
        ),
        _buildQuestion(
          title: '7. Identifica partes do corpo em si proprio.',
          score: _q7Score,
          readOnlyScore: true,
          description: 'Mostre o(a) seu(ua)...',
          items: [
            _buildSubItem('a. cabelo', _q7a, (v) => setState(() => _q7a = v)),
            _buildSubItem('b. olho', _q7b, (v) => setState(() => _q7b = v)),
            _buildSubItem('c. nariz', _q7c, (v) => setState(() => _q7c = v)),
            _buildSubItem('d. pe', _q7d, (v) => setState(() => _q7d = v)),
            _buildSubItem('e. orelha', _q7e, (v) => setState(() => _q7e = v)),
            _buildSubItem('f. mao', _q7f, (v) => setState(() => _q7f = v)),
            _buildSubItem('g. boca', _q7g, (v) => setState(() => _q7g = v)),
          ],
          scoreInfo: '(1 ponto = 4 acertos)',
        ),
        _buildQuestion(
          title: '8. Compreende acoes dentro de um contexto.',
          score: _q8Score,
          readOnlyScore: true,
          description:
              'Material: um cachorrinho, um pratinho, uma colher e um copo.\n'
              'Ordem: Coloque o material sobre a mesa e fale para a crianca:',
          items: [
            _buildSubItem(
              'a. O cachorro esta com fome. De comida para ele comer.',
              _q8a,
              (v) => setState(() => _q8a = v),
            ),
            _buildSubItem(
              'b. O cachorro esta com sede. De agua pra ele beber.',
              _q8b,
              (v) => setState(() => _q8b = v),
            ),
            _buildSubItem(
              'c. O cachorro esta com sono. Bote ele pra dormir.',
              _q8c,
              (v) => setState(() => _q8c = v),
            ),
          ],
          scoreInfo: '(1 ponto = 2 acertos)',
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
                  'Pontuacao total da linguagem receptiva',
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
          title: '1. Produz sons silabicos variados (faz combinacao de sons).',
          score: _q1ExpScore,
          description:
              'Observacao realizada em contexto ludico. Escreva os exemplos:',
          inputLabel: 'Exemplos observados',
          inputController: _q1ExpText,
          scoreInfo:
              '(1 ponto = produz duas silabas ou mais variando os fonemas em uma emissao vocal)',
        ),
        _buildExpressivaQuestion(
          title: '2. Possui vocabulario de pelo menos uma palavra:',
          score: _q2ExpScore,
          inputLabel: 'Palavra(s) utilizada(s)',
          inputController: _q2ExpText,
          scoreInfo:
              '(1 ponto = usa consistentemente a mesma combinacao de sons para nomear uma pessoa ou um objeto)',
        ),
        _buildExpressivaQuestion(
          title:
              '3. Comunica-se de forma nao verbal, usando gestos, chamando atencao para si ou apontando para um objeto ou pessoa.',
          score: _q3ExpScore,
          description: 'Descreva o que a crianca faz:',
          inputLabel: 'Comportamentos observados',
          inputController: _q3ExpText,
          scoreInfo:
              '(1 ponto = se apresenta alguns comportamentos descritos. Ex.: entrega brinquedo, puxa pela mao, aponta etc.)',
        ),
        _buildExpressivaQuestion(
          title: '4. Imita uma palavra:',
          score: _q4ExpScore,
          description:
              'Material: bola, carro, miniatura de boneco ou palavras do contexto da crianca como "mamae" e "papai".\n'
              'A examinadora aponta para o objeto e em seguida nomeia para a crianca, estimulando-a a repetir:\n'
              'Ex.: Olhe a bola ... bola\n'
              'Marque as palavras que a crianca repete:',
          inputLabel: 'Palavras repetidas',
          inputController: _q4ExpText,
          scoreInfo: '(1 ponto = repete 1 palavra)',
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
                  'Pontuacao total da linguagem expressiva',
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
                          'ADL\nPROTOCOLO DE APLICACAO E PONTUACAO',
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
                      '1 ano e 6 meses ate 1 ano e 11 meses',
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
