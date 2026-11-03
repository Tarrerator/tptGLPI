function Get-tptGLPIAssets {
    <#
    .SYNOPSIS
        Obtiene un inventario de activos (computadoras, impresoras, dispositivos de red) desde GLPI.

    .DESCRIPTION
        Recupera la lista de activos desde la API REST de GLPI según el tipo especificado
(computadoras, impresoras o dispositivos de red). Devuelve información detallada sobre
cada activo.

    .PARAMETER Type
        Tipo de activo: 'computers', 'printers' o 'networks'. Por defecto 'computers'.

    .OUTPUTS
        [PSCustomObject] con Id, Name, Type, Serial, Status y Location.

    .EXAMPLE
        Get-tptGLPIAssets
        Devuelve todos los equipos informáticos (por defecto).

    .EXAMPLE
        Get-tptGLPIAssets -Type 'printers'
        Devuelve todas las impresoras.

    .EXAMPLE
        Get-tptGLPIAssets -Type 'networks'
        Devuelve todos los dispositivos de red.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [ValidateSet('computers', 'printers', 'networks')]
        [string]$Type = 'computers'
    )

    if (-not $script:GLPIToken) {
        throw "No hay conexión activa con GLPI. Usa Connect-tptGLPI primero."
    }

    $headers = @{
        'Authorization' = "Bearer $script:GLPIToken"
        'Content-Type' = 'application/json'
    }

    $apiUrl = "$script:GLPIUrl/apirest.php/$Type"

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers -ErrorAction Stop
    } catch {
        throw "Error al obtener activos: $($_.Exception.Message)"
    }

    foreach ($asset in $response.results) {
        [PSCustomObject]@{
            Id = $asset.id
            Name = $asset.nombre
            Type = $Type
            Serial = if ($asset.serial) { $asset.serial } else { $null }
            Status = if ($asset.states_id) { "Estado$($asset.states_id)" } else { $null }
            Location = if ($asset.locations_id) { "Ubicación$($asset.locations_id)" } else { $null }
        }
    }
}