<div align="center">

# 🧠 ADL Fonoaudiologia

**Avaliação do Desenvolvimento da Linguagem — Plataforma Digital para Fonoaudiólogos**

[![Deploy Flutter Web](https://github.com/selds/adl_fono/actions/workflows/deploy.yml/badge.svg)](https://github.com/selds/adl_fono/actions/workflows/deploy.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.41.5-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%2B%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Plataformas](https://img.shields.io/badge/Plataformas-Web%20%7C%20Android%20%7C%20iOS-4CAF50?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/multi-platform)
[![Licença](https://img.shields.io/github/license/selds/adl_fono?style=for-the-badge&color=blue)](LICENSE)
[![Versão](https://img.shields.io/badge/vers%C3%A3o-0.1.0-informational?style=for-the-badge)](pubspec.yaml)

---

> Aplicativo Flutter para avaliação e acompanhamento do desenvolvimento da linguagem (ADL-2) por fonoaudiólogos.
> Cadastro de pacientes, aplicação do protocolo ADL completo com cálculo automático de escores e geração de relatórios.

</div>

---

## ✨ Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| 📝 **Anamnese** | Cadastro completo do paciente (dados pessoais, diagnóstico, avaliador, ambiente familiar) |
| 🧪 **Protocolo ADL** | Aplicação do ADL-2 com seções de Linguagem Compreensiva e Expressiva por faixa etária |
| 📊 **Cálculo dos Escores** | Ponto de partida, base (5 acertos) e teto (5 erros consecutivos) calculados automaticamente |
| 📂 **Histórico** | Consulta de protocolos por paciente com resultados LR, LE e LG |
| 📄 **Relatórios** | Exportação em CSV e PDF com resumo de atendimentos |
| 👥 **Usuários** | Painel admin com controle de acesso por papel (`admin` / `fonoaudiologo`) |
| 🌓 **Tema claro/escuro** | Salvo por preferência do dispositivo |

---

## 🏗️ Arquitetura

```text
┌─────────────────┬──────────────────────────────┐
│ Camada       │ Tecnologia                    │
├─────────────────┼──────────────────────────────┤
│ Frontend     │ Flutter Web / Android / iOS   │
├─────────────────┼──────────────────────────────┤
│ Autenticação │ Firebase Authentication        │
├─────────────────┼──────────────────────────────┤
│ Banco        │ Cloud Firestore               │
├─────────────────┼──────────────────────────────┤
│ Arquivos     │ Firebase Storage              │
├─────────────────┼──────────────────────────────┤
│ Deploy Web   │ GitHub Pages (via Actions)    │
└─────────────────┴──────────────────────────────┘
```

---

## 📂 Estrutura do Projeto

```text
adl_fono/
├── lib/                   # Código Flutter (frontend)
├── assets/                # Assets estáticos (imagens, fontes)
├── icons/                 # Ícones do app
├── android/               # Configurações Android
├── ios/                   # Configurações iOS
├── web/                   # Configurações Flutter Web
├── .github/workflows/     # CI/CD (GitHub Actions)
├── DEPLOY.md              # Guia de deploy e configuração
├── LICENSE
└── README.md
```

---

## ✅ Requisitos

- **Flutter 3.41.5+**
- **Dart 3.x**
- Projeto configurado no **Firebase** (Firestore, Authentication, Storage)
- **Node.js** (opcional, para ferramentas de deploy)

---

## ⚡ Instalação Local

```bash
# Clone o repositório
git clone https://github.com/selds/adl_fono.git
cd adl_fono

# Instale as dependências
flutter pub get

# Execute o app
flutter run
```

> **Atenção**: Requer as variáveis do Firebase configuradas via `--dart-define` ou arquivo `.env`.
> Consulte o [DEPLOY.md](DEPLOY.md) para detalhes completos de configuração de produção.

---

## ⚙️ Variáveis de Ambiente

As configurações do Firebase são passadas via `--dart-define` no build:

```bash
flutter build web \
  --dart-define=FIREBASE_API_KEY=sua_chave \
  --dart-define=FIREBASE_AUTH_DOMAIN=seu_projeto.firebaseapp.com \
  --dart-define=FIREBASE_PROJECT_ID=seu_projeto \
  --dart-define=FIREBASE_STORAGE_BUCKET=seu_projeto.appspot.com \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=123456789 \
  --dart-define=FIREBASE_APP_ID=1:123456789:web:abc123
```

---

## 🛡️ Administração

O primeiro admin deve ser configurado manualmente no Firebase Console:

```text
1. Firestore Console
   └── coleção: users
       └── documento: {uid}
           └── campo: role = "admin"

2. Faça logout/login no app para atualizar o estado.
```

A partir daí, admins podem gerenciar outros usuários diretamente pela interface do app.

---

## 🚀 Deploy

O deploy web é feito automaticamente via **GitHub Actions** ao fazer push na branch `main`.

O app é publicado no **GitHub Pages**:

```
https://selds.github.io/adl_fono/
```

Para detalhes completos de configuração, consulte o [DEPLOY.md](DEPLOY.md).

---

## 📄 Licença

Distribuído sob a licença **GPL-3.0**. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.

---

<div align="center">

Feito com ❤️ para a área de **Fonoaudiologia**

Stack: Flutter · Firebase · GitHub Pages

</div>
