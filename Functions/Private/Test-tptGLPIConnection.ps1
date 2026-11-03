function Test-tptGLPIConnection {
    <#
    .SYNOPSIS
        Establece conexión con GLPI y obtiene un token de autenticación.

    .DESCRIPTION
        Función privada. Realiza un inicio de sesión en la API REST de GLPI usando las
credenciales proporcionadas y guarda el token de autenticación y la URL base
para su uso posterior. Si el inicio de sesión falla, lanza un error con el
mensaje de respuesta de la API.

    .PARAMETER Url
        URL base de GLPI (por ejemplo, 'https://glpi.local').

    .PARAMETER Credential
        Credenciales (Usuario/Contraseña) para GLPI. Debe ser un objeto
        PSCredential válido.

    .OUTPUTS
        [void]

    .EXAMPLE
        Test-tptGLPIConnection -Url 'https://glpi.local' -Credential (Get-Credential)

    .NOTES
        Guarda el token en $script:GLPIToken y la URL en $script:GLPIUrl.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [PSCredential]$Credential
    )

    $body = @{
        method = 'login'
        input = @{
            user_id = $Credential.UserName
            password = $Credential.GetNetworkCredential().Password
            ip = '127.0.0.1'
            user_authtoken = ''
        }
        auth = $false
    } | ConvertTo-Json -Depth 3

    $headers = @{
        'Content-Type' = 'application/json'
    }

    try {
        $response = Invoke-RestMethod -Uri "$Url/apirest.php" -Method Post -Body $body -Headers $headers -ErrorAction Stop
    } catch {
        throw "Error al conectar con GLPI: $($_.Exception.Message)"
    }

    if ($response.auth -and $response.token) {
        $script:GLPIToken = $response.token
        $script:GLPIUrl = $Url
    } else {
        throw "Error de autenticación: la respuesta no contiene token de autenticación. Respuesta: $response"
    }
}