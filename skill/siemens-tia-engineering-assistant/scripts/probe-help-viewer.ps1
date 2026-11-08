[CmdletBinding()]
param(
    [uri]$BaseUrl = 'https://localhost:5112',
    [ValidateRange(1, [int]::MaxValue)]
    [int]$TimeoutSeconds = 5
)

$ErrorActionPreference = 'Stop'

if (-not $BaseUrl.IsAbsoluteUri -or $BaseUrl.Scheme -notin @('http', 'https') -or $BaseUrl.UserInfo) {
    throw 'BaseUrl debe ser una URI HTTP/HTTPS absoluta sin credenciales.'
}
# Las rutas de ayuda pueden incluir parámetros; no se registran query ni fragment.
$safeUrl = $BaseUrl.GetLeftPart([System.UriPartial]::Path)

try {
    $response = Invoke-WebRequest -Uri $BaseUrl -Method Get -UseBasicParsing -TimeoutSec $TimeoutSeconds
    [pscustomobject]@{
        available = $true
        reachable = $true
        url = $safeUrl
        status_code = [int]$response.StatusCode
        content_type = [string]$response.Headers['Content-Type']
        content_length = if ($response.RawContentLength -ge 0) { [int64]$response.RawContentLength } else { $null }
        checked_at_utc = [DateTime]::UtcNow.ToString('o')
    } | ConvertTo-Json -Depth 3
}
catch {
    $statusCode = $null
    if ($null -ne $_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
    }
    [pscustomobject]@{
        available = $false
        reachable = ($null -ne $statusCode)
        url = $safeUrl
        status_code = $statusCode
        error = if ($null -ne $statusCode) { 'http_error' } else { 'request_failed' }
        checked_at_utc = [DateTime]::UtcNow.ToString('o')
    } | ConvertTo-Json -Depth 3
    exit 1
}
