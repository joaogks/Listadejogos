# Tutorial para a IA: baixar o projeto e continuar a edição

Repositório: [joaogks/Listadejogos](https://github.com/joaogks/Listadejogos).

## 1. O que receber do usuário

O usuário fornecerá **o título do vídeo e o áudio final da narração**. Você deve transcrever a voz com timestamps e identificar console, jogos, ordem dos blocos e cenas necessárias. Não exigir roteiro escrito nem timecodes preparados pelo usuário.

O resultado esperado de uma tarefa de edição completa é uma timeline editável no DaVinci Resolve e um MP4 final. Preserve o conteúdo e a velocidade da voz enviada.

Antes de implementar ou editar, leia nesta ordem:

1. [AGENTS.md](AGENTS.md).
2. [GUIA-PARA-IAS.md](GUIA-PARA-IAS.md), com as regras completas do vídeo e o funcionamento do script.
3. Os scripts em `scripts/`.
4. [Referência da integração com o Resolve](reference/resolve-cartoon/README.md).

## 2. O que este repositório já faz

- Busca gameplays públicas no YouTube por jogo.
- Escolhe candidatos por título/plataforma/longplay e permite trocar a fonte.
- Baixa apenas o intervalo selecionado com yt-dlp e FFmpeg.
- Tenta formatos alternativos HLS quando a primeira seleção falha.
- Gera catálogo com duração, codecs e caminhos locais, além de prévias para curadoria.
- Inclui as fontes e os intervalos já selecionados dos 18 jogos da referência.
- Inclui código do importador anterior do Resolve como base para a continuação.

O plugin específico de lista de jogos, a transcrição automática, a seleção de console/OSTs e a montagem final **ainda precisam ser implementados ou executados pela IA**. O repositório não tem um comando que já faça todas essas etapas sozinho.

Os MP4s, o executável do yt-dlp, os logs e os catálogos com caminhos do computador original não estão versionados. A IA os reconstrói na máquina de destino usando as fontes selecionadas. O título e o áudio do próximo episódio também não vêm no repositório.

## 3. Instalar os requisitos no Windows

O fluxo atual foi desenvolvido em Windows com **PowerShell 7**. As folhas de contato usam System.Drawing; este tutorial não promete funcionamento em Linux/macOS sem adaptação.

| Programa | Finalidade |
|---|---|
| PowerShell 7 (`pwsh`) | Executar os scripts |
| Git | Clonar/atualizar o projeto |
| Node.js LTS (`node`) | Runtime JavaScript usado pelo yt-dlp |
| FFmpeg e ffprobe | Download de intervalos, análise e imagens |

O DaVinci Resolve é necessário na etapa de edição/render. Instale-o pelo [site oficial da Blackmagic Design](https://www.blackmagicdesign.com/products/davinciresolve) quando essa etapa for executada. Python/Pillow são dependências de parte do código histórico de referência, não dos dois scripts PowerShell atuais.

Se os programas estiverem ausentes, instalar com WinGet em um terminal Windows:

```powershell
winget install --id Microsoft.PowerShell --exact --source winget
winget install --id Git.Git --exact --source winget
winget install --id OpenJS.NodeJS.LTS --exact --source winget
winget install --id Gyan.FFmpeg --exact --source winget
```

Fechar e abrir o terminal depois das instalações para atualizar o PATH. Abrir **PowerShell 7**, não Windows PowerShell 5.1. Instalar somente requisitos faltantes; as instalações podem apresentar as confirmações normais do Windows.

Referências: [PowerShell no Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows), [manifestos oficiais WinGet](https://github.com/microsoft/winget-pkgs), [dependências do yt-dlp](https://github.com/yt-dlp/yt-dlp#dependencies).

## 4. Baixar o projeto

Em uma pasta de trabalho escolhida pelo usuário:

```powershell
git clone https://github.com/joaogks/Listadejogos.git
Set-Location -LiteralPath '.\Listadejogos'
```

Também é possível usar **Code > Download ZIP** no GitHub e extrair para uma pasta. Se o Windows marcar os scripts extraídos como bloqueados, usar `Unblock-File` nos arquivos deste repositório após lê-los. Não é necessário mudar permanentemente a política de execução da máquina.

Os scripts descobrem a raiz pela própria localização. A pasta pode ter qualquer nome/caminho; não precisa existir uma unidade `D:` nem uma pasta `LISTA DE JOGOS`.

## 5. Reconstruir a biblioteca de referência

Para reproduzir as seleções já feitas, começar com **Download**, sem rodar Find antes:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\YouTube-Gameplays.ps1 -Action Download
if ($LASTEXITCODE -ne 0) { throw 'Houve falha de download; consulte os logs por jogo em catalog.' }

pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Build-GameplayCatalog.ps1
if ($LASTEXITCODE -ne 0) { throw 'Falha ao gerar o catalogo; confira arquivos e requisitos.' }
```

`-ExecutionPolicy Bypass` vale somente para o processo invocado. O primeiro comando copia `catalog/sources.example.json` para `catalog/sources.json` caso o arquivo local ainda não exista. Depois baixa o yt-dlp oficial se necessário e os intervalos escolhidos para cada jogo.

Na reconstrução completa, esperar:

- MP4s em `gameplays/<slug>/`.
- Um `<slug>.download-status.json` por jogo em `catalog/`.
- `catalog/gameplays.json` com os caminhos deste computador.
- Três folhas de contato em `previews/`, com imagens de 20s, 60s e 100s de cada clipe.

O limite padrão é 720p. Na biblioteca original, Ridge Racer Type 4 foi baixado em uma seleção até 1080p. Para solicitar essa mesma altura máxima na nova máquina:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\YouTube-Gameplays.ps1 -Action Download -Game ridge-racer-type-4 -MaxHeight 1080 -Force
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Build-GameplayCatalog.ps1
```

IDs e intervalos reproduzem a seleção de origem; disponibilidade, formatos e duração exata podem mudar no YouTube. Não prometer arquivos idênticos byte a byte. Se uma fonte deixar de funcionar, buscar alternativa para aquele jogo, registrar a substituição e manter as regras do vídeo.

Não é obrigatório baixar todos os 18 jogos para um episódio diferente. Use `-Game` para baixar apenas slugs necessários já cadastrados. A lista efetiva do episódio vem da voz.

## 6. Encontrar ou trocar uma gameplay

```powershell
# Buscar alternativas; substitui a seleção desse jogo no sources.json local.
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\YouTube-Gameplays.ps1 -Action Find -Game tekken-3 -Candidates 8

# Baixar a nova seleção.
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\YouTube-Gameplays.ps1 -Action Download -Game tekken-3

# Reconstruir o catálogo após a alteração.
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Build-GameplayCatalog.ps1
```

Para alterar somente o intervalo, editar `start` e `duration`, em segundos, na entrada do jogo em `catalog/sources.json`. `start` é o tempo no vídeo completo do YouTube. Os in/out de edição são escolhidos depois no arquivo baixado.

Para acrescentar um jogo do novo áudio:

1. Criar slug e entrada em `catalog/games.json`.
2. Adicionar o padrão de título correspondente em `$titlePatterns` no script de busca.
3. Executar Find apenas para esse slug.
4. Conferir título, jogo, versão e plataforma; ajustar o intervalo se a fonte for curta.
5. Executar Download e reconstruir o catálogo.

Não apagar a biblioteca antiga nem forçar a lista do novo episódio a seguir a ordem de `games.json`. O manifesto de edição controla a ordem da voz.

`Find` não faz análise visual automática. Antes de aprovar um corte, revisar o trecho inteiro. As `reviewNotes` da seleção inicial são observações históricas e não aprovam automaticamente a nova captura.

## 7. Continuar a montagem a partir de título + áudio

1. Medir a voz e transcrevê-la com timestamps. Usar uma ferramenta de transcrição disponível no ambiente; confirmar nomes de jogos ouvindo os pontos ambíguos.
2. Identificar intro, jogos, comparações e encerramento. Determinar o console pelo título e pelo áudio.
3. Reutilizar as fontes existentes e buscar cenas específicas quando a fala exigir.
4. Selecionar e baixar a filmagem do console e OSTs separadas, conforme o guia.
5. Montar a intro: console primeiro; depois jogos reconhecíveis do episódio, com 2–4 segundos por trecho.
6. Cobrir cada bloco da voz com gameplay do jogo atual, lower third correto e OST reduzida. O áudio dos MP4s pode conter efeitos/falas; não tratá-lo como uma trilha isolada.
7. Escrever `edit-plan.json` com tempos em segundos e caminhos locais resolvidos.
8. Preparar a adaptação do importador do Resolve com base em `reference/resolve-cartoon/`, consultando também a documentação de scripting da instalação do amigo.
9. Criar timeline/projeto dedicado, preservar o trabalho já aberto e posicionar vídeo, voz, música e efeitos.
10. Quando a tarefa for a edição completa, conferir e renderizar o MP4 final, entregando também projeto editável, manifesto, transcrição e fontes.

O padrão é conservar a voz original. Se não houver uma intro falada, uma pequena abertura visual pode anteceder a voz; registrar seu deslocamento no manifesto. Não acelerar a narração para acomodar a montagem.

O código histórico de cartoons tem caminhos, slugs e assets específicos daquele projeto. Ele está aqui para estudar e adaptar. **Não executar o instalador antigo como se já fosse o plugin de lista de jogos.** O README da referência explica o que precisa mudar.

## 8. Problemas frequentes

| Problema | Ação |
|---|---|
| `node`, `ffmpeg` ou `ffprobe` não encontrado | Instalar o requisito e reabrir o terminal |
| Script bloqueado após Download ZIP | Ler os arquivos, desbloquear com `Unblock-File`, usar a invocação acima |
| ID/intervalo inválido | Corrigir `sources.json`; início + duração precisa caber na fonte |
| HTTP 403 ou formato indisponível | O script tenta HLS; se falhar, atualizar yt-dlp e selecionar outra fonte pública |
| Fonte incorreta/remake/outro console | Trocar a seleção; score de título não substitui conferência |
| Quer maior altura em arquivo já baixado | Usar `-MaxHeight` junto com `-Force` |
| Novo slug não funciona em Find | Adicionar também o padrão em `$titlePatterns` |
| Catálogo com caminhos antigos | Gerá-lo a partir dos status deste computador |
| Prévia em 100s falha para clipe curto | Adaptar amostragem; o gerador foi feito para trechos de 120s |
| Taxa de frames diferente na mídia | Não usar `durationInFrames30fps` como frames nativos; converter ou preparar cortes uniformes |
| Chamadas do Resolve não existem | Ler a documentação instalada; preparar assets/mixes externamente quando necessário |

## 9. Atualização e contribuição

```powershell
git pull --ff-only
.\tools\yt-dlp.exe -U
```

Preservar alterações locais antes de atualizar. O `.gitignore` mantém mídia, logs, executáveis e caminhos locais fora do Git. Para compartilhar novas fontes curadas, atualizar explicitamente `sources.example.json` com metadados portáveis; não copiar status ou URLs temporárias de download para o repositório.

Não há necessidade de Git LFS: o projeto distribui código e seleções de origem e baixa a mídia localmente.

## 10. Mensagem pronta para enviar à IA do amigo

> Clone ou baixe https://github.com/joaogks/Listadejogos. Leia `TUTORIAL-PARA-IA.md`, `AGENTS.md` e `GUIA-PARA-IAS.md`, depois os scripts. Vou fornecer somente o título do vídeo e o áudio final. Transcreva a voz com tempos, identifique console/jogos e monte o episódio preservando o áudio original. Comece com vídeo do console, depois gameplays reconhecíveis de 2–4s; no corpo, use gameplay do jogo da fala, lower third com seu nome e OST do próprio jogo em volume reduzido. Reaproveite as fontes existentes e baixe do YouTube os assets necessários. Reconstrua catálogos na sua máquina; não use caminhos do computador original. Adapte o método de API/Lua incluído em `reference/resolve-cartoon/` para o plugin desta lista, que ainda precisa ser implementado. Para a edição completa, entregue timeline/projeto editável no Resolve, MP4 final, manifesto, transcrição e fontes, seguindo os defaults do guia para decisões rotineiras.
