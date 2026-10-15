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

param([switch]$Recuperar)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

$EdgeGuid    = '{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}'
$WebViewGuid = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
$ProgX86     = ${env:ProgramFiles(x86)}
$UninstKey   = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge'
$DevKey      = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev'
$StubDir     = Join-Path $env:SystemRoot 'SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe'
$StubFile    = Join-Path $StubDir 'MicrosoftEdge.exe'
$StateDir    = Join-Path $env:ProgramData 'RemoverEdge'
$StateFile   = Join-Path $StateDir 'estado.txt'
$Desktop     = [Environment]::GetFolderPath('Desktop')
$LogFile     = Join-Path $Desktop 'RemoverEdge-log.txt'
$RestoreDesc = 'Antes de remover o Microsoft Edge'

function Write-Log([string]$Text) {
    $line = '[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Text
    try { Add-Content -LiteralPath $LogFile -Value $line -Encoding UTF8 } catch { }
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
# Estado dos destravamentos. Cada mudanca e anotada ANTES de ser feita,
# entao mesmo se a janela for fechada no meio, a proxima execucao (ou o
# reinstalar-edge.bat) desfaz tudo.
# ---------------------------------------------------------------------
function Save-State([hashtable]$State) {
    New-Item -ItemType Directory -Path $StateDir -Force | Out-Null
    $lines = foreach ($key in $State.Keys) { '{0}={1}' -f $key, $State[$key] }
    Set-Content -LiteralPath $StateFile -Value $lines -Encoding ASCII
}

function Undo-Unlock {
    if (-not (Test-Path -LiteralPath $StateFile)) { return }
    $s = @{}
    foreach ($line in (Get-Content -LiteralPath $StateFile)) {
        $i = $line.IndexOf('=')
        if ($i -gt 0) { $s[$line.Substring(0, $i)] = $line.Substring($i + 1) }
    }
    $ok = $true

    if ($s.ContainsKey('StubArquivoCriado') -and $s['StubArquivoCriado'] -eq '1') {
        try {
            if (Test-Path -LiteralPath $StubFile) { Remove-Item -LiteralPath $StubFile -Force }
            Write-Log 'Desfeito: arquivo vazio MicrosoftEdge.exe apagado.'
        } catch { $ok = $false; Write-Log "Falha ao apagar o arquivo vazio: $_" }
    }
    if ($s.ContainsKey('StubPastaCriada') -and $s['StubPastaCriada'] -eq '1') {
        try {
            if ((Test-Path -LiteralPath $StubDir) -and
                -not (Get-ChildItem -LiteralPath $StubDir -Force)) {
                Remove-Item -LiteralPath $StubDir -Force
                Write-Log 'Desfeito: pasta criada pelo script apagada.'
            }
        } catch { $ok = $false; Write-Log "Falha ao apagar a pasta criada: $_" }
    }
    if ($s.ContainsKey('AllowUninstallCriado') -and $s['AllowUninstallCriado'] -eq '1') {
        try {
            Remove-ItemProperty -Path $DevKey -Name 'AllowUninstall' -ErrorAction SilentlyContinue
            Write-Log 'Desfeito: valor AllowUninstall apagado.'
        } catch { $ok = $false; Write-Log "Falha ao apagar AllowUninstall: $_" }
    }
    if ($s.ContainsKey('DevKeyCriada') -and $s['DevKeyCriada'] -eq '1') {
        try {
            if (Test-Path -Path $DevKey) {
                $k = Get-Item -Path $DevKey
                if ($k.ValueCount -eq 0 -and $k.SubKeyCount -eq 0) {
                    Remove-Item -Path $DevKey -Force
                    Write-Log 'Desfeito: chave EdgeUpdateDev criada pelo script apagada.'
                }
            }
        } catch { $ok = $false; Write-Log "Falha ao apagar a chave EdgeUpdateDev: $_" }
    }

    if ($ok) {
        Remove-Item -LiteralPath $StateFile -Force -ErrorAction SilentlyContinue
        if ((Test-Path -LiteralPath $StateDir) -and -not (Get-ChildItem -LiteralPath $StateDir -Force)) {
            Remove-Item -LiteralPath $StateDir -Force -ErrorAction SilentlyContinue
        }
    } else {
        Say "Aviso: nem tudo foi desfeito. Rode o remover-edge.bat de novo depois." 'Yellow'
    }
}

function Set-Unlock {
    $state = @{ StubArquivoCriado = '0'; StubPastaCriada = '0'; AllowUninstallCriado = '0'; DevKeyCriada = '0' }
    Save-State $state

    # 1) AllowUninstall (texto vazio), so se ainda nao existir.
    if (-not (Test-Path -Path $DevKey)) {
        $state['DevKeyCriada'] = '1'; Save-State $state
        New-Item -Path $DevKey -Force | Out-Null
    }
    $existing = Get-ItemProperty -Path $DevKey -Name 'AllowUninstall' -ErrorAction SilentlyContinue
    if ($null -eq $existing) {
        $state['AllowUninstallCriado'] = '1'; Save-State $state
        New-ItemProperty -Path $DevKey -Name 'AllowUninstall' -Value '' -PropertyType String -Force | Out-Null
        Write-Log 'Destravamento: AllowUninstall criado.'
    } else {
        Write-Log 'AllowUninstall ja existia; nao foi alterado.'
    }

    # 2) Arquivo vazio do Edge antigo, so se ainda nao existir.
    if (-not (Test-Path -LiteralPath $StubDir)) {
        $state['StubPastaCriada'] = '1'; Save-State $state
        New-Item -ItemType Directory -Path $StubDir -Force | Out-Null
    }
    if (-not (Test-Path -LiteralPath $StubFile)) {
        $state['StubArquivoCriado'] = '1'; Save-State $state
        New-Item -ItemType File -Path $StubFile -Force | Out-Null
        Write-Log 'Destravamento: arquivo vazio MicrosoftEdge.exe criado.'
    } else {
        Write-Log 'MicrosoftEdge.exe antigo ja existia; nao foi alterado.'
    }
}

# ---------------------------------------------------------------------
# Desinstalador da Microsoft
# ---------------------------------------------------------------------
function Test-SafeUninstaller([hashtable]$U) {
    # Trava de seguranca: so aceita o setup.exe do NAVEGADOR, nunca o do WebView2.
    if ($null -eq $U) { return $false }
    if ($U.Exe -notmatch '\\Microsoft\\Edge\\Application\\') { return $false }
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

function Invoke-EdgeUninstall {
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
    $srKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
    $before = @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue | ForEach-Object { $_.SequenceNumber })
    $oldProp = Get-ItemProperty -Path $srKey -Name 'SystemRestorePointCreationFrequency' -ErrorAction SilentlyContinue
    try {
        # O Windows so cria 1 ponto a cada 24 h; libera so durante esta criacao.
        Set-ItemProperty -Path $srKey -Name 'SystemRestorePointCreationFrequency' -Value 0 -Type DWord
        Checkpoint-Computer -Description $RestoreDesc -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
    } catch {
        Write-Log "Checkpoint-Computer falhou: $_"
    } finally {
        try {
            if ($null -eq $oldProp) {
                Remove-ItemProperty -Path $srKey -Name 'SystemRestorePointCreationFrequency' -ErrorAction SilentlyContinue
            } else {
                Set-ItemProperty -Path $srKey -Name 'SystemRestorePointCreationFrequency' -Value $oldProp.SystemRestorePointCreationFrequency -Type DWord
            }
        } catch { Write-Log "Nao deu para restaurar SystemRestorePointCreationFrequency: $_" }
    }
    $after = @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue | ForEach-Object { $_.SequenceNumber })
    $new = @($after | Where-Object { $before -notcontains $_ })
    return ($new.Count -gt 0)
}

