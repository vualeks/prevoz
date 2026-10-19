# Podgorica Public Transit Tracker

## ⚠️ DEVELOPMENT PRACTICES

**MUST RUN `flutter analyze` after ANY code changes before considering the task complete.**

- Run `flutter analyze` to catch compilation errors
- Verify hot reload works on device
- Test the actual feature on device when possible

### Running & building (CARTO API key required)

Map tiles need a CARTO basemaps API key, injected at build time from `dart_defines.json` (gitignored, not in the repo):

```bash
flutter run --dart-define-from-file=dart_defines.json
flutter build apk --dart-define-from-file=dart_defines.json
```

`dart_defines.json` format: `{ "CARTO_API_KEY": "<key>" }`. Get a key at https://carto.com/basemaps/apikey.
Without the flag the key is empty and the map renders blank (CARTO returns 403).

---

## 📱 Current Status

**Version:** 1.0.3
**Status:** All major features complete and working

### Implemented Features
- ✅ Real-time bus tracking with 10-second auto-refresh
- ✅ Interactive map with CartoDB Voyager tiles + offline caching (FMTC)
- ✅ Route visualization with OSRM road-following polylines (cached in Hive)
- ✅ Bus stop real-time arrivals (tap any stop to see when buses arrive)
- ✅ User location tracking with GPS (center map on your location)
- ✅ Vehicle movement trails (last 7 positions, ~70 seconds of history)
- ✅ Toggle view between buses and all bus stops (573 stops with clustering)
- ✅ First-launch preload (downloads tiles, caches routes/stops/geometries)
- ✅ Route-specific colors (32 distinct colors, no repeats)
- ✅ Route names from putevi.me (28+ routes mapped)
- ✅ Marker clustering for bus stops view (performance optimization)
- ✅ Custom app icon
- ✅ Settings screen with cache management

---

## 🏗️ Tech Stack

### Core
- **Flutter** 3.x (Dart ^3.10.3)
- **State Management:** Riverpod 2.6.1 (with code generation)
- **Architecture:** Feature-first Clean Architecture
- **Code Generation:** freezed, json_serializable, riverpod_generator

### Map & Location
- **flutter_map** 8.0.0 - Interactive mapping
- **flutter_map_tile_caching** 10.0.1 - Offline tile storage (ObjectBox backend)
- **flutter_map_marker_cluster** 8.2.2 - Marker clustering
- **geolocator** 13.0.2 - User location
- **latlong2** 0.9.1 - Coordinates

### Networking & Storage
- **dio** 5.7.0 - HTTP client
- **hive** 2.2.3 + **hive_flutter** 1.1.0 - NoSQL local database
- **shared_preferences** 2.3.3 - Settings storage
- **OSRM API** - Road routing (free public API)

### Navigation & UI
- **go_router** 14.6.2
- **flutter_launcher_icons** 0.14.1 - App icon generation

---

## 🌐 API Endpoints

**Base URL:** `https://adminapi.prevoz.podgorica.me`

### Vehicle Tracking
- **GET** `/api/dispatcher/vehicles/public`
- Returns: `[{routeName, latitude, longitude}]` (`speed` dropped by the API in Oct 2026; model keeps it optional)
- Response contains duplicate entries (same route + position)
- Updates every 10 seconds

### Bus Stops
- **GET** `/api/gtfs/stops/by-route-day-direction`
- Params: `routeId`, `dayOfWeek` (Serbian: Ponedeljak-Nedjelja), `directionId` (0/1)
- Returns: `[{id, stopId, stopName, arrivalTime, departureTime, latitude, longitude, stopSequence, stopTimeId}]`

### Real-Time Arrivals
- **GET** `/api/gtfs/display/realtime/{stopId}`
- Returns: `[{routeShortName, destination, remainingMinutes, formattedArrivalTime}]`
- Shows when next buses will arrive at a specific stop
- Includes delay information in Serbian (e.g., "stiže za 3 min", "5 min kasnije")

### Map Tiles (CARTO)
- `https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=<CARTO_API_KEY>`
- Keyless requests return an "API KEY REQUIRED" watermark tile
- Config lives in `lib/core/network/map_tiles.dart`

