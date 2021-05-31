import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeoFinder {
  static Future<Position> getCurrentLocation() async {
    return await Geolocator
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true, timeLimit: Duration(seconds: 10)).catchError((e) {
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
      var canGps = await Geolocator.isLocationServiceEnabled();
        if (canGps) {
        var pos = await getCurrentLocation();

        if (pos == null)
          pos = await Geolocator.getLastKnownPosition();
        
        Placemark place = await getAddressFromLatLng(pos);
        return place.postalCode;
      } else {
        return "560017";
      }
    } catch (ex) {
      print(ex);
      return "or Unable to get your location";
    }
  }

  static Future<Location> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address, localeIdentifier: "en");
      
      Location location = locations[0];
      return location;
    } catch (ex) {
      return null;
    }
  }
}