# Remover o Microsoft Edge (mantendo o WebView2)

Feito para: **Windows 10 ou 11 de 64 bits**, PC no Brasil, com o **Firefox** como navegador.

## Antes de tudo: o que esperar

- **Fora da Europa, a Microsoft não deixa desinstalar o Edge.** Este pacote usa o **próprio desinstalador da Microsoft**, com dois "destravamentos" leves e temporários. São os mesmos usados pelas ferramentas mais conhecidas em 2026.
- **Pode não funcionar no seu PC.** Em parte dos computadores com Windows 11 versão 25H2, a Microsoft bloqueia mesmo assim (o "código 93"). Nesse caso o script **desfaz tudo e avisa**, e nada fica alterado.
- **Não uso métodos mais agressivos**, como mexer em arquivos do System32, trocar a região do Windows ou apagar pacotes do sistema. Em outros PCs, esses métodos já travaram o Windows Update e corromperam arquivos do Windows.
- **O Edge pode voltar** depois de uma atualização grande do Windows. Se voltar, é só rodar de novo.

### O que continua funcionando

O **WebView2** fica intacto. É um "pedaço" do Edge que muitos programas usam por dentro, mesmo sem o navegador: Teams, Outlook novo, Office, app Xbox, Fotos, Widgets e vários launchers. A própria Microsoft diz que o Edge pode ser removido sem atrapalhar o WebView2. O atualizador do WebView2 (Edge Update) também fica, para ele continuar recebendo atualizações de segurança.

A Steam e os jogos não dependem do Edge.

### O que muda depois da remoção

- **Resultados da internet na pesquisa do menu Iniciar** e **links de notícias dos Widgets** param de abrir, porque o Windows força esses links a abrirem no Edge, ignorando o Firefox.
- A tecla **F1** (ajuda do Windows) e alguns links "Saiba mais" das Configurações também param de abrir.
- **PDFs:** se o Edge era o programa que abria PDF, você precisa escolher outro (Passo 1).
- O **Copilot** pode parar de funcionar.

## Passo 1 — Prepare o Firefox e o Windows

1. **Traga seus dados do Edge:** no Firefox, aperte `Ctrl + Shift + O` → **Importar e fazer backup** → **Importar dados de outro navegador** → **Microsoft Edge**. Faça isso **antes** de remover.
2. **Firefox como navegador padrão:**
   - **Windows 11:** Configurações → Aplicativos → Aplicativos padrão → **Firefox** → botão **Definir padrão**. Na mesma tela, procure **.pdf** e escolha o Firefox (ou outro leitor de PDF).
   - **Windows 10:** Configurações → Aplicativos → Aplicativos padrão → **Navegador da Web** → Firefox.
3. **Windows Update em dia:** Configurações → Windows Update → instale tudo e reinicie. Remover o Edge com atualização pendente já causou Windows Update travado em outros PCs.

## Passo 2 — Rodar o removedor

1. Coloque os **3 arquivos** (`remover-edge.bat`, `remover-edge.ps1`, `reinstalar-edge.bat`) juntos numa pasta **do próprio PC**, por exemplo na Área de Trabalho ou em Downloads. Não use pen drive.
2. **Se você baixou os arquivos da internet:** clique com o botão direito em cada um → **Propriedades** → marque **Desbloquear** → OK. Sem isso, o Windows pode impedir que eles rodem.
3. Dê dois cliques em **`remover-edge.bat`**. O Windows vai perguntar se permite alterações: clique em **Sim**.
4. Leia a tela, digite **S** e aperte Enter.
5. O script cria um **ponto de restauração** do Windows, o que pode levar alguns minutos. Se a "Proteção do Sistema" estiver desligada, ele pergunta o que fazer:
   - **A**: ativar e tentar de novo (**recomendado**);
   - **C**: continuar sem ponto de restauração;
   - **S**: sair sem mudar nada.
6. No final aparece uma de duas mensagens:
   - **"Pronto: o navegador Microsoft Edge foi removido."** Reinicie o PC.
   - **"A Microsoft bloqueou a remoção nesta versão do Windows."** Nada foi alterado; veja a seção abaixo.

Tudo o que o script fez fica registrado no arquivo **`RemoverEdge-log.txt`**, na sua Área de Trabalho.

> Se o Windows mostrar "O Windows protegeu o computador", clique em **Mais informações → Executar assim mesmo**. Os arquivos são texto puro: abra no Bloco de Notas para conferir antes, se quiser. **Não desative o antivírus** para rodar. Se ele reclamar, me avise.

