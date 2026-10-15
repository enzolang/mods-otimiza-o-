# remover-edge.ps1 - remove o navegador Microsoft Edge, mantendo o WebView2.
#
# Rode pelo remover-edge.bat (ele pede permissao de administrador).
# Este arquivo usa so caracteres ASCII de proposito (sem acentos).
#
# O que este script faz:
#   1. Cria um ponto de restauracao do Windows.
#   2. Usa o PROPRIO desinstalador da Microsoft (setup.exe do Edge), com
#      dois destravamentos leves que sao desfeitos no final:
#        - valor AllowUninstall em HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev
#        - arquivo vazio %SystemRoot%\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe
#   3. Se der certo, apaga os atalhos do Edge.
#
# O que este script NUNCA faz:
#   - remover o WebView2 (usado por varios programas e launchers);
#   - apagar o Edge Update, os servicos, tarefas ou pastas EdgeCore/EdgeWebView;
#   - mexer em pacotes Appx, WinSxS, regiao do Windows ou arquivos do System32;
#   - baixar ou rodar programas de terceiros.
#
# Toda mudanca temporaria e anotada ANTES de ser feita, na chave
# HKLM\SOFTWARE\RemoverEdge. Se a janela for fechada no meio, a proxima
# execucao (ou o reinstalar-edge.bat) desfaz o que ficou pendente.

param([switch]$Recuperar)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

$WebViewGuid = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
$ProgX86     = ${env:ProgramFiles(x86)}
$UninstKey   = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge'
$DevKey      = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev'
$SrKey       = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
$StubDir     = Join-Path $env:SystemRoot 'SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe'
$StubFile    = Join-Path $StubDir 'MicrosoftEdge.exe'
$StateKey    = 'HKLM:\SOFTWARE\RemoverEdge'
$Desktop     = [Environment]::GetFolderPath('Desktop')
if (-not $Desktop) { $Desktop = $env:ProgramData }
$script:LogFile = Join-Path $Desktop 'RemoverEdge-log.txt'
$RestoreDesc = 'Antes de remover o Microsoft Edge'

function Write-Log([string]$Text) {
    $line = '[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Text
    try { Add-Content -LiteralPath $script:LogFile -Value $line -Encoding UTF8 }
    catch {
        # Ex.: "Acesso a pastas controladas" do Defender bloqueia a Area de Trabalho.
        $script:LogFile = Join-Path $env:ProgramData 'RemoverEdge-log.txt'
        try { Add-Content -LiteralPath $script:LogFile -Value $line -Encoding UTF8 } catch { }
    }
}

function Say([string]$Text, [string]$Color = 'Gray') {
    Write-Host $Text -ForegroundColor $Color
    Write-Log $Text
}

function Get-EdgeExe {
    foreach ($p in @("$ProgX86\Microsoft\Edge\Application\msedge.exe",
                     "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe")) {
        if (Test-Path -LiteralPath $p) { return $p }
    }
    return $null
}

function Get-WebView2Version {
    foreach ($k in @("HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\$WebViewGuid",
                     "HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\$WebViewGuid",
                     "HKCU:\Software\Microsoft\EdgeUpdate\Clients\$WebViewGuid")) {
        $p = Get-ItemProperty -Path $k -Name pv -ErrorAction SilentlyContinue
        if ($null -ne $p -and $p.pv -and $p.pv -ne '0.0.0.0') { return [string]$p.pv }
    }
    return $null
}

# ---------------------------------------------------------------------
# Estado das mudancas temporarias (HKLM\SOFTWARE\RemoverEdge, so
# administradores podem escrever ali).
# ---------------------------------------------------------------------
function Set-StateFlag([string]$Name, [string]$Value) {
    if (-not (Test-Path -Path $StateKey)) { New-Item -Path $StateKey -Force | Out-Null }
    New-ItemProperty -Path $StateKey -Name $Name -Value $Value -PropertyType String -Force | Out-Null
}

function Get-StateFlag([string]$Name) {
    $p = Get-ItemProperty -Path $StateKey -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $p) { return $null }
    return [string]$p.$Name
}

function Clear-StateFlag([string]$Name) {
    if ($null -ne (Get-StateFlag $Name)) { Remove-ItemProperty -Path $StateKey -Name $Name }
}

