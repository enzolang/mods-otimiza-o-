# Remover o Microsoft Edge (mantendo o WebView2)

Feito para: **Windows 10 ou 11 de 64 bits**, PC no Brasil, com o **Firefox** como navegador.

## Antes de tudo: o que esperar

- **Fora da Europa, a Microsoft não deixa desinstalar o Edge.** Este pacote usa o **próprio desinstalador da Microsoft**, com dois "destravamentos" leves e temporários. São os mesmos usados pelas ferramentas mais conhecidas em 2026.
- **Pode não funcionar no seu PC.** Em parte dos computadores com Windows 11 versão 25H2, a Microsoft bloqueia mesmo assim (o "código 93"). Nesse caso o script **desfaz os destravamentos e avisa**: o Edge continua como estava, e só fica o ponto de restauração que foi criado.
- **Não uso métodos mais agressivos**, como mexer em arquivos do System32, trocar a região do Windows ou apagar pacotes do sistema. Em outros PCs, esses métodos já travaram o Windows Update e corromperam arquivos do Windows.
- **O Edge pode voltar** depois de uma atualização grande do Windows. Se voltar, é só rodar de novo.

### O que continua funcionando

O **WebView2** fica intacto. É um "pedaço" do Edge que muitos programas usam por dentro, mesmo sem o navegador: Teams, Outlook novo, Office, app Xbox, Fotos, Widgets e vários launchers. A própria Microsoft diz que o Edge pode ser removido sem atrapalhar o WebView2. O atualizador do WebView2 (Edge Update) também fica, para ele continuar recebendo atualizações de segurança.

A Steam e os jogos não dependem do Edge.

### O que muda depois da remoção

- **Resultados da internet na pesquisa do menu Iniciar** e **links de notícias dos Widgets** param de abrir, porque o Windows força esses links a abrirem no Edge, ignorando o Firefox.
- A tecla **F1** (ajuda do Windows) e alguns links "Saiba mais" das Configurações também param de abrir.
- **Links no Outlook novo e no Teams** podem estar configurados para abrir no Edge e param de abrir. Nas configurações de cada um, procure a opção de abrir links (em "Arquivos e links") e escolha **Navegador padrão**.
- **PDFs:** se o Edge era o programa que abria PDF, você precisa escolher outro (Passo 1).
- O **Copilot** pode parar de funcionar.

## Passo 1 — Prepare o Firefox e o Windows

1. **Traga seus dados do Edge:** no Firefox, aperte `Ctrl + Shift + O` → **Importar e backup** → **Importar dados de outro navegador** → **Microsoft Edge** → **Importar**. Faça isso **antes** de remover.
2. **Firefox como navegador padrão:**
   - **Windows 11:** Configurações → Aplicativos → Aplicativos padrão → **Firefox** → botão **Definir padrão**. Na mesma tela, procure **.pdf** e escolha o Firefox (ou outro leitor de PDF). Se o Windows perguntar se você quer mesmo trocar, clique em **Alternar assim mesmo**.
   - **Windows 10:** Configurações → Aplicativos → Aplicativos padrão → **Navegador da Web** → Firefox. Depois, na mesma tela, clique em **Escolher aplicativos padrão por tipo de arquivo**, procure **.pdf** e escolha o Firefox (ou outro leitor de PDF).
3. **Windows Update em dia:** Configurações → Windows Update (no Windows 10: Configurações → Atualização e Segurança → Windows Update) → instale tudo e reinicie. Remover o Edge com atualização pendente já causou Windows Update travado em outros PCs.

## Passo 2 — Rodar o removedor

