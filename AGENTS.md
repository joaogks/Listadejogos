# Orientação para agentes neste projeto

Leia `GUIA-PARA-IAS.md` antes de trabalhar no roteiro, nas mídias ou na montagem. Ele contém o briefing do usuário, o funcionamento real dos scripts, o estado da biblioteca e as regras de integração com o DaVinci Resolve.

Para instalar e continuar em outro computador, siga `TUTORIAL-PARA-IA.md`. A raiz é a pasta clonada; não dependa dos caminhos D: da máquina original. O repositório distribui código, documentação e seleções portáveis, e a mídia é baixada localmente.

## Entradas do usuário

O usuário enviará somente o título do vídeo e o áudio final da narração. Transcreva a voz com timestamps e derive console, jogos, ordem e limites dos blocos. Não exija um roteiro escrito nem uma lista/timecodes preparados pelo usuário. Preserve a voz original; não a reescreva, substitua ou acelere. O episódio segue os jogos do áudio, não uma lista fixa dos 18 jogos da biblioteca inicial.

## Regras do vídeo

- Intro: primeiro uma filmagem do console; depois gameplays de jogos reconhecíveis presentes na lista, com 2–4 segundos por trecho.
- Corpo: gameplay do jogo atual na narração, lower third com o nome correto e trilha sonora dos próprios jogos em volume reduzido.
- Entre blocos de jogos: interrompa voz, OST e áudio da gameplay, mostre uma cartela com o nome do próximo jogo durante uma mini pausa e toque um efeito sonoro curto. Depois retome voz/gameplay/lower third/OST. Default: 1s de pausa, aproveitando silêncio existente quando suficiente.
- Divida a voz apenas entre frases, preservando palavras e velocidade. Registre segmentos e tempo adicional das pausas no manifesto e recalcule os tempos posteriores; não basta um deslocamento global.
- OST, áudio da gameplay e narração são elementos diferentes. O MP4 baixado não contém necessariamente uma OST isolada.
- Preserve a proporção das imagens. Escolha cenas que ilustrem a fala e evite menus/loading como preenchimento.

## Código e dados existentes

- `scripts/YouTube-Gameplays.ps1`: busca e download de trechos públicos do YouTube. O usuário já solicitou esse fluxo.
- `scripts/Build-GameplayCatalog.ps1`: catálogo e prévias dos arquivos locais.
- `catalog/gameplays.json`: biblioteca a reaproveitar. Guarde decisões de montagem em um manifesto separado, pois esse catálogo é regenerado.
- `catalog/sources.example.json`: seleções portáveis. O downloader cria `sources.json` local a partir delas quando necessário; comece com Download para reproduzir a seleção sem refazer Find.
- `Find` pode substituir seleções existentes em `sources.json`; use-o somente quando precisar de novas fontes.
- Adicionar um jogo à busca exige atualizar `games.json` e `$titlePatterns` no script.
- Os tempos da fonte no YouTube, do clipe local e da timeline são distintos. Não trate `durationInFrames30fps` como frames nativos de todas as mídias.
- A marcação `visuallyReviewed` atual se refere a três imagens por clipe, não à revisão integral dos cortes.

## Montagem

A biblioteca inicial está pronta; o plugin específico, o console e as OSTs separadas ainda não foram produzidos nesta etapa. A voz final será enviada pelo usuário. Consulte o guia para o estado detalhado e não apresente planejamento como implementação concluída.

Reaproveite o método de API/Lua incluído em `reference/resolve-cartoon/`, lendo seu README e o código. A pasta original de cartoons não é necessária. Implemente a adaptação neste projeto, preservando as cópias históricas. Consulte a documentação instalada do Resolve para métodos novos. Não carregue para este modelo o jazz ou os cartões de episódios dos cartoons.

Execute somente o trabalho pedido na tarefa atual. A documentação não é uma ordem para baixar novamente toda a biblioteca, modificar outros projetos, testar ou renderizar automaticamente.
