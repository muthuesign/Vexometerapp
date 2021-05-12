import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeoFinder {
  static Future<Position> getCurrentLocation() {
    return Geolocator
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true).catchError((e) {
        print(e);
      });
  }

  static Future<Placemark> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: "en"
      );
      
      Placemark place = placemarks[0];
      return place;
    } catch (ex) {
      throw ex;
    }
  }

  static Future<String> getPinCodeByMyLoction() async {
    try {
      var pos = await getCurrentLocation();
      
      Placemark place = await getAddressFromLatLng(pos);
      return place.postalCode;
    } catch (ex) {
      print(ex);
      return ex.toString();
    }
  }
}