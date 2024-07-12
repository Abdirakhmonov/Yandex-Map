import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapService {
  static Future<List<MapObject>> getDirection(
      Point from,
      Point to,
      ) async {
    final result = await YandexDriving.requestRoutes(
      points: [
        RequestPoint(point: from, requestPointType: RequestPointType.wayPoint),
        RequestPoint(point: to, requestPointType: RequestPointType.wayPoint),
      ],
      drivingOptions: const DrivingOptions(
        initialAzimuth: 1,
        routesCount: 1,
        avoidTolls: true,
      ),
    );

    final drivingResults = await result.$2;

    if (drivingResults.error != null) {
      return [];
    }

    final routes = drivingResults.routes!.take(2).toList();
    final List<MapObject> polyLines = [];
    if (routes.isNotEmpty) {
      final polyline1 = PolylineMapObject(
        mapId: MapObjectId(UniqueKey().toString()),
        polyline: Polyline(
          points: routes[0].geometry.points,
        ),
        strokeColor: Colors.blue,
      );
      polyLines.add(polyline1);
    }

    return polyLines;
  }
}