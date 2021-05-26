
import 'package:vaxometer/src/models/vaccine-centre.dart';
import 'package:vaxometer/src/shared/services/http-service.dart';

class VaxometerService {

  String _baseUrl = "https://vaxometerindia.azurewebsites.net/api/";
  VaccineResponse vaccineResponse;

  Future<VaccineResponse> getCentresByPin(String deviceId, String pinCode) async {
    var response = await HttpService.get<dynamic>(_baseUrl + "v2/VaxometerV2/Centers/DeviceIds/$deviceId/Pincodes/$pinCode");
    return response != null ? VaccineResponse.fromJson(response): null;
  }

  Future<void> followCentre(String deviceId, int centreId, bool isSubscribe) async {
    await HttpService.post<bool>(_baseUrl + "v1/Vaxometer/RegisterDevice/" + deviceId, {
      "centerId": centreId,
      "isRegister": isSubscribe
    });
  }
}