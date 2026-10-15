# Silent Hill 2 (Remake) — guia de otimização para PC

O Silent Hill 2 Remake roda na Unreal Engine 5 e tem dois problemas conhecidos no PC:

1. **FPS baixo:** a iluminação (Lumen) e as sombras pesam muito.
2. **Travadas ao andar pela cidade (*stutter*):** acontecem quando o jogo carrega áreas novas.

Nenhum ajuste elimina 100% das travadas, porque parte delas vem do próprio motor do jogo. Seguindo os passos abaixo na ordem, a melhora costuma ser bem grande.

> Este guia é para o **Remake (2024, Steam)**, não para o Silent Hill 2 original de 2001.

---

## Passo 1 — Configurações dentro do jogo (o que mais faz diferença)

Os nomes podem variar um pouco conforme a versão do jogo.

| Opção | Recomendado | Por quê |
|---|---|---|
| **Ray Tracing** | **Desligado** | Opção que mais derruba o FPS. |
| **Upscaler** | **DLSS** (placas NVIDIA RTX), **FSR 3** (AMD ou NVIDIA GTX), **XeSS** (Intel Arc) | Renderiza em resolução menor e reconstrói a imagem. É o maior ganho de FPS "de graça". |
| **Qualidade do upscaler** | **Qualidade** em 1080p; **Equilibrado** em 1440p/4K | Abaixo disso a imagem fica borrada. |
| **Geração de quadros** (Frame Generation) | Só ligue se o jogo já passar de **~50–60 FPS** sem ela | Em FPS baixo ela aumenta o atraso dos controles e cria artefatos. |
| **Sombras** | **Média** | Ganho grande, diferença visual pequena. |
| **Shaders / Sombreamento** | **Média** | Idem. |
| **Texturas** | **Alta** com 8 GB de VRAM ou mais; **Média** com 6 GB ou menos | Quase não afeta o FPS, mas estourar a VRAM causa travadas. |
| **Efeitos** | **Alta** | Pesa pouco. |
| **SSAO / SSR / SSS** (oclusão, reflexos, pele) | **Média**; **Baixa** em placas fracas | Ganho moderado. |
| **HZB Culling** (oclusão HZB) | Em placas **AMD ou Intel** com travadas, **experimente desligar** | A Bloober colocou essa opção justamente para reduzir travadas nessas placas. |
| **Limitador de FPS do jogo** | **Desligado** (veja o Passo 3) | O limitador interno gera tempos de quadro irregulares. |

Comece por esse conjunto. Se sobrar desempenho, suba **uma opção por vez**.

## Passo 2 — Ajustes do Engine.ini (reduz travadas)

O arquivo `Engine.ini` desta pasta tem ajustes da Unreal Engine que:

- guardam os shaders compilados em disco, para o jogo não recompilar (e travar) toda vez que um efeito aparece;
- quebram o carregamento de áreas novas em pedaços menores, evitando picos ao andar pela cidade;
- evitam uma pausa longa de limpeza de memória logo depois que uma área sai da memória;
- impedem que as texturas usem mais memória de vídeo do que a placa tem;
- removem a aberração cromática (bordas coloridas). Se preferir o visual original, apague essa linha.

Cada linha do arquivo tem um comentário explicando o que faz.

### Instalação automática (recomendada)

1. Abra o jogo **pelo menos uma vez** até o menu principal e feche.
2. Baixe **a pasta inteira** `silent-hill-2-remake` e extraia o `.zip`, se for o caso. O script precisa do `Engine.ini` ao lado dele.
3. Dê dois cliques em **`instalar.bat`**.

O script faz backup do seu `Engine.ini` atual e só depois acrescenta os ajustes no fim do arquivo. Se você rodar de novo, ele detecta que já instalou e não duplica nada.

> O Windows pode mostrar "O Windows protegeu o computador". Clique em **Mais informações → Executar assim mesmo**. Os scripts são texto puro: abra no Bloco de Notas e confira antes, se quiser.

### Instalação manual

1. Aperte `Win + R`, cole o caminho abaixo e dê Enter:
   ```
   %LOCALAPPDATA%\SilentHill2\Saved\Config\Windows
   ```
