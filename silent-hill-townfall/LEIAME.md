# Silent Hill: Townfall — guia de otimização para PC

Montado para este PC: **Ryzen 5 3600 · 32 GB de RAM · SSD · RTX 3050 · monitor 1080p**.

## O que se sabe do jogo

- Roda na **Unreal Engine 5.6.1**, só em DirectX 12.
- Os problemas mais relatados no PC são três:
  1. **Travadas por compilação de shaders** na primeira vez que um efeito ou área aparece. O patch 1.3.1 (30/09/2026) melhorou bastante, mas não zerou.
  2. **Travadas ao andar pela cidade.** O mapa é carregado em pedaços (mais de mil). O patch 1.4.0 (08/10/2026) melhorou isso também.
  3. **Uso alto do processador**, mesmo em áreas pequenas.
- A placa mínima oficial é a **RTX 2060 Super**, para 1080p a 30 FPS no Baixo. Ela é uns **25 a 35% mais rápida que a RTX 3050 de 8 GB** (ou seja, a 3050 é uns 20 a 25% mais fraca), e a 3050 de 6 GB é mais fraca ainda.
- **O que mais pesa:** a resolução interna (o DLSS resolve isso) e a **Neblina**. As outras opções mudam menos o FPS.
- **Estimativa, não medida** (não encontrei números confiáveis da 3050 neste jogo): seguindo este guia, com DLSS em Qualidade em 1080p, a **3050 de 8 GB** deve ficar perto de **45 a 60 FPS**, e a **de 6 GB** perto de **35 a 45 FPS**. O requisito oficial é conservador: uma GTX 1080, um pouco mais forte que a 3050, fez ~38 FPS em 1080p nativo no máximo. Nas partes abertas da cidade, o processador pode deixar o FPS um pouco abaixo disso.

---

## Passo 0 — Antes de jogar

1. **Jogo atualizado.** No menu principal, no canto inferior direito, deve aparecer **v1.5.154194 ou mais nova** (patch 1.4.0). A Steam atualiza sozinha.
2. **Driver da NVIDIA atualizado** (NVIDIA App ou GeForce Experience).
3. **Cache de shaders maior:** Painel de Controle NVIDIA → Gerenciar as configurações em 3D → **Tamanho do cache de shader (Shader Cache Size)** → **10 GB** ou **Ilimitado**.
4. **Primeira vez que abrir o jogo:** ele mostra uma tela compilando shaders. **Espere terminar**, porque num processador de 6 núcleos pode levar alguns minutos. Isso se repete depois de cada atualização do driver ou do jogo.

## Passo 1 — Configurações do menu (o que mais faz diferença)

O jogo **não tem predefinições** (Baixo/Médio/Alto), então ajuste cada opção. Os nomes em português são aproximados; entre parênteses está o nome em inglês.

