class VaccineSession {
  final String session_id;
  final String date;
  final int available_capacity;
  final int available_capacity_dose1;
  final int available_capacity_dose2;
  final int min_age_limit;
  final String vaccine;
  final List<String> slots;

  VaccineSession(this.session_id, this.date, this.available_capacity, this.available_capacity_dose1,this.available_capacity_dose2,
                 this.min_age_limit, this.vaccine,this.slots);

  VaccineSession.fromJson(Map<String, dynamic> json)
      : session_id = json["session_id"], 
        date = json["date"],
        available_capacity = json["available_capacity"],
        min_age_limit = json["min_age_limit"],
        vaccine = json["vaccine"],
        available_capacity_dose1 = json["available_capacity_dose1"],
        available_capacity_dose2 = json["available_capacity_dose2"],
        slots = json["slots"] != null ? new List<String>.from(json["slots"]) : null;


  bool hasSlots() => slots != null && slots.isNotEmpty;
}