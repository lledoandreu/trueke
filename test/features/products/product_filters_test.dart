import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  group(
    'Pruebas unitarias de la formula de Haversine y Filtros de Distancia',
    () {
      test('Calculo de distancia aproximada entre coordenadas conocidas', () {
        final double madridLat = 40.416775;
        final double madridLng = -3.703790;
        final double barcelonaLat = 41.385064;
        final double barcelonaLng = 2.173403;

        final double distanceInMeters = Geolocator.distanceBetween(
          madridLat,
          madridLng,
          barcelonaLat,
          barcelonaLng,
        );

        final double distanceInKm = distanceInMeters / 1000.0;

        expect(distanceInKm, closeTo(504.0, 10.0));
      });
    },
  );
}