| Opção | Recomendado | Por quê |
|---|---|---|
| **Upscaler** | **DLSS** | O melhor upscaler para placas RTX. Também diminui o uso de VRAM. |
| **Qualidade do upscaler** | **Qualidade**. Se não segurar o limite de FPS, **Equilibrado** (se o menu não tiver, **Desempenho**) | Em 1440p, use Equilibrado ou Desempenho. |
| **Neblina** (Fog Quality) | **Baixa** | Uma das opções mais pesadas e a que dá mais ganho. A neblina continua lá; muda pouco no visual. |
| **Iluminação global** (Global Illumination) | **Média** | O grande salto visual é do Baixo para o Médio. Acima disso, pesa mais e muda pouco. |
| **Sombras** (Shadow Quality) | **Média** (Baixa se faltar FPS) | Peso de moderado a alto. |
| **Reflexos** (Reflection Quality) | **Baixa** ou **Média** | Peso moderado. |
| **Pós-processamento** (Post Processing) | **Média** (Baixa se faltar FPS) | Ganho pequeno. Na Unreal padrão, a Baixa tira a profundidade de campo (o desfoque nas cenas) e a vinheta, que ajudam no clima. |
| **Texturas** (Texture Quality) | **Alta** na 3050 de 8 GB; **Média** na de 6 GB | Quase não pesa no FPS, só na memória de vídeo. Use o **medidor de memória de vídeo** do menu: fique abaixo de **~6,5 GB** na placa de 8 GB e de **~5 GB** na de 6 GB. |
| **Ray Tracing** | **Desligado** | A 3050 tem poucos núcleos de RT, e o ray tracing gasta mais VRAM. |
| **NVIDIA Reflex** | **Desligado** | No teste do site Wccftech, o Reflex deixou o ritmo dos quadros irregular neste jogo. |
| **Limite de FPS** (Frame Rate Limit) | **60** | FPS estável parece mais fluido que FPS alto oscilando, e sobra fôlego para o processador. Se não segurar 60, primeiro deixe o DLSS mais leve. Se ainda cair: **com G-Sync/FreeSync**, teste **50** (só use 45 se o mínimo do seu monitor for menor que isso; em muitos de 75 Hz o mínimo é 48 Hz); **sem**, use um valor que divida a taxa do monitor (60 Hz: 60 ou 30; 144 Hz: 48 ou 36). Num monitor de **75 Hz sem G-Sync/FreeSync**, mude a taxa para 60 Hz nas configurações de vídeo do Windows e use 60 ou 30. |
| **V-Sync** | **Desligado** com G-Sync/FreeSync ativo; **ligado** sem | Monitor FreeSync numa placa NVIDIA: ligue o FreeSync no menu do próprio monitor, use cabo **DisplayPort** e, no Painel de Controle NVIDIA → Monitor → Configurar G-SYNC, marque **Habilitar G-SYNC/Compatível com G-SYNC** e, se aparecer, **Habilitar configurações para o modelo de monitor selecionado** (os nomes podem variar um pouco). Sem isso, a tela "rasga". Se essa tela não aparecer (comum com cabo HDMI), trate o monitor como **sem** G-Sync/FreeSync. |
| **Desfoque de movimento** (Motion Blur) | Desligado | Gosto pessoal; pesa pouco. |
| **Campo de visão** (FOV) | Padrão | Um FOV maior mostra mais cenário e pesa um pouco mais. |

> O jogo **não tem geração de quadros** (Frame Generation) nem Ray Reconstruction no menu. Existem truques para forçar esses recursos pelo Engine.ini, mas eles **não estão neste pacote**: veja o Passo 3.

## Passo 2 — Ajustes do Engine.ini

### O que o arquivo faz

Ele tem só **2 ajustes ativos**, ambos de ganho pequeno:

- **`r.Streaming.LimitPoolSizeToVRAM=1`:** trava de segurança. Quando a memória de vídeo está quase cheia, a Unreal diminui o espaço das texturas em vez de passar do limite (algumas ficam um pouco menos nítidas, mas evita travadas). Na Unreal padrão isso já vem ligado nas Texturas Baixa/Média/Alta (o jogo tem a própria tabela de qualidade, então pode ser diferente); o ajuste garante que fique ligado em qualquer nível, inclusive no Ultra. Ele **não** controla o resto da VRAM (sombras, iluminação, efeitos), então o medidor do menu continua sendo o principal. Isso importa na RTX 3050, que se comunica com o PC por só 8 linhas PCIe (em placa-mãe B450/A520, PCIe 3.0 x8): quando a VRAM estoura, o jogo trava muito.
- **`gc.TimeBetweenPurgingPendingKillObjects=90`:** a Unreal dá uma pausa curtinha a cada ~60 segundos para limpar a memória. Com 32 GB de RAM, dá para espaçar essas pausas para 90 segundos. O ganho não foi medido neste jogo.

Também tem **4 opcionais**, que vêm desligados:

- tirar a aberração cromática (só muda algo com o Pós-processamento em Alta ou Ultra);
- tirar o granulado de filme (idem);
- filtro anisotrópico 16x (texturas mais nítidas, custo quase zero);
- forçar o DLSS 4 (imagem mais nítida, o que permite usar o DLSS um degrau abaixo).

**Por que tão pouco?** Conferi no código-fonte da Unreal 5.6. Quase todos os ajustes "anti-travada" que circulam na internet já vêm ligados de fábrica nessa versão, foram removidos da engine ou são desligados pelo próprio jogo durante a partida. Os poucos que sobram são arriscados (veja o Passo 3). Para travadas, o que realmente ajuda são os Passos 0 e 1.

### Instalação automática (recomendada)

