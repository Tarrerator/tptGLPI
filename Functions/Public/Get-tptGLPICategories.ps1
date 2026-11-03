function Get-tptGLPICategories {
    <#
    .SYNOPSIS
        Obtiene un inventario de las categorías de tickets desde GLPI.

    .DESCRIPTION
        Recupera la lista de categorías de tickets desde la API REST de GLPI,
aplicando un filtro opcional de categoría padre para obtener subcategorías.

    .PARAMETER Parent
        ID opcional de la categoría padre para filtrar subcategorías.
        Si no se proporciona, devuelve todas las categorías.

    .OUTPUTS
        [PSCustomObject] con Id, Name, Parent y Level.

    .EXAMPLE
        Get-tptGLPICategories
        Devuelve todas las categorías de tickets.

    .EXAMPLE
        Get-tptGLPICategories -Parent '5'
        Devuelve solo las subcategorías de la categoría padre con ID 5.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [string]$Parent = $null
    )

    if (-not $script:GLPIToken) {
        throw "No hay conexión activa con GLPI. Usa Connect-tptGLPI primero."
    }

    $headers = @{
        'Authorization' = "Bearer $script:GLPIToken"
        'Content-Type' = 'application/json'
    }

    $apiUrl = "$script:GLPIUrl/apirest.php/itilticketcategories"
    if ($Parent) {
        $apiUrl += "?parent=$Parent"
    }

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers -ErrorAction Stop
    } catch {
        throw "Error al obtener categorías: $($_.Exception.Message)"
    }

    foreach ($category in $response.results) {
        [PSCustomObject]@{
            Id = $category.id
            Name = $category.nombre
            Parent = if ($category.padre_id) { $category.padre_id } else { $null }
            Level = if ($category.nivel) { $category.nivel } else { $null }
        }
    }
}