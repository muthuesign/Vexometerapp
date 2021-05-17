
import 'package:vaxometer/src/models/vaccine-fee.dart';
import 'package:vaxometer/src/models/vaccine-session.dart';

class VaccineCentre {
  final int center_id;
  final String name;
  final String address;
  final String block_name;
  final String district_name;
  final String state_name;
  final String fee_type;
  final String from;
  final String to;
  final int lat;
  final int long;
  final int pinCode;
  final List<VaccineFee> vaccine_fees;
  final List<VaccineSession> sessions;
  bool isSubcribed;

  VaccineCentre(this.center_id, this.name, this.address, this.block_name, this.district_name,
                 this.state_name, this.fee_type, this.from, this.to, this.lat, this.long,
                  this.pinCode, this.vaccine_fees, this.sessions, this.isSubcribed);

  VaccineCentre.fromJson(Map<String, dynamic> json)
      : center_id = json["center_id"],
        name = json["name"],
        address = json["address"],
        block_name = json["block_name"],
        district_name = json["district_name"],
        state_name = json["state_name"],
        fee_type = json["fee_type"],
        from = json["from"],
        to = json["to"],
        lat = json["lat"],
        long = json["long"],
        pinCode = json["pinCode"],
        vaccine_fees = json["vaccine_fees"] != null ? List.from(json["vaccine_fees"]).map((e) => VaccineFee.fromJson(e)).toList() : null,
        sessions = json["sessions"] != null ? List.from(json["sessions"]).map((e) => VaccineSession.fromJson(e)).toList() : null,
        isSubcribed = json["isSubcribed"] ?? false;

  int getSlots() {
    if (sessions == null) return 0;
    return sessions.fold(0, (preValue, element) => preValue + element.available_capacity);
  }

  String getNextSlotOn() {
    if (sessions == null || sessions.length == 0) return "Nil";
    return sessions[0].date;
  }

  // Map<String, dynamic> toMap() => {
  //   'name': this.name, 
  //   'pinCode': this.pinCode, 
  //   'area': area,
  //   'vaccineFee': this.vaccineFee, 
  //   'isCovaxinAvailable': this.isCovaxinAvailable, 
  //   'is18StartedHere': this.is18StartedHere, 
  //   'isSlotAvailableFor18plus': this.isSlotAvailableFor18plus
  // };
}