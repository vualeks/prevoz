# Route Visualization Feature - Implementation Plan

## 📋 Feature Requirements
When a user taps on a bus:
1. Hide all buses except those on the same route
2. Fetch and display all stops for that route
3. Draw a line connecting the stops to show the route path
4. Allow user to clear selection and return to normal view

---

## 🔍 Current Data Analysis

### What We Have
**Vehicle API** (`/api/dispatcher/vehicles/public`)
- Returns: `routeName` (e.g., "10"), `latitude`, `longitude`, `speed`
- ✅ We know which buses are on which route

**Bus Stops API** (`/api/gtfs/stops/by-route-day-direction`)
- Parameters: `routeId`, `dayOfWeek`, `directionId` (0 or 1)
- Returns: List of stops with `latitude`, `longitude`, `stopSequence`, `stopName`, `arrivalTime`
- ✅ We can get ordered stops with coordinates

### Key Observations
1. **Route ID Assumption**: `routeName` from vehicles API should match `routeId` for stops API (both are strings like "10")
2. **Stop Sequence**: The `stopSequence` field allows us to order stops correctly
3. **Direction Issue**: Bus routes have TWO directions (outbound/inbound), but vehicles don't tell us their direction

---

## 🎯 Core Challenges & Solutions

### Challenge 1: Direction Ambiguity
**Problem**: The bus stops API requires `directionId` (0 or 1), but we don't know which direction a specific vehicle is traveling.

**Solutions Evaluated**:

**Option A: Fetch Both Directions (RECOMMENDED)**
- Fetch stops for directionId=0 AND directionId=1
- Show all stops on the map
- Draw two different colored lines (one for each direction)
- Pros: Complete picture, user sees entire route network
- Cons: More API calls, potentially cluttered if routes overlap

**Option B: Guess Direction from Vehicle Position**
- Compare vehicle position to all stops in both directions
- Choose direction with closest stops
- Pros: Shows only relevant direction
- Cons: Complex logic, might guess wrong, requires fetching both anyway

**Option C: Let User Choose Direction**
- Show dialog: "Direction A" or "Direction B"?
- Pros: User control, accurate
- Cons: Extra UI step, user might not know which direction they want

**RECOMMENDATION: Start with Option A** - Fetch both directions, show complete route. Can optimize later.

---

### Challenge 2: Drawing the Route Line

**Problem**: We need to draw a line that follows the actual bus route.

**Solutions Evaluated**:

**Option A: Connect Stops by Sequence (RECOMMENDED)**
- Sort stops by `stopSequence`
- Draw polyline connecting stop coordinates in order
- Pros: Simple, uses existing data, good enough for most routes
- Cons: Line might not follow actual roads (straight lines between stops)

**Option B: Use GTFS Shapes (if available)**
- Check if API has a `/shapes` endpoint with detailed route geometry
- Pros: Accurate route following roads
- Cons: Requires additional API endpoint (may not exist)

**Option C: Use Map Routing API**
- Use external routing service to calculate path between stops
- Pros: Perfect accuracy
- Cons: Complex, additional API costs, slow

**RECOMMENDATION: Start with Option A** - Connect stops in sequence order. This is how most transit apps work and users understand it.

---

### Challenge 3: State Management

**Problem**: Need to track selected route, visible buses, loaded stops, etc.

**Solutions**:

**Option A: Local State in MapScreen (RECOMMENDED for MVP)**
```dart
class _MapScreenState {
  String? _selectedRoute;
  List<BusStop> _routeStops = [];
  bool _isLoadingStops = false;

  void _selectRoute(String routeName) async {
    setState(() {
      _selectedRoute = routeName;
      _isLoadingStops = true;
    });

    // Fetch stops for both directions
    final stops0 = await fetchStops(routeName, 0);
    final stops1 = await fetchStops(routeName, 1);

    setState(() {
      _routeStops = [...stops0, ...stops1];
      _isLoadingStops = false;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedRoute = null;
      _routeStops = [];
    });
  }
}
```

**Option B: Riverpod Provider**
- Create a `selectedRouteProvider` and `routeStopsProvider`
- Pros: Reactive, cleaner separation
- Cons: More complex for this simple use case