# Devolve $true se nao sobrou nada pendente.
function Undo-Unlock {
    if (-not (Test-Path -Path $StateKey)) { return $true }
    $ok = $true

    # Frequencia dos pontos de restauracao.
    $freq = Get-StateFlag 'FrequenciaOriginal'
    if ($null -ne $freq) {
        try {
            if ($freq -eq 'ausente') {
                if (Get-ItemProperty -Path $SrKey -Name 'SystemRestorePointCreationFrequency' -ErrorAction SilentlyContinue) {
                    Remove-ItemProperty -Path $SrKey -Name 'SystemRestorePointCreationFrequency'
                }
            } else {
                Set-ItemProperty -Path $SrKey -Name 'SystemRestorePointCreationFrequency' -Value ([int]$freq) -Type DWord
            }
            Clear-StateFlag 'FrequenciaOriginal'
            Write-Log "Desfeito: SystemRestorePointCreationFrequency voltou para '$freq'."
        } catch { $ok = $false; Write-Log "Falha ao restaurar SystemRestorePointCreationFrequency: $_" }
    }

    # Arquivo vazio: so apaga se ainda estiver vazio (nunca um arquivo real).
    if ((Get-StateFlag 'StubArquivoCriado') -eq '1') {
        try {
            $f = Get-Item -LiteralPath $StubFile -Force -ErrorAction SilentlyContinue
            if ($null -ne $f -and $f.Length -eq 0) {
                Remove-Item -LiteralPath $StubFile -Force
                Write-Log 'Desfeito: arquivo vazio MicrosoftEdge.exe apagado.'
            } elseif ($null -ne $f) {
                Write-Log 'MicrosoftEdge.exe nao esta vazio (nao e o do script); NAO foi apagado.'
            }
            Clear-StateFlag 'StubArquivoCriado'
        } catch { $ok = $false; Write-Log "Falha ao apagar o arquivo vazio: $_" }
    }

    # Pasta: so apaga se foi criada pelo script e esta vazia.
    if ((Get-StateFlag 'StubPastaCriada') -eq '1' -and $null -ne (Get-StateFlag 'StubArquivoCriado')) {
        $ok = $false   # o arquivo vazio ainda nao saiu; a pasta fica anotada para a proxima vez
    } elseif ((Get-StateFlag 'StubPastaCriada') -eq '1') {
        try {
            if ((Test-Path -LiteralPath $StubDir) -and -not (Get-ChildItem -LiteralPath $StubDir -Force)) {
                Remove-Item -LiteralPath $StubDir -Force
                Write-Log 'Desfeito: pasta criada pelo script apagada.'
            }
            Clear-StateFlag 'StubPastaCriada'
        } catch { $ok = $false; Write-Log "Falha ao apagar a pasta criada: $_" }
    }

    if ((Get-StateFlag 'AllowUninstallCriado') -eq '1') {
        try {
            if (Get-ItemProperty -Path $DevKey -Name 'AllowUninstall' -ErrorAction SilentlyContinue) {
                Remove-ItemProperty -Path $DevKey -Name 'AllowUninstall'
            }
            Clear-StateFlag 'AllowUninstallCriado'
            Write-Log 'Desfeito: valor AllowUninstall apagado.'
        } catch { $ok = $false; Write-Log "Falha ao apagar AllowUninstall: $_" }
    }

    if ((Get-StateFlag 'DevKeyCriada') -eq '1' -and $null -ne (Get-StateFlag 'AllowUninstallCriado')) {
        $ok = $false   # AllowUninstall ainda nao saiu; a chave fica anotada para a proxima vez
    } elseif ((Get-StateFlag 'DevKeyCriada') -eq '1') {
        try {
            if (Test-Path -Path $DevKey) {
                $k = Get-Item -Path $DevKey
                if ($k.ValueCount -eq 0 -and $k.SubKeyCount -eq 0) {
                    Remove-Item -Path $DevKey -Force
                    Write-Log 'Desfeito: chave EdgeUpdateDev criada pelo script apagada.'
                }
            }
            Clear-StateFlag 'DevKeyCriada'
        } catch { $ok = $false; Write-Log "Falha ao apagar a chave EdgeUpdateDev: $_" }
    }

    if ($ok) {
        try {
            $k = Get-Item -Path $StateKey
            if ($k.ValueCount -eq 0 -and $k.SubKeyCount -eq 0) { Remove-Item -Path $StateKey -Force }
        } catch { Write-Log "Nao deu para apagar a chave de estado: $_" }
    }
    return $ok
}

