import 'package:flutter/material.dart';

class FichaPacientePage extends StatelessWidget {
  const FichaPacientePage({super.key});

  LinearGradient get _primaryGradient => const LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: const Text('Dados do Paciente'),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: _primaryGradient)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho (faixa vermelha da planilha)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(gradient: _primaryGradient),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _HeaderRow(
                      label: 'Nome da Criança',
                      child: _buildField('Paulo Miguel Borba Lima Lobo'),
                    ),
                    const SizedBox(height: 8),
                    _HeaderRow(
                      label: 'Data de Nasc.',
                      child: _buildField('02/05/2023'),
                    ),
                    const SizedBox(height: 8),
                    _HeaderRow(
                      label: 'Sexo',
                      child: _buildField('Masculino'),
                    ),
                    const SizedBox(height: 8),
                    _HeaderRow(
                      label: 'Responsável',
                      child: _buildField('Binca Romênia Lima Lobo e Rodrigo'),
                    ),
                    const SizedBox(height: 8),
                    _HeaderRow(
                      label: 'Data da Avaliação',
                      child: _buildField('04/02/2025'),
                    ),
                    const SizedBox(height: 8),
                    _HeaderRow(
                      label: 'Avaliador(a)',
                      child: _buildField('Camila Corrêa Lopes'),
                    ),
                    const SizedBox(height: 8),
                    _HeaderRow(
                      label: 'Especialidade',
                      child: _buildField('Fonoaudiologia'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Card de Anamnese
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título ANAMNESE com gradiente
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: _primaryGradient,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
                          subtitle: 'Quem mora na casa? Ex.: pai, mãe, irmãos...',
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
    );
  }

  Widget _buildField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
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
    return Row(
      children: [
        SizedBox(
          width: 130,
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
    required this.maxLines,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
