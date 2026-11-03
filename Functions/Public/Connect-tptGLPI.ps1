function Connect-tptGLPI {
    <#
    .SYNOPSIS
        Establece una conexión con GLPI y guarda las credenciales.

    .DESCRIPTION
        Crea una conexión con GLPI llamando a la función privada
Test-tptGLPIConnection, que realiza el inicio de sesión real y obtiene un token.
Si ya hay una conexión activa (token almacenado), devuelve esa información
en lugar de establecer una nueva conexión.

    .PARAMETER Url
        URL base de GLPI (por ejemplo, 'https://glpi.local'). Si no se proporciona,
usa $script:GLPIUrl si ya existe, o 'https://glpi.local' como predeterminado.

    .PARAMETER Credential
        Credenciales (Usuario/Contraseña) para GLPI. Debe ser un objeto
        PSCredential válido. Si no se proporciona y ya hay un token almacenado,
usa las credenciales almacenadas para probar la conexión.

    .OUTPUTS
        [PSCustomObject] con Url, User, Connected y Version.

    .EXAMPLE
        Connect-tptGLPI -Url 'https://glpi.local' -Credential (Get-Credential)
        Conecta con GLPI e inicializa la sesión.

    .EXAMPLE
        Connect-tptGLPI
        Usa el servidor almacenado o el predeterminado con las credenciales almacenadas.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [string]$Url = $script:GLPIUrl ?? 'https://glpi.local',

        [ValidateNotNull()]
        [PSCredential]$Credential = $null
    )

    if ($script:GLPIToken) {
        Write-Verbose "Ya hay una conexión activa con GLPI. Verificando la conexión..."

        try {
            $headers = @{
                'Authorization' = "Bearer $script:GLPIToken"
                'Content-Type' = 'application/json'
            }
            $response = Invoke-RestMethod -Uri "$script:GLPIUrl/apirest.php" -Method Get -Headers $headers -ErrorAction Stop
            return [PSCustomObject]@{
                Url = $script:GLPIUrl
                User = 'admin'
                Connected = $true
                Version = $response.version
            }
        } catch {
            Write-Warning "La conexión activa ha caducado. Restableciendo la conexión..."
            $script:GLPIToken = $null
        }
    }

    if (-not $Credential) {
        throw "Debe proporcionar credenciales para conectarse con GLPI."
    }

    Test-tptGLPIConnection -Url $Url -Credential $Credential

    return [PSCustomObject]@{
        Url = $Url
        User = 'admin'
        Connected = $true
        Version = $null
    }
}