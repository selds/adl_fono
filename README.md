# ADL Fonoaudiologia

Um aplicativo Flutter para gerenciamento de fichas de pacientes em fonoaudiologia, desenvolvido para a Fonoaudiologia.

## Descrição

Este aplicativo permite o cadastro, edição e visualização de fichas de pacientes, incluindo dados pessoais, diagnósticos, avaliações e acompanhamento. Os dados são persistidos localmente e organizados em um histórico acessível.

## Funcionalidades

- **Cadastro de Pacientes**: Formulário completo para inserir dados do paciente, incluindo nome, data de nascimento, sexo, diagnóstico, responsável, data da avaliação, avaliador, especialidade, atividades, ambiente familiar e demanda familiar.
- **Cálculo de Idade**: Exibe a idade atual do paciente baseada na data de nascimento (em anos ou meses).
- **Histórico**: Visualização de todos os registros salvos, agrupados por nome da criança, com busca por nome.
- **Edição e Exclusão**: Edite registros via swipe para a direita ou exclua com confirmação via swipe para a esquerda.
- **Persistência de Dados**: Os dados são salvos localmente usando SharedPreferences, sobrevivendo a reinicializações do app.
- **Interface Intuitiva**: Design moderno com Material Design, campos de data editáveis e seletor de calendário.

## Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento de apps multiplataforma.
- **Dart**: Linguagem de programação.
- **SharedPreferences**: Para persistência local de dados.
- **UUID**: Para identificação única de registros.
- **Intl**: Para formatação de datas.
- **Mask Text Input Formatter**: Para formatação de entrada em campos de data.

## Instalação

1. Certifique-se de ter o Flutter instalado: [Instalação do Flutter](https://flutter.dev/docs/get-started/install).
2. Clone o repositório:
   ```
   git clone <url-do-repositorio>
   cd adl_fono
   ```
3. Instale as dependências:
   ```
   flutter pub get
   ```
4. Execute o app:
   ```
   flutter run
   ```

## Uso

- **Tela Principal**: Preencha o formulário e clique em "Salvar" para adicionar um novo registro. Os campos são limpos automaticamente após salvar.
- **Histórico**: Acesse via o menu para visualizar, buscar, editar ou excluir registros.
- **Perfil**: Página simples com informações do usuário (placeholder).

## Estrutura do Projeto

- `lib/main.dart`: Ponto de entrada e navegação.
- `lib/adl.dart`: Tela principal do formulário.
- `lib/history_page.dart`: Tela de histórico.
- `lib/profile_page.dart`: Tela de perfil.
- `lib/models/paciente_ficha.dart`: Modelo de dados e repositório.

## Contribuição

Contribuições são bem-vindas! Abra issues ou pull requests para melhorias.

## Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

