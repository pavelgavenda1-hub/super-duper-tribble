import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/stone_model.dart';
import '../../services/stone_service.dart';
import '../../services/location_service.dart';
import '../stone/stone_detail_screen.dart';

enum StoneFilter {
  all,
  active,
  lost,
  myStones,
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final StoneService _stoneService = StoneService();
  final LocationService _locationService = LocationService();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  StoneFilter _currentFilter = StoneFilter.active;

  // Default camera position (Prague)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(50.0755, 14.4378),
    zoom: 6,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _centerMapOnUserLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 12,
          ),
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nepodařilo se získat polohu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Set<Marker> _createMarkers(List<StoneModel> stones) {
    return stones.map((stone) {
      if (stone.currentLocation == null) return null;

      return Marker(
        markerId: MarkerId(stone.id),
        position: LatLng(
          stone.currentLocation!.latitude,
          stone.currentLocation!.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          stone.isLost ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue,
        ),
        infoWindow: InfoWindow(
          title: 'Kámen ${stone.id.substring(0, 8)}',
          snippet: stone.isLost ? 'Ztracený' : 'Aktivní',
        ),
        onTap: () => _onMarkerTapped(stone),
      );
    }).whereType<Marker>().toSet();
  }

  void _onMarkerTapped(StoneModel stone) {
    // Clear previous polylines
    setState(() {
      _polylines.clear();
    });

    // Show stone route if it has history
    if (stone.history.isNotEmpty) {
      final polyline = _createStoneRoutePolyline(stone);
      setState(() {
        _polylines = {polyline};
      });
    }

    // Show bottom sheet with stone info
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildStoneBottomSheet(stone),
    );
  }

  Polyline _createStoneRoutePolyline(StoneModel stone) {
    final points = stone.history
        .map((h) => LatLng(h.location.latitude, h.location.longitude))
        .toList();

    return Polyline(
      polylineId: PolylineId(stone.id),
      points: points,
      color: Colors.blue,
      width: 3,
    );
  }

  Widget _buildStoneBottomSheet(StoneModel stone) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                stone.isLost ? Icons.error : Icons.place,
                size: 40,
                color: stone.isLost ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${stone.id.substring(0, 12)}...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${stone.history.length} destinací • '
                      '${stone.previousOwners.length} majitelů',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoneDetailScreen(stoneId: stone.id),
                ),
              );
            },
            child: const Text('Zobrazit detail'),
          ),
        ],
      ),
    );
  }

  Stream<List<StoneModel>> _getStonesStream() {
    switch (_currentFilter) {
      case StoneFilter.all:
        return _stoneService.stonesStream();
      case StoneFilter.active:
        return _stoneService.activeStonesStream();
      case StoneFilter.lost:
        return _stoneService.stonesStream().map(
              (stones) => stones.where((s) => s.isLost).toList(),
            );
      case StoneFilter.myStones:
        // TODO: Filter by current user
        return _stoneService.activeStonesStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa kamenů'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<StoneFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() {
                _currentFilter = filter;
                _polylines.clear();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: StoneFilter.all,
                child: Text('Všechny kameny'),
              ),
              const PopupMenuItem(
                value: StoneFilter.active,
                child: Text('Aktivní kameny'),
              ),
              const PopupMenuItem(
                value: StoneFilter.lost,
                child: Text('Ztracené kameny'),
              ),
              const PopupMenuItem(
                value: StoneFilter.myStones,
                child: Text('Moje kameny'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<StoneModel>>(
        stream: _getStonesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final stones = snapshot.data!;
            _markers = _createMarkers(stones);
          }

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerMapOnUserLocation,
        tooltip: 'Moje poloha',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
