import 'package:adl_fono/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.userData,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  final Map<String, dynamic>? userData;
  final ThemeMode currentThemeMode;
  final Future<void> Function(ThemeMode mode) onThemeModeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late Map<String, dynamic> _userData;

  Future<void> _refreshUserAccess() async {
    try {
      final appUser = await AuthService.getCurrentUserProfile();
      if (!mounted || appUser == null) return;

      final fallbackName = (_userData['name'] as String?) ?? 'Usuário';
      final displayName = (appUser.displayName ?? '').trim();
      setState(() {
        _userData = {
          ..._userData,
          'name': displayName.isEmpty ? fallbackName : displayName,
          'email': appUser.email,
          'photo': appUser.photoUrl ?? '',
          'role': appUser.role.value,
          'uid': appUser.uid,
          'isAdmin': appUser.isAdmin,
        };
      });
    } catch (_) {
      // Em caso de falha transitória, mantém os dados atuais da sessão.
    }
  }

  Future<void> _showThemeModeDialog() async {
    ThemeMode selected = widget.currentThemeMode;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Tema da interface'),
              content: RadioGroup<ThemeMode>(
                groupValue: selected,
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() => selected = value);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    RadioListTile<ThemeMode>(
                      title: Text('Claro'),
                      value: ThemeMode.light,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('Escuro'),
                      value: ThemeMode.dark,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('Seguir dispositivo'),
                      value: ThemeMode.system,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nav = Navigator.of(dialogContext);
                    await widget.onThemeModeChanged(selected);
                    if (!nav.mounted) return;
                    nav.pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _userData =
        widget.userData ??
        {
          'name': 'Usuário',
          'email': 'exemplo@dominio.com',
          'photo': '',
          'role': 'fonoaudiologo',
          'uid': '',
          'isAdmin': false,
        };

    _refreshUserAccess();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userData != widget.userData && widget.userData != null) {
      _userData = {..._userData, ...widget.userData!};
      _refreshUserAccess();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshUserAccess();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _showProfile() async {
    await showDialog<void>(
      context: context,
      builder: (context) =>
          _ProfileDialog(profileData: _userData, onEditPressed: _editProfile),
    );
  }

  Future<void> _editProfile() async {
    final updatedData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EditProfileDialog(initialData: _userData),
    );

    if (updatedData == null) return;

    try {
      await AuthService.updateCurrentUserProfile(
        displayName: updatedData['name'] as String,
        photoUrl: updatedData['photo'] as String,
      );
      await _refreshUserAccess();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar perfil: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Avaliação do Desenvolvimento da Linguagem 2 - ADL'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Alterar tema',
            onPressed: _showThemeModeDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              final nav = Navigator.of(context);
              AuthService.signOut().then((_) {
                nav.pushReplacementNamed('/login');
              });
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
                                    onPressed: _showProfile,
                                    tooltip: 'Ver perfil',
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
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Opacity(
                    opacity: 0.75,
                    child: Text(
                      'v1.0.0',
                      style: Theme.of(context).textTheme.labelSmall,
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
                      onTap: () => Navigator.of(context)
                          .pushNamed('/anamnese')
                          .then((_) => _refreshUserAccess()),
                    ),
                    _ActionCard(
                      label: 'Acessar histórico',
                      icon: Icons.history,
                      color: const Color(0xFF764ba2),
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed('/history').then((_) => _refreshUserAccess()),
                    ),
                    if (_userData['isAdmin'] == true)
                      _ActionCard(
                        label: 'Gerenciar usuários',
                        icon: Icons.admin_panel_settings,
                        color: const Color(0xFFFF6B6B),
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed('/admin').then((_) => _refreshUserAccess()),
                      ),
                    if (_userData['isAdmin'] == true)
                      _ActionCard(
                        label: 'Logs de acesso',
                        icon: Icons.fact_check,
                        color: const Color(0xFF2E7D32),
                        onTap: () => Navigator.of(context)
                            .pushNamed('/admin/logs')
                            .then((_) => _refreshUserAccess()),
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
  const _EditProfileDialog({required this.initialData});

  final Map<String, dynamic> initialData;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  static const int _maxUploadBytes = 5 * 1024 * 1024;
  static const Set<String> _acceptedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _photoController;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name']);
    _emailController = TextEditingController(text: widget.initialData['email']);
    _photoController = TextEditingController(text: widget.initialData['photo']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  void _save() {
    final rawPhoto = _photoController.text.trim();
    if (rawPhoto.isNotEmpty) {
      final uri = Uri.tryParse(rawPhoto);
      final isHttp =
          uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
      if (!isHttp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe uma URL válida (http/https).')),
        );
        return;
      }
    }

    final updatedData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'photo': rawPhoto,
      'role': widget.initialData['role'],
      'uid': widget.initialData['uid'],
      'isAdmin': widget.initialData['isAdmin'] ?? false,
    };
    Navigator.of(context).pop(updatedData);
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final selected = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (selected == null) return;
      if (!mounted) return;

      final fileName = selected.name.trim().toLowerCase();
      final extIndex = fileName.lastIndexOf('.');
      final extension = extIndex == -1 ? '' : fileName.substring(extIndex + 1);
      if (!_acceptedExtensions.contains(extension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formato não suportado. Use JPG, JPEG, PNG ou WEBP.'),
          ),
        );
        return;
      }

      final fileSize = await selected.length();
      if (!mounted) return;
      if (fileSize > _maxUploadBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arquivo muito grande. Tamanho máximo: 5 MB.'),
          ),
        );
        return;
      }

      setState(() => _uploadingPhoto = true);
      final url = await AuthService.uploadCurrentUserProfilePhoto(selected);
      if (!mounted) return;
      setState(() {
        _photoController.text = url;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto enviada com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao enviar foto: $e')));
    } finally {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: _photoController.text.trim().isNotEmpty
                  ? NetworkImage(_photoController.text.trim())
                  : null,
              child: _photoController.text.trim().isEmpty
                  ? const Icon(Icons.person, size: 32)
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _photoController,
              decoration: const InputDecoration(
                labelText: 'URL da foto de perfil (opcional)',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _uploadingPhoto ? null : _pickAndUploadPhoto,
                icon: _uploadingPhoto
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  _uploadingPhoto
                      ? 'Enviando foto...'
                      : 'Selecionar foto do dispositivo',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tipos aceitos: JPG, JPEG, PNG, WEBP. Tamanho máximo: 5 MB por upload.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
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

class _ProfileDialog extends StatelessWidget {
  const _ProfileDialog({
    required this.profileData,
    required this.onEditPressed,
  });

  final Map<String, dynamic> profileData;
  final Future<void> Function() onEditPressed;

  @override
  Widget build(BuildContext context) {
    final photo = (profileData['photo'] as String?)?.trim() ?? '';
    final role = (profileData['role'] as String?)?.trim() ?? '';

    return AlertDialog(
      title: const Text('Perfil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty ? const Icon(Icons.person, size: 36) : null,
            ),
            const SizedBox(height: 16),
            Text(
              profileData['name'] as String? ?? 'Usuário',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(profileData['email'] as String? ?? ''),
            if (role.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                role,
                style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.of(context).pop();
            await onEditPressed();
          },
          icon: const Icon(Icons.edit),
          label: const Text('Editar perfil'),
        ),
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
