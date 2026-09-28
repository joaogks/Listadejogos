# Referência: método de importação por API no DaVinci Resolve

Esta pasta contém cópias do código usado no projeto anterior Black and White Cartoon. Elas permitem estudar o funcionamento sem acesso à pasta original do computador de João.

**São arquivos de referência, não o plugin pronto de lista de jogos.** Não instalar nem executar o batch antigo para editar o episódio novo. Ele usa um caminho absoluto do projeto original, dez slugs de cartoons e manifestos/assets que não estão neste repositório.

## Arquivos

| Arquivo | Função no projeto anterior |
|---|---|
| `CartoonJazzResolveBatch.lua` | Script de menu do Resolve: projeto dedicado, importação de mídia, criação de timelines, posicionamento via API e fila de render |
| `Install-CartoonJazzResolveBatch.ps1` | Copia o Lua para a pasta de scripts do usuário do Resolve |
| `prepare_resolve_api.py` | Converte os intermediários do projeto anterior para planos da API e prepara fades/mixagens |
| `build_resolve_fcpxml.ps1` | Gera cartões/assets e manifestos/intermediários daquele projeto |
| `README-original.md` | Instruções originais, preservadas como contexto histórico |

As cópias preservam o comportamento original. Dependências do preparador Python incluem Pillow e FFmpeg; seus planos, episódios, áudio e imagens de cartoons não foram copiados. Os dois scripts de gameplay deste repositório não dependem desse preparador.

## O método que deve ser reaproveitado

1. Preparar caminhos e um plano de edição antes de abrir o importador.
2. Salvar o projeto atual e criar/carregar um projeto dedicado quando houver trabalho aberto.
3. Criar timeline e pistas necessárias.
4. Importar os assets com `MediaPool:ImportMedia`.
5. Posicionar itens por `MediaPool:AppendToTimeline`, usando mídia, in/out, faixa e `recordFrame`.
6. Conferir a timeline e, quando solicitado, preparar os jobs e iniciar o render.

Na instalação original, o FCPXML era intermediário de preparação, não o caminho de importação validado para a entrega. A importação funcionou pela API nativa do Resolve.

## Adaptações necessárias para a lista de jogos

- Trocar raiz fixa, nome de projeto, slugs e planos de cartoons por uma raiz configurável e manifesto derivado do título/áudio.
- Remover requisitos específicos como dez vídeos, quantidade mínima de linhas do plano, cartões de episódios e jazz.
- Usar filmagem do console e montagem de gameplay na intro.
- Criar lower thirds do jogo correto em uma pista superior.
- Separar narração, OST e áudio da gameplay, com tempos/ganhos/fades adequados.
- Tratar as taxas de frames das mídias; o projeto anterior assume 30fps em partes do preparador.
- Adaptar o instalador para um novo nome de menu e o novo script, preservando o menu do projeto anterior.
- Consultar a documentação de scripting do Resolve instalado antes de adicionar métodos de controle que não aparecem no código.

O manifesto novo é descrito em [GUIA-PARA-IAS.md](../../GUIA-PARA-IAS.md). O tutorial de continuação está em [TUTORIAL-PARA-IA.md](../../TUTORIAL-PARA-IA.md).
