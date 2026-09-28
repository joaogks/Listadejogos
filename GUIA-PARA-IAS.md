# Guia para IAs: vídeo de lista de jogos com gameplay e montagem no DaVinci Resolve

## Usar este guia em outro computador

Clone ou baixe [joaogks/Listadejogos](https://github.com/joaogks/Listadejogos) e siga [TUTORIAL-PARA-IA.md](TUTORIAL-PARA-IA.md). A raiz de trabalho é a pasta clonada, em qualquer unidade. Os caminhos `D:\...` mencionados como histórico pertencem à máquina original e não são requisitos para a continuação.

Os vídeos e os catálogos com caminhos absolutos devem ser reconstruídos localmente. `catalog/sources.example.json` contém as seleções portáveis e inicializa `sources.json` no primeiro uso do downloader. O código do método anterior do Resolve foi incluído em [reference/resolve-cartoon](reference/resolve-cartoon/README.md), evitando dependência da pasta original de cartoons.

## 1. Objetivo e referência

Este documento é o briefing completo para outra IA continuar o trabalho sem depender do histórico do chat. A tarefa é produzir vídeos narrados sobre jogos, com gameplay correspondente à fala, nome do jogo em lower third, abertura com o console e uma sequência curta dos jogos mais reconhecíveis, além de música dos próprios jogos em volume reduzido. A montagem deve ser automatizada no DaVinci Resolve, seguindo o método de importação por script já usado no projeto Black and White Cartoon.

### Entrada do usuário: somente título e áudio final

O usuário enviará **o título do vídeo e o arquivo de áudio da narração**. A IA deve executar a edição a partir desses dois elementos e deste briefing. Não exigir um roteiro escrito, uma lista de jogos, timecodes, músicas escolhidas ou uma seleção manual de gameplays como condição para começar.

- **Título:** informa o tema, o console quando citado e a proposta editorial. Também serve para nomear projeto e entrega.
- **Áudio:** é a fonte principal do conteúdo, da ordem dos jogos, dos limites dos blocos e da duração do vídeo.
- **Este guia:** define o estilo de montagem e o funcionamento da biblioteca.

A IA precisa ouvir/transcrever o áudio com marcação de tempo, identificar os nomes dos jogos e gerar o plano de edição. Não escrever outra narração, não sintetizar uma voz substituta e não alterar as palavras, a ordem ou a velocidade do áudio recebido. Pode aplicar ajustes de ganho/mixagem e dividir a voz entre frases para inserir as pausas de transição solicitadas pelo usuário, preservando todo o conteúdo falado.

O vídeo novo **não precisa conter os 18 jogos da referência**. Essa lista é a biblioteca inicial disponível. A seleção e a ordem do novo episódio vêm da narração enviada; reaproveitar arquivos compatíveis e buscar os demais jogos conforme necessário.

Se título e áudio divergirem, seguir o áudio para as cenas e registrar a divergência, sem inventar blocos para alcançar um número prometido no título. Pedir esclarecimento apenas quando uma informação essencial continuar ambígua após ouvir a fala e verificar o contexto; por exemplo, duas versões diferentes de um jogo indistinguíveis na narração. Continuar as partes independentes enquanto isso.

Referência fornecida pelo usuário: [vídeo no YouTube](https://youtu.be/fS3K4sByX9A), identificado anteriormente como **“18 Jogos de PS1 Que Ainda Impressionam Mais de 25 Anos Depois”**, do canal Jogos Renkai. Os metadados recuperados indicaram duração de aproximadamente 19min41s e primeiro jogo em 0:17.

As características visuais obrigatórias abaixo vêm da descrição do usuário e da análise estrutural feita no chat. A reprodução integral e a transcrição do vídeo não ficaram disponíveis naquela análise. Portanto, fonte tipográfica, cores, animação exata do lower third, tempos individuais dos cortes e nível sonoro exato não foram medidos. Os valores sugeridos neste guia são escolhas de implementação; não os apresente como medições da referência.

### Regras obrigatórias definidas pelo usuário

1. Durante cada bloco, mostrar gameplay do jogo sobre o qual o narrador está falando naquele momento.
2. Colocar um lower third com o nome desse jogo.
3. Começar a introdução com um vídeo mostrando o console abordado.
4. Depois do console, mostrar vários trechos de gameplay de jogos que aparecerão no vídeo, priorizando os mais famosos/reconhecíveis.
5. Cada trecho de gameplay dessa montagem da introdução deve durar **entre 2 e 4 segundos**.
6. Usar trilhas sonoras dos próprios jogos em volume reduzido, mantendo a narração clara.
7. Encontrar e baixar as gameplays **do próprio YouTube**. O usuário já solicitou expressamente esse fluxo; não substitua a tarefa por uma sugestão genérica de gravar todas as gameplays novamente.
8. Montar o vídeo automaticamente por um script/plugin do DaVinci Resolve, aproveitando o método do projeto anterior.
9. **Entre os blocos narrados de um jogo e outro, interromper o áudio e fazer uma mini pausa com uma cartela na tela mostrando o nome do próximo jogo.** Depois retomar a narração e a gameplay desse jogo.
10. **Colocar um efeito sonoro na transição entre jogos.** Durante a cartela, o efeito toca sozinho, sem voz, OST ou áudio da gameplay.
11. **No corpo, usar uma seleção de gameplay com cortes de cerca de 5 segundos, mostrando partes diferentes do mesmo jogo durante seu bloco.** Variar situações, fases, cenários, personagens ou ações conforme o gênero e a fala. Não deixar apenas uma sequência contínua cobrindo o comentário inteiro.

Essas regras têm prioridade sobre os parâmetros sugeridos ao longo deste documento. O intervalo de 2–4 segundos é uma regra da **montagem da intro**, não uma obrigação para todos os cortes do corpo do vídeo.

As regras 9, 10 e 11 foram acrescentadas expressamente pelo usuário após a análise da referência. Elas são requisitos deste modelo, não uma afirmação de que esses tempos/transições foram medidos no vídeo original. A intro mantém cortes de 2–4s; o corpo passa a usar aproximadamente 5s por corte.

### Estado do trabalho em 28/09/2026

| Parte | Estado real |
|---|---|
| Busca de gameplay no YouTube | Implementada em PowerShell com yt-dlp |
| Download de intervalos de gameplay | Implementado, incluindo tentativa alternativa por HLS |
| Biblioteca inicial na máquina original | 18 jogos, aproximadamente 2 minutos por jogo; 36 minutos e 404 MB no catálogo principal; mídia reconstruída localmente a partir das fontes versionadas |
| Conferência dos arquivos | Vídeo, áudio e duração conferidos com ffprobe |
| Prévias | Três imagens por clipe, em 20s, 60s e 100s; três folhas de contato |
| Curadoria visual | Amostragem de imagens; não houve revisão integral dos 18 clipes |
| Vídeo do console | Ainda precisa ser selecionado e baixado |
| OSTs separadas | Ainda precisam ser selecionadas e baixadas |
| Título e voz final do novo episódio | Serão enviados pelo usuário; a IA deriva transcrição, jogos e tempos |
| Plugin específico para esta lista | Ainda não implementado neste projeto |
| Vídeo final editado/renderizado | Ainda não produzido |

Não descreva componentes planejados como se já existissem. O código atual busca, baixa e cataloga gameplays; ele ainda não escreve roteiro, gera voz, escolhe todos os cortes nem monta a timeline.

## 2. Modelo editorial e roteiro

### Estrutura geral

```text
Narração da introdução
  → vídeo do console
  → montagem de gameplays famosas, 2–4s por trecho
  → entrada no primeiro jogo

Bloco do jogo 1
  → seleção de partes diferentes do jogo 1, ~5s por corte + lower third + OST
Transição para o jogo 2
  → parar voz, OST e áudio da gameplay
  → mini pausa + cartela com o nome do jogo 2 + efeito sonoro
Bloco do jogo 2
  → retomar voz + seleção de partes do jogo 2, ~5s por corte + lower third + OST
...
Encerramento curto
  → gameplay de jogo(s) já apresentados, com identificação coerente
```

A narração enviada conduz o tempo do vídeo. A seleção de imagens deve acompanhar o assunto da fala, e a música deve ficar abaixo da voz. A biblioteca de dois minutos por jogo é matéria-prima: o vídeo final utiliza partes dela conforme a duração real dos blocos. As orientações de escrita abaixo ajudam a compreender a estrutura; não são uma autorização para reescrever o áudio final do usuário.

### Introdução

A intro deve apresentar o console, a proposta da lista e o motivo para assistir. Para um tema como o da referência, a linha editorial pode combinar nostalgia com aspectos dos jogos que ainda chamam atenção. Esse é um modelo de escrita sugerido, não uma transcrição do vídeo original.

Enquanto o narrador apresenta o console, mostrar uma filmagem real dele. Quando a fala promete ou antecipa os jogos, iniciar a montagem com os títulos mais reconhecíveis que realmente estão na lista. Evitar abertura demorada com menus, logos de canais de terceiros ou tela de carregamento.

Exemplo de distribuição para uma intro de 17 segundos:

| Tempo na timeline | Imagem | Duração |
|---|---|---:|
| 0–5s | Filmagem do PlayStation original | 5s |
| 5–8s | Tekken 3, luta identificável | 3s |
| 8–11s | Crash Bandicoot 3: Warped, ação | 3s |
| 11–14s | Metal Gear Solid, gameplay | 3s |
| 14–17s | Resident Evil 3: Nemesis, gameplay | 3s |

Esse é um exemplo de montagem, não a ordem comprovada da intro da referência. Ajuste o tempo do console e a quantidade de trechos à voz real, mantendo cada gameplay da intro entre 2 e 4 segundos. Não acelere a voz para fazê-la caber nesse exemplo.

A seleção de títulos conhecidos deve ser uma decisão editorial explícita. A busca atual não mede popularidade. Se o usuário definir os títulos da intro, use essa seleção. Para outra lista, escolha somente jogos presentes nela.

### Blocos dos jogos

Modelo sugerido para escrever cada bloco:

1. Apresentar o nome do jogo e a ideia central do comentário.
2. Explicar o que chama atenção: visual, animação, ambientação, mecânica, combate, exploração, som ou impacto na época.
3. Dar um ou dois exemplos concretos que possam ser ilustrados com gameplay.
4. Relacionar esses exemplos ao tema da lista.
5. Fazer uma passagem breve para o jogo seguinte.

Não inventar fatos de lançamento, vendas, tecnologia, notas ou bastidores. Verificar fatos específicos antes de incluí-los no roteiro. Não fabricar uma transcrição ou atribuir frases ao narrador da referência.

No corpo, o ritmo dos cortes acompanha as ideias da fala com duração-alvo de **5 segundos por plano**. Usar uma seleção de momentos distintos do jogo, em vez de manter uma única gameplay contínua durante todo o bloco. Ajustes pequenos, normalmente entre 4 e 6s, podem preservar uma ação ou acompanhar uma frase; o resultado deve continuar próximo de 5s por corte. A duração do áudio não muda para encaixar essa cadência.

### Sincronização da voz

O áudio final é uma entrada obrigatória deste fluxo. Transcrevê-lo e marcar os limites dos blocos com base no que realmente é ouvido, sem estimar o tempo somente pela quantidade de palavras. Ferramentas de transcrição/alinhamento podem fornecer um primeiro resultado, mas nomes de jogos e pontos de mudança exigem conferência no áudio.

Procedimento:

1. Medir a duração do arquivo de voz e registrar seu caminho absoluto.
2. Transcrever a fala com timestamps por frase ou trecho. Corrigir a grafia dos títulos na transcrição/identificação, preservando a voz original.
3. Identificar intro, blocos de jogos, passagens e encerramento.
4. Criar uma lista ordenada de jogos realmente abordados. Separar os títulos do assunto principal de menções breves usadas em comparações.
5. Determinar início e fim de cada bloco na voz, anotando trechos que pedem uma cena específica.
6. Selecionar imagens que preencham esses intervalos, com música e lower thirds correspondentes.

Identificar o console pelo título e pela narração. Conferir a plataforma quando um jogo tiver versões diferentes. Se a voz usar abreviações ou traduções, mapear para o nome correto e para um `slug` consistente.

Cada bloco precisa de `gameSlug`, `timelineStartSeconds` e `timelineEndSeconds`. A simples ocorrência do nome de outro jogo numa comparação não muda automaticamente a gameplay. O contexto do bloco define o jogo atual; uma comparação visual com outro título deve ser uma escolha anotada e identificada.

Normalmente a narração entra em 0s e a intro visual cabe na introdução já presente no áudio. Se o arquivo começar diretamente no primeiro jogo e não houver tempo para console + vários trechos de 2–4s, preparar uma abertura visual curta antes da voz e registrar esse deslocamento. Isso posiciona o áudio mais tarde na timeline, sem cortar, acelerar ou modificar sua fala. Não cobrir o primeiro bloco inteiro com imagens aleatórias da intro.

Quando houver deslocamento inicial de voz, guardar `narration.timelineStartSeconds`. As mini pausas entre jogos também podem acrescentar tempo: manter a transcrição nos tempos do áudio original e um mapa dos segmentos de voz na timeline. Não aplicar apenas um deslocamento global depois que houver pausas inseridas.

Após cada pausa, os elementos seguintes precisam ser deslocados pelo tempo **adicional** acumulado. Se uma cartela reutilizar um silêncio já existente no áudio, contar somente a extensão desse silêncio. Guardar `sourceBoundarySeconds`, `durationSeconds` e `insertedPauseSeconds` em cada transição. Para eventos de fala após a transição:

```text
timelineTime = sourceAudioTime + narration.timelineStartSeconds
               + soma(insertedPauseSeconds das transições anteriores)
```

Durante as cartelas não há fala. Representar a voz por segmentos com `sourceInSeconds`, `durationSeconds` e `timelineStartSeconds`, separados por esses intervalos. A duração final considera deslocamento inicial, duração original, extensões das pausas e eventual cauda curta de encerramento.

Se a fala exigir uma cena ausente na biblioteca — um chefe, uma mecânica ou uma fase específica — buscar e baixar esse material adicional. Não preencher a fala com gameplay de outro jogo nem repetir uma sequência inteira só para ocupar tempo.

## 3. Regras de imagem, lower third e música

### Escolha de gameplay

- Confirmar jogo, versão e plataforma. Para esta lista, procurar a versão de PS1; um remake de PC/PS4 não representa automaticamente o jogo original.
- Preferir longplays ou walkthroughs sem comentários de outro narrador.
- Escolher momentos com ação legível e identidade visual clara do jogo.
- Durante cada bloco, alternar trechos de aproximadamente 5s de situações diferentes do mesmo jogo; trechos consecutivos de uma única situação não garantem variedade.
- Combinar cena e fala: corrida para condução, luta para combate, exploração para cenários, cena narrativa quando a fala trata de história.
- Evitar menus, pausa, loading, tela preta, créditos e falas longas de NPC quando esses elementos não forem o assunto.
- Inspecionar o intervalo inteiro do corte escolhido. Uma imagem boa em 60s não aprova automaticamente os 5 segundos seguintes.
- Preservar a proporção original. Não esticar 4:3 para 16:9. Um enquadramento com barras é preferível à distorção; qualquer crop deve preservar HUD e informação importante.
- Fontes com molduras, marcas de canal ou grandes bordas devem ser registradas e, se possível, substituídas por alternativas mais limpas.
- Não ampliar uma fonte de baixa resolução e anunciá-la como captura nativa em alta definição.

Detecção automática de preto, pouca movimentação ou mudança de cena pode ajudar a encontrar candidatos ruins, mas não é decisão editorial suficiente. Alien Resurrection e Alone in the Dark, por exemplo, têm cenários escuros legítimos.

### Seleção de partes diferentes: cortes de aproximadamente 5s

A meta é mostrar um panorama visual do jogo durante a fala. Escolher cenas distribuídas por momentos diferentes de um longplay, ou por fontes compatíveis, em vez de simplesmente picotar cinco segundos após cinco segundos da mesma captura contínua.

Exemplos de variedade, sempre subordinados ao conteúdo da narração:

| Tipo de jogo | Situações que podem alternar |
|---|---|
| Luta | Personagens, adversários, arenas, golpes e confrontos diferentes |
| Corrida | Pistas, carros, curvas, ultrapassagens e pontos de vista diferentes |
| Plataforma | Fases, obstáculos, habilidades, inimigos e chefes |
| RPG | Exploração, cenários, combate, habilidades e personagens |
| Terror/ação | Ambientes, exploração, inimigos, combate e situações de tensão |

Procedimento para cada bloco:

1. Calcular a duração da fala correspondente e planejar aproximadamente um corte a cada 5s. Um bloco de 60s usa cerca de 12 cortes; um de 45s, cerca de 9.
2. Selecionar momentos de mais de uma situação/fase/ambiente. Para blocos mais longos, buscar pelo menos três situações distintas quando houver material adequado; isso é um critério de curadoria, não uma ordem para inventar cenas.
3. Priorizar as situações citadas pela voz. Alternar as demais para variar a imagem, mantendo sempre o jogo e a versão corretos.
4. Rever os cortes completos e descartar intervalos com menus/loading ou interrupções inadequadas.
5. Posicionar os cortes sem gaps até o fim do bloco. Se a duração não for múltipla de 5, ajustar o último corte ou distribuir o ajuste entre os últimos planos para evitar um flash muito curto. Um bloco inteiro menor que 5s usa somente sua duração real.
6. Manter voz e OST contínuas durante os cortes do **mesmo jogo**. Não reaplicar a pausa, cartela ou efeito sonoro de mudança de jogo a cada corte de 5s; não reiniciar o lower third em todos os planos.

O banco inicial contém apenas um intervalo principal de aproximadamente dois minutos por jogo. Ele pode não ter a variedade necessária. Nesse caso, selecionar outros intervalos do mesmo longplay ou fontes compatíveis e baixar esse material adicional. Os clipes de 120s são matéria-prima; o corte usado na timeline normalmente terá cerca de 5s.

O downloader atual aceita **uma seleção ativa por slug** em `sources.json`, e o catálogo principal guarda o último status desse jogo. Para obter vários intervalos com ele, alterar a seleção/início e baixar sequencialmente, preservando os MP4s anteriores. O nome do arquivo inclui ID e início; usar inícios/IDs distintos evita sobrescrever os intervalos anteriores. Registrar cada arquivo e sua origem no manifesto enquanto a seleção estiver ativa.

Não presumir que `gameplays.json` já enumera todos os arquivos extras: ele é reconstruído a partir do último status por jogo. Na montagem futura, cada item de `gameplayCuts` pode indicar `src` explicitamente para um arquivo extra; quando omitido, usar o `src` principal do catálogo para o `gameSlug` do bloco. Guardar as origens dos extras em um inventário de assets separado, com jogo, URL, início solicitado e caminho local.

Essa seleção automática/curadoria de múltiplos trechos ainda precisa ser executada pela IA ou implementada no gerador da timeline. Os dois scripts atuais não reconhecem sozinhos fases, bosses ou diversidade de cenas.

### Lower third

Função: identificar o jogo em exibição. O texto principal é o nome completo e correto do jogo; usar o campo `game` do catálogo, relacionado pelo `slug` do bloco.

Implementação sugerida quando não houver uma arte fornecida:

- Posição no terço inferior, com margem de segurança e sem cobrir o HUD essencial.
- Tipografia legível, texto claro e fundo/faixa discreta que dê contraste.
- Mesmo padrão visual e mesma escala de texto ao longo do vídeo.
- Aparecer no início do bloco de cada jogo. Duração inicial sugerida: **4 segundos**, limitada à duração do bloco.
- Entrada e saída suaves, com aproximadamente 0,2s cada, se a implementação permitir.
- Reapresentar a identificação ao voltar ao jogo após uma comparação longa, quando necessário para clareza.

Posição precisa, fonte, cor e persistência do lower third não foram especificadas nem medidas na referência. Os números acima são defaults de implementação. Não acrescentar dados técnicos, pontuações, ano ou texto extenso sem necessidade editorial.

### Trilha sonora

Usar música dos próprios jogos. A escolha preferencial é uma OST separada, do jogo do bloco atual, para controlar música e efeitos de forma independente.

O áudio dos MP4s baixados é o áudio original da gameplay: pode conter música, efeitos e falas. Reduzir seu volume **não isola a música**. Não chamar esse áudio de OST limpa. Se não existir uma trilha separada, esse uso temporário deve ficar indicado no plano de edição.

Regras de mixagem:

1. Narração sempre inteligível e prioritária.
2. OST em faixa separada, com volume reduzido durante a voz.
3. Áudio da gameplay em outra faixa, inicialmente silenciado; habilitar efeitos apenas em momentos úteis e com nível adequado.
4. A OST pode continuar por vários cortes de gameplay do mesmo jogo. Não reiniciá-la a cada corte de imagem.
5. Ao encerrar um jogo, finalizar sua música antes da cartela. Durante a mini pausa, somente o efeito de transição fica audível. Iniciar a OST seguinte junto da nova gameplay, com fade breve.
6. Não fazer crossfade de OSTs atravessando a cartela nem deixar música ou efeitos da gameplay vazando durante essa pausa.
7. Ouvir a mixagem; nenhuma redução fixa em dB garante o resultado para todas as gravações.

Como ponto de partida, aplicar ganho de **−24 dB à OST** e fades de **0,5s**, depois ajustar à voz e ao nível da gravação. São sugestões, não níveis medidos na referência. Ducking pode ser usado se a automação já o oferecer. Não introduzir jazz do projeto de cartoons neste modelo.

Na intro, escolher uma música de um dos jogos apresentados e manter continuidade durante a montagem. No corpo, acompanhar o jogo atual. A trilha não precisa mudar a cada trecho de 2–4 segundos da abertura.

### Transição entre jogos: cartela, pausa e efeito sonoro

Esta transição é obrigatória na passagem de **um bloco narrado de jogo para o seguinte**. Ela é diferente do lower third: a cartela apresenta o próximo jogo durante a pausa; o lower third identifica a gameplay quando a fala recomeça.

Sequência exata:

1. Terminar a frase do jogo anterior, sem cortar palavras ou respirações necessárias à compreensão.
2. Dividir a narração nesse limite e parar a voz. Encerrar também OST e áudio da gameplay anterior; usar fades curtos para evitar estalos, sem apagar sílabas.
3. Mostrar uma cartela ocupando a tela com o **nome do próximo jogo**, centralizado e legível.
4. Tocar um efeito sonoro curto na entrada da cartela, por exemplo um whoosh discreto ou um impacto suave. Usar um padrão consistente e evitar efeitos estridentes.
5. Manter uma mini pausa sem fala, com somente esse efeito sonoro. Não é necessário preencher toda a pausa com som.
6. Encerrar a cartela e retomar a voz na apresentação do próximo jogo, junto de sua gameplay, lower third e OST em volume reduzido.

Defaults de implementação quando o usuário não definir outros valores:

| Elemento | Padrão sugerido |
|---|---|
| Cartela/mini pausa | 1 segundo; até 1,5s se o nome longo precisar de mais leitura |
| Visual | Fundo escuro opaco, nome do próximo jogo em texto claro e grande; quebrar em duas linhas se necessário |
| Efeito sonoro | 0,2–0,5s, iniciado na entrada da cartela e encerrado antes da voz seguinte |
| Ganho inicial do efeito | −12 dB, ajustado à gravação para evitar um salto de volume |
| Microfades de voz | Apenas o suficiente para evitar estalos em limites sem fala; não truncar fonemas |

Os valores são defaults; a exigência do usuário é pausa curta + título do próximo jogo + efeito sonoro. Se já houver silêncio suficiente entre as frases no áudio original, aproveitar esse intervalo. Se faltar tempo, ampliar a pausa deslocando os segmentos seguintes. Não silenciar uma palavra para criar a pausa nem adicionar um segundo extra desnecessário a um silêncio que já comporta a cartela.

Exemplo sem silêncio prévio: o jogo A termina em 47s do áudio; inserir uma cartela entre 47s e 48s da timeline. A voz do jogo B, que começava em 47s da fonte, passa a começar em 48s. As mudanças seguintes acumulam os deslocamentos. Para 18 jogos com 17 pausas adicionais de 1s, o vídeo ganha 17s; se algumas usarem silêncios existentes, o acréscimo é menor.

Essa pausa aplica-se às mudanças dos blocos principais, não a cada corte de câmera dentro do mesmo jogo. Na montagem rápida da intro, manter os trechos de 2–4s e a voz contínua; efeitos de passagem podem ser discretos, sem inserir uma cartela entre cada teaser.

Guardar o efeito em `assets/sfx/` e a cartela em `assets/titles/` quando preparados, com caminho, duração e origem no manifesto. Essas mídias ainda precisam ser selecionadas/geradas; os scripts de gameplay não as criam automaticamente.

## 4. Arquivos existentes e suas responsabilidades

Raiz deste projeto: a pasta clonada/extraída. Na máquina original ela era `D:\LISTA DE JOGOS`; os scripts calculam a raiz pela sua própria localização.

| Caminho relativo | Conteúdo e uso |
|---|---|
| `scripts/YouTube-Gameplays.ps1` | Busca candidatos e baixa intervalos selecionados |
| `scripts/Build-GameplayCatalog.ps1` | Confere arquivos e gera catálogo/prévias |
| `tools/yt-dlp.exe` | Downloader portátil oficial |
| `catalog/games.json` | Lista de jogos, slug, consulta, início e duração sugeridos |
| `catalog/sources.example.json` | Seleções portáveis versionadas; copiadas para sources.json no primeiro uso, se ele estiver ausente |
| `catalog/sources.json` | Fontes escolhidas e intervalos solicitados |
| `catalog/<slug>.candidates.json` | Resultados da busca daquele jogo |
| `catalog/<slug>.info.json` | Metadados completos consultados para o download |
| `catalog/<slug>.download-status.json` | Último resultado de download de cada jogo |
| `catalog/<slug>.find.log` | Log da busca |
| `catalog/<slug>.download.log` | Log do download/tentativa mais recente |
| `catalog/gameplays.json` | Arquivos conferidos, caminhos e durações para o editor |
| `gameplays/<slug>/<slug>__<id>__<start>.mp4` | Trecho local baixado |
| `previews/<slug>-20.jpg`, `-60.jpg`, `-100.jpg` | Imagens extraídas do clipe local |
| `previews/gameplay-sheet-01.jpg` a `03.jpg` | Folhas de contato da biblioteca atual |

`slug` é a chave que conecta roteiro, gameplay, lower third e música. Não fazer associação por posição de arquivo em uma pasta nem por nomes aproximados.

O catálogo é regenerado a partir dos arquivos `download-status.json`, na ordem de `games.json`. Portanto, edições manuais feitas apenas em `gameplays.json` serão perdidas quando ele for reconstruído. Guardar decisões de montagem em um manifesto separado.

## 5. Como funciona o script de busca e download

### Requisitos e parâmetros

Executar no PowerShell 7, com Node.js, FFmpeg e ffprobe no PATH. Nesta máquina eles já foram encontrados. O downloader usa Node para resolver os desafios JavaScript suportados pelo yt-dlp. Se `tools/yt-dlp.exe` não existir, o script baixa o executável oficial do GitHub.

Na máquina de destino, instalar esses requisitos conforme o tutorial. Quando `sources.json` não existir, o script o inicializa com `sources.example.json` se disponível. Assim, é possível executar Download para as escolhas compartilhadas sem refazer Find.

| Parâmetro | Padrão | Efeito |
|---|---|---|
| `-Action` | `Find` | Aceita `Find` ou `Download` |
| `-Game` | Todos | Filtra por um ou mais slugs existentes em `games.json` |
| `-Candidates` | `5` | Quantidade de resultados buscados por jogo no modo Find |
| `-MaxHeight` | `720` | Altura máxima do vídeo selecionado; aceita 240 a 2160 |
| `-Force` | Desligado | Refaz um download que já estava concluído |

Mudar `-MaxHeight` sem `-Force` não substitui um arquivo que o script considera já baixado. Uma fonte menor continua menor: o script não faz upscale.

### Modo Find

1. Ler `catalog/games.json` e aplicar o filtro `-Game`, se fornecido.
2. Buscar no YouTube usando `ytsearch5:<consulta>`, ou a quantidade de `-Candidates`.
3. Salvar os resultados brutos em `<slug>.candidates.json`.
4. Aceitar IDs de vídeo de 11 caracteres válidos e títulos que correspondam ao padrão específico daquele jogo.
5. Excluir títulos contendo `remaster`, `remake` ou `reignited`.
6. Classificar os candidatos restantes e escolher o maior score.
7. Atualizar a entrada do jogo em `sources.json`.

Pontuação atual:

| Critério | Pontos |
|---|---:|
| Título contém longplay, full game ou walkthrough | +4 |
| Título contém no commentary ou sem coment | +4 |
| Título menciona PS1, PSX ou PlayStation, sem número de console posterior nesse padrão | +4 |
| Canal identificado como World of Longplays ou LongplayArchive pelo padrão do código | +5 |
| Título indica remaster/remake/reignited/review/retrospective/comparison/top numerado | −25 |
| Duração informada menor que 600s | −10 |

Essa pontuação é uma heurística de metadados. Não garante versão correta, ausência de comentários, qualidade da imagem ou presença de uma cena específica. Não usa views para escolher os jogos da intro. A verificação editorial continua necessária.

**Find substitui a seleção dos jogos pesquisados em `sources.json`**, incluindo o intervalo sugerido de `games.json`. Para aproveitar a biblioteca já pronta, não execute uma nova busca geral sem necessidade. Pesquise apenas os jogos que precisam de nova fonte e preserve as escolhas de curadoria importantes.

### Modo Download

1. Ler a fonte escolhida em `sources.json` e reconstruir a URL do YouTube a partir do ID.
2. Se houver status salvo com o mesmo ID, início e duração, reutilizar esse status.
3. Ignorar o download quando o status indica sucesso e o arquivo existe, salvo com `-Force`.
4. Consultar os metadados atuais e salvá-los em `<slug>.info.json`.
5. Rejeitar um intervalo cujo início + duração ultrapasse a duração da fonte.
6. Baixar o intervalo com `--download-sections '*inicio-fim'`.
7. Priorizar vídeo AVC/H.264 até `MaxHeight` mais áudio M4A, com alternativas de MP4/formato combinado.
8. Se a tentativa falhar ou ficar incompleta, tentar os formatos públicos HLS de vídeo AVC e áudio disponíveis na fonte.
9. Usar FFmpeg para obter o MP4 e ffprobe para conferir vídeo e duração.
10. Salvar arquivo, metadados básicos, sucesso ou erro em `<slug>.download-status.json`.

O fluxo usa timeout de 20s e duas tentativas de retry configuradas no yt-dlp. O script não usa cookies, login ou proxies. A alternativa HLS resolveu um dos casos de falha no download desta biblioteca.

Se qualquer jogo falhar, o script continua nos demais e termina com código 1. O log de cada tentativa pode ser substituído pela tentativa seguinte. Não publique logs brutos sem revisar: metadados e mensagens podem conter URLs temporárias de mídia.

**Importante:** Download grava o status por jogo; não sincroniza automaticamente todos esses resultados de volta a `sources.json`. Para saber o que foi baixado, leia o status ou o catálogo reconstruído. Editar o ID, início ou duração em `sources.json` muda a solicitação; alterar somente notas pode ser sobreposto pelo status reutilizado.

### Comandos de operação

```powershell
# Executar na raiz da pasta clonada/extraída.

# Aproveitar as seleções atuais e baixar apenas o que estiver pendente.
.\scripts\YouTube-Gameplays.ps1 -Action Download

# Procurar alternativas de um jogo específico; altera sua seleção.
.\scripts\YouTube-Gameplays.ps1 -Action Find -Game 'tekken-3' -Candidates 8

# Refazer o download desse jogo, solicitando até 1080p.
.\scripts\YouTube-Gameplays.ps1 -Action Download -Game 'tekken-3' -MaxHeight 1080 -Force

# Recriar o índice e as prévias com os arquivos presentes.
.\scripts\Build-GameplayCatalog.ps1

# Atualizar o downloader oficial quando necessário.
.\tools\yt-dlp.exe -U
```

Para mudar o trecho, editar `start` e `duration` da entrada do jogo em `sources.json`, em segundos, e executar Download para esse slug. A duração de 120s é o padrão de curadoria desta biblioteca, não um limite fixo do downloader. Para buscar futuramente com esse mesmo intervalo sugerido, atualizar também `games.json`.

Para acrescentar outro jogo, adicionar sua entrada em `games.json` **e** seu padrão de título em `$titlePatterns` dentro do script. O código atual tem padrões explícitos para os 18 slugs; adicionar só uma linha no JSON não completa o suporte à busca de um novo jogo. Inícios e durações precisam ser válidos para a fonte escolhida.

No fluxo de título + áudio, essa preparação é responsabilidade da IA. Não pedir ao usuário que cadastre os novos jogos. Preservar a biblioteca existente, acrescentar apenas os títulos faltantes e pesquisar esses slugs. A ordem do episódio fica no manifesto derivado da voz; não depende da ordem do catálogo geral da biblioteca.

### Como funciona Build-GameplayCatalog

O script lê os status de download, ignora entradas sem sucesso/arquivo e exige vídeo, áudio e duração de pelo menos `duration solicitada − 2s`. Depois extrai imagens em 20s, 60s e 100s do arquivo local, recriando as prévias, e monta folhas de contato com seis jogos cada usando System.Drawing.

Os campos de inspeção visual vêm do status; gerar uma folha de contato não transforma automaticamente um arquivo em clipe aprovado. `visuallyReviewed: true` na biblioteca atual significa inspeção de **três imagens**, conforme `visualReviewMethod`.

As prévias têm tempos fixos adequados aos clipes atuais de 120s. Para usar arquivos menores que 100s, adaptar esses tempos antes de reconstruir as prévias. Não tratar essa rotina como um gerador universal para qualquer duração.

## 6. Como ler o catálogo e lidar com os tempos

Campos essenciais de `catalog/gameplays.json`:

| Campo | Interpretação |
|---|---|
| `slug`, `game` | Identidade do jogo e texto de identificação |
| `src` | Caminho absoluto do MP4 local a importar |
| `sourceUrl`, `sourceTitle`, `channel` | Origem do material |
| `sourceStartSeconds` | Início solicitado no vídeo do YouTube |
| `requestedDurationSeconds` | Duração solicitada do download |
| `durationSeconds` | Duração real medida no arquivo local |
| `durationInFrames30fps` | Duração equivalente calculada a 30fps; não é a contagem de frames nativos da fonte |
| `width`, `height`, `sourceFrameRate` | Dimensões e taxa média reportadas por ffprobe |
| `videoCodec`, `audioCodec` | Codecs realmente encontrados |
| `poster` | Imagem de prévia local |
| `visuallyReviewed`, `visualReviewMethod`, `reviewNotes` | Escopo da amostragem e problemas encontrados |
| `sourceNotes` | Observações adicionais sobre a fonte |

### Três referências de tempo diferentes

1. **YouTube:** posição no vídeo completo da fonte.
2. **Clipe local:** posição dentro do trecho já baixado; normalmente começa perto do início solicitado, com possível folga de keyframe.
3. **Timeline:** posição em que o corte aparece no vídeo editado.

Exemplo: uma gameplay foi baixada a partir de 900s do YouTube. Um corte escolhido em 20s do MP4 corresponde aproximadamente a 920s da fonte. Se esse corte entra em 17s da timeline, deve ser colocado em 17s, não em 920s.

Na curadoria final, **o arquivo local é a referência do in/out**. Os downloads não garantem corte exato de frame no instante solicitado do YouTube. Confirme a imagem local antes de aprovar o plano.

Guardar decisões de edição em segundos e converter na integração:

```text
recordFrame = round(timelineStartSeconds × timelineFps)
timelineDurationFrames = round(cutDurationSeconds × timelineFps)
```

Para índices de frames na mídia, usar a base de tempo que o Resolve atribui à mídia importada e a convenção documentada da API instalada. Não multiplicar todo `sourceInSeconds` por 30 indiscriminadamente: a biblioteca mistura fontes de aproximadamente 30, 50 e 60fps, entre outras taxas.

Uma forma simples de evitar ambiguidades é preparar apenas os cortes finais em arquivos uniformes na taxa escolhida para a timeline e importá-los a partir do frame zero. Se importar os arquivos originais, converter o in/out da mídia corretamente. Manter começo, duração e arredondamento coerentes para não criar lacunas.

O script anterior usa `endFrame = startFrame + duration − 1`; isso não autoriza reutilizar uma duração calculada a 30fps para todas as mídias deste projeto. Conferir a API instalada e a taxa da mídia antes de adaptar essa chamada.

## 7. Buscar o console e as músicas

O script `YouTube-Gameplays.ps1` cobre os jogos cadastrados. Ele ainda não possui uma ação específica para consoles ou OSTs. Não afirmar que `Find` já cria esses dois tipos de assets.

### Console

Buscar no YouTube uma filmagem do console do vídeo, por exemplo `original PlayStation console footage close up`. Escolher um trecho curto com o aparelho visível, sem apresentação longa de outro narrador ou propaganda. Baixar só o intervalo necessário com o mesmo yt-dlp/FFmpeg.

Guardar em `assets/console/` quando essa etapa for implementada. Registrar URL, canal, intervalo da fonte e caminho local em um manifesto de assets. Usar esse vídeo na primeira imagem da intro; não substituir por gameplay ou por uma imagem estática sem uma alteração expressa do briefing.

### OST

Pesquisar por `<nome do jogo> original soundtrack OST <nome da faixa>`. Confirmar que é música da versão abordada e evitar covers/remixes quando o objetivo for a trilha original. Preferir uma faixa adequada à fala e registrar nome, jogo, fonte e trecho.

Exemplo de comando, **somente depois de substituir o ID por uma fonte real escolhida**:

```powershell
New-Item -ItemType Directory -Path '.\music\tekken-3' -Force | Out-Null
$ostUrl = 'https://www.youtube.com/watch?v=SUBSTITUIR_ID'
$ffmpegPath = (Get-Command ffmpeg.exe).Source
.\tools\yt-dlp.exe --ignore-config --no-playlist --js-runtimes node `
  --ffmpeg-location $ffmpegPath --download-sections '*0-180' `
  -f 'ba[ext=m4a]/ba' -x --audio-format wav `
  -o 'music/tekken-3/tekken-3-ost.%(ext)s' $ostUrl
```

Esse comando é uma instrução para uma etapa futura; não foi usado para criar a biblioteca de OSTs. O intervalo precisa caber na fonte e cobrir a duração desejada. Se houver falha de acesso/formato, consultar os formatos públicos disponíveis e adaptar a seleção, como no fluxo de gameplay.

Na fonte de Chrono Cross já selecionada, a própria descrição informa uma reivindicação relacionada à música. A observação foi registrada em `sourceNotes`. Preservar observações de origem relevantes no manifesto, sem tratá-las como características do vídeo final.

## 8. Plano de montagem e integração com o Resolve

### Método já existente a reaproveitar

Projeto anterior na máquina original: `D:\BLACK AND WHITE CARTOON\remotion-cartoon-jazz`. Para outra máquina, ler as cópias incluídas em `reference/resolve-cartoon/`; não é preciso possuir a pasta original.

Arquivos úteis para leitura:

- `scripts/README-resolve-batch.md`: fluxo de instalação, preparação e execução.
- `scripts/CartoonJazzResolveBatch.lua`: cria/reutiliza projeto dedicado, importa mídia, cria timelines e posiciona itens com a API do Resolve; também possui fila de render.
- `scripts/prepare_resolve_api.py`: prepara planos de edição e mixagens do projeto anterior.
- `scripts/build_resolve_fcpxml.ps1`: gera assets e manifestos usados naquele fluxo.

Esses nomes acima descrevem a organização original. As cópias estão diretamente em `reference/resolve-cartoon/`, e o README original foi preservado como `README-original.md`. Ler também o README novo dessa pasta: o Lua histórico ainda tem raiz e slugs fixos de cartoons, e precisa de adaptação antes de ser usado.

Na instalação usada nesse projeto anterior, o FCPXML é um intermediário consumido pela preparação; ele não deve ser apresentado como uma importação já validada nesta máquina. O caminho que funcionou foi importar e posicionar mídia pela API nativa.

Reaproveitar a estrutura de importação e montagem, adaptando-a para os assets e tempos desta lista. Os cartões de episódios, a abertura tipográfica e a música jazz do projeto de cartoons não fazem parte deste modelo. Preservar as cópias de referência e implementar o novo plugin na pasta deste repositório.

Antes de adicionar chamadas novas à API, ler a documentação de scripting instalada do DaVinci Resolve. Não inventar métodos para lower thirds, keyframes de volume, fades ou ducking. Se o recurso necessário não estiver disponível pela API, preparar o asset correspondente antes da importação: por exemplo, PNG transparente para identificação ou áudio com fades já calculados por FFmpeg.

### Organização sugerida da timeline

| Faixa | Conteúdo |
|---|---|
| V1 | Console na intro; gameplays e cartelas de transição nos intervalos planejados |
| V2 | Lower thirds com transparência |
| V3 | Outros elementos apenas se o briefing exigir |
| A1 | Narração |
| A2 | OST com volume reduzido e transições |
| A3 | Áudio da gameplay, separado e inicialmente silenciado |
| A4 | Efeitos sonoros das transições, separados da voz e da música |

Durante a cartela, não posicionar lower third nem mídia audível em A1–A3. Só o efeito planejado em A4 toca; a imagem da cartela deve preencher o intervalo, sem gap preto involuntário. Ao encerrar a cartela, retomar voz/gameplay/OST com os tempos recalculados.

Se for necessário renderizar uma mixagem previamente, manter narração e música em stems separados sempre que possível, para permitir ajustes no Resolve. Se importar vídeo sem som, posicionar apenas o componente de vídeo. Não deixar o áudio vinculado da gameplay somar-se silenciosamente à OST e à voz.

Parâmetros iniciais sugeridos: timeline 1920×1080, 30fps, áudio 48kHz. São escolhas compatíveis com o fluxo anterior, não propriedades medidas do vídeo de referência. Preservar o enquadramento dos jogos e escolher outro FPS quando houver uma definição expressa para a entrega.

### Manifesto de edição

Criar um manifesto separado, por exemplo `edit-plan.json`, **quando a montagem for implementada**. Ele deve guardar:

- Configuração da timeline.
- Título enviado e identificação do episódio.
- Arquivo da narração final.
- Posição inicial da narração na timeline, caso haja uma abertura anterior à voz.
- Segmentos da narração após as divisões entre jogos, preservando os limites no áudio original.
- Transcrição temporal e lista de jogos extraídas do áudio.
- Asset do console e seu corte local.
- Seleção e cortes de gameplay da intro, com 2–4s por item.
- Ordem dos blocos, slug do jogo e limites de tempo alinhados à voz.
- Seleção de cortes de aproximadamente 5s que mostrem partes diferentes do jogo e preencham cada bloco, incluindo `src` quando houver arquivos extras.
- Inventário/origem dos trechos extras, além do arquivo principal de cada jogo.
- Texto, início e duração de cada lower third.
- Música de cada bloco, corte, ganho e fades.
- Transições: jogo anterior/próximo, limite no áudio original, início na timeline, duração da cartela, tempo adicional inserido, texto e efeito sonoro.
- Observações de curadoria e origem.

Exemplo estrutural de manifesto, **não implementado pelo código atual e não pronto para render**:

```json
{
  "version": 3,
  "title": "Título enviado pelo usuário",
  "editing": { "introCutMinSeconds": 2, "introCutMaxSeconds": 4, "bodyTargetCutSeconds": 5, "varyScenesWithinGame": true },
  "timeline": { "width": 1920, "height": 1080, "fps": 30, "audioSampleRate": 48000 },
  "narration": {
    "src": "narration/exemplo.wav",
    "timelineStartSeconds": 0,
    "segments": [
      { "sourceInSeconds": 0, "durationSeconds": 47, "timelineStartSeconds": 0 },
      { "sourceInSeconds": 47, "durationSeconds": 30, "timelineStartSeconds": 48 }
    ]
  },
  "intro": {
    "console": { "src": "assets/console/ps1.mp4", "sourceInSeconds": 0, "timelineStartSeconds": 0, "durationSeconds": 5 },
    "gameplayCuts": [
      { "gameSlug": "tekken-3", "sourceInSeconds": 20, "timelineStartSeconds": 5, "durationSeconds": 3 },
      { "gameSlug": "crash-bandicoot-3-warped", "sourceInSeconds": 20, "timelineStartSeconds": 8, "durationSeconds": 3 },
      { "gameSlug": "metal-gear-solid", "sourceInSeconds": 60, "timelineStartSeconds": 11, "durationSeconds": 3 },
      { "gameSlug": "resident-evil-3-nemesis", "sourceInSeconds": 100, "timelineStartSeconds": 14, "durationSeconds": 3 }
    ]
  },
  "transitions": [
    {
      "fromGameSlug": "warpath-jurassic-park",
      "toGameSlug": "ridge-racer-type-4",
      "sourceBoundarySeconds": 47,
      "timelineStartSeconds": 47,
      "durationSeconds": 1,
      "insertedPauseSeconds": 1,
      "title": { "text": "R4: Ridge Racer Type 4", "src": "assets/titles/ridge-racer-type-4.png" },
      "soundEffect": { "src": "assets/sfx/game-transition.wav", "sourceInSeconds": 0, "durationSeconds": 0.35, "gainDb": -12 }
    }
  ],
  "blocks": [
    {
      "gameSlug": "warpath-jurassic-park",
      "timelineStartSeconds": 17,
      "timelineEndSeconds": 47,
      "gameplayCuts": [
        { "sourceInSeconds": 20, "timelineStartSeconds": 17, "durationSeconds": 5 },
        { "src": "gameplays/warpath-jurassic-park/trecho-extra-01.mp4", "sourceInSeconds": 10, "timelineStartSeconds": 22, "durationSeconds": 5 },
        { "sourceInSeconds": 60, "timelineStartSeconds": 27, "durationSeconds": 5 },
        { "src": "gameplays/warpath-jurassic-park/trecho-extra-02.mp4", "sourceInSeconds": 20, "timelineStartSeconds": 32, "durationSeconds": 5 },
        { "src": "gameplays/warpath-jurassic-park/trecho-extra-01.mp4", "sourceInSeconds": 35, "timelineStartSeconds": 37, "durationSeconds": 5 },
        { "src": "gameplays/warpath-jurassic-park/trecho-extra-02.mp4", "sourceInSeconds": 55, "timelineStartSeconds": 42, "durationSeconds": 5 }
      ],
      "lowerThird": { "text": "Warpath: Jurassic Park", "timelineStartSeconds": 17, "durationSeconds": 4 },
      "music": { "src": "music/warpath-jurassic-park/ost.wav", "sourceInSeconds": 0, "timelineStartSeconds": 17, "durationSeconds": 30, "gainDb": -24, "fadeInSeconds": 0.5, "fadeOutSeconds": 0.5 }
    },
    {
      "gameSlug": "ridge-racer-type-4",
      "timelineStartSeconds": 48,
      "timelineEndSeconds": 78,
      "gameplayCuts": [
        { "sourceInSeconds": 60, "timelineStartSeconds": 48, "durationSeconds": 5 },
        { "src": "gameplays/ridge-racer-type-4/trecho-extra-01.mp4", "sourceInSeconds": 10, "timelineStartSeconds": 53, "durationSeconds": 5 },
        { "sourceInSeconds": 95, "timelineStartSeconds": 58, "durationSeconds": 5 },
        { "src": "gameplays/ridge-racer-type-4/trecho-extra-02.mp4", "sourceInSeconds": 20, "timelineStartSeconds": 63, "durationSeconds": 5 },
        { "src": "gameplays/ridge-racer-type-4/trecho-extra-01.mp4", "sourceInSeconds": 35, "timelineStartSeconds": 68, "durationSeconds": 5 },
        { "src": "gameplays/ridge-racer-type-4/trecho-extra-02.mp4", "sourceInSeconds": 55, "timelineStartSeconds": 73, "durationSeconds": 5 }
      ],
      "lowerThird": { "text": "R4: Ridge Racer Type 4", "timelineStartSeconds": 48, "durationSeconds": 4 },
      "music": { "src": "music/ridge-racer-type-4/ost.wav", "sourceInSeconds": 0, "timelineStartSeconds": 48, "durationSeconds": 30, "gainDb": -24, "fadeInSeconds": 0.5, "fadeOutSeconds": 0.5 }
    }
  ]
}
```

Os caminhos de voz, console, música, cartela, efeito e trechos extras acima são ilustrativos e ainda não existem. Os cortes são exemplos de dados, não intervalos integralmente aprovados. Antes da montagem, resolver cada `gameSlug` para o `src` real do catálogo quando não houver um `src` explícito no corte, baixar/registrar os extras e conferir todos os in/out. Os nomes `trecho-extra-01/02` ilustram arquivos de situações diferentes; tempos distantes, por si só, não comprovam variedade. Cada bloco de 30s do exemplo tem seis planos de 5s. Trinta segundos não é uma regra para a duração de um jogo. O exemplo supõe voz de 77s e pausa adicional de 1s, resultando em timeline de 78s; 47s é somente um limite ilustrativo entre frases.

### Sequência de trabalho para a próxima IA

1. Ler este guia, o README e os scripts atuais antes de alterar o projeto.
2. Receber o título e o áudio final; medir e transcrever a voz sem substituí-la.
3. Extrair console, lista/ordem dos jogos e limites dos blocos nos tempos da voz.
4. Ler o catálogo existente e reaproveitar gameplays compatíveis.
5. Buscar/baixar apenas cenas faltantes, além do console, das OSTs e do efeito sonoro de transição.
6. Selecionar partes diferentes de cada jogo em cortes próximos de 5s, rever os intervalos completos, marcar pausas entre jogos e escrever o manifesto em segundos, com os deslocamentos acumulados.
7. Preparar lower thirds, cartelas com o nome do próximo jogo e, se necessário, segmentos de voz/cortes/mixes com FFmpeg.
8. Adaptar o importador Lua/API para criar uma timeline dedicada e posicionar os assets.
9. Preservar o projeto aberto do usuário: salvar e criar um projeto separado quando ele já contiver trabalho.
10. Gerar a timeline editável com caminhos válidos e durações calculadas.
11. Quando o usuário solicitar a edição completa a partir do título e áudio, conferir o resultado no Resolve e renderizar o vídeo final nas configurações definidas para a entrega.
12. Relatar o que foi criado e qualquer asset ainda ausente; não chamar uma timeline incompleta de vídeo final.

Usar caminhos absolutos na comunicação com o Resolve e no plano convertido para sua API. O manifesto portátil pode usar caminhos relativos, desde que o importador os resolva a partir da raiz do projeto.

### Entregas do fluxo de título + áudio

Quando o pedido for editar o vídeo completo, entregar:

- Projeto/timeline editável no DaVinci Resolve, com mídia acessível.
- Vídeo final em MP4; default sugerido: 1080p30, H.264 e AAC, salvo em `outputs/<slug-do-episodio>/video-final.mp4`.
- `edit-plan.json` com todos os cortes, identificação, faixas e tempos usados.
- Transcrição temporal e relação de fontes dos assets, no diretório da entrega.

Usar os defaults deste guia para detalhes não especificados. Não devolver ao usuário uma lista de decisões rotineiras sobre fontes, cores, cuts ou ganhos como condição para editar. Se não houver ferramentas para baixar, transcrever ou acessar o Resolve, declarar a limitação concreta e preservar os artefatos preparados; não fingir execução.

## 9. Critérios de fidelidade e entrega

Para considerar a montagem fiel ao pedido, todos estes pontos precisam estar atendidos:

- A primeira imagem da intro é um vídeo do console correto.
- A montagem seguinte antecipa jogos presentes no vídeo, com 2–4s por gameplay.
- A fala sobre um jogo é acompanhada por material desse jogo/versão.
- Cada bloco usa uma seleção de partes diferentes do mesmo jogo, em cortes de aproximadamente 5s, com ajuste final para a duração real da fala.
- O bloco não é preenchido só com pedaços consecutivos da mesma situação nem com repetição de uma sequência; quando falta variedade, há material adicional selecionado.
- O nome do lower third corresponde à gameplay e está legível.
- A duração de cada bloco acompanha o áudio real e as pausas inseridas; não existem gaps involuntários de imagem ou voz.
- Entre os blocos de jogos há mini pausa com cartela do próximo jogo e efeito sonoro; voz, OST e gameplay ficam sem som nesse intervalo.
- Nenhuma palavra foi cortada para abrir a pausa; os tempos posteriores foram recalculados, incluindo lower thirds, músicas e imagens.
- Menus, telas pretas e loading não aparecem por mero preenchimento.
- OSTs dos jogos ficam em volume reduzido, com voz inteligível.
- Música, efeitos e narração não foram duplicados por importação de áudio vinculado.
- A imagem mantém a proporção e o HUD útil; fontes com bordas/marcas estão registradas.
- Os cortes cabem nos arquivos locais; segundos e frames não foram confundidos.
- O projeto/timeline pode ser aberto e ajustado no DaVinci Resolve.
- Quando solicitado render, existe um arquivo final reproduzível; a mera presença de um job na fila não comprova a entrega.

Os critérios descrevem o resultado esperado. Não execute renders ou uma bateria de testes só por ter lido este documento: respeite o escopo solicitado na tarefa atual.

### Prompt pronto para repassar a outra IA

Copiar o texto abaixo e preencher título e arquivo de áudio. Se a IA estiver fora deste workspace, enviar também este guia e disponibilizar os scripts/arquivos necessários para que ela os acesse.

> **Título do vídeo:** [COLOCAR O TÍTULO]
>
> **Áudio final da narração:** [ANEXAR O ARQUIVO OU INFORMAR SEU CAMINHO]
>
> Edite e entregue o vídeo completo com base neste título, no áudio enviado e no guia. Clone ou baixe https://github.com/joaogks/Listadejogos e trabalhe na pasta do repositório. Leia `TUTORIAL-PARA-IA.md`, `GUIA-PARA-IAS.md`, `README.md` e os dois scripts em `scripts/`. Reconstrua `catalog/gameplays.json` localmente quando necessário. Transcreva o áudio com timestamps e extraia o console, os jogos, sua ordem e os limites de cada bloco. Use a voz original integral, sem reescrever a narração, gerar outra voz ou mudar sua velocidade. Não exija roteiro escrito, lista de jogos ou timecodes do usuário: derive esses elementos da fala.
>
> Comece a imagem com um vídeo do console abordado; em seguida, mostre gameplays de jogos conhecidos presentes no episódio, com 2–4 segundos por trecho. Faça essa intro caber na introdução da voz; se o áudio começar direto no primeiro jogo, coloque uma abertura visual curta antes dele e registre o deslocamento. No corpo, use uma seleção de partes diferentes do jogo atual, em cortes de cerca de 5 segundos, coloque um lower third com seu nome e use música do próprio jogo em volume reduzido. Busque momentos em fases, cenários, ações ou personagens distintos, conforme o gênero e a fala; não apenas divida a mesma situação contínua em pedaços. Mantenha voz e OST contínuas entre os cortes do mesmo jogo, preserve a voz clara e separe OST, áudio da gameplay e narração.
>
> Entre os blocos de um jogo e outro, corte a voz somente no limite entre frases, encerre música/áudio da gameplay e faça uma mini pausa de cerca de 1s com uma cartela mostrando o nome do próximo jogo. Toque um efeito sonoro curto nessa entrada; durante a cartela, só ele fica audível. Depois retome a narração original junto da gameplay, lower third e OST do próximo jogo. Aproveite silêncios existentes quando suficientes e amplie-os quando necessário, sem apagar palavras nem acelerar a voz. Registre as divisões de áudio e recalcule todos os tempos posteriores pelo acréscimo acumulado.
>
> Reaproveite a biblioteca já baixada do YouTube e busque/baixe as cenas faltantes, o vídeo do console e as OSTs. O novo episódio deve seguir os jogos do áudio, não obrigatoriamente os 18 da referência. Confirme jogo, versão e plataforma. Não use menus, loading ou telas pretas como preenchimento; revise os cortes completos, preserve proporção e HUD e registre as fontes.
>
> Para a montagem automática no DaVinci Resolve, adapte o método de API/Lua incluído em `reference/resolve-cartoon/`, preservando as cópias históricas. O plugin específico desta lista ainda precisa ser implementado. Guarde as decisões em um manifesto separado e diferencie tempo no YouTube, no clipe local e na timeline. Use os defaults do guia para detalhes não especificados. Entregue projeto/timeline editável, MP4 final, manifesto e transcrição temporal com as fontes utilizadas. Informe exatamente o que foi concluído e qualquer limitação concreta de execução.

Documentação do downloader: [yt-dlp oficial](https://github.com/yt-dlp/yt-dlp). Para o Resolve, consultar a documentação de scripting instalada e o código do importador anterior antes de usar novos métodos.
