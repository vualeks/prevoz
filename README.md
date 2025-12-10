# Prevoz - Podgorica Public Transit Tracker

[🇬🇧 English](#english) | [🇷🇸 Srpski](#srpski)

---

## English

### 📱 About

**Prevoz** is a real-time public transit tracking application for Podgorica, Montenegro. Built with Flutter, it provides citizens with live bus locations, routes, and schedules in an intuitive, offline-capable mobile experience.

Track buses in real-time, explore routes, discover nearby stops, and plan your journey - all in one beautiful, fast, and reliable app.

### 📥 Download

**Latest Release: v1.0.0**

[![Download APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](https://github.com/vualeks/prevoz/releases/download/v1.0.0/prevoz-v1.0.0-release.apk)

**Direct Download:** [prevoz-v1.0.0-release.apk](https://github.com/vualeks/prevoz/releases/download/v1.0.0/prevoz-v1.0.0-release.apk) (57 MB)

> **Note:** This is a release APK signed with a debug key. For production use, you should sign it with your own release key.

### ✨ Features

#### 🚍 Real-Time Bus Tracking
- **Live bus positions** updated every 10 seconds
- **Colored route markers** with route numbers and names
- **Movement trails** showing bus direction and recent path (last 70 seconds)
- **28+ bus routes** covering all of Podgorica
- Auto-refresh for seamless real-time experience

#### 🗺️ Interactive Map
- **Dual view modes**: Switch between buses and bus stops
- **573 bus stops** with intelligent marker clustering
- **Offline map tiles** with CartoDB Voyager styling
- **Smooth zoom and pan** with excellent performance
- **Map rotation** with auto-upright markers
- Compass button for quick north orientation

#### 🚏 Bus Stop Information
- **Tap any stop** to see all routes that service it
- **Route schedules** with arrival and departure times
- **Interactive route cards** - tap to visualize the entire route
- **Smart clustering** - stops group at low zoom for better performance
- **573 unique stops** across Podgorica

#### 🛤️ Route Visualization
- **Tap any bus** to see its complete route
- **Two-direction display** with color-coded stops (blue/orange)
- **Road-following routes** using OSRM routing engine
- **OSRM caching** for instant subsequent loads
- Route information panel with stop counts

#### 🚀 Performance & Offline
- **First-launch preload** - downloads all data on first run
- **Smart caching** with Hive NoSQL database
- **OSRM route geometry caching** (30-day expiration)
- **Map tile caching** (zoom levels 10-16)
- **Offline-capable** after initial data download
- **Daily auto-refresh** of schedule data
- **Marker clustering** reduces rendering from 573 to ~50-100 markers

#### 🎨 User Experience
- **Material 3 design** with clean, modern interface
- **Route-specific colors** (32 distinct colors for easy identification)
- **Custom bus stop icons** with visibility-optimized design
- **Smooth animations** for cluster splitting/merging
- **Settings screen** for cache management
- **Zero lag** with optimized rendering

### 🏗️ Architecture

Built using **Clean Architecture** with a feature-first approach:

```
lib/
├── core/
│   ├── models/         # Data models (Freezed)
│   ├── network/        # Dio HTTP client
│   ├── services/       # Business logic services
│   └── utils/          # Utilities and constants
├── features/
│   ├── map/            # Map display and interaction
│   ├── preload/        # First-launch data preload
│   └── settings/       # App settings and cache management
└── app/                # App initialization and routing
```

**Key Patterns:**
- **State Management**: Riverpod with code generation
- **Immutable Models**: Freezed for data classes
- **Dependency Injection**: Riverpod providers
- **Repository Pattern**: Separation of data sources and domain logic
- **Caching Strategy**: Multi-layer with Hive and FMTC

### 🛠️ Technologies

#### Core Framework
- **Flutter** 3.x - Cross-platform mobile framework
- **Dart** 3.10.3 - Programming language

#### State Management & Code Generation
- **Riverpod** 2.6.1 - State management
- **Freezed** 2.5.7 - Immutable models
- **JSON Serializable** 6.8.0 - JSON parsing
- **Build Runner** 2.4.13 - Code generation

#### Networking
- **Dio** 5.7.0 - HTTP client
- **OSRM API** - Road routing engine

#### Map & Location
- **flutter_map** 8.0.0 - Interactive maps
- **flutter_map_marker_cluster** 8.2.2 - Marker clustering
- **flutter_map_tile_caching** 10.0.1 - Offline map tiles
- **Geolocator** 13.0.2 - Device location
- **LatLong2** 0.9.1 - Coordinate calculations

#### Local Storage
- **Hive** 2.2.3 - NoSQL database
- **SharedPreferences** 2.3.3 - Simple key-value storage

#### Navigation
- **GoRouter** 14.6.2 - Declarative routing

### 📦 Installation

#### Prerequisites
- Flutter SDK 3.10.3 or higher
- Dart SDK 3.10.3 or higher
- Android Studio / Xcode (for platform-specific builds)

#### Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/prevoz.git
cd prevoz
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**
```bash
flutter run
```

### 🚀 Getting Started

1. **First Launch**: The app will automatically download all necessary data:
   - Map tiles for Podgorica (zoom levels 10-16)
   - All 28+ bus routes with metadata
   - Current day's bus stop schedules
   - Route geometries from OSRM

2. **View Buses**: Default view shows all active buses with real-time positions

3. **View Bus Stops**: Tap the toggle at bottom-left to switch to bus stops view

4. **Explore Routes**:
   - Tap any bus to see its complete route with all stops
   - Tap any bus stop to see which routes service it
   - Tap route cards to visualize different routes

5. **Settings**: Access via gear icon to:
   - View cache statistics
   - Refresh today's schedule data
   - Clear cache and reload

### 🗺️ Data Sources

- **Vehicle Positions**: `https://adminapi.prevoz.podgorica.me/api/dispatcher/vehicles/public`
- **Bus Stops**: `https://adminapi.prevoz.podgorica.me/api/gtfs/stops/by-route-day-direction`
- **Route Geometry**: OSRM public API (`https://router.project-osrm.org`)
- **Map Tiles**: CartoDB Voyager (`https://{s}.basemaps.cartocdn.com`)

### 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

#### Development Guidelines
- Follow existing code style and architecture
- Run `flutter analyze` before committing
- Add tests for new features
- Update documentation as needed

### 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### 🙏 Acknowledgments

- **Podgorica Municipality** for providing public transit API
- **OSRM Project** for routing engine
- **CartoDB** for map tiles
- **Flutter Community** for excellent packages and support
- **Claude Code** for wholehearted development assistance and pair programming throughout the entire project

### 🤖 Built with AI

This project was developed with the wholehearted help of [Claude Code](https://claude.ai/claude-code) - Anthropic's AI-powered coding assistant. From architecture design to implementation, debugging, and optimization, Claude Code was instrumental in bringing this app to life through collaborative pair programming.

---

## Srpski

### 📱 O aplikaciji

**Prevoz** je aplikacija za praćenje javnog gradskog prevoza u Podgorici u realnom vremenu. Razvijena u Flutter tehnologiji, pruža građanima informacije o pozicijama autobusa, rutama i voznim redovima kroz intuitivan, brz i pouzdan mobilni interfejs koji radi i bez internet konekcije.

Pratite autobuse u realnom vremenu, istražite rute, pronađite najbliže stanice i planirajte svoje putovanje - sve u jednoj lepoj, brzoj i pouzdanoj aplikaciji.

### 📥 Preuzimanje

**Poslednja verzija: v1.0.0**

[![Preuzmi APK](https://img.shields.io/badge/Preuzmi-APK-green?style=for-the-badge&logo=android)](https://github.com/vualeks/prevoz/releases/download/v1.0.0/prevoz-v1.0.0-release.apk)

**Direktno preuzimanje:** [prevoz-v1.0.0-release.apk](https://github.com/vualeks/prevoz/releases/download/v1.0.0/prevoz-v1.0.0-release.apk) (57 MB)

> **Napomena:** Ovo je release APK potpisan debug ključem. Za produkcijsku upotrebu, trebali biste ga potpisati sopstvenim release ključem.

### ✨ Mogućnosti

#### 🚍 Praćenje autobusa u realnom vremenu
- **Pozicije autobusa uživo** ažurirane svakih 10 sekundi
- **Obojeni markeri ruta** sa brojevima i nazivima linija
- **Tragovi kretanja** koji pokazuju pravac i nedavni put autobusa (poslednjih 70 sekundi)
- **28+ autobusnih linija** koje pokrivaju celu Podgoricu
- Automatsko osvežavanje za neprekidno praćenje

#### 🗺️ Interaktivna mapa
- **Dva režima prikaza**: Prebacivanje između autobusa i autobuskih stanica
- **573 autobuske stanice** sa inteligentnim grupisanjem markera
- **Offline keširanje mape** sa CartoDB Voyager stilom
- **Glatko zumiranje i pomeranje** sa odličnim performansama
- **Rotacija mape** sa automatskim ispravljanjem markera
- Dugme kompasa za brzu orijentaciju ka severu

#### 🚏 Informacije o stanicama
- **Dodirnite bilo koju stanicu** da vidite sve linije koje prolaze kroz nju
- **Vozni redovi linija** sa vremenima dolaska i polaska
- **Interaktivne kartice linija** - dodirnite da vizualizujete celu rutu
- **Pametno grupisanje** - stanice se grupišu pri malim zum nivoima za bolje performanse
- **573 jedinstvene stanice** širom Podgorice

#### 🛤️ Vizualizacija ruta
- **Dodirnite bilo koji autobus** da vidite njegovu kompletnu rutu
- **Prikaz oba smera** sa stanicama u boji (plava/narandžasta)
- **Rute koje prate puteve** koristeći OSRM routing engine
- **OSRM keširanje** za trenutno učitavanje pri ponovnom otvaranju
- Panel sa informacijama o ruti i broju stanica

#### 🚀 Performanse i offline rad
- **Preuzimanje pri prvom pokretanju** - preuzima sve podatke pri prvom korišćenju
- **Pametno keširanje** sa Hive NoSQL bazom podataka
- **Keširanje OSRM geometrija ruta** (ističe nakon 30 dana)
- **Keširanje mapa** (zum nivoi 10-16)
- **Rad bez interneta** nakon inicijalnog preuzimanja
- **Automatsko dnevno osvežavanje** podataka o voznom redu
- **Grupisanje markera** smanjuje renderovanje sa 573 na ~50-100 markera

#### 🎨 Korisničko iskustvo
- **Material 3 dizajn** sa čistim, modernim interfejsom
- **Boje specifične za linije** (32 različite boje za laku identifikaciju)
- **Prilagođene ikone stanica** sa optimizovanim dizajnom za vidljivost
- **Glatke animacije** pri razdvajanju/spajanju grupa markera
- **Ekran sa podešavanjima** za upravljanje kešom
- **Nema zastoja** sa optimizovanim renderovanjem

### 🏗️ Arhitektura

Izgrađena korišćenjem **Clean Architecture** sa pristupom usmrenim na funkcionalnosti:

```
lib/
├── core/
│   ├── models/         # Modeli podataka (Freezed)
│   ├── network/        # Dio HTTP klijent
│   ├── services/       # Servisi sa poslovnom logikom
│   └── utils/          # Pomoćne funkcije i konstante
├── features/
│   ├── map/            # Prikaz i interakcija sa mapom
│   ├── preload/        # Preuzimanje podataka pri prvom pokretanju
│   └── settings/       # Podešavanja aplikacije i upravljanje kešom
└── app/                # Inicijalizacija aplikacije i rutiranje
```

**Ključni obrasci:**
- **State Management**: Riverpod sa generisanjem koda
- **Nepromenjivi modeli**: Freezed za klase podataka
- **Dependency Injection**: Riverpod provideri
- **Repository Pattern**: Razdvajanje izvora podataka i domenske logike
- **Strategija keširanja**: Više slojeva sa Hive i FMTC

### 🛠️ Tehnologije

#### Osnovni framework
- **Flutter** 3.x - Cross-platform mobilni framework
- **Dart** 3.10.3 - Programski jezik

#### State Management i generisanje koda
- **Riverpod** 2.6.1 - Upravljanje stanjem
- **Freezed** 2.5.7 - Nepromenjivi modeli
- **JSON Serializable** 6.8.0 - JSON parsiranje
- **Build Runner** 2.4.13 - Generisanje koda

#### Mreža
- **Dio** 5.7.0 - HTTP klijent
- **OSRM API** - Engine za rutiranje puteva

#### Mapa i lokacija
- **flutter_map** 8.0.0 - Interaktivne mape
- **flutter_map_marker_cluster** 8.2.2 - Grupisanje markera
- **flutter_map_tile_caching** 10.0.1 - Offline keširanje mapa
- **Geolocator** 13.0.2 - Lokacija uređaja
- **LatLong2** 0.9.1 - Kalkulacije koordinata

#### Lokalno skladištenje
- **Hive** 2.2.3 - NoSQL baza podataka
- **SharedPreferences** 2.3.3 - Jednostavno key-value skladište

#### Navigacija
- **GoRouter** 14.6.2 - Deklarativno rutiranje

### 📦 Instalacija

#### Preduslovi
- Flutter SDK 3.10.3 ili noviji
- Dart SDK 3.10.3 ili noviji
- Android Studio / Xcode (za platform-specifične buildove)

#### Koraci

1. **Klonirajte repozitorijum**
```bash
git clone https://github.com/yourusername/prevoz.git
cd prevoz
```

2. **Instalirajte zavisnosti**
```bash
flutter pub get
```

3. **Generišite kod**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Pokrenite aplikaciju**
```bash
flutter run
```

### 🚀 Početak korišćenja

1. **Prvo pokretanje**: Aplikacija će automatski preuzeti sve potrebne podatke:
   - Mape za Podgoricu (zum nivoi 10-16)
   - Svih 28+ autobusnih linija sa metapodacima
   - Vozni red za tekući dan
   - Geometrije ruta sa OSRM

2. **Prikaz autobusa**: Podrazumevani prikaz pokazuje sve aktivne autobuse sa pozicijama uživo

3. **Prikaz stanica**: Dodirnite preklopnik u donjem levom uglu za prebacivanje na prikaz stanica

4. **Istraživanje ruta**:
   - Dodirnite bilo koji autobus da vidite njegovu kompletnu rutu sa svim stanicama
   - Dodirnite bilo koju stanicu da vidite koje linije prolaze kroz nju
   - Dodirnite kartice linija da vizualizujete različite rute

5. **Podešavanja**: Pristupite preko ikone zupčanika da:
   - Vidite statistiku keša
   - Osvežite podatke voznog reda za danas
   - Očistite keš i ponovo učitate podatke

### 🗺️ Izvori podataka

- **Pozicije vozila**: `https://adminapi.prevoz.podgorica.me/api/dispatcher/vehicles/public`
- **Autobuske stanice**: `https://adminapi.prevoz.podgorica.me/api/gtfs/stops/by-route-day-direction`
- **Geometrija ruta**: OSRM javni API (`https://router.project-osrm.org`)
- **Mape**: CartoDB Voyager (`https://{s}.basemaps.cartocdn.com`)

### 🤝 Doprinos projektu

Doprinosi su dobrodošli! Slobodno podnesite Pull Request. Za veće izmene, molimo vas da prvo otvorite issue kako bismo razgovarali o tome šta želite da promenite.

#### Smernice za razvoj
- Pratite postojeći stil koda i arhitekturu
- Pokrenite `flutter analyze` pre commit-a
- Dodajte testove za nove funkcionalnosti
- Ažurirajte dokumentaciju po potrebi

### 📄 Licenca

Ovaj projekat je licenciran pod MIT licencom - pogledajte [LICENSE](LICENSE) fajl za detalje.

### 🙏 Zahvalnice

- **Opština Podgorica** za obezbeđivanje API-ja javnog prevoza
- **OSRM Project** za routing engine
- **CartoDB** za mape
- **Flutter Community** za odlične pakete i podršku
- **Claude Code** za iskrenu pomoć u razvoju i pair programming tokom celog projekta

### 🤖 Razvijeno uz pomoć AI

Ovaj projekat je razvijen uz iskrenu pomoć [Claude Code](https://claude.ai/claude-code) - Anthropic-ovog AI asistenta za programiranje. Od dizajna arhitekture do implementacije, debug-ovanja i optimizacije, Claude Code je bio ključan u oživljavanju ove aplikacije kroz kolaborativno pair programming.

---

<div align="center">

**Made with ❤️ for Podgorica | Napravljeno sa ❤️ za Podgoricu**

⭐ If you like this project, please give it a star! | Ako vam se sviđa projekat, dajte mu zvezdicu! ⭐

</div>
