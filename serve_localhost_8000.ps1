param(
    [ValidateSet("user", "developer")]
    [string]$Mode = "user"
)

$ErrorActionPreference = "Stop"
$BuildId = "STABLE-LOCALHOST-8000-USER-TEXT-CLEANUP"
$Port = 8000
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Url = "http://localhost:$Port/index.html?build=$Mode&v=$BuildId"

function Pause-End {
    Write-Host ""
    Read-Host "Press Enter to close this window"
}

function Get-ContentType([string]$Path) {
    $Ext = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
    switch ($Ext) {
        ".html" { return "text/html; charset=utf-8" }
        ".mp3"  { return "audio/mpeg" }
        ".css"  { return "text/css; charset=utf-8" }
        ".js"   { return "application/javascript; charset=utf-8" }
        ".json" { return "application/json; charset=utf-8" }
        ".png"  { return "image/png" }
        ".jpg"  { return "image/jpeg" }
        ".jpeg" { return "image/jpeg" }
        ".svg"  { return "image/svg+xml" }
        default { return "application/octet-stream" }
    }
}

Write-Host "============================================================"
Write-Host "Territorial - $Mode build"
Write-Host "Build: $BuildId"
Write-Host "============================================================"
Write-Host ""
Write-Host "Folder: $Root"
Write-Host "URL:    $Url"
Write-Host ""

if (!(Test-Path (Join-Path $Root "index.html"))) {
    Write-Host "ERROR: index.html is missing. Extract the ZIP first, then run the BAT from the extracted folder."
    Pause-End
    exit 1
}

try {
    $Listener = [System.Net.HttpListener]::new()
    $Listener.Prefixes.Add("http://localhost:$Port/")
    $Listener.Start()
} catch {
    Write-Host "ERROR: PowerShell could not start the local server on port $Port."
    Write-Host "Close any old Territorial black server windows, then try again. If it still fails, restart the computer."
    Write-Host ""
    Write-Host $_.Exception.Message
    Pause-End
    exit 1
}

Start-Process $Url

Write-Host "Server started successfully. Keep this window open while playing."
Write-Host "If the browser did not open, manually paste this URL:"
Write-Host $Url
Write-Host ""

while ($Listener.IsListening) {
    try {
        $Context = $Listener.GetContext()
        $RequestPath = [System.Uri]::UnescapeDataString($Context.Request.Url.AbsolutePath.TrimStart("/"))
        if ([string]::IsNullOrWhiteSpace($RequestPath)) { $RequestPath = "index.html" }

        $Candidate = [System.IO.Path]::GetFullPath((Join-Path $Root $RequestPath))
        $RootFull = [System.IO.Path]::GetFullPath($Root)

        if (!$Candidate.StartsWith($RootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
            $Context.Response.StatusCode = 403
            $Context.Response.Close()
            continue
        }

        if (!(Test-Path $Candidate) -or (Get-Item $Candidate).PSIsContainer) {
            $Candidate = Join-Path $Root "index.html"
        }

        $Bytes = [System.IO.File]::ReadAllBytes($Candidate)
        $Context.Response.ContentType = Get-ContentType $Candidate
        $Context.Response.ContentLength64 = $Bytes.Length
        $Context.Response.AddHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        $Context.Response.AddHeader("Pragma", "no-cache")
        $Context.Response.OutputStream.Write($Bytes, 0, $Bytes.Length)
        $Context.Response.OutputStream.Close()
    } catch {
        Write-Host "Server request error:"
        Write-Host $_.Exception.Message
    }
}
