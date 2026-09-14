[CmdletBinding()]
param(
    [string]$BaseUrl = 'https://localhost:5112',
    [int]$TimeoutSeconds = 5
)

$ErrorActionPreference = 'Stop'

try {
    $response = Invoke-WebRequest -Uri $BaseUrl -Method Get -UseBasicParsing -TimeoutSec $TimeoutSeconds
    [pscustomobject]@{
        available = $true
        url = $BaseUrl
        status_code = [int]$response.StatusCode
        content_type = [string]$response.Headers['Content-Type']
        content_length = if ($response.RawContentLength -ge 0) { [int64]$response.RawContentLength } else { $null }
        checked_at_utc = [DateTime]::UtcNow.ToString('o')
    } | ConvertTo-Json -Depth 3
}
catch {
    [pscustomobject]@{
        available = $false
        url = $BaseUrl
        error = $_.Exception.Message
        checked_at_utc = [DateTime]::UtcNow.ToString('o')
    } | ConvertTo-Json -Depth 3
    exit 1
}