## Se a Microsoft bloquear (código 93)

Nada foi alterado no PC. Nesse caso, o melhor é deixar o Edge instalado, mas **"quieto"**, para ele não gastar memória nem processador enquanto você joga:

1. Abra o Edge → **Configurações** → **Sistema e desempenho**.
2. Desligue **Aumento de inicialização** (*Startup boost*).
3. Desligue **Continuar executando extensões e aplicativos em segundo plano quando o Microsoft Edge for fechado**.
4. No **Gerenciador de Tarefas** → **Aplicativos de inicialização**, desabilite o Microsoft Edge, se ele aparecer.

Os nomes das opções podem variar um pouco conforme a versão do Edge.

> **Não recomendo** outros "removedores de Edge" da internet. Vários apagam o WebView2 junto, o que quebra programas, ou mexem em arquivos do sistema, o que já travou o Windows Update em outros PCs.

## Desfazer

- **`reinstalar-edge.bat`:** reinstala o Edge pelo **winget**, o instalador oficial de programas da Microsoft. Se o winget não funcionar, ele abre a página oficial de download do Edge.
- **Ponto de restauração:** menu Iniciar → digite `rstrui` → Enter → escolha **"Antes de remover o Microsoft Edge"**. Depois de restaurar, alguns apps da Microsoft Store podem dar erro por um tempo; rodar o Windows Update resolve.

## Problemas comuns

| Sintoma | O que fazer |
|---|---|
| O Windows Update falha várias vezes seguidas depois da remoção (por exemplo, erro 0x800f0922) | Rode o `reinstalar-edge.bat`, instale as atualizações e, se quiser, remova o Edge de novo depois. |
| O Edge voltou sozinho | Foi uma atualização grande do Windows. Rode o `remover-edge.bat` de novo. |
| Um programa reclama que falta o WebView2 | Abra o Terminal como administrador e rode `winget install --id Microsoft.EdgeWebView2Runtime -e`, ou baixe em https://developer.microsoft.com/microsoft-edge/webview2/ |
| A pesquisa do menu Iniciar não abre resultados da internet | É esperado sem o Edge. Pesquise direto no Firefox. |
| A janela fechou no meio | Rode o `remover-edge.bat` de novo. Ele desfaz sozinho o que ficou pela metade antes de qualquer outra coisa. |

## O que o script faz, tecnicamente

1. Confere se tem permissão de administrador, se o Windows é de 64 bits e se o Edge está instalado.
2. Anota a versão do WebView2 para conferir no final.
3. Cria o ponto de restauração.
4. Fecha o Edge (só o navegador, `msedge.exe`).
5. Aplica dois destravamentos temporários, anotando cada um antes num arquivo de estado em `C:\ProgramData\RemoverEdge`:
   - o valor `AllowUninstall` em `HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev`, só se ele ainda não existir;
   - um arquivo vazio `MicrosoftEdge.exe` em `C:\Windows\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe`, só se ele ainda não existir.
6. Roda o desinstalador oficial do Edge (`setup.exe --uninstall ... --force-uninstall`), com uma trava que impede rodar o desinstalador do WebView2.
7. **Sempre** desfaz os dois destravamentos, dando certo ou não.
8. Se o Edge foi removido, apaga os atalhos dele e a inicialização automática.
9. Confere se o WebView2 continua instalado.

**Nunca:** remove o WebView2 nem o Edge Update; apaga serviços, tarefas ou as pastas `EdgeCore`/`EdgeWebView`; mexe em pacotes do sistema, WinSxS, região do Windows ou arquivos do System32; baixa programas de terceiros.

## Fontes

- [Microsoft — WebView2: perguntas frequentes](https://github.com/MicrosoftDocs/edge-developer/blob/main/microsoft-edge/webview2/concepts/end-user-faq.md) ("Microsoft Edge can be uninstalled without causing a problem for WebView2")
- [Win11Debloat](https://github.com/Raphire/Win11Debloat) e [winutil](https://github.com/ChrisTitusTech/winutil): ferramentas mantidas que usam a mesma técnica
- [EdgeRemover — relato de bloqueio no 25H2](https://github.com/he3als/EdgeRemover/issues/19)
- [Remove-MS-Edge — aviso sobre o Windows Update](https://github.com/ShadowWhisperer/Remove-MS-Edge)