function Set-Unlock {
    # 1) AllowUninstall (texto vazio), so se ainda nao existir.
    if (-not (Test-Path -Path $DevKey)) {
        Set-StateFlag 'DevKeyCriada' '1'
        New-Item -Path $DevKey -Force | Out-Null
    }
    if ($null -eq (Get-ItemProperty -Path $DevKey -Name 'AllowUninstall' -ErrorAction SilentlyContinue)) {
        Set-StateFlag 'AllowUninstallCriado' '1'
        New-ItemProperty -Path $DevKey -Name 'AllowUninstall' -Value '' -PropertyType String -Force | Out-Null
        Write-Log 'Destravamento: AllowUninstall criado.'
    } else {
        Write-Log 'AllowUninstall ja existia; nao foi alterado.'
    }

    # 2) Arquivo vazio do Edge antigo, so se ainda nao existir.
    if (-not (Test-Path -LiteralPath $StubDir)) {
        Set-StateFlag 'StubPastaCriada' '1'
        New-Item -ItemType Directory -Path $StubDir -Force | Out-Null
    }
    if (-not (Test-Path -LiteralPath $StubFile)) {
        Set-StateFlag 'StubArquivoCriado' '1'
        New-Item -ItemType File -Path $StubFile -Force | Out-Null
        Write-Log 'Destravamento: arquivo vazio MicrosoftEdge.exe criado.'
    } else {
        Write-Log 'MicrosoftEdge.exe antigo ja existia; nao foi alterado.'
    }
}

# ---------------------------------------------------------------------
# Desinstaladores
# ---------------------------------------------------------------------
function Test-SafeUninstaller([hashtable]$U) {
    # Trava de seguranca: so aceita o setup.exe do NAVEGADOR, em modo de
    # desinstalacao, e nunca o do WebView2.
    if ($null -eq $U) { return $false }
    if ($U.Exe -notmatch '\\Microsoft\\Edge\\Application\\\d+(\.\d+){3}\\Installer\\setup\.exe$') { return $false }
    if ($U.Args -notmatch '(^|\s)--uninstall(\s|$)') { return $false }
    if ($U.Exe -match 'EdgeWebView' -or $U.Args -match 'msedgewebview') { return $false }
    return (Test-Path -LiteralPath $U.Exe)
}

function Get-EdgeUninstaller {
    # 1) O comando que o proprio Edge registrou no Windows.
    $p = Get-ItemProperty -Path $UninstKey -Name 'UninstallString' -ErrorAction SilentlyContinue
    if ($null -ne $p -and $p.UninstallString) {
        $us = [string]$p.UninstallString
        Write-Log "UninstallString: $us"
        if ($us -match '^\s*"([^"]+)"\s*(.*)$' -or $us -match '^\s*(\S+\.exe)\s*(.*)$') {
            $u = @{ Exe = $Matches[1]; Args = ($Matches[2] + ' --force-uninstall').Trim() }
            if (Test-SafeUninstaller $u) { return $u }
            Write-Log 'UninstallString recusado pela trava de seguranca; tentando o setup.exe direto.'
        }
    }
    # 2) Plano B: setup.exe da versao mais nova instalada.
    $appDir = "$ProgX86\Microsoft\Edge\Application"
    if (Test-Path -LiteralPath $appDir) {
        $ver = Get-ChildItem -LiteralPath $appDir -Directory |
            Where-Object { $_.Name -match '^\d+(\.\d+){3}$' } |
            Sort-Object { [version]$_.Name } -Descending |
            Select-Object -First 1
        if ($ver) {
            $u = @{ Exe = (Join-Path $ver.FullName 'Installer\setup.exe')
                    Args = '--uninstall --msedge --channel=stable --system-level --verbose-logging --force-uninstall' }
            if (Test-SafeUninstaller $u) { return $u }
        }
    }
    return $null
}

# Edge instalado como MSI (por exemplo, reinstalado pelo winget).
function Get-EdgeMsiCodes {
    $codes = @()
    foreach ($base in @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
                        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall')) {
        foreach ($k in @(Get-ChildItem -Path $base -ErrorAction SilentlyContinue)) {
            if ($k.PSChildName -notmatch '^\{[0-9A-Fa-f-]{36}\}$') { continue }
            $name = [string]$k.GetValue('DisplayName')
            $us   = [string]$k.GetValue('UninstallString')
            if ($name -eq 'Microsoft Edge' -and $us -match 'MsiExec') { $codes += $k.PSChildName }
        }
    }
    return $codes
}