**RECOMMENDATION: Option A for MVP** - Simple local state. Can refactor to Riverpod later if needed.

---

## 🎨 UI/UX Design

### User Flow
```
1. User sees map with all buses moving
   ↓
2. User taps a bus marker (e.g., Route 10)
   ↓
3. Immediate visual changes:
   - All other routes fade out/hide
   - Only Route 10 buses remain visible
   - Loading indicator appears
   ↓
4. API calls complete:
   - Bus stops appear as smaller markers
   - Route lines draw in two colors (direction 0 & 1)
   - Route info panel appears at bottom
   ↓
5. User can:
   - Tap stops to see arrival times
   - Tap "Clear" button to return to normal view
   - Tap another bus on same route (no change)
   - Tap a bus on different route (switch routes)
```

### Visual Design

**Normal Mode:**
- All buses visible with route number labels
- No stops visible
- No route lines

**Route Selected Mode:**
- Selected route buses: Full visibility
- Other route buses: Hidden (or 20% opacity as alternative)
- Bus stops: Small circular markers with stop icon
- Route lines: Two polylines with different colors
  - Direction 0: Blue (#2196F3)
  - Direction 1: Orange (#FF9800)
- UI additions:
  - Bottom panel: Route info (route number, direction count, stop count)
  - Floating "Clear" button (top-right or with other FABs)

---

## 🛠️ Technical Implementation Plan

### Phase 1: Data Layer ✅ (Already Done!)
- [x] BusStop model exists
- [x] busStopsProvider exists
- [x] Day of week utility exists

### Phase 2: State Management (1-2 hours)

**Add to MapScreen:**
```dart
// State variables
String? _selectedRoute;
List<BusStop> _directionZeroStops = [];
List<BusStop> _directionOneStops = [];
bool _isLoadingRoute = false;

// Methods
Future<void> _onBusTapped(String routeName) async {
  setState(() {
    _selectedRoute = routeName;
    _isLoadingRoute = true;
  });

  try {
    final day = SerbianDayOfWeek.today.apiName;

    // Fetch both directions in parallel
    final results = await Future.wait([
      ref.read(busStopsProvider(
        routeId: routeName,
        dayOfWeek: day,
        directionId: 0,
      ).future),
      ref.read(busStopsProvider(
        routeId: routeName,
        dayOfWeek: day,
        directionId: 1,
      ).future),
    ]);

    setState(() {
      _directionZeroStops = results[0];
      _directionOneStops = results[1];
      _isLoadingRoute = false;
    });
  } catch (e) {
    debugPrint('Error loading route: $e');
    setState(() {
      _isLoadingRoute = false;
    });
    // Show error snackbar
  }
}

void _clearRouteSelection() {
  setState(() {
    _selectedRoute = null;
    _directionZeroStops = [];
    _directionOneStops = [];
  });
}
```

### Phase 3: Vehicle Filtering (30 mins)

**Update vehicle marker layer:**
```dart
MarkerLayer(
  markers: vehicles
    .where((vehicle) {
      // If no route selected, show all
      if (_selectedRoute == null) return true;
      // If route selected, show only that route
      return vehicle.routeName == _selectedRoute;
    })
    .map((vehicle) => Marker(
      point: LatLng(vehicle.latitude, vehicle.longitude),
      child: GestureDetector(
        onTap: () => _onBusTapped(vehicle.routeName),
        // ... existing marker UI
      ),
    ))
    .toList(),
)
```

### Phase 4: Bus Stop Markers (1 hour)

**Create helper method to build stop markers:**
```dart
List<Marker> _buildStopMarkers(List<BusStop> stops, Color color) {
  return stops.map((stop) {
    return Marker(
      point: LatLng(stop.latitude, stop.longitude),
      width: 30,
      height: 30,
      child: GestureDetector(
        onTap: () => _showStopDetails(stop),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            Icons.place,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }).toList();
}

// Add to FlutterMap children (AFTER vehicle markers):
if (_selectedRoute != null) ...[
  // Direction 0 stops
  MarkerLayer(
    markers: _buildStopMarkers(_directionZeroStops, Colors.blue),
  ),
  // Direction 1 stops
  MarkerLayer(
    markers: _buildStopMarkers(_directionOneStops, Colors.orange),
  ),
],
```

### Phase 5: Route Polylines (1 hour)

**Create helper method to build polylines:**
```dart
Polyline? _buildRoutePolyline(List<BusStop> stops, Color color) {
  if (stops.isEmpty) return null;

  // Sort by stopSequence to ensure correct order
  final sortedStops = List<BusStop>.from(stops)
    ..sort((a, b) => a.stopSequence.compareTo(b.stopSequence));

  final points = sortedStops
    .map((stop) => LatLng(stop.latitude, stop.longitude))
    .toList();

  return Polyline(
    points: points,
    strokeWidth: 4.0,
    color: color,
  );
}

// Add to FlutterMap children (BEFORE markers so lines are below):
if (_selectedRoute != null) ...[
  PolylineLayer(
    polylines: [
      if (_buildRoutePolyline(_directionZeroStops, Colors.blue) != null)
        _buildRoutePolyline(_directionZeroStops, Colors.blue)!,
      if (_buildRoutePolyline(_directionOneStops, Colors.orange) != null)
        _buildRoutePolyline(_directionOneStops, Colors.orange)!,
    ],
  ),
],
```

### Phase 6: UI Elements (1 hour)

**1. Clear Selection Button:**
```dart
// Add to floating action buttons column
if (_selectedRoute != null)
  FloatingActionButton.small(
    heroTag: 'clear_route',
    onPressed: _clearRouteSelection,
    tooltip: 'Clear route',
    backgroundColor: Colors.red,
    child: const Icon(Icons.close),
  ),
```

**2. Route Info Panel:**
```dart
// Add to Stack in body
if (_selectedRoute != null)
  Positioned(
    top: 16,
    left: 16,
    right: 16,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(_selectedRoute!),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route $_selectedRoute',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Stops: ${_directionZeroStops.length + _directionOneStops.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (_isLoadingRoute)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    ),
  ),
```

**3. Stop Details Bottom Sheet:**
```dart
void _showStopDetails(BusStop stop) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stop.stopName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('Stop ID: ${stop.stopId}'),
          Text('Sequence: ${stop.stopSequence}'),
          const Divider(),
          Text(
            'Next Arrivals',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text('Arrival: ${stop.arrivalTime}'),
          Text('Departure: ${stop.departureTime}'),
        ],
      ),
    ),
  );
}
```

---

## 📊 Implementation Layers (Rendering Order)

```
Bottom → Top
1. Map tiles (CartoDB)
2. Route polylines (PolylineLayer) - Blue for direction 0, Orange for direction 1
3. Bus stop markers (MarkerLayer x2) - One layer per direction
4. Vehicle markers (MarkerLayer) - Filtered by selected route
5. UI overlays (Route info panel, loading indicators)
6. Floating action buttons (Including clear button)
```

---

## 🎭 Edge Cases & Error Handling

### 1. Route with No Stops
```dart
if (_directionZeroStops.isEmpty && _directionOneStops.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('No stops found for route $_selectedRoute')),
  );
  _clearRouteSelection();
}
```

### 2. API Error
```dart
catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Failed to load route information'),
      action: SnackBarAction(label: 'Retry', onPressed: _retryLoadRoute),
    ),
  );
}
```

### 3. Duplicate Stops
- The API returns stops with same `stopId` but different arrival times (same stop, different schedules)
- For visualization, we only need unique stop positions
- Solution: Group by `stopId` and take first occurrence for map display
```dart
final uniqueStops = <String, BusStop>{};
for (var stop in allStops) {
  if (!uniqueStops.containsKey(stop.stopId)) {
    uniqueStops[stop.stopId] = stop;
  }
}
return uniqueStops.values.toList();
```

### 4. Switching Between Routes
```dart
if (_selectedRoute != null && _selectedRoute != routeName) {
  // Different route tapped, clear current and load new
  _clearRouteSelection();
  Future.delayed(Duration(milliseconds: 100), () {
    _onBusTapped(routeName);
  });
}
```

---

## ⚡ Performance Considerations

### 1. API Calls
- **Current**: 2 API calls when route selected (direction 0 + 1)
- **Optimization**: Cache stops per route (don't refetch if already loaded today)

### 2. Marker Count
- Worst case: 50 stops per direction = 100 stop markers + N vehicle markers + 2 polylines
- **flutter_map handles this well**, but consider:
  - Clustering stops if zoom level is low (future enhancement)
  - Only showing stops when zoomed in enough (future enhancement)

### 3. State Updates
- Don't use `setState` unnecessarily
- Batch stop updates (fetch both directions, then single setState)

---

## 📱 Testing Checklist

### Manual Testing
- [ ] Tap bus → Route appears correctly
- [ ] Multiple buses on same route → All show when route selected
- [ ] Buses on other routes → Hidden when route selected
- [ ] Clear button → Returns to normal view
- [ ] Tap stop → Bottom sheet shows details
- [ ] API error → Error message shows
- [ ] No stops for route → Graceful error
- [ ] Switch between different routes → Works smoothly
- [ ] Duplicate stops → Only show unique positions

### Device Testing
- [ ] Test on ASUS Z01KD (Android 13)
- [ ] Hot reload works after changes
- [ ] Performance is acceptable with 100+ markers
- [ ] Polylines render correctly

---

## 🚀 Implementation Timeline

**Estimated Total: 4-5 hours**

1. **Phase 2 - State Management**: 1-2 hours
   - Add state variables
   - Implement _onBusTapped method
   - Implement _clearRouteSelection method

2. **Phase 3 - Vehicle Filtering**: 30 mins
   - Update vehicle marker filtering logic

3. **Phase 4 - Stop Markers**: 1 hour
   - Create _buildStopMarkers helper
   - Add MarkerLayers for stops
   - Handle duplicate stops

4. **Phase 5 - Route Polylines**: 1 hour
   - Create _buildRoutePolyline helper
   - Add PolylineLayer
   - Test line rendering

5. **Phase 6 - UI Elements**: 1 hour
   - Add clear button
   - Add route info panel
   - Add stop details bottom sheet
   - Polish styling

6. **Testing & Bug Fixes**: 30 mins
   - Test all flows
   - Fix edge cases
   - Run flutter analyze

---

## 🔮 Future Enhancements (Not in MVP)

1. **Smart Direction Detection**
   - Use vehicle heading to guess direction
   - Show only relevant direction stops

2. **Stop Clustering**
   - Cluster nearby stops when zoomed out
   - Expand clusters when zoomed in

3. **Real-time Bus Position on Route**
   - Show bus progress along route line
   - Highlight next stops

4. **Route Comparison**
   - Select multiple routes
   - Different colors for each route

5. **Favorite Routes**
   - Save commonly viewed routes
   - Quick access to favorites

6. **Offline Route Data**
   - Cache route geometry locally
   - Work offline with cached routes

---

## 💡 Alternative Approaches Considered

### A. Single Direction Only
- Pro: Simpler, less cluttered
- Con: User might want to see return journey
- **Decision**: Show both directions for completeness

### B. Separate Stop Types
- Show regular stops vs. major stops differently
- Pro: Visual hierarchy
- Con: API doesn't distinguish types
- **Decision**: Not possible with current data

### C. Animated Route Drawing
- Draw polyline with animation when route loads
- Pro: Looks cool, draws attention
- Con: Adds complexity, might be annoying if slow
- **Decision**: Skip for MVP, can add later

---

## ✅ Recommendation

**PROCEED WITH PLAN AS OUTLINED**

This is a solid, achievable feature that will greatly enhance UX. The implementation is straightforward using flutter_map's built-in components, and we have all the data we need.

**Suggested Next Steps:**
1. Review this plan together
2. Clarify any questions
3. Start with Phase 2 (State Management)
4. Build incrementally, testing after each phase
5. Run `flutter analyze` after each phase

**Risk Level**: LOW
- All required data is available
- Flutter_map supports all needed features (markers, polylines)
- Clean architecture makes changes isolated to MapScreen
- Can rollback easily if issues arise