1. Abra o jogo **pelo menos uma vez** até o menu principal e feche.
2. Coloque **todos os arquivos desta pasta juntos** numa pasta qualquer, por exemplo na Área de Trabalho. **Não** coloque na pasta de configuração do jogo (a do `Engine.ini`, que aparece na Instalação manual).
3. Dê dois cliques em **`instalar.bat`**.

O script:
- faz **backup** do seu `Engine.ini`, se ele existir (normalmente o jogo não cria um);
- grava os ajustes;
- marca o arquivo como **somente leitura**, porque o jogo pode apagar linhas que não reconhece.

Pode rodar o `instalar.bat` quantas vezes quiser: ele sempre parte do original e **nunca duplica** os ajustes.

> **Para ligar um opcional:** abra o `Engine.ini` **desta pasta** no Bloco de Notas, tire o `;` do começo da linha do ajuste, salve e rode o `instalar.bat` de novo.

> **Atenção:** os scripts reconstroem o arquivo a partir do backup. Mudanças feitas **dentro** do `Engine.ini` instalado são descartadas quando você roda o instalar, o testar ou o desinstalar. Se você **trocar o arquivo inteiro** por outro (de outro mod, por exemplo), os scripts percebem e não o apagam.

> O Windows pode mostrar "O Windows protegeu o computador". Clique em **Mais informações → Executar assim mesmo**. Os scripts são texto puro: abra no Bloco de Notas para conferir antes, se quiser.

### Teste opcional: o jogo está lendo o arquivo?

Alguns sites dizem que este jogo guarda as configurações num formato próprio e talvez ignore o `Engine.ini`. Para tirar a dúvida:

1. Dê dois cliques em **`testar.bat`**. Ele instala os ajustes **mais** um efeito de nitidez exagerado de propósito.
2. Abra o jogo e entre numa partida.
   - **Imagem MUITO "crocante", com contornos marcados e chiado exagerado:** o jogo lê o arquivo e os ajustes estão sendo aplicados.
   - **Imagem normal:** o jogo **provavelmente** está ignorando o arquivo. Não tem problema, porque os Passos 0 e 1 continuam valendo.
3. Feche o jogo e rode o **`instalar.bat`** para tirar o efeito exagerado.

### Desfazer

Dê dois cliques em **`desinstalar.bat`**: tudo volta a ser como era antes.

### Instalação manual

1. Aperte `Win + R`, cole o caminho abaixo e dê Enter:
   ```
   %LOCALAPPDATA%\Townfall\Saved\Config\Windows
   ```
2. Se já existir um `Engine.ini`, faça uma cópia de segurança. Se não existir, crie um: no Bloco de Notas, **Salvar como → Tipo: Todos os arquivos → nome `Engine.ini`**. Assim ele não vira `Engine.ini.txt`.
3. Vá até o final do arquivo, aperte **Enter** para começar uma linha nova, cole todo o conteúdo do `Engine.ini` desta pasta e salve.
4. Clique com o botão direito no `Engine.ini` → Propriedades → marque **Somente leitura**.

## Passo 3 — O que NÃO fazer

- **Pacotes de Engine.ini com dezenas de linhas "anti-stutter":** na Unreal 5.6, a maior parte não faz nada. Alguns são perigosos:
  - `wp.Runtime.BlockOnSlowStreaming=0` pode fazer você **cair do mapa** ou pular eventos da história.
  - `gc.AllowIncrementalReachability=1` é experimental e pode **fechar o jogo do nada**.
  - `D3D12.PSO.DiskCache` é um recurso que a própria Unreal diz que "não funciona mais".
- **Forçar a geração de quadros FSR pelo Engine.ini** (`r.FidelityFX.FI.Enabled=1`): há relatos de o jogo fechar ao trocar de janela ou com overlays abertos. Com FPS base baixo, como numa 3050, ela também aumenta o atraso dos controles e cria defeitos na imagem.
- **Forçar o Ray Reconstruction pelo Engine.ini:** num PC bem mais forte, o FPS caiu de 72 para 60. Numa 3050 não compensa.
- **Opções de inicialização `-dx11` ou `-vulkan`:** o jogo só tem shaders de DirectX 12, então elas não funcionam.
- **Apagar vídeos da pasta do jogo para pular as logos:** os vídeos das TVs dentro do jogo ficam na mesma pasta.