2. Faça uma cópia de segurança do `Engine.ini` que estiver lá.
3. Abra o `Engine.ini` no Bloco de Notas, cole **no final** todo o conteúdo do `Engine.ini` desta pasta e salve.

### Desfazer

Dê dois cliques em **`desinstalar.bat`**: ele restaura o backup original. Também dá para apagar manualmente tudo entre as linhas `SH2-OTIMIZACAO (inicio)` e `SH2-OTIMIZACAO (fim)`.

## Passo 3 — Limitar o FPS do jogo do jeito certo

FPS estável parece mais fluido do que FPS alto oscilando. Use um limitador **externo** em vez do limitador do jogo:

- **NVIDIA:** Painel de Controle NVIDIA → Gerenciar configurações 3D → Configurações de programa → Silent Hill 2 → **Taxa máxima de quadros**.
- **AMD:** Software Adrenalin → Jogos → Silent Hill 2 → **Frame Rate Target Control** ou **Radeon Chill** (mínimo = máximo).
- **Qualquer placa:** RivaTuner Statistics Server (RTSS), que vem junto com o MSI Afterburner.

Que valor usar:
- Com monitor **G-Sync/FreeSync**: 3 abaixo da taxa do monitor (ex.: 141 em 144 Hz), ou um valor que o PC sustente sem cair (ex.: 60).
- Sem G-Sync/FreeSync: **60** (ou 30 em PCs bem fracos) com V-Sync ligado.

> As **cutscenes rodam travadas em 30 FPS de propósito**: não é problema do seu PC. Existem mods da comunidade que removem esse limite, mas são opcionais e podem quebrar com atualizações do jogo.

## Passo 4 — Windows, drivers e hardware

- **Instale o jogo num SSD**, de preferência NVMe. Em HD as travadas ao andar pela cidade ficam muito piores. Na Steam: Propriedades → Arquivos instalados → **Mover pasta de instalação**.
- **Atualize o driver de vídeo** (NVIDIA App/GeForce Experience, AMD Adrenalin ou Intel Arc Control).
- **Primeira vez que abrir o jogo** (e depois de cada atualização do driver ou do jogo): deixe a compilação de shaders terminar antes de jogar. As primeiras áreas podem travar um pouco até o cache se formar.
- **Feche programas pesados** em segundo plano: navegador com vídeo, Discord com compartilhamento de tela, gravadores etc.
- **Notebook:** jogue **na tomada**, use o plano de energia **Melhor desempenho** e confirme que o jogo usa a **placa dedicada**: Configurações do Windows → Sistema → Tela → Elementos gráficos → Silent Hill 2 → **Alto desempenho**.
- **Memória RAM:** com 16 GB o jogo roda bem. Com 8 GB vai travar de qualquer jeito; feche tudo que puder.
- **Arquivos corrompidos:** Steam → Silent Hill 2 → Propriedades → Arquivos instalados → **Verificar integridade dos arquivos**.

## Problemas comuns

| Sintoma | O que fazer |
|---|---|
| Os ajustes "sumiram" depois de jogar | O jogo pode ter reescrito o arquivo. Rode o `instalar.bat` de novo. Se continuar acontecendo, clique com o botão direito no `Engine.ini` → Propriedades → marque **Somente leitura**. |
| Texturas borradas ou demorando a carregar | Ative a linha `r.Streaming.PoolSize` no `Engine.ini`, com o valor certo para a VRAM da sua placa. As instruções estão no próprio arquivo. |
| O jogo não abre depois dos ajustes | Rode o `desinstalar.bat` e me avise. |
| Continua travando muito | Confira se o jogo está num SSD e se a VRAM não está estourando (abaixe Texturas). Mande sua configuração para ajustar melhor. |

## Para ajustar ao seu PC

Com estas informações dá para indicar configurações bem mais precisas:

- Processador (CPU)
- Placa de vídeo (GPU) e quantidade de VRAM
- Memória RAM
- Resolução e taxa de atualização do monitor (ex.: 1080p 144 Hz)
- Tipo de disco onde o jogo está instalado (HD, SSD SATA ou NVMe)
