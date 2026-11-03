# tptGLPI

Módulo PowerShell que envuelve la API REST oficial de GLPI (ITSM) para gestionar recursos de infraestructura: activos, tickets, categorías y estado de conexión.

Parte de la suite *tarre pwsh tools* (TPT): prefijo `tpt` en módulos y funciones para evitar colisiones.

El objetivo es no llamar a la API REST de GLPI directamente: `tptGLPI` aporta una capa de conveniencia con nombres estables, estado de conexión compartido en el módulo y errores limpios.

## Requisitos

- PowerShell 7.2 o superior (también compatible con Windows PowerShell 5.1).
- GLPI 10+ con la API REST habilitada y un servidor GLPI accesible desde el cliente.

## Instalación

```powershell
# Desde PowerShell Gallery (cuando se publique)
Install-Module tptGLPI
Import-Module tptGLPI

# Desde este repositorio (desarrollo)
git clone https://github.com/Tarrerator/tptGLPI.git
Import-Module ./tptGLPI/tptGLPI.psd1
```

## Uso básico

```powershell
Import-Module tptGLPI

# Conectar a un servidor GLPI
Connect-tptGLPI -Url 'https://glpi.local' -Credential (Get-Credential)

# Estado de conexión
Get-tptGLPIStatus

# Inventario de equipos informáticos
Get-tptGLPIHosts

# Inventario de tickets
Get-tptGLPITickets

# Inventario de categorías de tickets
Get-tptGLPICategories

# Inventario de otros activos (impresoras, dispositivos de red)
Get-tptGLPIAssets
```

## Configuración

El módulo usa un estado de conexión compartido almacenado en memoria durante la sesión.
Para el uso futuro, se leerá un fichero YAML con las plataformas declaradas:

Ubicación: `~/.tpt/tptGLPI.yaml` en Linux/macOS y `~\.tpt\tptGLPI.yaml` en Windows.

```yaml
# ~/.tpt/tptGLPI.yaml
# Plataformas declaradas para tptGLPI.
platforms:
  - name: production
    url: 'https://glpi.local'
    default: true
    tags: [producción]

  - name: lab
    url: 'https://glpi.lab.local'
    default: false
    tags: [laboratorio]
```

Aviso de seguridad: no guardar credenciales en este fichero; las credenciales se piden en tiempo de conexión con `Get-Credential` (o el gestor de credenciales del sistema operativo).

## Estructura

```
tptGLPI/
├── tptGLPI.psd1            # Manifiesto: metadatos, exports, dependencias
├── tptGLPI.psm1            # Cargador: importa Functions/Public y Functions/Private
├── README.md
├── LICENSE                 # GPL-3.0
├── CHANGELOG.md
├── Functions/
│   ├── Public/             # Funciones exportadas al usuario
│   │   ├── Connect-tptGLPI.ps1
│   │   ├── Get-tptGLPIHosts.ps1
│   │   ├── Get-tptGLPITickets.ps1
│   │   ├── Get-tptGLPICategories.ps1
│   │   ├── Get-tptGLPIAssets.ps1
│   │   └── Get-tptGLPIStatus.ps1
│   └── Private/            # Funciones internas, no exportadas
│       └── Test-tptGLPIConnection.ps1
└── docs/
    └── ROADMAP.md           # Funciones planificadas
```

## Funciones públicas actuales

| Función | Descripción |
|---------|-------------|
| `Connect-tptGLPI` | Establece una conexión con GLPI y obtiene un token de autenticación. |
| `Get-tptGLPIHosts` | Obtiene un inventario de equipos informáticos (computadoras) desde GLPI. |
| `Get-tptGLPITickets` | Obtiene un inventario de tickets (incidencias) desde GLPI. |
| `Get-tptGLPICategories` | Obtiene un inventario de categorías de tickets desde GLPI. |
| `Get-tptGLPIAssets` | Obtiene un inventario de activos (impresoras, dispositivos de red) desde GLPI. |
| `Get-tptGLPIStatus` | Muestra el estado actual de la conexión con GLPI. |

## Desarrollo

```powershell
# Lint
Install-Module PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path . -Recurse

# Probar en sesión limpia
pwsh -NoProfile -Command 'Import-Module ./tptGLPI.psd1; Get-Command -Module tptGLPI'
```

Las funciones públicas van una por fichero en `Functions/Public/` y las privadas en `Functions/Private/`. El manifiesto lista explícitamente `FunctionsToExport`; nada se exporta con comodines.

## Licencia

[GPL-3.0](LICENSE).