function Invoke-EdgeUninstall {
    foreach ($code in @(Get-EdgeMsiCodes)) {
        Write-Log "Edge registrado como MSI: $code. Rodando msiexec /X."
        $m = Start-Process -FilePath "$env:SystemRoot\System32\msiexec.exe" -ArgumentList "/qn /X$code REBOOT=ReallySuppress /norestart" -Wait -PassThru
        Write-Log "msiexec /X $code -> $($m.ExitCode)"
    }
    if (-not (Get-EdgeExe)) { return 0 }

    $u = Get-EdgeUninstaller
    if ($null -eq $u) { Say 'Nao encontrei o desinstalador do Edge.' 'Red'; return $null }
    Write-Log "Rodando: `"$($u.Exe)`" $($u.Args)"
    $proc = Start-Process -FilePath $u.Exe -ArgumentList $u.Args -Wait -PassThru
    Write-Log "Codigo de saida do desinstalador: $($proc.ExitCode)"
    return $proc.ExitCode
}

function Remove-EdgeShortcuts {
    $links = @(
        (Join-Path $env:PUBLIC 'Desktop\Microsoft Edge.lnk'),
        (Join-Path $Desktop 'Microsoft Edge.lnk'),
        (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk'),
        (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk'),
        (Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk'),
        (Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk'),
        (Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Tombstones\Microsoft Edge.lnk')
    )
    foreach ($l in $links) {
        if (Test-Path -LiteralPath $l) {
            try { Remove-Item -LiteralPath $l -Force; Write-Log "Atalho apagado: $l" }
            catch { Write-Log "Nao deu para apagar o atalho $l : $_" }
        }
    }
    foreach ($k in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
                     'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run')) {
        $item = Get-Item -Path $k -ErrorAction SilentlyContinue
        if ($null -eq $item) { continue }
        foreach ($name in $item.GetValueNames()) {
            if ($name -like 'MicrosoftEdgeAutoLaunch_*') {
                try { Remove-ItemProperty -Path $k -Name $name -Force; Write-Log "Inicializacao automatica removida: $name" }
                catch { Write-Log "Nao deu para remover $name : $_" }
            }
        }
    }
}

# ---------------------------------------------------------------------
# Ponto de restauracao
# ---------------------------------------------------------------------
function New-RestorePointChecked {
    $before = @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue | ForEach-Object { $_.SequenceNumber })
    $oldProp = Get-ItemProperty -Path $SrKey -Name 'SystemRestorePointCreationFrequency' -ErrorAction SilentlyContinue
    $old = 'ausente'
    if ($null -ne $oldProp) { $old = [string]$oldProp.SystemRestorePointCreationFrequency }
    try {
        # O Windows so cria 1 ponto a cada 24 h; libera so durante esta criacao.
        # O valor original e anotado antes, para ser devolvido mesmo se a janela fechar.
        if ($null -eq (Get-StateFlag 'FrequenciaOriginal')) { Set-StateFlag 'FrequenciaOriginal' $old }
        Set-ItemProperty -Path $SrKey -Name 'SystemRestorePointCreationFrequency' -Value 0 -Type DWord
        Checkpoint-Computer -Description $RestoreDesc -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
    } catch {
        Write-Log "Checkpoint-Computer falhou: $_"
    } finally {
        $null = Undo-Unlock
    }
    $after = @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue | ForEach-Object { $_.SequenceNumber })
    $new = @($after | Where-Object { $before -notcontains $_ })
    return ($new.Count -gt 0)
}

function Confirm-RestorePoint {
    Say 'Criando ponto de restauracao (pode levar alguns minutos; nao feche a janela)...'
    if (New-RestorePointChecked) { Say "Ponto de restauracao criado: '$RestoreDesc'." 'Green'; return $true }

    Say 'Nao foi possivel criar o ponto de restauracao.' 'Yellow'
    Say 'Normalmente e porque a "Protecao do Sistema" do Windows esta desligada.' 'Yellow'
    while ($true) {
        $r = [string](Read-Host 'Digite A para ativar a Protecao do Sistema e tentar de novo, C para continuar SEM ponto, ou S para sair')
        $r = $r.Trim().ToUpper()
        Write-Log "Resposta: $r"
        if ($r -eq 'A') {
            try {
                Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction Stop
                Write-Log "Protecao do Sistema ativada em $env:SystemDrive (por escolha do usuario)."
                Start-Sleep -Seconds 5
            } catch { Say "Nao deu para ativar a Protecao do Sistema: $_" 'Yellow'; continue }
            Say 'Criando ponto de restauracao...'
            if (New-RestorePointChecked) { Say "Ponto de restauracao criado: '$RestoreDesc'." 'Green'; return $true }
            Say 'Ainda nao foi possivel criar o ponto de restauracao.' 'Yellow'
        } elseif ($r -eq 'C') {
            Say 'Continuando sem ponto de restauracao, por escolha sua.' 'Yellow'
            return $true
        } elseif ($r -eq 'S') {
            return $false
        }
    }
}

# =====================================================================
# Inicio
# =====================================================================
Write-Log '===================================================='
Write-Log "Inicio. Parametro Recuperar=$Recuperar"

# Uma execucao por vez (duas janelas ao mesmo tempo atrapalhariam o estado).
$script:Trava = New-Object System.Threading.Mutex($false, 'Global\RemoverEdge')
$temTrava = $false
try { $temTrava = $script:Trava.WaitOne(0) } catch [System.Threading.AbandonedMutexException] { $temTrava = $true }
if (-not $temTrava) {
    Write-Host 'O remover-edge ja esta aberto em outra janela. Use so aquela e feche esta.' -ForegroundColor Yellow
    exit 3
}

# --- Checagens ---------------------------------------------------------
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Say 'Este script precisa de permissao de administrador. Abra pelo remover-edge.bat.' 'Red'; exit 1 }
if ($id.IsSystem) { Say 'Nao rode como SYSTEM. Abra pelo remover-edge.bat com o seu usuario.' 'Red'; exit 1 }
if (-not [Environment]::Is64BitOperatingSystem -or $env:PROCESSOR_ARCHITECTURE -ne 'AMD64' -or -not [Environment]::Is64BitProcess) {
    Say 'Este script so foi feito para Windows 64 bits em processador Intel/AMD.' 'Red'; exit 1
}

# Sempre desfaz restos de uma execucao anterior interrompida.
$limpezaOk = Undo-Unlock
if ($Recuperar) {
    Write-Log "Modo recuperar: concluido (ok=$limpezaOk)."
    if ($limpezaOk) { exit 0 } else { exit 1 }
}
if (-not $limpezaOk) {
    Say 'Restos de uma execucao anterior nao puderam ser desfeitos.' 'Red'
    Say 'Reinicie o PC e rode o remover-edge.bat de novo.' 'Red'
    exit 1
}

Write-Host ''
Write-Host '  Remover o Microsoft Edge (mantendo o WebView2)' -ForegroundColor Cyan
Write-Host '  ==============================================' -ForegroundColor Cyan
Write-Host ''

$cv = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue
if ($null -ne $cv) {
    $disp = ''
    if ($cv.PSObject.Properties['DisplayVersion']) { $disp = $cv.DisplayVersion }
    Write-Log ("Windows: {0} {1} build {2}" -f $cv.ProductName, $disp, $cv.CurrentBuild)
}

$edgeExe = Get-EdgeExe
if (-not $edgeExe) {
    Say 'O navegador Edge nao foi encontrado neste PC. Nada a remover.' 'Green'
    Remove-EdgeShortcuts
    exit 0
}
Write-Log "Edge encontrado: $edgeExe"

$wvBefore = Get-WebView2Version
if ($wvBefore) { Write-Log "WebView2 antes: $wvBefore" } else {
    Say 'Aviso: o WebView2 nao foi encontrado (isso nao tem relacao com este script).' 'Yellow'
}

# --- Confirmacao -------------------------------------------------------
Write-Host 'Antes de continuar, confira:'
Write-Host '  1. O Firefox (ou outro navegador) esta instalado e definido como padrao,'
Write-Host '     inclusive para abrir PDF.'
Write-Host '  2. O Windows Update esta em dia (sem atualizacao pendente).'
Write-Host '  3. Seus favoritos e senhas do Edge ja foram importados para o Firefox.'
Write-Host ''
Write-Host 'Este script vai:'
Write-Host '  - criar um ponto de restauracao do Windows;'
Write-Host '  - fechar o Edge e rodar o desinstalador da propria Microsoft;'
Write-Host '  - manter o WebView2 e o atualizador dele (outros programas precisam).'
Write-Host ''
$r = [string](Read-Host 'Digite S e aperte Enter para continuar (qualquer outra coisa cancela)')
$r = $r.Trim().ToUpper()
Write-Log "Confirmacao: $r"
if ($r -ne 'S') { Say 'Cancelado. Nada foi alterado.' 'Yellow'; exit 0 }

# --- Ponto de restauracao ---------------------------------------------
if (-not (Confirm-RestorePoint)) { $null = Undo-Unlock; Say 'Cancelado. O Edge nao foi mexido.' 'Yellow'; exit 0 }

# --- Desinstalacao -----------------------------------------------------
$exitCode = $null
$erroInterno = $null
$undoOk = $true
try {
    Say 'Fechando o Edge...'
    Get-Process -Name 'msedge' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    Say 'Aplicando os destravamentos temporarios...'
    Set-Unlock

    Get-Process -Name 'msedge' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Say 'Rodando o desinstalador da Microsoft (pode levar 1 ou 2 minutos; nao feche a janela)...'
    $exitCode = Invoke-EdgeUninstall
    Start-Sleep -Seconds 3
} catch {
    $erroInterno = "$_"
    Say "Erro durante a desinstalacao: $_" 'Red'
} finally {
    Say 'Desfazendo os destravamentos temporarios...'
    $undoOk = Undo-Unlock
}

# --- Resultado ---------------------------------------------------------
$removed = -not (Get-EdgeExe)
$naoUse = 'NAO use outros removedores de Edge da internet: varios apagam o WebView2 ou travam o Windows Update.'
Write-Host ''
if ($removed) {
    Say 'Pronto: o navegador Microsoft Edge foi removido.' 'Green'
    Remove-EdgeShortcuts
} elseif ($exitCode -eq 93) {
    Say 'A Microsoft bloqueou a remocao nesta versao do Windows (codigo 93).' 'Yellow'
    if ($undoOk) {
        Say 'O Edge continua instalado e os destravamentos ja foram desfeitos.' 'Yellow'
    } else {
        Say 'O Edge continua instalado, mas nem tudo foi desfeito: rode o remover-edge.bat de novo' 'Yellow'
        Say '(ele limpa os restos logo no comeco; depois e so digitar N para sair).' 'Yellow'
    }
    Say 'Veja no LEIAME.md (abra com o Bloco de Notas) a secao "Se nao der certo".' 'Yellow'
    Say $naoUse 'Yellow'
} elseif ($erroInterno -or $null -eq $exitCode) {
    Say 'O desinstalador da Microsoft nao chegou a rodar; nada foi removido.' 'Yellow'
    Say 'Veja no LEIAME.md (abra com o Bloco de Notas) a secao "Se nao der certo".' 'Yellow'
    Say $naoUse 'Yellow'
} elseif ($exitCode -eq 19 -or $exitCode -eq 29) {
    Say "O desinstalador terminou (codigo $exitCode), mas alguns arquivos so serao apagados depois de reiniciar." 'Yellow'
    Say 'Reinicie o PC e rode o remover-edge.bat UMA vez para conferir.' 'Yellow'
} else {
    Say "Nao deu para confirmar a remocao (codigo $exitCode)." 'Yellow'
    Say 'Reinicie o PC e rode o remover-edge.bat UMA vez para conferir.' 'Yellow'
    Say 'Se o Edge continuar instalado, siga a secao "Se nao der certo" do LEIAME.md (abra com o Bloco de Notas).' 'Yellow'
    Say $naoUse 'Yellow'
}

if (-not $undoOk -and ($removed -or $exitCode -ne 93)) {
    Say 'Aviso: nem todos os destravamentos temporarios foram desfeitos.' 'Yellow'
    Say 'Reinicie o PC e rode o remover-edge.bat mais uma vez: ele limpa os restos logo no comeco.' 'Yellow'
}

# --- Conferencia do WebView2 ------------------------------------------
$wvAfter = Get-WebView2Version
if ($wvAfter) {
    Say "WebView2 continua instalado (versao $wvAfter)." 'Green'
} elseif ($wvBefore) {
    Say 'ATENCAO: o WebView2 sumiu. Veja no LEIAME.md (abra com o Bloco de Notas) como reinstalar.' 'Red'
}
if (Get-Service -Name 'edgeupdate' -ErrorAction SilentlyContinue) {
    Write-Log 'Servico edgeupdate (atualizador do WebView2) continua presente.'
}

Write-Host ''
Say "Registro completo salvo em: $script:LogFile"
if ($removed) { Say 'Recomendado: reinicie o PC.' 'Cyan' }
