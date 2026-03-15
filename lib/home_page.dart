import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.userData});

  final Map<String, String>? userData;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, String> _userData;

  @override
  void initState() {
    super.initState();
    _userData =
        widget.userData ??
        {
          'name': 'Usuário',
          'email': 'exemplo@dominio.com',
          'photo': '',
          'role': 'Administrador',
        };
  }

  void _editProfile() {
    showDialog<void>(
      context: context,
      builder: (context) => _EditProfileDialog(
        initialData: _userData,
        onSave: (updatedData) {
          setState(() {
            _userData = updatedData;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADL'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Painel do usuário logado
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _userData['photo']!.isNotEmpty
                              ? NetworkImage(_userData['photo']!)
                              : null,
                          backgroundColor: const Color(0xFF667eea),
                          child: _userData['photo']!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Bem-vindo, ${_userData['name']}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: _editProfile,
                                    tooltip: 'Editar perfil',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userData['email']!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              if (_userData['role']!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _userData['role']!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _ActionCard(
                      label: 'Criar nova anamnese',
                      icon: Icons.note_add,
                      color: const Color(0xFF667eea),
                      onTap: () => Navigator.of(context).pushNamed('/anamnese'),
                    ),
                    _ActionCard(
                      label: 'Acessar histórico',
                      icon: Icons.history,
                      color: const Color(0xFF764ba2),
                      onTap: () => Navigator.of(context).pushNamed('/history'),
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

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.initialData, required this.onSave});

  final Map<String, String> initialData;
  final void Function(Map<String, String>) onSave;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _photoController;
  late final TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name']);
    _emailController = TextEditingController(text: widget.initialData['email']);
    _photoController = TextEditingController(text: widget.initialData['photo']);
    _roleController = TextEditingController(text: widget.initialData['role']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _photoController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'photo': _photoController.text.trim(),
      'role': _roleController.text.trim(),
    };
    widget.onSave(updatedData);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _photoController,
              decoration: const InputDecoration(
                labelText: 'URL da Foto (opcional)',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Cargo'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovering = false;
  bool _pressed = false;

  void _setHover(bool value) {
    setState(() {
      _hovering = value;
    });
  }

  void _setPressed(bool value) {
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final elevation = _pressed ? 2.0 : (_hovering ? 14.0 : 8.0);
    final scale = _pressed ? 0.98 : (_hovering ? 1.02 : 1.0);
    final transform = Matrix4.diagonal3Values(scale, scale, 1);

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: transform,
        child: SizedBox(
          width: 260,
          height: 140,
          child: Material(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
            elevation: elevation,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap,
              onTapDown: (_) => _setPressed(true),
              onTapCancel: () => _setPressed(false),
              onTapUp: (_) => _setPressed(false),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, size: 36, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
