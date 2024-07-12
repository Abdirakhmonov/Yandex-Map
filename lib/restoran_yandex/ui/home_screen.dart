
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../yandex_learn/yandex_map_service.dart';
import '../model/restaurant.dart';
import '../services/location_service.dart';
import '../widgets/add_new_restaurant.dart';
import '../widgets/restaurant_tapped.dart';
import '../widgets/show_error_dialog.dart';
import '../widgets/zoom_button.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  YandexMapController? _yandexMapController;
  Point? _userCurrentPosition;
  List<MapObject>? _polyLines;
  final TextEditingController _searchTextController = TextEditingController();
  final Set<PlacemarkMapObject> _set = {};
  bool _isFetchingAddress = true;

  void _onMapCreated(YandexMapController yandexMapController) {
    _yandexMapController = yandexMapController;
    if (_userCurrentPosition != null) {
      _yandexMapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _userCurrentPosition!, zoom: 17),
        ),
      );
    }
  }

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
    LocationService.determinePosition().then(
          (value) async {
        if (value != null) {
          _userCurrentPosition = Point(
            latitude: value.latitude,
            longitude: value.longitude,
          );
        }
        _isFetchingAddress = false;
      },
    ).catchError((error) {
      showDialog(
        context: context,
        builder: (context) => ShowErrorDialog(errorText: error.toString()),
      );
    }).whenComplete(
          () {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  void _onMyLocationTapped() {
    if (_userCurrentPosition != null || _yandexMapController != null) {
      _yandexMapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _userCurrentPosition!, zoom: 17),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: <Widget>[
          YandexMap(
            nightModeEnabled: true,
            onMapCreated: _onMapCreated,
            zoomGesturesEnabled: true,
            mapObjects: [
              if (_userCurrentPosition != null)
                PlacemarkMapObject(
                  text: const PlacemarkText(
                    text: 'My location',
                    style: PlacemarkTextStyle(
                      color: Colors.white
                    ),
                  ),
                  mapId: const MapObjectId('current_location'),
                  point: _userCurrentPosition!,
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage(
                          "assets/images/marker2.png"),scale: 0.2
                    ),
                  ),
                ),
              ...?_polyLines,
              ..._set
            ],
            onMapLongTap: (argument) async {
              Restaurant? restaurant = await showDialog(
                context: context,
                builder: (context) =>
                    AddNewRestaurant(location: argument),
              );
              if (restaurant != null) {
                _set.add(
                  PlacemarkMapObject(
                    text: PlacemarkText(
                      text: restaurant.title,
                      style: const PlacemarkTextStyle(
                        color: Colors.white,
                        outlineColor: Colors.white,
                      ),
                    ),
                    onTap: (mapObject, point) async {
                      bool? isPolyline = await showDialog(
                        context: context,
                        builder: (context) => OnRestaurantTapped(
                          restaurant: restaurant,
                          onDeleteTap: () {
                            _set.removeWhere(
                                  (element) =>
                              element.mapId ==
                                  MapObjectId(restaurant.id),
                            );
                            setState(() {});
                          },
                        ),
                      );
                      if (isPolyline != null && isPolyline) {
                        _polyLines = await YandexMapService.getDirection(
                            _userCurrentPosition!, restaurant.location, mode: '');
                        setState(() {});
                      }
                    },
                    mapId: MapObjectId(restaurant.id),
                    point: argument,
                    icon: PlacemarkIcon.single(
                      PlacemarkIconStyle(
                        image: BitmapDescriptor.fromAssetImage(
                          "assets/images/marker2.png",
                        ),scale: 0.2
                      ),
                    ),
                  ),
                );
                setState(() {});
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomZoomButton(
                    isZoomIn: true,
                    onTap: () {
                      _yandexMapController!.moveCamera(
                        CameraUpdate.zoomIn(),
                      );
                    },
                  ),
                  const Gap(10),
                  CustomZoomButton(
                    isZoomIn: false,
                    onTap: () {
                      _yandexMapController!.moveCamera(
                        CameraUpdate.zoomOut(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed:
        _userCurrentPosition != null ? _onMyLocationTapped : null,
        child: const Icon(
          Icons.my_location,
          color: Colors.white,
        ),
      ),
    );
  }
}
