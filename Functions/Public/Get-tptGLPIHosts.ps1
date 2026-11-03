function Get-tptGLPIHosts {
    <#
    .SYNOPSIS
        Obtiene un inventario de los equipos informáticos (computadoras) desde GLPI.

    .DESCRIPTION
        Recupera la lista de computadoras desde la API REST de GLPI, aplicando
filtros opcionales de nombre y guardando los resultados en un formato estandarizado.

    .PARAMETER Name
        Array opcional de nombres de computadoras a devolver. Permite wildcards
(por ejemplo, 'host*', '*host', 'host-*-prod'). Si está vacío, devuelve todos los
computadores.

    .OUTPUTS
        [PSCustomObject] con Id, Name, Serial, Manufacturer, Model, Status y Location.

    .EXAMPLE
        Get-tptGLPIHosts
        Devuelve todos los equipos informáticos disponibles.

    .EXAMPLE
        Get-tptGLPIHosts -Name 'server01'
        Devuelve solo la computadora 'server01'.

    .EXAMPLE
        Get-tptGLPIHosts -Name '*prod*'
        Devuelve todas las computadoras con 'prod' en el nombre.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [string[]]$Name = @()
    )

    if (-not $script:GLPIToken) {
        throw "No hay conexión activa con GLPI. Usa Connect-tptGLPI primero."
    }

    $headers = @{
        'Authorization' = "Bearer $script:GLPIToken"
        'Content-Type' = 'application/json'
    }

    $queryParams = @('?page=1&max=1000')
    if ($Name) {
        foreach ($namePattern in $Name) {
            $queryParams += "&search[]=nombre=$namePattern"
        }
    }

    $queryString = ($queryParams -join '')
    $apiUrl = "$script:GLPIUrl/apirest.php/computers$queryString"

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers -ErrorAction Stop
    } catch {
        throw "Error al obtener computadoras: $($_.Exception.Message)"
    }

    foreach ($computer in $response.results) {
        [PSCustomObject]@{
            Id = $computer.id
            Name = $computer.nombre
            Serial = if ($computer.serial) { $computer.serial } else { $null }
            Manufacturer = if ($computer.marcas_id) { "Fabricante$($computer.marcas_id)" } else { $null }
            Model = if ($computer.modeles_id) { "Modelo$($computer.modeles_id)" } else { $null }
            Status = if ($computer.states_id) { "Estado$($computer.states_id)" } else { $null }
            Location = if ($computer.locations_id) { "Ubicación$($computer.locations_id)" } else { $null }
        }
    }
}