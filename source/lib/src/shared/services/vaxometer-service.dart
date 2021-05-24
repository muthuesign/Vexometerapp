
import 'package:vaxometer/src/models/vaccine-centre.dart';
import 'package:vaxometer/src/shared/services/http-service.dart';

class VaxometerService {

  String _baseUrl = "https://vaxometerindia.azurewebsites.net/api/v2/";
  VaccineCentreV2 vaccineCentreV2;

  Future<VaccineCentreV2> getCentresByPin(String deviceId, String pinCode) async {
    var response = await HttpService.get<dynamic>(_baseUrl + "VaxometerV2/Centers/DeviceIds/$deviceId/Pincodes/560037");
    VaccineCentreV2 vaccineCentreV2 = new VaccineCentreV2(null, null, null);

    vaccineCentreV2.centersViewModel = getCenters(response);
    vaccineCentreV2.vaccineTypes = getVaccineCenters(response);
    vaccineCentreV2.totalSubscriptionCount = response["totalSubscriptionCount"];
    return vaccineCentreV2;
  }
  
  List<CentersViewModel> getCenters(vaccineCentreV2)
  {
    var centersViewModel = vaccineCentreV2["centersViewModel"];
    return List.from(centersViewModel).map((e) => CentersViewModel.fromJson(e)).toList();
  }
  List<String> getVaccineCenters(vaccineCentreV2)
  {
    return new List<String>.from(vaccineCentreV2["vaccineTypes"]);
  }

  Future<void> followCentre(String deviceId, int centreId, bool isSubscribe) async {
    _baseUrl = "https://vaxometerindia.azurewebsites.net/api/v1/";
    await HttpService.post<bool>(_baseUrl + "Vaxometer/RegisterDevice/" + deviceId, {
      "deviceId": deviceId,
      "date": DateTime.now().toString(),
      "centerId": centreId,
      "isRegister": isSubscribe
    });
  }
}