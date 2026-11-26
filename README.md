# Arma 3 Singleplayer Battle Royale - Multi-Map Porting Guide

Base del proyecto: Escenario derivado de `[QBR] Quick Battle Royale: Altis`[cite: 1] extraído de Workshop (`3802598086`)[cite: 1, 2].
Objetivo: Eliminar dependencias exclusivas de `Altis` para compilar variantes `.pbo` funcionales en cualquier terreno de Arma 3.

---

## 1. Arquitectura de Archivos del Escenario

* `00_init_vars.sqf`: Variables globales, configuración de zona, radios y centro del mapa[cite: 4]. **Punto crítico #1.**
* `10_spawn_funcs_and_lists.sqf`: Listas de clases (armas, ítems, vehículos) y funciones auxiliares de spawn[cite: 4].
* `20_ban_markers.sqf`: Lista de marcadores de exclusión (zonas donde no cierra el círculo ni spawnea loot/IA)[cite: 4]. **Punto crítico #2 (suele depender de marcadores puestos en `mission.sqm`).**
* `30_spawn_triggers.sqf`: Disparadores y lógica de generación de botín/zonas[cite: 4].
* `40_last_point_runner.sqf`: Lógica del cierre final de zona[cite: 4].
* `50_notify_generator.sqf` / `60_graphics_creator.sqf`: UI, notificaciones y marcadores visuales en mapa[cite: 4].
* `AISpawn.sqf` / `ai_agression.sqf`: Generación y comportamiento de bots enemigos[cite: 4].
* `lootspawn.sqf` / `WeaponFind.sqf` / `WeaponTake.sqf`: Sistema de saqueo en edificios[cite: 4].
* `description.ext`: Metadatos de la misión (`onLoadName`, parámetros, clases de sonido/UI)[cite: 4].
* `mission.sqm`: Entidades, unidad del jugador, módulos y marcadores del Eden Editor[cite: 4].

---

## 2. Reglas Técnicas de Arma 3 para Portar Mapas

1. **Nomenclatura de carpeta:** Arma 3 determina el terreno por la extensión de la carpeta antes de empaquetar:
   `<NombreMision>.<worldName>` (ej. `YoRah_BR.Tanoa`, `YoRah_BR.Enoch`, `YoRah_BR.Cam_Lao_Nam`).
2. **Dimensiones dinámicas:**
   * `Altis` mide `30720 x 30720` metros. Cualquier coordenada superior a `8192` o `15360` romperá la lógica en mapas medianos (como `Stratis`, `Malden` o `Tanoa`).
   * Usar siempre `worldSize` para calcular centros (`[worldSize / 2, worldSize / 2, 0]`) y radios máximos (`worldSize * 0.45`).
3. **Validación de terreno:**
   * Usar `surfaceIsWater _pos` para descartar puntos de aparición o cierres de zona en el océano (crítico en mapas insulares como `Tanoa` o `Malden`).
4. **Archivo `mission.sqm`:**
   * Si `mission.sqm` está binarizado (formato rapificado/ilegible), debe desbinarizarse con `CfgConvert` (Arma 3 Tools) o reemplazarse por una plantilla limpia con al menos una unidad jugable (`isPlayer = 1`) en posición válida `[worldSize/2, worldSize/2, 0]`.
   * Las referencias a `addons[]` dentro de `mission.sqm` deben limpiarse si incluyen dependencias exclusivas de mapas específicos que no sean universales.

---

## 3. Compilación con `armake_w64`

### Sintaxis básica de empaquetado (PBO)
Para compilar una carpeta de misión a un archivo `.pbo` funcional sin binarizar configs críticos de misión:

```powershell
.\armake_w64.exe build -f -p "Ruta\CarpetaMision.Tanoa" "Ruta\Salida\CarpetaMision.Tanoa.pbo"
```
-f: Sobrescribe el .pbo de salida si ya existe.
-p: Empaqueta sin intentar binarizar archivos .sqm o .ext que ya estén en texto plano (evita errores de sintaxis en scripts SQF).

### Generar variantes para varios mapas
Desde PowerShell, ejecuta el script desde la carpeta del proyecto. `armake_w64.exe` y `CfgConvert.exe` deben estar en `PATH` o indicarse con `-ArmakePath`/`-CfgConvertPath`:

```powershell
.\build_maps.ps1 -WorldNames Altis,Stratis,Malden,Tanoa,Enoch,SefrouRamal `
  -ArmakePath "C:\Tools\armake_w64.exe" `
  -CfgConvertPath "C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools\CfgConvert\CfgConvert.exe"
```

El script crea carpetas `<Mision>.<worldName>` y sus `.pbo` en `..\QBRSE-maps` (o en `-OutputDirectory`), y actualiza `onLoadName`/`onLoadMission` a `YoRah's BRSE - <nombre del mapa>` en `description.ext` y el `briefingName` de la misión (por ejemplo, `YoRah's BRSE - Tanoa (Apex)`). Para mapas no incluidos en la tabla de nombres, usa el `worldName` como nombre visible. CfgConvert ajusta y binariza `mission.sqm` dentro de cada copia generada, sin alterar el original ni sus entidades. El archivo convertido por Eden contiene ubicaciones Altis estáticas para 150 `ban_marker_*`, 17 `city_spawn*` y 140 `field_spawn_*`, y no guarda una propiedad `worldName`; por tanto, esos puntos no son una configuración válida para otros mapas. En las variantes que no son Altis se ignoran como centros de partida y la lógica genera una posición seca dentro del terreno. Solo se recolocan los triggers de juego (zona, rondas, daño, loot y victoria), no todos los detectores de spawn.

La lógica SQF escala los radios existentes con `worldSize`, valida las posiciones contra agua y utiliza puntos editoriales solo en Altis; para otros mapas busca terreno seco dinámicamente. Los 150 marcadores estáticos `ban_marker_*` se ocultan en todos los mapas, pero sus exclusiones solo se aplican en Altis, que es el terreno al que pertenecen.

Classnames (worldName) disponibles en mi Arma 3

Altis: Altis

Stratis: Stratis

Malden 2035: Malden

Tanoa (Apex): Tanoa

Livonia (Contact): Enoch

Sefrou-Ramal (Western Sahara): SefrouRamal

## 4. Rutas de Despliegue Local
Escenarios Singleplayer (.pbo compilados):<Directorio_Instalacion_Arma3>\Missions\

Escenarios Multiplayer / LAN (.pbo compilados):<Directorio_Instalacion_Arma3>\MPMissions\

Proyectos sin compilar (para abrir en Eden Editor):%USERPROFILE%\Documents\Arma 3 - Other Profiles\<Perfil>\missions\