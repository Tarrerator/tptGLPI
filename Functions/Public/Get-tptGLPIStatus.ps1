function Get-tptGLPIStatus {
    <#
    .SYNOPSIS
        Muestra el estado de conexión actual con GLPI.

    .DESCRIPTION
        Devuelve el estado actual de la conexión con GLPI, incluyendo la URL base,
 el estado de conexión y la versión de la API (si está disponible).

    .OUTPUTS
        [PSCustomObject] con Url, Connected y Version.

    .EXAMPLE
        Get-tptGLPIStatus
        Muestra el estado actual de la conexión con GLPI.

    .EXAMPLE
        Get-tptGLPIStatus -Url 'https://glpi.local'
        Muestra el estado de una conexión específica con GLPI.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [string]$Url = $script:GLPIUrl ?? 'https://glpi.local'
    )

    $connected = $false
    $version = $null

    if ($script:GLPIToken) {
        try {
            $headers = @{
                'Authorization' = "Bearer $script:GLPIToken"
                'Content-Type' = 'application/json'
            }
            $response = Invoke-RestMethod -Uri "$script:GLPIUrl/apirest.php" -Method Get -Headers $headers -ErrorAction Stop
            $connected = $true
            $version = $response.version
        } catch {
            Write-Warning "La conexión con GLPI ha caducado: $($_.Exception.Message)"
        }
    }

    [PSCustomObject]@{
        Url = $Url
        Connected = $connected
        Version = $version
    }
}