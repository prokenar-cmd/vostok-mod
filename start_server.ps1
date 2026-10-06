$ErrorActionPreference = "Stop"

$server  = $PSScriptRoot
$mysqld  = Join-Path $server "mariadb\bin\mysqld.exe"
$myini   = Join-Path $server "mariadb-data\my.ini"
$dataDir = Join-Path $server "mariadb-data"
$omp     = Join-Path $server "omp-server.exe"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "      VOSTOK PERFECT LOCAL STARTUP" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

function Test-Port3306 {
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $async = $client.BeginConnect("127.0.0.1", 3306, $null, $null)

        if(!$async.AsyncWaitHandle.WaitOne(300)) {
            $client.Close()
            return $false
        }

        $client.EndConnect($async)
        $client.Close()
        return $true
    }
    catch {
        return $false
    }
}

# ------------------------------------------------------------
# PREFLIGHT
# ------------------------------------------------------------

foreach($file in @($mysqld, $myini, $omp)) {
    if(!(Test-Path $file)) {
        Write-Host "[FAIL] Missing: $file" -ForegroundColor Red
        Read-Host "ENTER"
        exit 1
    }
}

if(!(Test-Path (Join-Path $dataDir "ibdata1"))) {
    Write-Host "[FAIL] MariaDB ibdata1 not found in:" -ForegroundColor Red
    Write-Host $dataDir
    Read-Host "ENTER"
    exit 1
}

Write-Host "[PASS] MariaDB executable" -ForegroundColor Green
Write-Host "[PASS] MariaDB data: $dataDir" -ForegroundColor Green
Write-Host "[PASS] MariaDB config: $myini" -ForegroundColor Green

# ------------------------------------------------------------
# DATABASE
# ------------------------------------------------------------

Write-Host ""
Write-Host "[DB] Checking 127.0.0.1:3306..." -ForegroundColor Yellow

if(Test-Port3306) {
    Write-Host "[DB] MariaDB already running." -ForegroundColor Green
}
else {
    Write-Host "[DB] Starting MariaDB..." -ForegroundColor Yellow

    $stdout = Join-Path $dataDir "vostok_mariadb_stdout.log"
    $stderr = Join-Path $dataDir "vostok_mariadb_stderr.log"

    Remove-Item $stdout -Force -ErrorAction SilentlyContinue
    Remove-Item $stderr -Force -ErrorAction SilentlyContinue

    $dbArgs = @(
        "--defaults-file=`"$myini`""
        "--datadir=`"$dataDir`""
    )

    $dbProcess = Start-Process `
        -FilePath $mysqld `
        -ArgumentList $dbArgs `
        -WorkingDirectory (Split-Path $mysqld) `
        -WindowStyle Hidden `
        -RedirectStandardOutput $stdout `
        -RedirectStandardError $stderr `
        -PassThru

    $ready = $false

    for($i = 0; $i -lt 40; $i++) {
        Start-Sleep -Milliseconds 500

        if(Test-Port3306) {
            $ready = $true
            break
        }

        if($dbProcess.HasExited) {
            break
        }
    }

    if(!$ready) {
        Write-Host ""
        Write-Host "[FAIL] MariaDB did not start." -ForegroundColor Red

        if(Test-Path $stderr) {
            Write-Host ""
            Write-Host "===== MariaDB STDERR =====" -ForegroundColor Yellow
            Get-Content $stderr -Tail 50
        }

        if(Test-Path $stdout) {
            Write-Host ""
            Write-Host "===== MariaDB STDOUT =====" -ForegroundColor Yellow
            Get-Content $stdout -Tail 50
        }

        Read-Host "ENTER"
        exit 1
    }

    Write-Host "[PASS] MariaDB listening on 127.0.0.1:3306" -ForegroundColor Green
}

# ------------------------------------------------------------
# OPEN.MP
# ------------------------------------------------------------

Write-Host ""

$existing = Get-Process -Name "omp-server" -ErrorAction SilentlyContinue

if($existing) {
    Write-Host "[SERVER] omp-server is already running." -ForegroundColor Yellow
    Write-Host "[SERVER] PID: $($existing.Id)"
    Read-Host "ENTER"
    exit 0
}

Write-Host "[SERVER] Starting VOSTOK PERFECT..." -ForegroundColor Cyan
Write-Host ""

Set-Location $server

& $omp

