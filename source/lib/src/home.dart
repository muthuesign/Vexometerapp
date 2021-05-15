
import 'package:flutter/material.dart';
import 'package:vaxometer/src/shared/services/geo-finder.dart';
import 'package:vaxometer/src/shared/services/http-service.dart';
import './shared/slot-tile.dart';
import 'models/vaccine-centre.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<VaccineCentre>> _vaccineCentres;
  String _pinCode;
  var _vacCentrefilters = [true, true, true, true];

  @override
  void initState() {
    super.initState();
  }

  Future<List<VaccineCentre>> _getVaccineCentre() async {
    _pinCode = await GeoFinder.getPinCodeByMyLoction();
    _pinCode = "560017";
    var response = await HttpService.get<dynamic>("https://vaxometerindia.azurewebsites.net/api/v1/Vaxometer/Centers/pincode/" + _pinCode );
    var vaccCentres = List.generate(response.length,
        (i) => VaccineCentre.fromJson(response[i]));

    // vaccCentres = vaccCentres.where((ele) => 
    //   (!_vacCentrefilters[0] || (ele.sessions != null && ele.sessions.any((a) => a.min_age_limit <= 18))) 
    //   && (!_vacCentrefilters[1] || (ele.sessions != null && ele.sessions.any((a) => a.min_age_limit <= 45))) 
    //   && (!_vacCentrefilters[2] || ele.fee_type == 'Free')
    //   &&  (!_vacCentrefilters[3] || ele.fee_type == 'Paid')
    // );

    return vaccCentres;
  }

  ListView _vaccineCentreListView(data) {
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: data.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SlotTile(data[index], callBack: (int index) async {
            await _pullRefresh();
          });
        });
  }

  Future<void> _pullRefresh() async {
    _vaccineCentres = Future.value(_getVaccineCentre());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildBar(context),
        body: FutureBuilder<List<VaccineCentre>>(
              future: _getVaccineCentre(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  List<VaccineCentre> data = snapshot.data;
                  return RefreshIndicator(
                      child: _vaccineCentreListView(data),
                      onRefresh: () =>
                          _pullRefresh());
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else {
                  return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 100.0),
                      child: Text("No records found " + _pinCode,
                        textAlign: TextAlign.center,
                      ));
                }
              },
            ),
    );
  }
  
  
  Widget buildBar(BuildContext context) {
    return new AppBar(
      leadingWidth: 35.0,
      flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(55, 167, 148, 1), Color.fromRGBO(181, 220, 202, 1)],
              ),
            ),
          ),
      // leading: IconButton(iconSize: 20.0, icon: Icon(Icons.list, color: Colors.white), onPressed: () {
          
      //   }),
      
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(35.0),
        child: Container(
          height: 35.0,
          padding: EdgeInsets.symmetric(vertical: 2.0),
          color: Colors.white30,
          child: ToggleButtons(
              borderColor: Colors.blueGrey,
              fillColor: Colors.white,
              borderRadius: BorderRadius.circular(2.0),
              selectedBorderColor: Colors.blue,
              color: Colors.blueGrey,
              children: <Widget>[
                Container(width: (MediaQuery.of(context).size.width - 5)/4, child:Text("18+", textAlign: TextAlign.center)),
                Container(width: (MediaQuery.of(context).size.width - 5)/4, child:Text("45+", textAlign: TextAlign.center)),
                Container(width: (MediaQuery.of(context).size.width - 5)/4, child:Text("Free", textAlign: TextAlign.center)),
                Container(width: (MediaQuery.of(context).size.width - 5)/4, child:Text("Paid", textAlign: TextAlign.center))
              ],
              onPressed: (int index) {
                setState(() {
                  _vacCentrefilters[index] = !_vacCentrefilters[index];
                });
              },
              isSelected: _vacCentrefilters
            )
        ),
      ),
      title: Container(
        height: 25.0,
        child: TextField(
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.white24),
            contentPadding: EdgeInsets.all(5.0),
            hintText: 'Search center',
            isDense: true
          ),
        ),
      ),
      actions: <Widget>[
        new IconButton(iconSize: 20.0, icon: Icon(Icons.search, color: Colors.black), onPressed: () {
          
        })//,
        // new IconButton(iconSize: 20.0, icon: Icon(Icons.filter_alt_outlined, color: Colors.white), onPressed: () {
          
        // },)
      ]
    );
  }
}