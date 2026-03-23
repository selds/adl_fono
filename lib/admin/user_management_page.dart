import 'package:adl_fono/models/app_user.dart';
import 'package:adl_fono/services/auth_service.dart';
import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late Future<List<AppUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    _usersFuture = AuthService.getAllUsers();
  }

  void _showCreateUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    UserRole selectedRole = UserRole.fonoaudiologo;
    bool isLoading = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Criar Novo Usuário'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'usuario@exemplo.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    hintText: 'João Silva',
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha (mínimo 6 caracteres)',
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 12),
                DropdownButton<UserRole>(
                  value: selectedRole,
                  isExpanded: true,
                  onChanged: isLoading
                      ? null
                      : (role) {
                          if (role != null) {
                            setState(() => selectedRole = role);
                          }
                        },
                  items: UserRole.values
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(
                            role == UserRole.admin
                                ? 'Administrador'
                                : 'Fonoaudiólogo',
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() => isLoading = true);
                      _performCreateUser(
                        dialogContext,
                        emailController.text.trim(),
                        passwordController.text,
                        nameController.text.trim(),
                        selectedRole,
                      ).then((_) {
                        if (mounted) setState(() => isLoading = false);
                      });
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performCreateUser(
    BuildContext dialogContext,
    String email,
    String password,
    String displayName,
    UserRole role,
  ) async {
    final nav = Navigator.of(dialogContext);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await AuthService.createUser(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      if (!mounted) return;
      nav.pop();
      _refreshUsers();
      setState(() {});
      messenger.showSnackBar(
        const SnackBar(content: Text('Usuário criado com sucesso!')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  void _showEditUserDialog(AppUser user) {
    UserRole selectedRole = user.role;
    bool isActive = user.isActive;
    bool isLoading = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text('Editar: ${user.email}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Usuário: ${user.displayName ?? 'N/A'}'),
                const SizedBox(height: 16),
                Text('UID: ${user.uid}'),
                const SizedBox(height: 16),
                const Text('Função:'),
                const SizedBox(height: 8),
                DropdownButton<UserRole>(
                  value: selectedRole,
                  isExpanded: true,
                  onChanged: isLoading
                      ? null
                      : (role) {
                          if (role != null) {
                            setState(() => selectedRole = role);
                          }
                        },
                  items: UserRole.values
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(
                            role == UserRole.admin
                                ? 'Administrador'
                                : 'Fonoaudiólogo',
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Usuário Ativo'),
                  value: isActive,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() => isActive = value ?? true);
                        },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() => isLoading = true);
                      _performUpdateUser(
                        dialogContext,
                        user,
                        selectedRole,
                        isActive,
                      ).then((_) {
                        if (mounted) setState(() => isLoading = false);
                      });
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performUpdateUser(
    BuildContext dialogContext,
    AppUser user,
    UserRole newRole,
    bool isActive,
  ) async {
    final nav = Navigator.of(dialogContext);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (newRole != user.role) {
        await AuthService.updateUserRole(uid: user.uid, role: newRole);
      }
      if (isActive != user.isActive) {
        await AuthService.setUserActive(uid: user.uid, isActive: isActive);
      }
      if (!mounted) return;
      nav.pop();
      _refreshUsers();
      setState(() {});
      messenger.showSnackBar(
        const SnackBar(content: Text('Usuário atualizado!')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Usuários'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        tooltip: 'Criar novo usuário',
        child: const Icon(Icons.person_add),
      ),
      body: FutureBuilder<List<AppUser>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _refreshUsers()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Nenhum usuário encontrado'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showCreateUserDialog,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Criar Primeiro Usuário'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() => _refreshUsers()),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final trimmedName = (user.displayName ?? '').trim();
                final fallbackFromEmail = user.email.contains('@')
                  ? user.email.split('@').first
                  : user.email;
                final displayName = trimmedName.isNotEmpty
                  ? trimmedName
                  : (fallbackFromEmail.isNotEmpty
                      ? fallbackFromEmail
                      : 'Sem nome');
                final roleLabel = user.role == UserRole.admin
                    ? 'Administrador'
                    : 'Fonoaudiólogo';
                final statusColor = user.isActive
                    ? Colors.green
                    : Colors.orange;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.role == UserRole.admin
                          ? Colors.orange
                          : Colors.blue,
                      child: Icon(
                        user.role == UserRole.admin
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(displayName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(roleLabel),
                              backgroundColor: user.role == UserRole.admin
                                  ? Colors.orange.shade100
                                  : Colors.blue.shade100,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                color: user.role == UserRole.admin
                                    ? Colors.orange
                                    : Colors.blue,
                              ),
                            ),
                            Chip(
                              label: Text(user.isActive ? 'Ativo' : 'Inativo'),
                              backgroundColor: statusColor.withAlpha(77),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditUserDialog(user),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
