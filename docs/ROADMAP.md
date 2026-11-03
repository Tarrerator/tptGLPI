# Hoja de Ruta - tptGLPI

## 1. Conexión
- [x] Connect-tptGLPI: autenticación y conexión básica con GLPI
- [ ] Configuración manual: `~/.tpt/tptGLPI.yaml` para conexión declarativa

## 2. Inventario
- [x] Get-tptGLPIHosts: inventario de equipos informáticos
- [x] Get-tptGLPITickets: inventario de tickets de incidencias
- [x] Get-tptGLPICategories: inventario de categorías de tickets
- [x] Get-tptGLPIAssets: inventario de otros activos (impresoras, dispositivos de red)
- [ ] Get-tptGLPIContracts: inventario de contratos
- [ ] Get-tptGLPISoftware: inventario de software instalado
- [ ] Get-tptGLPIKnowledgeBase: inventario de artículos de base de conocimientos

## 3. Tickets
- [ ] New-tptGLPITicket: creación de nuevos tickets
- [ ] Set-tptGLPITicket: actualización de estado de tickets existentes
- [ ] Add-tptGLPITicketComment: adición de comentarios a tickets

## 4. Administración
- [ ] New-tptGLPIHost: creación de nuevos equipos
- [ ] Set-tptGLPIHost: actualización de información de equipos
- [ ] Remove-tptGLPIHost: eliminación de equipos

## 5. Calidad
- [ ] Testes Pester: suite de pruebas unitarias y de integración
- [ ] CI: integración continua con GitHub Actions

## Próximos pasos
- Implementar la carga de configuración desde YAML
- Agregar funciones de gestión completa de tickets
- Implementar funciones de administración de hosts
- Agregar pruebas automatizadas
- Configurar CI/CD