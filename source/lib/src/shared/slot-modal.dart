
import 'package:flutter/material.dart';
import 'package:vaxometer/src/models/vaccine-session.dart';

class SlotModal extends StatefulWidget {
  final List<VaccineSession> _sessions;
  SlotModal(this._sessions, {Key key}) : super(key: key);

  @override
  _SlotModalState createState() => _SlotModalState(_sessions);
}

class _SlotModalState extends State<SlotModal> {
  final List<VaccineSession> _sessions;

  _SlotModalState(this._sessions);

  @override
  void initState() {
    super.initState();
  }

   @override
  Widget build(BuildContext context) {
    
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
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
          ListView.separated(
             padding: EdgeInsets.all(0.0),
             shrinkWrap: true,
              itemCount: _sessions == null ? 1 : _sessions.length + 1,
              itemBuilder: (context, index) {
                if (index == 0)
                {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(padding: EdgeInsets.all(2.0), width: 80.0, child:Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0))),
                      Container(padding: EdgeInsets.all(2.0), width: 40.0, child:Text("Age", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0))),
                      Container(padding: EdgeInsets.all(2.0), width: 80.0, child:Text("Vaccine", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0))),
                      Container(padding: EdgeInsets.all(2.0), width: 50.0, child:Text("Slots", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)))
                    ],
                  );
                }
                index -= 1;
                return
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(padding: EdgeInsets.all(2.0), width: 80.0, child:Text(_sessions[index].date, style: TextStyle(fontSize: 12.0))),
                      Container(padding: EdgeInsets.all(2.0), width: 40.0, child:Text(_sessions[index].min_age_limit.toString(), style: TextStyle(fontSize: 12.0))),
                      Container(padding: EdgeInsets.all(2.0), width: 80.0, child:Text(_sessions[index].vaccine, style: TextStyle(fontSize: 12.0))),
                      Container(padding: EdgeInsets.all(2.0), width: 50.0, child:Text(_sessions[index].available_capacity.toString(), style: TextStyle(fontSize: 12.0)))
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider();
                }
              )
        ]
      )
    );
  }
}