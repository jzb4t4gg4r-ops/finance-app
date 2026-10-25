# Finanças

App iOS simples e minimalista para registrar receitas e despesas do dia a dia.
SwiftUI + SwiftData, sem dependências externas, sem rede.

## Requisitos

- Xcode 16 ou superior
- iOS 17 ou superior

## Como rodar

1. Abra `FinanceApp.xcodeproj` no Xcode.
2. Em *Signing & Capabilities*, escolha seu *Team* e, se quiser, troque o
   *Bundle Identifier* (`com.example.financeapp`).
3. Rode em um simulador ou iPhone.

O projeto usa pastas sincronizadas (Xcode 16): todo arquivo criado dentro de
`FinanceApp/` entra no target automaticamente.

## Funcionalidades

- Cadastrar, listar, editar e excluir lançamentos (receita ou despesa)
- Navegação por mês com saldo, total de receitas e total de despesas
- Categorias com ícones
- Bloqueio opcional com Face ID / Touch ID / código do aparelho

## Estrutura

```
FinanceApp/
  App/          ponto de entrada e RootView (bloqueio + capa de privacidade)
  Models/       Entry (@Model) e Category
  Persistence/  criação do banco local protegido
  Security/     AppLock (LocalAuthentication)
  Utilities/    formatação/parsing de valores e datas
  Views/        telas
```

## Segurança

| Decisão | Como foi feito |
|---|---|
| Dados só no aparelho | SwiftData local, `cloudKitDatabase: .none`, nenhum código de rede |
| Criptografia em repouso | Diretório do banco com `FileProtectionType.complete`: ilegível enquanto o iPhone está bloqueado |
| Bloqueio do app (opcional) | `LAPolicy.deviceOwnerAuthentication`; ligar/desligar exige autenticação |
| Seletor de apps | Uma capa cobre o conteúdo sempre que o app não está ativo |
| Valores monetários | Inteiros em centavos (sem erro de ponto flutuante), com validação e limite máximo |
| Entrada de texto | Descrição limitada a 80 caracteres e observação a 500 |

Observações:

- **Backup:** o banco entra no backup do iCloud/computador do aparelho (que é
  criptografado). Para excluí-lo do backup, marque o diretório com
  `isExcludedFromBackup`. A desvantagem é perder os dados junto com o aparelho.
- Se o bloqueio estiver ativo e o código do iPhone for removido, o bloqueio é
  desligado automaticamente. Sem código, o iOS também não criptografa os dados.

## Desempenho e bateria

- Nenhum timer, serviço em segundo plano, localização ou rede.
- A consulta filtra por mês no SQLite: só os lançamentos do mês ficam em memória.
- `List` carrega as linhas sob demanda; os totais são calculados em um único laço.
- Gravações explícitas só ao salvar ou excluir.
- Release com otimização `-O` e *whole module*.

## Prévia web

`preview/index.html` é uma prévia web das mesmas telas, para ver o app no
celular sem Xcode. Usa dados de exemplo e salva só no navegador
(`localStorage`, sem criptografia), então use apenas valores de teste.

## PWA (ícone na tela inicial, sem Mac e sem loja)

`pwa/build.py` monta o PWA em `_site/` a partir de `preview/index.html`, com
manifesto, ícones, service worker (funciona offline) e CSP restritiva
(sem script inline, sem conexões externas). O workflow
`.github/workflows/pages.yml` publica no GitHub Pages a cada push.

Para ativar: no GitHub, *Settings › Pages › Source: GitHub Actions*
(Pages gratuito exige repositório público). Depois, no iPhone, abra o
endereço no Safari › Compartilhar › Adicionar à Tela de Início.

Os dados ficam só no aparelho (`localStorage`), sem criptografia própria.
Apps adicionados à Tela de Início não sofrem a limpeza automática de 7 dias
do Safari, mas apagar o ícone apaga os dados.
