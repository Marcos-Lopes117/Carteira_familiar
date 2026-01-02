
# Carteira Familiar
A gestão financeira da sua família em suas mãos

##  Visão Geral

Carteira Familiar é um aplicativo mobile de gestão financeira pessoal e familiar, desenvolvido com foco em organização, controle e privacidade.
O aplicativo foi pensado para ajudar famílias a organizar o orçamento mensal, quitar dívidas, planejar economias e manter o controle financeiro, tudo isso sem depender de internet.

Os dados são armazenados exclusivamente no dispositivo do usuário, garantindo segurança, privacidade e funcionamento offline.

##  Público-Alvo

Famílias que desejam controlar gastos mensais

Pessoas que estão saindo do endividamento

Usuários que buscam planejamento financeiro simples

Qualquer pessoa que queira organizar a vida financeira sem complicação

- Proposta de Valor

- Funciona 100% offline

- Dados locais, sem servidores externos

- Foco em gestão financeira real

- Interface simples, clara e objetiva

- Pensado para uso diário no mobile


##  Arquitetura do Aplicativo

Plataforma: Flutter (Android / iOS)

Banco de dados: Local (SQLite via Drift ou Hive)

Arquitetura: Offline-first, separação de camadas

Estado: Provider ou Riverpod

Design: Material 3


## Funcionalidades Principais
Onboarding Customizado: Configuração inicial do perfil com nome da família, renda mensal base e meta de economia.

Gestão de Transações: Cadastro intuitivo de Entradas e Saídas com seletor de categorias inteligente.

Dashboard Reativo:

Saldo Geral: Atualização instantânea conforme transações são adicionadas ou removidas.

Barra de Metas: Visualização gamificada do progresso em relação à meta de economia mensal.

Gráfico de Pizza Dinâmico: Análise visual de gastos e rendas agrupados por categoria (exibe apenas categorias com movimentações ativas).

Histórico de Atividades: Lista de transações recentes com ícones categorizados e suporte a Swipe-to-Delete (deslizar para excluir).

Configurações de Perfil: Possibilidade de editar nome, renda e metas a qualquer momento através de um modal dedicado.

## Tecnologias Utilizadas
Linguagem: Dart

Framework: Flutter

Gerenciamento de Estado: Riverpod (abordagem reativa com Streams).

Banco de Dados Local: Drift (Moor) - SQLite para persistência de dados performática.

Gráficos: FL Chart.

Arquitetura: Repository Pattern para separação clara de lógica de dados e interface.


# Conclusão

Carteira Familiar não é apenas um projeto de estudo, mas um aplicativo funcional, pensado para resolver um problema real do dia a dia das famílias brasileiras, com foco em simplicidade, eficiência e privacidade.
