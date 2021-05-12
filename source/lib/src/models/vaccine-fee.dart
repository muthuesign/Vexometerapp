class VaccineFee {
  final String vaccine;
  final String fee;

  VaccineFee(this.vaccine, this.fee);

  VaccineFee.fromJson(Map<String, dynamic> json)
      : vaccine = json["vaccine"],
        fee = json["fee"];
}