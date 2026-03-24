import 'package:flutter/material.dart';

class ScoresPage extends StatelessWidget {
  const ScoresPage({super.key});

  static const List<_ScorePair> _compreensivaParte1 = [
    _ScorePair('0-4', '54'),
    _ScorePair('5', '56'),
    _ScorePair('6', '57'),
    _ScorePair('7', '59'),
    _ScorePair('8', '61'),
    _ScorePair('9', '63'),
    _ScorePair('10', '65'),
    _ScorePair('11', '66'),
    _ScorePair('12', '68'),
    _ScorePair('13', '70'),
    _ScorePair('14', '72'),
    _ScorePair('15', '73'),
    _ScorePair('16', '75'),
    _ScorePair('17', '77'),
    _ScorePair('18', '79'),
    _ScorePair('19', '81'),
    _ScorePair('20', '82'),
    _ScorePair('21', '84'),
    _ScorePair('22', '86'),
    _ScorePair('23', '88'),
    _ScorePair('24', '90'),
    _ScorePair('25', '91'),
    _ScorePair('26', '93'),
    _ScorePair('27', '95'),
    _ScorePair('28', '97'),
    _ScorePair('29', '99'),
    _ScorePair('30', '100'),
    _ScorePair('31', '102'),
    _ScorePair('32', '104'),
  ];

  static const List<_ScorePair> _expressivaParte1 = [
    _ScorePair('0-2', '54'),
    _ScorePair('3', '56'),
    _ScorePair('4', '57'),
    _ScorePair('5', '59'),
    _ScorePair('6', '61'),
    _ScorePair('7', '62'),
    _ScorePair('8', '64'),
    _ScorePair('9', '66'),
    _ScorePair('10', '67'),
    _ScorePair('11', '69'),
    _ScorePair('12', '70'),
    _ScorePair('13', '72'),
    _ScorePair('14', '74'),
    _ScorePair('15', '75'),
    _ScorePair('16', '77'),
    _ScorePair('17', '78'),
    _ScorePair('18', '80'),
    _ScorePair('19', '82'),
    _ScorePair('20', '83'),
    _ScorePair('21', '85'),
    _ScorePair('22', '86'),
    _ScorePair('23', '88'),
    _ScorePair('24', '90'),
    _ScorePair('25', '91'),
    _ScorePair('26', '93'),
    _ScorePair('27', '95'),
    _ScorePair('28', '96'),
    _ScorePair('29', '98'),
    _ScorePair('30', '99'),
  ];

  static const List<_ScorePair> _compreensivaParte2 = [
    _ScorePair('33', '106'),
    _ScorePair('34', '107'),
    _ScorePair('35', '109'),
    _ScorePair('36', '111'),
    _ScorePair('37', '113'),
    _ScorePair('38', '115'),
    _ScorePair('39', '116'),
    _ScorePair('40', '118'),
    _ScorePair('41', '120'),
    _ScorePair('42', '122'),
    _ScorePair('43', '124'),
    _ScorePair('44', '125'),
    _ScorePair('45', '127'),
    _ScorePair('46', '129'),
    _ScorePair('47', '131'),
    _ScorePair('48', '133'),
    _ScorePair('49', '134'),
    _ScorePair('50', '136'),
    _ScorePair('51', '138'),
    _ScorePair('52', '140'),
  ];

