@{
    # Identidad del módulo
    RootModule           = 'tptGLPI.psm1'
    ModuleVersion        = '0.0.1'
    GUID                 = '3f8b9c12-4a7d-4e9f-8b2c-6d5a3f1e9b8d'
    Author               = 'TPT'
    CompanyName          = 'Tarrerator'
    Copyright            = '(c) 2026 Tarrerator'

    # Descripción
    Description          = 'Módulo PowerShell que envuelve la API REST oficial de GLPI (ITSM) para gestionar recursos de infraestructura: activos, tickets, categorías y estado de conexión.'

    # Compatibilidad
    PowerShellVersion    = '7.2'
    CompatiblePSEditions = @('Desktop', 'Core')

    # Exportaciones explícitas: nada de comodines
    FunctionsToExport    = @(
        'Connect-tptGLPI'
        'Get-tptGLPIHosts'
        'Get-tptGLPITickets'
        'Get-tptGLPICategories'
        'Get-tptGLPIAssets'
        'Get-tptGLPIStatus'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()

    PrivateData          = @{
        PSData = @{
            Tags         = @('GLPI', 'ITSM', 'API', 'Inventory', 'Tickets')
            ProjectUri   = 'https://github.com/Tarrerator/tptGLPI'
            ReleaseNotes = 'Inventario inicial de GLPI con conexión y consultas básicas.'
        }
    }
}