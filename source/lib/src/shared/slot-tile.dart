import 'package:flutter/material.dart';
import 'package:vaxometer/src/models/vaccine-centre.dart';

class SlotTile extends StatelessWidget {
  final VaccineCentre _vaccineCentre;
  final Future<void> Function(int index) callBack;

  SlotTile(this._vaccineCentre, {this.callBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(padding: EdgeInsets.all(4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(child: Text(_vaccineCentre.name),
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
                    Text(_vaccineCentre.fee_type, style: TextStyle(fontSize: 13.0, color: Colors.black87))
                ]),)
              ),
              Container(
                height: 100.0,
                width: 120.0,
                color: Colors.lightGreen,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_vaccineCentre.getSlots().toString())
                  ],
                ) 
              )
            ],
          ),
        ),
    );
  }
}