import 'package:geocoding/geocoding.dart';
import 'package:vaxometer/src/models/vaccine-session.dart';
import 'package:vaxometer/src/shared/services/geo-finder.dart';

class VaccineResponse {
  List<String> vaccineTypes;
  int totalSubscriptionCount;
  List<VaccineCentre> centersViewModel;

  VaccineResponse(this.vaccineTypes,this.totalSubscriptionCount,this.centersViewModel);

  VaccineResponse.fromJson(Map<String, dynamic> json)
      : totalSubscriptionCount = json["totalSubscriptionCount"],
        vaccineTypes = json["vaccineTypes"] != null ? new List<String>.from(json["vaccineTypes"]) : null,
        centersViewModel = json["centersViewModel"] != null ? 
                  List.from(json["centersViewModel"]).map((e) => VaccineCentre.fromJson(e)).toList() : null;
}

class VaccineCentre {
  final int center_id;
  final String name;
  final String address;
  final String block_name;
  final String district_name;
  final int pinCode;
  final String fee_type;
  final List<VaccineSession> sessions;
   bool isSubcribed;
  final bool isAVailableFor18;
  final bool isAVailableFor45;
  final DateTime nextAvailableSlot_Dose1;
  final DateTime nextAvailableSlot_Dose2;
  final DateTime nextAvailableSlot18_Dose1;
  final DateTime nextAvailableSlot18_Dose2;
  final DateTime nextAvailableSlot45_Dose1;
  final DateTime nextAvailableSlot45_Dose2;
  final int totalAvailableCapacityDose1;
  final int totalAvailableCapacityDose2;
  final int totalAvailableCapacityDose1_18;
  final int totalAvailableCapacityDose2_18;
  final int totalAvailableCapacityDose1_45;
  final int totalAvailableCapacityDose2_45;

  VaccineCentre(this.center_id, this.name, this.address, this.block_name,
      this.district_name, this.pinCode, this.fee_type, this.sessions,
      this.isSubcribed,
      this.isAVailableFor18, this.isAVailableFor45,
      this.nextAvailableSlot18_Dose1, this.nextAvailableSlot18_Dose2,
      this.nextAvailableSlot45_Dose1, this.nextAvailableSlot45_Dose2,
      this.nextAvailableSlot_Dose1
      , this.nextAvailableSlot_Dose2, this.totalAvailableCapacityDose1,
      this.totalAvailableCapacityDose2, this.totalAvailableCapacityDose1_18,
      this.totalAvailableCapacityDose1_45
      , this.totalAvailableCapacityDose2_18,
      this.totalAvailableCapacityDose2_45);

  VaccineCentre.fromJson(Map<String, dynamic> json)
      : center_id = json["center_id"],
        name = json["name"],
        address = json["address"],
        block_name = json["block_name"],
        district_name = json["district_name"],
        fee_type = json["fee_type"],
        pinCode = json["pinCode"],
        sessions = json["sessions"] != null ? List.from(json["sessions"]).map((
            e) => VaccineSession.fromJson(e)).toList() : null,
        isSubcribed = json["isSubcribed"] ?? false,
        isAVailableFor18 = json["isAVailableFor18"],
        isAVailableFor45 = json["isAVailableFor45"],
        nextAvailableSlot_Dose1 = json["nextAvailableSlot_Dose1"]!=null ? DateTime.parse(json["nextAvailableSlot_Dose1"]) : null,
        nextAvailableSlot_Dose2 = json["nextAvailableSlot_Dose2"]!=null ? DateTime.parse(json["nextAvailableSlot_Dose2"]) : null,
        nextAvailableSlot18_Dose1 = json["nextAvailableSlot18_Dose1"]!=null ? DateTime.parse(json["nextAvailableSlot18_Dose1"]) : null,
        nextAvailableSlot18_Dose2 = json["nextAvailableSlot18_Dose2"]!=null ? DateTime.parse(json["nextAvailableSlot18_Dose2"]) : null,
        nextAvailableSlot45_Dose1 = json["nextAvailableSlot45_Dose1"]!=null ? DateTime.parse(json["nextAvailableSlot45_Dose1"]) : null,
        nextAvailableSlot45_Dose2 = json["nextAvailableSlot45_Dose2"]!=null ? DateTime.parse(json["nextAvailableSlot45_Dose2"]) : null,
        totalAvailableCapacityDose1 = json["totalAvailableCapacityDose1"],
        totalAvailableCapacityDose2 = json["totalAvailableCapacityDose2"],
        totalAvailableCapacityDose1_18 = json["totalAvailableCapacityDose1_18"],
        totalAvailableCapacityDose2_18 = json["totalAvailableCapacityDose2_18"],
        totalAvailableCapacityDose1_45 = json["totalAvailableCapacityDose1_45"],
        totalAvailableCapacityDose2_45 = json["totalAvailableCapacityDose2_45"];

  int getSlots() {
    if (sessions == null) return 0;
    return sessions.fold(0, (preValue, element) => preValue + element.available_capacity);
  }

  String getNextSlotOn() {
    if (sessions == null || sessions.length == 0) return "Nil";
    return sessions[0].date;
  }

  bool hasNextSlot() => isAVailableFor18 || isAVailableFor45;

  int getInitialSlots() {
    return totalAvailableCapacityDose1 + totalAvailableCapacityDose2;
  }

  Location geoLocation;

  Future<void> setGeoLocation() async {
    geoLocation = await GeoFinder.getCoordinatesFromAddress(address);
  }
}