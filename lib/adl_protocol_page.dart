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

  // EXPRESSIVA
  late final TextEditingController _produzSons;
  late final TextEditingController _vocabulario;
  late final TextEditingController _comunicacaoNaoVerbal;
  late final TextEditingController _imitaPalavra;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final r = widget.protocol?.receptiveAnswers ?? {};
    final p = widget.protocol;

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

    _produzSons = TextEditingController(text: p?.produzSons ?? '');
    _vocabulario = TextEditingController(text: p?.vocabulario ?? '');
    _comunicacaoNaoVerbal =
        TextEditingController(text: p?.comunicacaoNaoVerbal ?? '');
    _imitaPalavra = TextEditingController(text: p?.imitaPalavra ?? '');
  }

  @override
  void dispose() {
    _q5Score.dispose();
    _q6Score.dispose();
    _q7Score.dispose();
    _q8Score.dispose();
    _produzSons.dispose();
    _vocabulario.dispose();
    _comunicacaoNaoVerbal.dispose();
    _imitaPalavra.dispose();
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

    final protocol = AdlProtocol(
      pacienteId: widget.pacienteId,
      receptiveAnswers: receptiveAnswers,
      produzSons: _produzSons.text.trim(),
      vocabulario: _vocabulario.text.trim(),
      comunicacaoNaoVerbal: _comunicacaoNaoVerbal.text.trim(),
      imitaPalavra: _imitaPalavra.text.trim(),
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

  Widget _buildScoreField(TextEditingController controller) {
    return SizedBox(
      width: 56,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
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
          onTap: () => setState(() => onChange(value == true ? null : true)),
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
          onTap: () => setState(() => onChange(value == false ? null : false)),
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

  Widget _buildExpressivaField(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
        minLines: 2,
        maxLines: 4,
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
          description:
              'Material: Manual de Figuras, pagina 2.\nOlhe estas figuras. Mostre...',
          items: [
            _buildSubItem('a. a banana', _q6a, (v) => setState(() => _q6a = v)),
            _buildSubItem('b. o pe', _q6b, (v) => setState(() => _q6b = v)),
            _buildSubItem('c. o carro', _q6c, (v) => setState(() => _q6c = v)),
            _buildSubItem(
              'd. o sapato',
              _q6d,
              (v) => setState(() => _q6d = v),
            ),
            _buildSubItem('e. o gato', _q6e, (v) => setState(() => _q6e = v)),
            _buildSubItem('f. a mao', _q6f, (v) => setState(() => _q6f = v)),
          ],
          scoreInfo: '(1 ponto = 4 acertos)',
        ),
        _buildQuestion(
          title: '7. Identifica partes do corpo em si proprio.',
          score: _q7Score,
          description: 'Mostre o(a) seu(ua)...',
          items: [
            _buildSubItem(
              'a. cabelo',
              _q7a,
              (v) => setState(() => _q7a = v),
            ),
            _buildSubItem('b. olho', _q7b, (v) => setState(() => _q7b = v)),
            _buildSubItem('c. nariz', _q7c, (v) => setState(() => _q7c = v)),
            _buildSubItem('d. pe', _q7d, (v) => setState(() => _q7d = v)),
            _buildSubItem(
              'e. orelha',
              _q7e,
              (v) => setState(() => _q7e = v),
            ),
            _buildSubItem('f. mao', _q7f, (v) => setState(() => _q7f = v)),
            _buildSubItem('g. boca', _q7g, (v) => setState(() => _q7g = v)),
          ],
          scoreInfo: '(1 ponto = 4 acertos)',
        ),
        _buildQuestion(
          title: '8. Compreende acoes dentro de um contexto.',
          score: _q8Score,
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
      ],
    );

    final expressivaContent = _buildColumnCard(
      title: 'LINGUAGEM EXPRESSIVA',
      children: [
        _buildExpressivaField(
          '1. Produz sons silabicos variados (faz combinacao de sons)',
          _produzSons,
        ),
        _buildExpressivaField(
          '2. Possui vocabulario de pelo menos uma palavra',
          _vocabulario,
        ),
        _buildExpressivaField(
          '3. Comunica-se de forma nao verbal (gestos, apontar)',
          _comunicacaoNaoVerbal,
        ),
        _buildExpressivaField('4. Imita uma palavra', _imitaPalavra),
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
