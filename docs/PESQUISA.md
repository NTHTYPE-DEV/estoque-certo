# Pesquisa objetiva e decisão

Consulta em 19/11/2026 aos repositórios e seus READMEs. Esta é uma avaliação de documentação e estrutura visível, não uma auditoria de segurança nem teste de execução dos projetos. Nenhum código desses projetos foi copiado.

| Projeto | Licença declarada | Arquitetura e referência | Decisão |
|---|---|---|---|
| [InvenTree](https://github.com/inventree/InvenTree) | MIT | Python/Django, API REST e frontend React; controle detalhado de materiais. | Completo, mas sua infraestrutura e escopo são maiores do que o necessário para o prazo e a pilha escolhida. |
| [Warehouse Management System](https://github.com/mazeemsharif/Warehouse-Management-System) | MIT, conforme README | React-Admin e Supabase; inclui fornecedores, movimentações, tabelas e autenticação. | Bom para referência de recursos; usa modelo e dependências próprios que exigiriam adaptação e revisão de segurança. |
| [StockPilot](https://github.com/Rustambek-dot/stockpilot-inventory) | MIT | Next.js, TypeScript e Supabase; movimentações em função PostgreSQL atômica. | Reforça a escolha de gravar saldo e histórico juntos; Next.js e seu modelo de múltiplos locais não são necessários no MVP. |
| [Inventory Management](https://github.com/BoviliusMeidi/inventory-management) | MIT, conforme README | Next.js, TypeScript, Supabase; fornecedores e painel administrativo. | Referência de organização, mas demanda adaptação para Vite e para a comparação por unidade. |

## Escolha

Projeto próprio com React, TypeScript e Vite, usando Supabase Auth e PostgreSQL. Não há evidência suficiente de que um fork economize tempo considerando a revisão de permissões, remoção de recursos e implementação da comparação de unidades. O sistema guarda o histórico e atualiza o saldo na mesma transação usando bloqueio da linha. Todas as tabelas têm políticas RLS. O escopo inicial é uma conta isolada por usuário; acesso compartilhado por funcionários exige um modelo de organizações e permissões posterior.