  static const List<_ScorePair> _expressivaParte2 = [
    _ScorePair('31', '101'),
    _ScorePair('32', '103'),
    _ScorePair('33', '104'),
    _ScorePair('34', '106'),
    _ScorePair('35', '107'),
    _ScorePair('36', '109'),
    _ScorePair('37', '111'),
    _ScorePair('38', '112'),
    _ScorePair('39', '114'),
    _ScorePair('40', '115'),
    _ScorePair('41', '117'),
    _ScorePair('42', '119'),
    _ScorePair('43', '120'),
    _ScorePair('44', '122'),
    _ScorePair('45', '124'),
    _ScorePair('46', '125'),
    _ScorePair('47', '127'),
    _ScorePair('48', '128'),
    _ScorePair('49', '130'),
    _ScorePair('50', '132'),
    _ScorePair('51', '133'),
    _ScorePair('52', '135'),
    _ScorePair('53', '136'),
    _ScorePair('54', '138'),
    _ScorePair('55', '140'),
    _ScorePair('56', '141'),
    _ScorePair('57', '143'),
    _ScorePair('58', '144'),
  ];

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Tabela dos Escores ADL'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: primaryGradient),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1220),
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
                            'Faixa etária: 3 anos a 3 anos e 5 meses',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Conversão de escore bruto para escore padrão em Linguagem Compreensiva e Linguagem Expressiva.',
                            style: TextStyle(color: Colors.white, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 980;
                      final left = _ScoreTableCard(
                        title: '3 anos a 3 anos e 5 meses',
                        compreensiva: _compreensivaParte1,
                        expressiva: _expressivaParte1,
                        colorScheme: colorScheme,
                      );
                      final right = _ScoreTableCard(
                        title: '3 anos a 3 anos e 5 meses (cont.)',
                        compreensiva: _compreensivaParte2,
                        expressiva: _expressivaParte2,
                        colorScheme: colorScheme,
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: left),
                            const SizedBox(width: 14),
                            Expanded(child: right),
                          ],
                        );
                      }

                      return Column(
                        children: [left, const SizedBox(height: 14), right],
                      );
                    },
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

class _ScoreTableCard extends StatelessWidget {
  const _ScoreTableCard({
    required this.title,
    required this.compreensiva,
    required this.expressiva,
    required this.colorScheme,
  });

  final String title;
  final List<_ScorePair> compreensiva;
  final List<_ScorePair> expressiva;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final rowCount = compreensiva.length > expressiva.length
        ? compreensiva.length
        : expressiva.length;

    return Card(
      elevation: 2,
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: colorScheme.primaryContainer,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 560),
              child: Column(
                children: [
                  _tableRow(
                    colorScheme,
                    const ['Linguagem Compreensiva', 'Linguagem Expressiva'],
                    bold: true,
                    grouped: true,
                  ),
                  _tableRow(
                    colorScheme,
                    const [
                      'Escore Bruto',
                      'Escore Padrão',
                      'Escore Bruto',
                      'Escore Padrão',
                    ],
                    bold: true,
                    background: colorScheme.surfaceContainerHighest,
                  ),
                  ...List.generate(rowCount, (index) {
                    final comp = index < compreensiva.length
                        ? compreensiva[index]
                        : const _ScorePair('', '');
                    final exp = index < expressiva.length
                        ? expressiva[index]
                        : const _ScorePair('', '');
                    final zebra = index.isEven
                        ? colorScheme.surface
                        : colorScheme.surfaceContainerLow;

                    return _tableRow(colorScheme, [
                      comp.rawScore,
                      comp.standardScore,
                      exp.rawScore,
                      exp.standardScore,
                    ], background: zebra);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(
    ColorScheme colorScheme,
    List<String> values, {
    bool bold = false,
    bool grouped = false,
    Color? background,
  }) {
    if (grouped) {
      return Row(
        children: [
          _cell(
            values[0],
            colorScheme,
            widthFlex: 2,
            bold: bold,
            background: background,
          ),
          _cell(
            values[1],
            colorScheme,
            widthFlex: 2,
            bold: bold,
            background: background,
          ),
        ],
      );
    }

    return Row(
      children: values
          .map(
            (value) => _cell(
              value,
              colorScheme,
              widthFlex: 1,
              bold: bold,
              background: background,
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _cell(
    String text,
    ColorScheme colorScheme, {
    required int widthFlex,
    bool bold = false,
    Color? background,
  }) {
    return Expanded(
      flex: widthFlex,
      child: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(minHeight: 34),
        decoration: BoxDecoration(
          color: background ?? colorScheme.surface,
          border: Border(
            right: BorderSide(color: colorScheme.outlineVariant),
            bottom: BorderSide(color: colorScheme.outlineVariant),
            left: BorderSide(color: colorScheme.outlineVariant),
            top: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: colorScheme.onSurface,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class _ScorePair {
  const _ScorePair(this.rawScore, this.standardScore);

  final String rawScore;
  final String standardScore;
}