### Route Names Reference
Source: https://putevi.me/gradski-prevoz/aktuelni-red-voznje/

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── network/          # Dio client, API endpoints
│   ├── theme/            # App theming
│   ├── utils/            # Constants, route colors/names, day of week, trail tracker
│   ├── models/           # route_geometry, bus_stop_cache, route_metadata, unique_bus_stop
│   └── services/         # OSRM service, route cache, preload, bus stop query
├── features/
│   ├── map/              # Main map screen, vehicle/bus stop markers, providers
│   ├── preload/          # First-launch data preload screen
│   └── settings/         # Cache management screen
└── app/                  # App widget, routing

assets/
└── icons/
    ├── app_icon.png          # 512x512 app icon
    └── bus_stop_marker.png   # 512x512 custom marker icon
```

---

## 🗄️ Hive Data Models

**TypeId 0:** `RouteGeometry` - OSRM cached polylines (30-day expiration)
**TypeId 1:** `LatLngCache` - Helper for storing coordinates
**TypeId 2:** `BusStopCache` - Bus stops by route/direction/day (30-day expiration)
**TypeId 3:** `RouteMetadata` - Route cache status tracking

---

## 🚀 First-Launch Preload Process

1. **Download map tiles** (35% progress) - Podgorica area, zoom 10-16, CartoDB Voyager
2. **Cache routes** (20% progress) - All 28+ routes from route_constants
3. **Cache bus stops** (25% progress) - Current day only (~56 API calls, ~7x faster than all days)
4. **Cache OSRM geometries** (20% progress) - Road-following polylines for both directions

**Detection:** SharedPreferences flag + Hive box verification
**Daily refresh:** Auto-checks for today's data on app start

---

## 🎨 Route Colors & Names

- **32 distinct colors** - Hash-based assignment ensures consistency
- **28+ routes mapped** - Including alternative formats (15|7, 8|53, 54B, 1B, 6A, etc.)
- **Color normalization** - Alternative route formats get identical colors
- Defined in: `lib/core/utils/route_constants.dart`

---

## 🐛 Bug Fixes Included

- ✅ FMTC initialization (added in main.dart)
- ✅ FMTC backend initialised once in main.dart (second `initialise()` threw `RootAlreadyInitialised`, so the tile store was never created)
- ✅ Tile cache actually used while browsing (`BrowseStoreStrategy.readUpdateCreate` on store `cartoTiles`; legacy `mapStore` deleted on startup)
- ✅ INTERNET permission (added to AndroidManifest.xml)
- ✅ Location permissions (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION)
- ✅ Preload screen visibility (light grey background, darker blue for contrast)
- ✅ "Error loading vehicles" after API dropped `speed` (made optional in `Vehicle`)

## ⚠️ Code generation is currently broken

`dart run build_runner build` crashes (`Missing implementation of visitDotShorthandPropertyAccess`): the pinned
riverpod_generator/freezed/json_serializable bundle analyzer 3.9, older than the Flutter SDK's Dart 3.13.
`--delete-conflicting-outputs` deletes all generated files before crashing (restore with `git checkout`).
`vehicle.freezed.dart` / `vehicle.g.dart` were hand-edited for the nullable `speed`. Upgrade the codegen
packages before changing any freezed/riverpod/json model.

---

## 📝 Notes

- **Vehicle matching:** Proximity-based (no unique IDs in API), max expected distance based on speed (60 km/h assumed when the API omits it)
- **Trail filtering:** Only adds points when bus moves >5m (preserves history during stops)
- **Marker rotation:** Counter-rotation applied to stay upright when map rotates
- **Cache strategy:** Cache-first with OSRM fallback, straight-line fallback on error
- **Performance:** Marker clustering reduces 573 stops to ~50-100 clusters at low zoom
- **Real-time arrivals:** Shows live bus arrivals with delay info, replaces static schedule display
- **User location:** GPS-based with permission handling, centers map at zoom 16, shows blue marker
- **Location permissions:** Full permission flow with proper error handling and Settings deep-link

---

## 🔮 Future Enhancements

- Improve vehicle marker design (add rotation/heading indicator based on trail bearing)
- Add route comparison feature (show multiple routes side-by-side)
- Add favorites system (save favorite routes/stops)
- Add notifications for bus arrival at favorite stops
- Add offline route planning
- Add analytics (route frequency, average wait times)
