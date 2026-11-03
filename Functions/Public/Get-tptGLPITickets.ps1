function Get-tptGLPITickets {
    <#
    .SYNOPSIS
        Obtiene un inventario de las incidencias (tickets) desde GLPI.

    .DESCRIPTION
        Recupera la lista de tickets desde la API REST de GLPI, aplicando filtros
opcionales de nombre, estado y límite de resultados.

    .PARAMETER Name
        Array opcional de nombres de tickets a devolver. Permite wildcards
(por ejemplo, 'ticket*', '*ticket', 'ticket-*-urgente'). Si está vacío, devuelve
todos los tickets.

    .PARAMETER Status
        Estado opcional del ticket: 'new', 'assigned' o 'closed'. Si no se
proporciona, devuelve tickets de todos los estados (con límite).

    .PARAMETER Limit
        Número máximo de tickets a devolver. Por defecto 100.

    .OUTPUTS
        [PSCustomObject] con Id, Name, Status, Priority, Urgency, RequestedBy y
CreatedAt.

    .EXAMPLE
        Get-tptGLPITickets
        Devuelve hasta 100 tickets (Estado por defecto).

    .EXAMPLE
        Get-tptGLPITickets -Name 'ticket-001'
        Devuelve solo el ticket 'ticket-001'.

    .EXAMPLE
        Get-tptGLPITickets -Status 'new' -Limit 50
        Devuelve hasta 50 tickets nuevos.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [string[]]$Name = @(),

        [ValidateSet('new', 'assigned', 'closed')]
        [string]$Status = $null,

        [int]$Limit = 100
    )

    if (-not $script:GLPIToken) {
        throw "No hay conexión activa con GLPI. Usa Connect-tptGLPI primero."
    }

    $headers = @{
        'Authorization' = "Bearer $script:GLPIToken"
        'Content-Type' = 'application/json'
    }

    $queryParams = @("?page=1&max=$Limit")
    if ($Status) {
        $queryParams += "&status=$Status"
    }
    if ($Name) {
        foreach ($namePattern in $Name) {
            $queryParams += "&search[]=nombre=$namePattern"
        }
    }

    $queryString = ($queryParams -join '')
    $apiUrl = "$script:GLPIUrl/apirest.php/tickets$queryString"

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers -ErrorAction Stop
    } catch {
        throw "Error al obtener tickets: $($_.Exception.Message)"
    }

    foreach ($ticket in $response.results) {
        [PSCustomObject]@{
            Id = $ticket.id
            Name = $ticket.nombre
            Status = $ticket.estado
            Priority = if ($ticket.prioridad) { $ticket.prioridad } else { $null }
            Urgency = if ($ticket.urgencia) { $ticket.urgencia } else { $null }
            RequestedBy = if ($ticket.requester_id) { "Solicitante$($ticket.requester_id)" } else { $null }
            CreatedAt = $ticket.fechacreacion
        }
    }
}