## Passo 4 — Windows e hardware

- **O jogo pesa no processador.** O Ryzen 5 3600 é exatamente o processador mínimo oficial. O limite de FPS do Passo 1 ajuda a deixar sobra para ele.
- **Placa de vídeo no slot de cima** da placa-mãe, o slot principal. O slot de baixo costuma ter bem menos linhas PCIe, o que piora as travadas quando a VRAM enche.
- **Feche programas pesados** em segundo plano: navegador com vídeo, gravadores, etc.
- **DLSS mais novo (opcional):** no **NVIDIA App** → Gráficos → Silent Hill Townfall, procure a substituição do modelo DLSS (*DLSS Override – Model Presets*) e escolha **Predefinição K** (*Preset K*), se a opção aparecer.
  - Se só aparecerem "Recomendado" e "Mais recente", use **Recomendado** só com o DLSS do jogo em **Qualidade** ou **Equilibrado** (nesses modos ele usa o K). Em **Desempenho**, o Recomendado passa a usar o M, mais pesado nas RTX 30: nesse caso, desligue a substituição no NVIDIA App e use o opcional do DLSS 4 do Engine.ini, que força o K em qualquer modo.
  - **Não use "Mais recente"/"Latest" nem as predefinições L ou M.** Elas são o DLSS 4.5, bem mais pesado nas RTX 30.
  - Use isto **ou** o opcional do DLSS 4 no Engine.ini, não os dois. O NVIDIA App tem prioridade.
- **HDR e brilho:** se o seu monitor não for HDR de verdade (modelos baratos "HDR10"/"HDR400"), deixe o HDR do Windows desligado. Em HDR, o jogo usa brilho fixo e o ajuste de gama do menu não funciona. Se os interiores ficarem escuros demais, aumente o gama no menu (com o HDR desligado).

## Problemas comuns

| Sintoma | O que fazer |
|---|---|
| Trava na primeira vez que entra numa área ou vê um efeito | É compilação de shaders. Melhora ao voltar no mesmo lugar. Confira se o Passo 0 foi feito. |
| Travadas constantes e texturas demorando a carregar | Abaixe **Texturas** um nível e confira o medidor de VRAM do menu. |
| Controle fazendo comandos duplicados | Problema conhecido da Steam. Biblioteca → botão direito no jogo → Propriedades → Controle → **desative o Steam Input**. |
| Não sei se os ajustes do Engine.ini funcionam | Rode o `testar.bat` (Passo 2). |
| O jogo não abre depois dos ajustes | Rode o `desinstalar.bat`. |

## Para ajustar ainda mais

Com estas informações dá para refinar o guia:

- A sua RTX 3050 é de **6 GB ou 8 GB**? Aparece no Gerenciador de Tarefas → Desempenho → GPU → "Memória dedicada da GPU".
- **Resolução e Hz** do monitor, e se ele tem **G-Sync/FreeSync**.
- Quantos **FPS** você está fazendo e em que lugar do jogo.

## Fontes

- [TechPowerUp — teste de desempenho](https://www.techpowerup.com/review/silent-hill-townfall-performance-benchmark/3.html)
- [Wccftech — análise e guia de ajustes no PC](https://wccftech.com/how-to/silent-hill-townfall-pc-performance-analysis-tuning-guide-how-to-get-the-best-experience-on-pc/)
- [DSOGaming — análise de desempenho no PC](https://www.dsogaming.com/pc-performance-analyses/silent-hill-townfall-benchmarks-pc-performance-analysis/)
- [GameGPU — teste com placas mais antigas em 1080p](https://en.gamegpu.com/news/igry/radeon-rx-vega-64-oboshla-gtx-1080-ti-v-silent-hill-townfall-pri-1080p)
- [Konami — notas do patch 1.4.0](https://www.konami.com/games/silenthill/townfall/updates/us/en/patch-note_v1-4-0)
- [OC3D — patch 1.3.1 contra travadas de shader](https://overclock3d.net/news/software/konami-battles-pc-stutter-with-silent-hill-townfalls-1-3-1-patch/)
- [DSOGaming — requisitos oficiais](https://www.dsogaming.com/news/official-pc-requirements-new-gameplay-for-silent-hill-townfall/)