1. **Se os arquivos vieram num .zip:** clique com o botão direito no .zip → **Propriedades** → marque **Desbloquear**, se a opção aparecer → OK. Depois, botão direito no .zip → **Extrair tudo**. Não rode nada de dentro do .zip.
2. Deixe os **3 arquivos** (`remover-edge.bat`, `remover-edge.ps1`, `reinstalar-edge.bat`) juntos numa pasta **do próprio PC**, por exemplo na Área de Trabalho ou em Downloads. Não use pen drive. Se você baixou os arquivos soltos (sem .zip), faça o **Desbloquear** em cada um, se a opção aparecer.
3. Dê dois cliques em **`remover-edge.bat`**.
   - Se aparecer a tela azul **"O Windows protegeu o computador"**, clique em **Mais informações → Executar assim mesmo**. Se esse botão não existir, faça o **Desbloquear** do item anterior e tente de novo.
   - Quando o Windows perguntar se permite alterações, clique em **Sim**.
4. Leia a tela, digite **S** e aperte Enter.
5. O script cria um **ponto de restauração** do Windows, o que pode levar alguns minutos. **Não feche a janela.** Se a "Proteção do Sistema" estiver desligada, ele pergunta o que fazer:
   - **A**: ligar a Proteção do Sistema e tentar de novo (**recomendado**; ela fica ligada depois e ocupa um pouco de espaço no disco);
   - **C**: continuar sem ponto de restauração;
   - **S**: sair sem mudar nada.
6. No final aparece uma destas mensagens (o script escreve sem acentos):
   - **"Pronto: o navegador Microsoft Edge foi removido."** Reinicie o PC.
   - **"A Microsoft bloqueou a remocao nesta versao do Windows (codigo 93)."** O Edge continua como estava; veja a seção "Se não der certo".
   - **"O desinstalador terminou (codigo 19 ou 29)..."** Reinicie o PC e rode o `remover-edge.bat` mais **uma** vez para conferir.
   - **"Nao deu para confirmar a remocao"** ou **"O desinstalador da Microsoft nao chegou a rodar"**: reinicie o PC e rode mais **uma** vez. Se a mensagem se repetir, **não insista**: siga a seção "Se não der certo" e me mande o arquivo de registro.

Tudo o que o script fez fica registrado no arquivo **`RemoverEdge-log.txt`**, na sua Área de Trabalho. Se o antivírus bloquear a Área de Trabalho, o arquivo vai para `C:\ProgramData`. O caminho certo aparece no fim da tela.

> Os arquivos são texto puro: abra no Bloco de Notas para conferir antes, se quiser. **Não desative o antivírus** para rodar. Se ele reclamar, me avise.

## Se não der certo

Se a Microsoft bloquear (código 93) ou a remoção não funcionar mesmo depois de reiniciar, o melhor é deixar o Edge instalado, mas **"quieto"**, para ele não gastar memória nem processador enquanto você joga:

1. Abra o Edge, digite `edge://settings/system` na barra de endereço e aperte Enter (é a página **Configurações → Sistema e desempenho**).
2. Desligue **Aumento de inicialização** (*Startup boost*).
3. Desligue **Continuar executando extensões e aplicativos em segundo plano quando o Microsoft Edge for fechado**.
4. No **Gerenciador de Tarefas** (`Ctrl + Shift + Esc`) → aba **Aplicativos de inicialização** (no Windows 10 a aba se chama **Inicializar**), desabilite o Microsoft Edge, se ele aparecer.

Os nomes das opções podem variar um pouco conforme a versão do Edge.

> **Não use outros "removedores de Edge" da internet.** Vários apagam o WebView2 junto, o que quebra programas, ou mexem em arquivos do sistema, o que já travou o Windows Update em outros PCs.

## Desfazer

- **`reinstalar-edge.bat`:** reinstala o Edge pelo **winget**, o instalador oficial de programas da Microsoft. Se o winget não funcionar, ele abre a página oficial de download do Edge.
- **Ponto de restauração:** menu Iniciar → digite `rstrui` → Enter → escolha **"Antes de remover o Microsoft Edge"**. Depois de restaurar, alguns apps da Microsoft Store podem dar erro por um tempo; rodar o Windows Update resolve.

## Problemas comuns

