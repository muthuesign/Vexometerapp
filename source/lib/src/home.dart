
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toast/toast.dart';
import 'package:vaxometer/src/globals.dart' as globals;
import 'package:vaxometer/src/models/vaccine-session.dart';
import 'package:vaxometer/src/shared/expansion-slot-tile.dart';
import 'package:vaxometer/src/shared/loader.dart';
import 'package:vaxometer/src/shared/services/geo-finder.dart';
import 'package:vaxometer/src/shared/services/vaxometer-service.dart';
import 'models/vaccine-centre.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _deviceId;
  TextEditingController _searchController = new TextEditingController();
  VaxometerService _vaxometerService = new VaxometerService();
  GoogleMapController _mapController;
  TabController _tabController;
  LatLngBounds _mBounds = LatLngBounds(
      southwest: const LatLng(-38.483935, 113.248673),
      northeast: const LatLng(-8.982446, 153.823821),
    );
  Future<List<VaccineCentre>> _futureVaccineCentres;
  List<VaccineCentre> _vaccineCentres;
  List<VaccineCentre> _filteredVaccineCentres;
  String _pinCode = "";
  bool isPinEntered = true;
  var _vacCentrefilters = [true, true, true, true, true];
  Iterable _gMapMarkers = [];
  Map<String, bool> _vaccineTypes;
  Map<String, bool> ageFilter = {"age18": true, "age45" : true};

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });

    _futureVaccineCentres = _getVaccineCentre();

    _tabController = TabController(vsync: this, length: 2);
  }

  Future<List<VaccineCentre>> _getVaccineCentre() async {
    try {
      _vaccineCentres = null;
      _pinCode = _searchController.text.isEmpty ? await GeoFinder.getPinCodeByMyLoction(): _searchController.text;
      var vaccCentres = await _vaxometerService.getCentresByPin(globals.onesignalUserId, _pinCode);
      var centersViewModel = vaccCentres.centersViewModel;
      centersViewModel.sort((b,a) => a.getInitialSlots().compareTo(b.getInitialSlots()));
      _vaccineCentres = centersViewModel;
      _mapMarkers();
      _vaccineTypes = new Map.fromIterable(vaccCentres.vaccineTypes,
        key: (item) => item,
          value: (item) => true
        );
      _vaccineTypes["Dose 1"] = true;
      _vaccineTypes["Dose 2"] = true;
      return _vaccineCentres;
    } finally {
      Loader.close(context);
    }
  }

  bool _ageFilter(VaccineSession vs) {
    if (!_vacCentrefilters[0]) {
      ageFilter.update("age18", (value) => true);

      if(!_vacCentrefilters[1]){
        ageFilter.update("age45", (value) => true);
      } else
      ageFilter.update("age45", (value) => false);
      return vs.min_age_limit == 18;
    }
    if (!_vacCentrefilters[1]) {
      ageFilter.update("age45", (value) => true);
      if(!_vacCentrefilters[0]){
        ageFilter.update("age18", (value) => true);
      } else
        ageFilter.update("age18", (value) => false);
      return vs.min_age_limit == 45;

    }
    return true;

  }

  bool _feeTypeFilter(String feeType) {
    if (!_vacCentrefilters[2] && _vacCentrefilters[3])
      return feeType == 'Free';
    else if (_vacCentrefilters[2] && !_vacCentrefilters[3])
      return feeType == 'Paid';
    
    return true;
  }

  bool _vacTypeFilter(VaccineSession vs) {
    var vacTypes = [];
    _vaccineTypes.forEach((key, value) {
      if (value && (key!="Dose 1" && key!= "Dose 2"))
        vacTypes.add(key.toLowerCase());
     });
      
    return vacTypes.contains(vs.vaccine.toLowerCase());
  }
 void applyFilter() {
      _filteredVaccineCentres = _vaccineCentres.where((ele) => 
        (ele.sessions != null && ele.sessions.any((a) => _ageFilter(a))) 
        && _feeTypeFilter(ele.fee_type)
        && (ele.sessions != null && ele.sessions.any((a) => _vacTypeFilter(a)))

      ).toList();
      _filteredVaccineCentres.sort((b, a) => a.getSlots().compareTo(b.getSlots()));
      _setMarkers();
  }

  ListView _vaccineCentreListView() {
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredVaccineCentres.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ExpansionSlotTile(_filteredVaccineCentres[index], callBack: (int centreId, bool isSubscribe) async {
            await followCentre(centreId, isSubscribe);
            Toast.show(isSubscribe ? "Subscribed": "Un Subscribed", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
            _pullRefresh().then((value) => {
              setState(() {})
            });
          });
        });
  }

  Future<void> _pullRefresh() async {
    _futureVaccineCentres = Future.value(_getVaccineCentre());
  }

  Future<void> followCentre(int centreId, bool isSubscribe) async {
    try {
      Loader.show(context);
      await _vaxometerService.followCentre(globals.onesignalUserId, centreId, isSubscribe);
    }
    finally {
      Loader.close(context);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _mapMarkers() {
    if (_vaccineCentres == null || _vaccineCentres.isEmpty) return;
    
    var locTasks = <Future<void>>[];
    for(var vacCentre in _vaccineCentres) {
      locTasks.add(vacCentre.setGeoLocation());
    }

    Future.wait(locTasks).then((value) => _setMarkers());
  }

  void _setMarkers() {
    List<Marker> mMarkers = [];
    int index = 0;
    for(var vacCentre in _filteredVaccineCentres){
      if (vacCentre.geoLocation != null) {
        mMarkers.add(
          Marker(
            markerId: MarkerId("mId$index"),
            infoWindow: InfoWindow(
              title: vacCentre.name,
              snippet: vacCentre.address,
            ),
            position: LatLng(vacCentre.geoLocation.latitude, vacCentre.geoLocation.longitude)
          ),
        );
        index++;
      }
    }

    setState(() {
    _gMapMarkers = mMarkers.toSet();
    });

    _mBounds = _bounds(_gMapMarkers);
    if (_tabController.index == 1) {
      _moveCamaraPos();
    }
  }

  void _moveCamaraPos() {
    Future.delayed(Duration(milliseconds: 2000)).then((value) {
      _mapController.moveCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: _mBounds.southwest,
            northeast: _mBounds.northeast,
          ),
          10.0
        )
      );
    });
  }

  LatLngBounds _bounds(Set<Marker> markers) {
    if (markers == null || markers.isEmpty) return null;
    return _createBounds(markers.map((m) => m.position).toList());
  }

  LatLngBounds _createBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce((value, element) => value < element ? value : element); // smallest
    final southwestLon = positions.map((p) => p.longitude).reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce((value, element) => value > element ? value : element); // biggest
    final northeastLon = positions.map((p) => p.longitude).reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon)
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveCamaraPos();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
          length: 2,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: buildBar(context),
          body: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
            FutureBuilder<List<VaccineCentre>>(
                future: _futureVaccineCentres,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.isNotEmpty) {
                    // _vaccineCentres = _vaccineCentres ?? snapshot.data;
                    // _filteredVaccineCentres = _filteredVaccineCentres ?? _vaccineCentres;
                    return RefreshIndicator(
                        child: _vaccineCentreListView(),
                        onRefresh: () =>
                            _pullRefresh());
                  } else if (snapshot.hasError) {
                    return Align(
                        alignment: Alignment.center,
                        child: Text("${snapshot.error}",
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)));
                  } else {
                    return Align(
                        alignment: Alignment.center,
                        child: Text("No records found " + _pinCode,
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)
                        ));
                  }
                },
              ),
              GoogleMap(
                mapType: MapType.normal,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: const LatLng(
                    12.120334410922474,
                    77.62019331249995,
                  ),
                  tilt: 30.0,
                  zoom: 17.0
                ),
                markers: Set.from(
                  _gMapMarkers,
                )
              )
        ]),
      )
    );
  }
  
  void _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      color: Colors.blue[50],
      position: RelativeRect.fromLTRB(left, top, left+1, top+1),
      items: List.generate(_vaccineTypes.length, (index) => PopupMenuItem<bool>(
            child: StatefulBuilder(builder:
                  (BuildContext context, StateSetter setState) {
                    return CheckboxListTile(dense: true, selected: _vaccineTypes[_vaccineTypes.keys.elementAt(index)], contentPadding: EdgeInsets.all(0.0), 
            value: _vaccineTypes[_vaccineTypes.keys.elementAt(index)], onChanged: (bool value) {
              setState(() {
                _vaccineTypes[_vaccineTypes.keys.elementAt(index)] = value;
                applyFilter();
              });
            }, title: Text(_vaccineTypes.keys.elementAt(index)), 
            controlAffinity: ListTileControlAffinity.leading);}))),
      elevation: 0.0,
  );
}
  
  Widget buildBar(BuildContext context) {
    return new AppBar(
      leadingWidth: 35.0,
      flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue[300]],
              ),
            ),
          ),
      // leading: IconButton(iconSize: 20.0, icon: Icon(Icons.list, color: Colors.white), onPressed: () {
          
      //   }),
      
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Column(
          children: [
            Container(
                height: 35.0,
                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                color: Colors.white30,
                child: ToggleButtons(
                borderColor: Colors.white30,
                fillColor: Colors.white,
                borderRadius: BorderRadius.circular(6.0),
                selectedBorderColor: Colors.blue,
                color: Colors.blueGrey,
                children: <Widget>[
                  Container(width: (MediaQuery.of(context).size.width - 9)/5, child:Text("18+", textAlign: TextAlign.center)),
                  Container(width: (MediaQuery.of(context).size.width - 9)/5, child:Text("45+", textAlign: TextAlign.center)),
                  Container(width: (MediaQuery.of(context).size.width - 9)/5, child:Text("Free", textAlign: TextAlign.center)),
                  Container(width: (MediaQuery.of(context).size.width - 9)/5, child:Text("Paid", textAlign: TextAlign.center)),
                  Container(width: (MediaQuery.of(context).size.width - 9)/5.1, child:GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          _showPopupMenu(details.globalPosition);
                        },
                        child: Icon(Icons.filter_alt)))
                ],
                onPressed: (int index) {
                  setState(() {
                    _vacCentrefilters[index] = !_vacCentrefilters[index];
                    applyFilter();
                  });
                },
                isSelected: _vacCentrefilters
              )
            ),
            TabBar(
              controller: _tabController,
              indicator: BoxDecoration(color: Colors.blue[300]),
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              isScrollable: false,
              tabs: [
                new Container(
                    height: 30.0,
                    child: Tab(text: "List View")),
                //Tab(text: "PENDING"),
                new Container(
                    height: 30.0,
                    child: Tab(text: "Map View"))
              ])
          ],
        ),
      ),
      title: Container(
        height: 36.0,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.5),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: TextField(
          controller: _searchController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            fillColor: Colors.yellow,
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            isDense: true,
            suffixIcon: _searchController.text.isNotEmpty ? new IconButton(iconSize: 20.0, icon: new Icon(Icons.cancel), onPressed: () {
              _searchController.clear();
            }): null,
            hintStyle: TextStyle(color: Colors.grey),
            hintText: 'Search With Your Pincode',
          ),
        ),
      ),
      actions: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 15.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(fontSize: 11.0),
                        padding: EdgeInsets.all(0.0),
                        primary: Colors.blue[700], // background
                        onPrimary: Colors.white, // foreground
                      ),
	        child: Icon(Icons.search, color: Colors.white),
	          onPressed: () async {
              if(_searchController.text.isNotEmpty) {
                Loader.show(context);
                await _pullRefresh();
                setState(() {
                  isPinEntered = true;
                });
              } else {
                setState(() {
                  isPinEntered = false;
                });
              }
            },
          ),
        )
      ]
    );
  }
}