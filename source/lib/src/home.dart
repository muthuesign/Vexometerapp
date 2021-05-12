
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

  @override
  void initState() {
    super.initState();
  }

  Future<List<VaccineCentre>> _getVaccineCentre() async {
    _pinCode = await GeoFinder.getPinCodeByMyLoction();
    _pinCode = "560017";
    var response = await HttpService.get<dynamic>("https://vaxometer.azurewebsites.net/api/v1/Vaxometer/Centers/pincode/" + _pinCode );
    var vaccCentres = List.generate(response.length,
        (i) => VaccineCentre.fromJson(response[i]));
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
  
  bool isAge45 = true;

   Widget buildBar(BuildContext context) {
    return new AppBar(
        leadingWidth: 35.0,
        leading: IconButton(iconSize: 20.0, icon: Icon(Icons.list, color: Colors.white), onPressed: () {
            
          }),
        
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: Container(
            height: 45.0,
            padding: EdgeInsets.symmetric(vertical: 0.0),
            color: Colors.white30,
            child: Wrap(
                
                direction: Axis.horizontal,
                children: <Widget>[
                  
                ListTileTheme(
                  horizontalTitleGap: 0.0,
                  style: ListTileStyle.list,
                  dense: true,
            contentPadding: EdgeInsets.zero,
            child: CheckboxListTile(
                  title: Text("45+"),
                  value: isAge45,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (bool value) {
                    
                  },
                  controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                )),
                ListTileTheme(
                  horizontalTitleGap: 0.0,
                  style: ListTileStyle.list,
                  dense: true,
            contentPadding: EdgeInsets.zero,
            child: CheckboxListTile(
                  title: Text("18+"),
                  value: isAge45,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (bool value) {
                    
                  },
                  controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                )),
                
              ],
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
          new IconButton(iconSize: 20.0, icon: Icon(Icons.search, color: Colors.white), onPressed: () {
            
          },),
          new IconButton(iconSize: 20.0, icon: Icon(Icons.filter_alt_outlined, color: Colors.white), onPressed: () {
            
          },)
        ]
    );
  }
}