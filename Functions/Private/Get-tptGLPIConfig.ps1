function Get-tptGLPIConfig {
    <#
    .SYNOPSIS
        Lee y valida el fichero de configuración centralizado para tptGLPI.
    
    .DESCRIPTION
        Lee el fichero YAML centralizado ~/.tpt/tpt_config.yaml, extrae la sección
        tptGLPI y valida su estructura y campos obligatorios. Retorna una matriz
        de objetos de plataforma con validación de plataforma predeterminada.
    
    .OUTPUTS
        [PSCustomObject[]] Matriz de objetos de plataforma validados.
    
    .EXAMPLE
        Get-tptGLPIConfig
        Lee la configuración centralizada y retorna plataformas GLPI validadas.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param()

    $configPath = "~\/.tpt\/tpt_config.yaml"
    if (-not (Test-Path $configPath)) {
        throw "Fichero de configuración centralizado no encontrado: $configPath"
    }

    try {
        $yamlContent = Get-Content -Path $configPath -Raw
        # Convertir YAML a JSON usando la sintaxis de objeto de PowerShell (YAML no está estructurado en PS)
        # Usar ConvertFrom-Yaml si está disponible, o ConvertFrom-Json para YAML estructurado
        $yamlData = $yamlContent | ConvertFrom-Yaml -ErrorAction Stop
    } catch {
        # Fallback: intentar convertir YAML estructurado como JSON
        try {
            $yamlData = $yamlContent | ConvertFrom-Json -ErrorAction Stop
        } catch {
            throw "No se pudo parsear el fichero YAML $configPath. Error: $($_.Exception.Message)"
        }
    }

    if (-not $yamlData -or -not $yamlData.platforms) {
        throw "Estructura inválida en el fichero YAML: falta la sección 'platforms'"
    }

    if (-not $yamlData.platforms.tptGLPI) {
        throw "No se encontró la sección 'tptGLPI' en la configuración YAML"
    }

    $platforms = $yamlData.platforms.tptGLPI
    $platformsArray = @()

    foreach ($platform in $platforms) {
        # Validar campos obligatorios según la documentación
        $requiredFields = @('name', 'url')
        $missingFields = $requiredFields | Where-Object { -not $platform.PSObject.Properties.Name.Contains($_) }
        
        if ($missingFields) {
            throw "Plataforma '$($platform.name)': campos obligatorios faltantes: $(Join-String -InputObject $missingFields)"
        }

        # Validar URL
        if (-not $platform.url.StartsWith('http://') -and -not $platform.url.StartsWith('https://')) {
            throw "Plataforma '$($platform.name)': URL inválida '$($platform.url)'. Debe comenzar con 'http://' o 'https://'"
        }

        # Validar campo default (debe ser bool
        if ($platform.PSObject.Properties.Name.Contains('default')) {
            if ($platform.default -isnot [bool]) {
                throw "Plataforma '$($platform.name)': campo 'default' debe ser booleano, se recibió $($platform.default)"
            }
        } else {
            # Establecer default false si no se proporciona
            $platform | Add-Member -NotePropertyName 'default' -NotePropertyValue $false
        }

        # Asegurar que tags es una matriz (si se proporciona
        if ($platform.PSObject.Properties.Name.Contains('tags')) {
            if ($platform.tags -isnot [array]) {
                throw "Plataforma '$($platform.name)': campo 'tags' debe ser una matriz"
            }
        } else {
            # Establecer tags vacío si no se proporciona
            $platform | Add-Member -NotePropertyName 'tags' -NotePropertyValue @()
        }

        $platformsArray += $platform
    }

    # Validar que hay al menos una plataforma predeterminada
    $defaultPlatforms = $platformsArray | Where-Object { $_.default -eq $true }
    if ($defaultPlatforms.Count -eq 0) {
        throw "No se encontró plataforma predeterminada en la configuración tptGLPI. Al menos una plataforma debe tener 'default: true'."
    }

    if ($defaultPlatforms.Count -gt 1) {
        throw "Múltiples plataformas predeterminadas en tptGLPI. Solo una plataforma debe tener 'default: true'."
    }

    $platformsArray
}