function Confirm-RestorePoint {
    Say 'Criando ponto de restauracao (pode levar alguns minutos)...'
    if (New-RestorePointChecked) { Say "Ponto de restauracao criado: '$RestoreDesc'." 'Green'; return $true }

    Say 'Nao foi possivel criar o ponto de restauracao.' 'Yellow'
    Say 'Normalmente e porque a "Protecao do Sistema" do Windows esta desligada.' 'Yellow'
    while ($true) {
        $r = (Read-Host 'Digite A para ativar a Protecao do Sistema e tentar de novo, C para continuar SEM ponto, ou S para sair').Trim().ToUpper()
        Write-Log "Resposta: $r"
        if ($r -eq 'A') {
            try {
                Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction Stop
                Write-Log "Protecao do Sistema ativada em $env:SystemDrive."
                Start-Sleep -Seconds 5
            } catch { Say "Nao deu para ativar a Protecao do Sistema: $_" 'Yellow'; continue }
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

# Sempre desfaz restos de uma execucao anterior interrompida.
Undo-Unlock
if ($Recuperar) { Write-Log 'Modo recuperar: concluido.'; exit 0 }

Write-Host ''
Write-Host '  Remover o Microsoft Edge (mantendo o WebView2)' -ForegroundColor Cyan
Write-Host '  ==============================================' -ForegroundColor Cyan
Write-Host ''

# --- Checagens ---------------------------------------------------------
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Say 'Este script precisa de permissao de administrador. Abra pelo remover-edge.bat.' 'Red'; exit 1 }
if ($id.IsSystem) { Say 'Nao rode como SYSTEM. Abra pelo remover-edge.bat com o seu usuario.' 'Red'; exit 1 }
if (-not [Environment]::Is64BitOperatingSystem -or $env:PROCESSOR_ARCHITECTURE -ne 'AMD64' -or -not [Environment]::Is64BitProcess) {
    Say 'Este script so foi feito para Windows 64 bits em processador Intel/AMD.' 'Red'; exit 1
}

$cv = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue
if ($null -ne $cv) {
    $disp = ''
    if ($cv.PSObject.Properties['DisplayVersion']) { $disp = $cv.DisplayVersion }
    Write-Log ("Windows: {0} {1} build {2}" -f $cv.ProductName, $disp, $cv.CurrentBuild)
}

$edgeExe = Get-EdgeExe
if (-not $edgeExe) {
    Say 'O navegador Edge nao foi encontrado neste PC. Nada a fazer.' 'Green'
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
$r = (Read-Host 'Digite S e aperte Enter para continuar (qualquer outra coisa cancela)').Trim().ToUpper()
Write-Log "Confirmacao: $r"
if ($r -ne 'S') { Say 'Cancelado. Nada foi alterado.' 'Yellow'; exit 0 }

# --- Ponto de restauracao ---------------------------------------------
if (-not (Confirm-RestorePoint)) { Say 'Cancelado. Nada foi alterado.' 'Yellow'; exit 0 }

# --- Desinstalacao -----------------------------------------------------
$exitCode = $null
try {
    Say 'Fechando o Edge...'
    Get-Process -Name 'msedge' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    Say 'Aplicando os destravamentos temporarios...'
    Set-Unlock

    Get-Process -Name 'msedge' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Say 'Rodando o desinstalador da Microsoft (pode levar 1 ou 2 minutos)...'
    $exitCode = Invoke-EdgeUninstall
    Start-Sleep -Seconds 3
} catch {
    Say "Erro durante a desinstalacao: $_" 'Red'
} finally {
    Say 'Desfazendo os destravamentos temporarios...'
    Undo-Unlock
}

# --- Resultado ---------------------------------------------------------
$removed = -not (Get-EdgeExe)
Write-Host ''
if ($removed) {
    Say 'Pronto: o navegador Microsoft Edge foi removido.' 'Green'
    Remove-EdgeShortcuts
} elseif ($exitCode -eq 93) {
    Say 'A Microsoft bloqueou a remocao nesta versao do Windows (codigo 93).' 'Yellow'
    Say 'Nada foi alterado: os destravamentos ja foram desfeitos e o Edge continua instalado.' 'Yellow'
    Say 'Veja no LEIAME.md o que da para fazer nesse caso.' 'Yellow'
} else {
    Say "Nao deu para confirmar a remocao (codigo $exitCode)." 'Yellow'
    Say 'Reinicie o PC e rode o remover-edge.bat de novo para conferir.' 'Yellow'
}

# --- Conferencia do WebView2 ------------------------------------------
$wvAfter = Get-WebView2Version
if ($wvAfter) {
    Say "WebView2 continua instalado (versao $wvAfter)." 'Green'
} elseif ($wvBefore) {
    Say 'ATENCAO: o WebView2 sumiu. Veja no LEIAME.md como reinstalar.' 'Red'
}
if (Get-Service -Name 'edgeupdate' -ErrorAction SilentlyContinue) {
    Write-Log 'Servico edgeupdate (atualizador do WebView2) continua presente.'
}

Write-Host ''
Say "Registro completo salvo em: $LogFile"
if ($removed) { Say 'Recomendado: reinicie o PC.' 'Cyan' }