| Sintoma | O que fazer |
|---|---|
| O Windows Update falha várias vezes seguidas depois da remoção (por exemplo, erro 0x800f0922) | Rode o `reinstalar-edge.bat`, reinicie e instale as atualizações. Se ainda falhar: clique com o botão direito no botão Iniciar → **Terminal (Admin)** (no Windows 10: **Windows PowerShell (Admin)**), rode `sfc /scannow` e depois `DISM /Online /Cleanup-Image /RestoreHealth`, reinicie e tente de novo. Último recurso: o ponto de restauração (seção Desfazer). |
| O Edge voltou sozinho | Foi uma atualização grande do Windows. Rode o `remover-edge.bat` de novo. |
| Um programa reclama que falta o WebView2 | Clique com o botão direito no botão Iniciar → **Terminal (Admin)** (no Windows 10: **Windows PowerShell (Admin)**) e rode `winget install --id Microsoft.EdgeWebView2Runtime -e`, ou baixe em https://developer.microsoft.com/microsoft-edge/webview2/consumer/ |
| A pesquisa do menu Iniciar não abre resultados da internet | É esperado sem o Edge. Pesquise direto no Firefox. |
| A janela fechou no meio | Rode o `remover-edge.bat` de novo. Antes de qualquer outra coisa, ele desfaz sozinho o que ficou pela metade. Depois, se não quiser continuar, é só digitar qualquer coisa diferente de S. |
| "O remover-edge ja esta aberto em outra janela" | Você abriu duas vezes. Use só a primeira janela. |

## O que o script faz, tecnicamente

1. Confere se tem permissão de administrador, se o Windows é de 64 bits e se só uma janela dele está aberta.
2. Desfaz restos de uma execução anterior interrompida, se houver.
3. Anota a versão do WebView2 para conferir no final.
4. Cria o ponto de restauração. Para isso, zera por alguns instantes o valor `SystemRestorePointCreationFrequency` em `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore` (senão o Windows só cria 1 ponto a cada 24 h) e depois devolve o valor original. Se você escolher **A**, a Proteção do Sistema do disco do Windows fica ligada.
5. Fecha o Edge (só o navegador, `msedge.exe`).
6. Aplica dois destravamentos temporários:
   - o valor `AllowUninstall` em `HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev`, só se ele ainda não existir;
   - um arquivo vazio `MicrosoftEdge.exe` em `C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe`, só se ele ainda não existir.

   Cada mudança temporária (inclusive a do item 4) é anotada **antes** de ser feita na chave `HKLM\SOFTWARE\RemoverEdge`, para poder ser desfeita mesmo se a janela fechar.
7. Se o Edge foi instalado como MSI (por exemplo, reinstalado pelo winget), remove esse registro com o `msiexec`.
8. Roda o desinstalador oficial do Edge (`setup.exe --uninstall ... --force-uninstall`), com uma trava que só aceita o `setup.exe` do navegador e nunca o do WebView2.
9. **Sempre** desfaz os destravamentos, dando certo ou não. O arquivo vazio só é apagado se ainda estiver vazio.
10. Se o Edge foi removido, apaga os atalhos dele e a inicialização automática.
11. Confere se o WebView2 continua instalado.

**Nunca:** remove o WebView2 nem o Edge Update; apaga serviços, tarefas ou as pastas `EdgeCore`/`EdgeWebView`; mexe em pacotes do sistema, WinSxS, região do Windows ou arquivos do System32; baixa programas de terceiros.

## Fontes

Links só para consulta. **Não baixe nem rode** ferramentas desses sites.

- [Microsoft — WebView2: perguntas frequentes](https://learn.microsoft.com/microsoft-edge/webview2/concepts/end-user-faq) ("Microsoft Edge can be uninstalled without causing a problem for WebView2")
- [Win11Debloat](https://github.com/Raphire/Win11Debloat) e [winutil](https://github.com/ChrisTitusTech/winutil): ferramentas mantidas que usam a mesma técnica
- [EdgeRemover — relato de bloqueio no 25H2](https://github.com/he3als/EdgeRemover/issues/19)
- [Relato de Windows Update falhando (0x800f0922) depois de remover o Edge](https://github.com/ShadowWhisperer/Remove-MS-Edge/issues/63)
