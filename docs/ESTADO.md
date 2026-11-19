# Estado da implementação — 19/11/2026

## Implementado

- Login e saída com Supabase Auth, controle de sessão e telas protegidas na aplicação.
- Painel, materiais com cadastro e edição, fornecedores com cadastro e edição, movimentações, reposição, cadastro e comparação de cotações.
- Migração SQL com políticas por conta, bloqueio de alterações diretas no saldo, função de movimentação atômica, integridade referencial e proteção contra mudança de unidade depois de histórico ou cotação.
- Histórico e responsáveis, prioridade explicada e comparação por unidade base.

## Testes executados

- `npm run build`: concluído. O empacotador avisou que o arquivo JavaScript é maior que 500 kB; é uma oportunidade futura de otimização, não um erro de compilação.
- `npm run test`: 13 testes passaram. Seis verificam as regras de domínio; sete executam a migração em PostgreSQL local PGlite e verificam saldo, histórico, negação de saída excessiva, permissões, isolamento de usuário e unidade.
- A tela de orientação sem configuração foi aberta no navegador local.

## Pendente de validação

- Nenhum projeto Supabase real foi conectado. Portanto o login, navegação autenticada, formulários, API, políticas no serviço e experiência em celular ainda não foram testados de ponta a ponta.
- O bloqueio com `FOR UPDATE` foi implementado para concorrência, mas o teste simultâneo com duas conexões reais ainda não foi executado.
- Contas são isoladas; usuários diferentes não compartilham estoques. Empresas com equipe precisarão de organizações e perfis.
- O MVP não faz conversões automáticas de unidades, atualização de preços, fretes, edição de cotações, depósitos, QR Code, exportação ou versão Android.
- Antes de 09/12: conectar ambiente de testes autorizado, verificar o fluxo completo e concorrência, corrigir resultados, testar celular e preparar demonstração. De 10/12 a 14/12: treinar apresentação.
