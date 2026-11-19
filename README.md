# Estoque Certo

Sistema web do Projeto Integrador do IFSC para acompanhar materiais, reposição e comparação manual de fornecedores. Este pacote é uma primeira implementação; veja o estado de validação em `docs/ESTADO.md`.

## Requisitos

Node.js 20 ou superior, npm e um projeto Supabase. Sem projeto Supabase configurado, o aplicativo mostra uma tela de orientação e não simula dados nem autenticação.

## Preparação do banco

1. Crie ou escolha um projeto Supabase adequado. Não use um banco com dados importantes sem revisar a migração: ela cria tabelas no schema `public`.
2. No painel Supabase, abra **SQL Editor**, crie uma consulta e execute todo o conteúdo de `supabase/migrations/202611190001_inicial.sql` uma única vez.
3. Em **Authentication > Users**, crie um usuário com e-mail e senha. O cadastro público não faz parte do MVP; mantenha desativada a inscrição pública se não quiser que pessoas criem contas.
4. Em **Project Settings > API** (ou Connect), copie a URL do projeto e a chave **publishable** ou **anon**. São chaves públicas próprias para o frontend. Nunca use `service_role` ou chaves secretas no navegador.
5. Copie `.env.example` para `.env` e preencha `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY`.

## Executar localmente

```bash
npm install
npm run dev
```

Abra o endereço local mostrado no terminal. Entre com o usuário criado. Para verificar o projeto:

```bash
npm run test
npm run build
```

## Fluxo

1. Cadastre um material com sua unidade base, como metro, kg ou unidade. Cada especificação diferente deve ter um cadastro próprio.
2. Registre uma entrada para estabelecer o saldo inicial. Toda alteração do saldo ocorre por movimentações, que identificam responsável e data.
3. Cadastre fornecedores e suas cotações manuais. Na cotação, informe a quantidade equivalente na unidade base: por exemplo, uma caixa com 100 unidades deve ser registrada como 100 unidades. Não há conversão automática entre kg e g, metro e cm ou embalagens; converta antes de registrar.
4. Consulte a lista de reposição e compare o preço por unidade. O sistema não inclui frete ou prazo no cálculo.

## Regras

- Abaixo do mínimo significa quantidade **menor** que o mínimo. Mínimo zero desativa alerta. A sugestão completa o mínimo.
- Urgente: saldo igual ou inferior a 25% do mínimo. Outras faltas são sinalizadas como atenção.
- A função SQL valida saldo, bloqueia a linha e registra o histórico na mesma transação. O frontend não pode alterar diretamente o saldo ou criar movimentos por inserção direta.
- Materiais com movimentações ou cotações não podem ser excluídos, e sua unidade não pode ser alterada após histórico ou cotação. Fornecedores com cotações vinculadas não podem ser excluídos. Para remoção, os erros do banco são exibidos.
- Cada usuário acessa apenas seus próprios registros. Contas diferentes não compartilham uma empresa no MVP; colaboração, múltiplos depósitos e permissões por função ainda precisam ser implementados.
- Não há preço ou fornecedor fictício. Para testar, cadastre dados próprios de teste e identifique-os como tais.

## Estrutura

`src/domain.ts`: regras de cálculo e validação. `src/main.tsx`: telas e integração. `src/style.css`: interface responsiva. `supabase/migrations`: banco e segurança. `tests`: testes de regras. `docs/PESQUISA.md`: projetos pesquisados e decisão.

## Próximos passos

Validar a migração e fluxos ponta a ponta em um projeto Supabase autorizado, incluindo concorrência com duas sessões, autenticação e isolamento de usuários; melhorar mensagens dos erros de banco; testar no celular; preparar dados explicitamente fictícios para apresentação; avaliar múltiplas organizações, QR Code, importação e Android posteriormente.
