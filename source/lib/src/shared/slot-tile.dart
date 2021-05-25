import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaxometer/src/models/vaccine-centre.dart';
import 'package:vaxometer/src/models/vaccine-session.dart';
import 'package:vaxometer/src/shared/slot-modal.dart';

class SlotTile extends StatelessWidget {
  final CentersViewModel _vaccineCentre;
   Map<String, bool> _vaccineTypes;
   Map<String, bool> ageFilter;
  Map<String, String> _nextAvailableslots = {"Dose" : "-"};
  final Future<void> Function(int centreId, bool isSubscribe) callBack;

  SlotTile(this._vaccineCentre,this._vaccineTypes,this.ageFilter, {this.callBack});
  // SlotTile(this._vaccineCentre, {this.callBack});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      padding: EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.blue[100], Colors.blue[50]])
      ),
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.hardEdge,
        child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(padding: EdgeInsets.all(6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(child: Text(_vaccineCentre.name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),),
                          onTap: () {
                            
                          }
                        ),
                        InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_pin, color: Colors.grey, size: 14.0),
                               Flexible(
               child:Text(_vaccineCentre.address ?? _vaccineCentre.block_name, style: TextStyle(fontSize: 11.0, color: Colors.grey)))
                            ],),
                          onTap: () {
                            
                          }
                        )
                      ],
                    ),
                    Container(
                      height: 20.0,
                      padding: EdgeInsets.only(top: 5.0),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: Color.fromRGBO(171, 187, 191, 1), width: 1))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(_vaccineCentre.fee_type, style: TextStyle(fontSize: 13.0, color: Colors.orange)),
                          Text("Next Slot on: " + _nextAvailableslots["Dose"], style: TextStyle(fontSize: 13.0, color: Colors.green)),
                        ]
                      )
                    ),
                    
                ]),)
              ),
              Container(
                height: 100.0,
                width: 80.0,
                padding: EdgeInsets.only(bottom: 10.0, top: 15.0),
                decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100], Colors.blue[100]],
                ),
              ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // InkResponse(
                    //   onTap: () async {
                    //     await showDialog(
                    //       context: context,
                    //       builder: (context) =>
                    //           SlotModal(
                    //               _vaccineCentre.sessions),
                    //     ).then((val) {
                          
                    //     });
                    //   },
                    //   child: CircleAvatar(
                    //     child: Text(_vaccineCentre.getSlots().toString(), style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                    //     foregroundColor: Colors.white,
                    //     backgroundColor: Colors.white,
                    //   ),
                    // ),

                    GestureDetector(
                      child: Text(getSlots().toString() + ' slots', style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                      //   child: Text(_vaccineCentre.getSlots().toString() + ' slots', style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (context) =>
                              SlotModal(
                                  filterSessions(),_vaccineTypes),
                        ).then((val) {
                          
                        });
                      }
                    ),
                    Container(
                    height: 20.0,
                    child: ElevatedButton(
                      clipBehavior: Clip.hardEdge,
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(fontSize: 11.0),
                        padding: EdgeInsets.all(0.0),
                        primary: Colors.blue[700], // background
                        onPrimary: Colors.white, // foreground
                      ),
                      onPressed: () async { 
                        if (getSlots() > 0) {
                          //Book 
                          var bookUrl = "https://selfregistration.cowin.gov.in/";
                          await canLaunch(bookUrl) ? await launch(bookUrl) : 
                              Toast.show("Unable to redirect to book", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                        } else {
                          //Notify call
                          _vaccineCentre.isSubcribed = !_vaccineCentre.isSubcribed;
                          await callBack(_vaccineCentre.center_id, _vaccineCentre.isSubcribed);
                        }
                      },
                      child: Text(getSlots() > 0 ? 'Book Now': (!_vaccineCentre.isSubcribed ? 'Notify Me': "Unsubscribe")),
                    ))
                  ],
                ) 
              )
            ],
          ),
        ),
    );
  }
  int getSlots() {
    if (ageFilter["age18"] && ageFilter["age45"] && _vaccineTypes["Dose 1"] &&
        _vaccineTypes["Dose 2"]) {
      // _nextAvailableslots["Dose 1"] = _vaccineCentre.nextAvailableSlot_Dose1;
      // _nextAvailableslots["Dose 2"] = _vaccineCentre.nextAvailableSlot_Dose2;
      if (_vaccineCentre.nextAvailableSlot_Dose1 != null &&
          _vaccineCentre.nextAvailableSlot_Dose2 != null)
        _nextAvailableslots["Dose"] =
            (_vaccineCentre.nextAvailableSlot_Dose1.compareTo(
                _vaccineCentre.nextAvailableSlot_Dose2) > 0 ? _vaccineCentre
                .nextAvailableSlot_Dose2 : _vaccineCentre
                .nextAvailableSlot_Dose1).toString();
      else
        _nextAvailableslots["Dose"] =
            ((_vaccineCentre.nextAvailableSlot_Dose1 ??
                _vaccineCentre.nextAvailableSlot_Dose2) ?? "-").toString();
      return _vaccineCentre.getSlots();
    }
    if (ageFilter["age18"] && ageFilter["age45"] && _vaccineTypes["Dose 1"] &&
        !_vaccineTypes["Dose 2"]) {
      // _nextAvailableslots["Dose 1"] = _vaccineCentre.nextAvailableSlot_Dose1;
      // _nextAvailableslots["Dose 2"] = _vaccineCentre.nextAvailableSlot_Dose2;
      if (_vaccineCentre.nextAvailableSlot18_Dose1 != null &&
          _vaccineCentre.nextAvailableSlot45_Dose1 != null)
        _nextAvailableslots["Dose"] =
            (_vaccineCentre.nextAvailableSlot18_Dose1.compareTo(
                _vaccineCentre.nextAvailableSlot45_Dose1) > 0 ? _vaccineCentre
                .nextAvailableSlot45_Dose1 : _vaccineCentre
                .nextAvailableSlot18_Dose1).toString();
      else
        _nextAvailableslots["Dose"] =
            ((_vaccineCentre.nextAvailableSlot18_Dose1 ??
                _vaccineCentre.nextAvailableSlot45_Dose1) ?? "-").toString();
      return _vaccineCentre.totalAvailableCapacityDose1_18 ??
          0 + _vaccineCentre.totalAvailableCapacityDose1_45 ?? 0;
    }
    if (ageFilter["age18"] && ageFilter["age45"] && !_vaccineTypes["Dose 1"] &&
        _vaccineTypes["Dose 2"]) {
      if (_vaccineCentre.nextAvailableSlot18_Dose2 != null &&
          _vaccineCentre.nextAvailableSlot45_Dose2 != null)
        _nextAvailableslots["Dose"] =
            (_vaccineCentre.nextAvailableSlot18_Dose2.compareTo(
                _vaccineCentre.nextAvailableSlot45_Dose2) > 0 ? _vaccineCentre
                .nextAvailableSlot45_Dose2 : _vaccineCentre
                .nextAvailableSlot18_Dose2).toString();
      else
        _nextAvailableslots["Dose"] =
            ((_vaccineCentre.nextAvailableSlot18_Dose2 ??
                _vaccineCentre.nextAvailableSlot45_Dose2) ?? "-").toString();

      return _vaccineCentre.totalAvailableCapacityDose2_18 ??
          0 + _vaccineCentre.totalAvailableCapacityDose2_45 ?? 0;
    }
    if (ageFilter["age18"] && !ageFilter["age45"] && _vaccineTypes["Dose 1"] &&
        _vaccineTypes["Dose 2"]) {
      if (_vaccineCentre.nextAvailableSlot18_Dose1 != null &&
          _vaccineCentre.nextAvailableSlot18_Dose2 != null)
        _nextAvailableslots["Dose"] =
            (_vaccineCentre.nextAvailableSlot18_Dose1.compareTo(
                _vaccineCentre.nextAvailableSlot18_Dose2) > 0 ? _vaccineCentre
                .nextAvailableSlot18_Dose2 : _vaccineCentre
                .nextAvailableSlot18_Dose1).toString();
      else
        _nextAvailableslots["Dose"] =
            ((_vaccineCentre.nextAvailableSlot18_Dose2 ??
                _vaccineCentre.nextAvailableSlot18_Dose1) ?? "-").toString();

      return _vaccineCentre.totalAvailableCapacityDose1_18 ??
          0 + _vaccineCentre.totalAvailableCapacityDose2_18 ?? 0;
    }
    if (!ageFilter["age18"] && ageFilter["age45"] && _vaccineTypes["Dose 1"] &&
        _vaccineTypes["Dose 2"]) {
      if (_vaccineCentre.nextAvailableSlot45_Dose1 != null &&
          _vaccineCentre.nextAvailableSlot45_Dose2 != null)
        _nextAvailableslots["Dose"] =
            (_vaccineCentre.nextAvailableSlot45_Dose1.compareTo(
                _vaccineCentre.nextAvailableSlot45_Dose2) > 0 ? _vaccineCentre
                .nextAvailableSlot45_Dose2 : _vaccineCentre
                .nextAvailableSlot45_Dose1).toString();
      else
        _nextAvailableslots["Dose"] =
            ((_vaccineCentre.nextAvailableSlot45_Dose2 ??
                _vaccineCentre.nextAvailableSlot45_Dose1) ?? "-").toString();

      return _vaccineCentre.totalAvailableCapacityDose1_45 ??
          0 + _vaccineCentre.totalAvailableCapacityDose2_45 ?? 0;
    }
    if (!ageFilter["age18"] && ageFilter["age45"] && !_vaccineTypes["Dose 1"] &&
        _vaccineTypes["Dose 2"]) {
      _nextAvailableslots["Dose"] =
          (_vaccineCentre.nextAvailableSlot45_Dose2 ?? "-").toString();
      return _vaccineCentre.totalAvailableCapacityDose2_45 ?? 0;
    }
    if (!ageFilter["age18"] && ageFilter["age45"] && _vaccineTypes["Dose 1"] &&
        !_vaccineTypes["Dose 2"]) {
      _nextAvailableslots["Dose"] =
          (_vaccineCentre.nextAvailableSlot45_Dose1 ?? "-").toString();
      return _vaccineCentre.totalAvailableCapacityDose1_45 ?? 0;
    }
    if (ageFilter["age18"] && !ageFilter["age45"] && !_vaccineTypes["Dose 1"] &&
        _vaccineTypes["Dose 2"]) {
      _nextAvailableslots["Dose"] =
          (_vaccineCentre.nextAvailableSlot18_Dose2 ?? "-").toString();
      return _vaccineCentre.totalAvailableCapacityDose2_18 ?? 0;
    }
    if (ageFilter["age18"] && !ageFilter["age45"] && _vaccineTypes["Dose 1"] &&
        !_vaccineTypes["Dose 2"]) {
      _nextAvailableslots["Dose"] =
          (_vaccineCentre.nextAvailableSlot18_Dose1 ?? "-").toString();
      return _vaccineCentre.totalAvailableCapacityDose2_18 ?? 0;
    }
    return 0;
  }

 List<VaccineSession> filterSessions() {
    if(!ageFilter["age18"]){
      _vaccineCentre.sessions.removeWhere((element) => element.min_age_limit == 18);
    }
    if(!ageFilter["age45"]){
      _vaccineCentre.sessions.removeWhere((element) => element.min_age_limit == 45);
    }
    return _vaccineCentre.sessions;
  }
}