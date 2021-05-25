
import 'package:flutter/material.dart';
import 'package:vaxometer/src/models/vaccine-session.dart';

class SlotModal extends StatefulWidget {
  final List<VaccineSession> _sessions;
  final Map<String, bool> _vaccineTypes;
  SlotModal(this._sessions, this._vaccineTypes, {Key key}) : super(key: key);

  @override
  _SlotModalState createState() => _SlotModalState();
}

class _SlotModalState extends State<SlotModal> {
  // final List<VaccineSession> _sessions;

  // _SlotModalState(this._sessions);

  @override
  void initState() {
    super.initState();
  }

   @override
  Widget build(BuildContext context) {
    
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
      content: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            height: 30.0,
            width: 30.0,
            right: -25.0,
            top: -30.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop(null);
              },
              child: CircleAvatar(
                child: Icon(Icons.close),
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
                padding: EdgeInsets.all(0.0),
                shrinkWrap: true,
                itemCount: widget._sessions == null ? 1 : widget._sessions.length + 1,
                // itemCount: widget._sessions == null ? 0 : widget._sessions.length,
                itemBuilder: (context, index) {
                  if (index == 0)
                  {
                    return Container(
                        color: Colors.blue[100],
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(padding: EdgeInsets.all(2.0), width: 75.0, child:Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0))),
                            Container(padding: EdgeInsets.all(2.0), width: 35.0, child:Text("Age", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0))),
                            Container(padding: EdgeInsets.all(2.0), width: 70.0, child:Text("Vaccine", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0))),
                            Container(padding: EdgeInsets.all(2.0), width: 30.0, child:Text("Dose1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0))),
                            Container(padding: EdgeInsets.all(2.0), width: 30.0, child:Text("Dose2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)))
                          ],
                        )
                    );
                  }
                  index -= 1;
                  return
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(padding: EdgeInsets.all(2.0), width: 75.0, child:Text(widget._sessions[index].date,   style: TextStyle(fontSize: 12.0))),
                        Container(padding: EdgeInsets.all(2.0), width: 35.0, child:Text(widget._sessions[index].min_age_limit.toString(), style: TextStyle(fontSize: 12.0))),
                        Container(padding: EdgeInsets.all(2.0), width: 70.0, child:Text(widget._sessions[index].vaccine, style: TextStyle(fontSize: 12.0))),
                        Container(padding: EdgeInsets.all(2.0), width: 30.0, child:Text(widget._vaccineTypes["Dose 1"] == true? widget._sessions[index].available_capacity_dose1.toString() : "-", textAlign: TextAlign.right, style: TextStyle(fontSize: 12.0))),
                        Container(padding: EdgeInsets.all(2.0), width: 30.0, child:Text(widget._vaccineTypes["Dose 2"] == true? widget._sessions[index].available_capacity_dose2.toString() : "-", textAlign: TextAlign.right, style: TextStyle(fontSize: 12.0)))
                      ],
                    );
                },
                separatorBuilder: (context, index) {
                  return Divider();
                }
            ) ,
          )

        ]
      )
    );
  }
}