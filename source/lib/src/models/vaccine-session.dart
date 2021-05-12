class VaccineSession {
  final String session_id;
  final String date;
  final int available_capacity;
  final int min_age_limit;
  final String vaccine;

  VaccineSession(this.session_id, this.date, this.available_capacity,
                 this.min_age_limit, this.vaccine);

  VaccineSession.fromJson(Map<String, dynamic> json)
      : session_id = json["session_id"], 
        date = json["date"],
        available_capacity = json["available_capacity"],
        min_age_limit = json["min_age_limit"],
        vaccine = json["vaccine"];

  // Map<String, dynamic> toMap() => {
  //   'date': this.date, 
  //   'currentAvailableCapacity': this.currentAvailableCapacity, 
  //   'ageLimit': ageLimit,
  //   'vaccine': this.vaccine
  // };
}