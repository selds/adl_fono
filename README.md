# ADL Fonoaudiologia

[![Deploy Flutter Web](https://github.com/selds/adl_fono/actions/workflows/deploy.yml/badge.svg)](https://github.com/selds/adl_fono/actions/workflows/deploy.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.41.5-blue?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%2B%20Auth-orange?logo=firebase)](https://firebase.google.com)
[![Plataformas](https://img.shields.io/badge/Plataformas-Web%20%7C%20Android%20%7C%20iOS-green)](https://flutter.dev/multi-platform)
[![Licença](https://img.shields.io/github/license/selds/adl_fono)](LICENSE)
[![Último commit](https://img.shields.io/github/last-commit/selds/adl_fono)](https://github.com/selds/adl_fono/commits/main)
[![Versão](https://img.shields.io/badge/vers%C3%A3o-0.1.0-informational)](pubspec.yaml)

Aplicativo Flutter para avaliação e acompanhamento do desenvolvimento da linguagem (ADL-2) por fonoaudiólogos. Permite cadastrar pacientes, aplicar o protocolo ADL completo com cálculo automático de escores e gerar relatórios.

## Funcionalidades

- **Anamnese**: Cadastro completo do paciente (dados pessoais, diagnóstico, avaliador, ambiente familiar).
- **Protocolo ADL**: Aplicação do protocolo ADL-2 com seções de Linguagem Compreensiva e Expressiva, agrupadas por faixa etária.
- **Cálculo dos Escores**: Ponto de partida por idade cronológica, base (5 acertos consecutivos), teto (5 erros consecutivos) e escore bruto — tudo calculado automaticamente.
- **Histórico**: Consulta dos protocolos por paciente com resultado dos escores (LR, LE, LG).
- **Relatórios**: Exportação em CSV e PDF com resumo de atendimentos.
- **Gerenciamento de usuários**: Painel admin para controle de acesso por papel (`admin` / `fonoaudiologo`).
- **Tema claro/escuro**: Salvo por preferência do dispositivo.

## Tecnologias

| Camada | Tecnologia |
|---|---|
| Framework | Flutter (Dart) |
| Backend / Auth | Firebase Authentication |
| Banco de dados | Cloud Firestore |
| Armazenamento | Firebase Storage |
| Deploy Web | GitHub Pages (Actions) |

## Instalação local

```bash
git clone https://github.com/selds/adl_fono.git
cd adl_fono
flutter pub get
flutter run
```

> Requer as variáveis do Firebase configuradas via `--dart-define` ou arquivo `.env`. Consulte [DEPLOY.md](DEPLOY.md) para detalhes de produção.

## Administração

O primeiro admin deve ser definido manualmente no Firebase Console:

1. Firestore → coleção `users` → documento `{uid}` → campo `role = admin`
2. Faça logout/login no app para atualizar o estado.

A partir daí, admins podem gerenciar outros usuários pela interface do app.

## Licença

[MIT](LICENSE)

