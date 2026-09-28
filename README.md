# Lista de jogos — gameplays do YouTube e edição no DaVinci Resolve

**Para a IA do amigo:** comece por [TUTORIAL-PARA-IA.md](TUTORIAL-PARA-IA.md). Ele explica como baixar este repositório, instalar os requisitos, reconstruir as gameplays e continuar a montagem. Há uma mensagem pronta para enviar à IA no final do tutorial.

## Baixar e começar — Windows / PowerShell 7

Requisitos: Git, PowerShell 7, Node.js LTS, FFmpeg e ffprobe no PATH. O tutorial inclui os comandos de instalação. DaVinci Resolve é necessário na etapa de edição.

```powershell
git clone https://github.com/joaogks/Listadejogos.git
Set-Location -LiteralPath '.\Listadejogos'

# Reproduzir as fontes já selecionadas, sem pesquisar tudo novamente.
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\YouTube-Gameplays.ps1 -Action Download

# Criar o catálogo com os caminhos deste computador e as prévias.
pwsh -NoProfile -ExecutionPolicy Bypass -File .\scripts\Build-GameplayCatalog.ps1
```

No primeiro uso, o script cria `catalog/sources.json` a partir de `catalog/sources.example.json`, se necessário, e baixa o yt-dlp oficial quando estiver ausente. A raiz é calculada pela localização do script; a pasta pode estar em qualquer unidade.

O repositório distribui **scripts, instruções, seleções de fontes e código de referência do Resolve**. MP4s, executáveis, logs e catálogos com caminhos locais são reconstruídos na máquina de destino. O plugin específico de lista de jogos ainda precisa ser implementado; o importador anterior está em [reference/resolve-cartoon](reference/resolve-cartoon/README.md) para estudar e adaptar.

## Modelo do vídeo

Para continuar este projeto com outra IA, leia [GUIA-PARA-IAS.md](GUIA-PARA-IAS.md). O guia reúne o modelo do vídeo, as regras de roteiro/edição, o funcionamento dos scripts, os formatos de dados e o método de integração com o Resolve. `AGENTS.md` orienta agentes que abrem esta pasta a consultar esse briefing.

Fluxo de entrada: o usuário fornece **o título e o áudio final**. A IA transcreve a narração, identifica console/jogos e seus tempos, seleciona/baixa as mídias e monta o vídeo. Há um prompt pronto para copiar no final do guia.

Busca videos publicos no YouTube, escolhe candidatos pelo nome do jogo e por palavras como PS1, PSX, longplay e no commentary, e baixa trechos com yt-dlp + FFmpeg. Os arquivos mantem o audio da gameplay e a proporcao da fonte. Nao sao trilhas isoladas: o audio pode incluir musica, efeitos e falas do jogo.

## Biblioteca atual

Na biblioteca original, os 18 jogos da referencia foram baixados: cerca de 2 minutos por jogo, 36 minutos no catalogo principal e 404 MB. Os arquivos principais foram conferidos quanto a video, audio e duracao. Foram inspecionadas imagens em 20s, 60s e 100s de cada clipe; as observacoes historicas em `reviewNotes` registram menus, telas pretas, bordas e marcas presentes nas fontes. Essa amostragem nao substitui a revisao dos cortes finais nem a conferencia dos arquivos reconstruidos na nova maquina.

A fonte de Chrono Cross informa uma reivindicacao sobre a musica na propria descricao; essa observacao esta em `sourceNotes`. A selecao compartilhada aponta para o intervalo com combate.

## Arquivos

- `catalog/games.json`: os 18 jogos da referencia, consultas de busca e tempos sugeridos.
- `catalog/sources.example.json`: selecoes portaveis compartilhadas pelo Git, usadas para inicializar a configuracao local.
- `catalog/sources.json`: fontes selecionadas. Edite `id`, `start` e `duration` para mudar um video ou intervalo; os tempos sao em segundos.
- `catalog/*.candidates.json`: alternativas encontradas pela busca.
- `catalog/*.info.json`: metadados da fonte obtidos pelo yt-dlp.
- `catalog/*.download-status.json`: resultado do download de cada jogo, incluindo arquivo, canal e URL.
- `catalog/gameplays.json`: indice de arquivos conferidos com ffprobe, preparado para ser consumido pelo gerador da timeline.
- `gameplays/<jogo>/`: MP4 de cada jogo.
- `previews/`: imagens extraidas e folhas de contato para revisar a selecao.
- `reference/resolve-cartoon/`: codigo do fluxo anterior e explicacao do que precisa ser adaptado.

Os dados gerados, midias, logs e `sources.json` local ficam fora do Git. Guarde a ordem e as decisoes de montagem num manifesto separado, como `edit-plan.json`.

## Uso no PowerShell

```powershell
# Descobrir fontes. Pode substituir as escolhas atuais do catalogo.
.\scripts\YouTube-Gameplays.ps1 -Action Find

# Baixar as fontes selecionadas; retoma ignorando resultados ja concluidos.
.\scripts\YouTube-Gameplays.ps1 -Action Download

# Baixar apenas um jogo, com limite de resolucao opcional.
.\scripts\YouTube-Gameplays.ps1 -Action Download -Game 'tekken-3' -MaxHeight 1080 -Force

# Conferir video, audio e duracao, e gerar catalogo e folhas de contato.
.\scripts\Build-GameplayCatalog.ps1
```

Requisitos: PowerShell 7, Node.js, FFmpeg e ffprobe no PATH. O yt-dlp oficial fica em `tools/yt-dlp.exe`; o script baixa a versao oficial caso esse arquivo esteja ausente. Instale os requisitos no computador de destino conforme o tutorial. O limite padrao e 720p, sem ampliar fontes menores. Para atualizar o downloader: `.\tools\yt-dlp.exe -U`.

O download usa trechos de dois minutos para iniciar a biblioteca, preservando H.264 e AAC quando disponiveis. Se o formato direto falhar, tenta a alternativa HLS que a fonte publica oferece. Nao usa cookies, contas, proxies ou formatos com DRM. Os cortes podem incluir folga de keyframe, registrada pela duracao medida no catalogo.

Os horarios iniciais sao pontos de partida para curadoria. As folhas de contato ajudam a detectar menus, loading, dialogos e cenas que devem ser substituidas. A origem dos arquivos permanece registrada; o download nao comprova permissao de republicacao.

## Uso na edicao

O gerador da timeline pode ler `catalog/gameplays.json`, relacionar `slug` ao bloco da narracao e recortar o arquivo `src`. Para a intro, escolher trechos de 2-4 segundos; para o corpo, escolher as cenas adequadas a cada fala. O lower third e a faixa de narracao entram acima da gameplay. O audio da fonte fica separado para ajustar volume e fades no Resolve.

Documentacao do downloader: https://github.com/yt-dlp/yt-dlp
