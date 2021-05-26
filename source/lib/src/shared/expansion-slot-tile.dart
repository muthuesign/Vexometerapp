import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaxometer/src/models/vaccine-centre.dart';

const Duration _kExpand = Duration(milliseconds: 200);

class ExpansionSlotTile extends StatefulWidget {
  final VaccineCentre _vaccineCentre;
  final Future<void> Function(int centreId, bool isSubscribe) callBack;
  
  const ExpansionSlotTile(this._vaccineCentre, {
    Key key,
    this.callBack,
    this.onExpansionChanged,
    this.initiallyExpanded = false,
  }) : super(key: key);

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool> onExpansionChanged;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  @override
  _ExpansionSlotTileState createState() => _ExpansionSlotTileState();
}

class _ExpansionSlotTileState extends State<ExpansionSlotTile> with SingleTickerProviderStateMixin {
  VaccineCentre _vaccineCentre;
  static final Animatable<double> _easeOutTween = CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  AnimationController _controller;
  Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _vaccineCentre = widget._vaccineCentre;

    _isExpanded = PageStorage.of(context)?.readState(context) as bool ?? widget.initiallyExpanded;
    if (_isExpanded)
      _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted)
            return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null)
      widget.onExpansionChanged(_isExpanded);
  }

  Widget _expansionTile() {
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
                          Text("Next Slot on: " + _vaccineCentre.getNextSlotOn(), style: TextStyle(fontSize: 13.0, color: Colors.green))
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
                    GestureDetector(
                      child: Text(_vaccineCentre.getSlots().toString() + ' slots', style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                      onTap: _handleTap
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
                        if (_vaccineCentre.getSlots() > 0) {
                          //Book 
                          var bookUrl = "https://selfregistration.cowin.gov.in/";
                          await canLaunch(bookUrl) ? await launch(bookUrl) : 
                              Toast.show("Unable to redirect to book", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                        } else {
                          //Notify call
                          _vaccineCentre.isSubcribed = !_vaccineCentre.isSubcribed;
                          await widget.callBack(_vaccineCentre.center_id, _vaccineCentre.isSubcribed);
                        }
                      },
                      child: Text(_vaccineCentre.getSlots() > 0 ? 'Book Now': (!_vaccineCentre.isSubcribed ? 'Notify Me': "Unsubscribe")),
                    ))
                  ],
                ) 
              )
            ],
          ),
        ),
    );
  }

  Widget _buildChildren() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.blue[100], Colors.blue[50]])
      ),
      child: ListView.separated(
             padding: EdgeInsets.all(0.0),
             shrinkWrap: true,
              itemCount: _vaccineCentre.sessions == null ? 1 : _vaccineCentre.sessions.length + 1,
              itemBuilder: (context, index) {
                if (index == 0)
                {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.blue[100], Colors.blue[100]])
                    ),
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(padding: EdgeInsets.all(2.0), width: 75.0, child:Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0))),
                        Container(padding: EdgeInsets.all(2.0), width: 35.0, child:Text("Age", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0))),
                        Container(padding: EdgeInsets.all(2.0), width: 80.0, child:Text("Vaccine", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0))),
                        Container(padding: EdgeInsets.all(2.0), width: 40.0, child:Text("Slots", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)))
                      ],
                    )
                  );
                }
                index -= 1;
                return Container(
                    color: Colors.blue[50],
                    height: 30,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(padding: EdgeInsets.all(2.0), width: 75.0, child:Text(_vaccineCentre.sessions[index].date, style: TextStyle(fontSize: 12.0))),
                      Container(padding: EdgeInsets.all(2.0), width: 35.0, child:Text(_vaccineCentre.sessions[index].min_age_limit.toString(), style: TextStyle(fontSize: 12.0))),
                      Container(padding: EdgeInsets.all(2.0), width: 80.0, child:Text(_vaccineCentre.sessions[index].vaccine, style: TextStyle(fontSize: 12.0))),
                      Container(padding: EdgeInsets.all(2.0), width: 40.0, child:Text(_vaccineCentre.sessions[index].available_capacity.toString(), textAlign: TextAlign.right, style: TextStyle(fontSize: 12.0)))
                    ],
                  ));
                },
                separatorBuilder: (context, index) {
                  return Divider(height: 0.0,);
                }
              )
    );
  }

  Widget _buildTile(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        // border: Border(
        //   top: BorderSide(color: borderSideColor),
        //   bottom: BorderSide(color: borderSideColor),
        // ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _expansionTile(),
          ClipRect(
            child: Align(
              alignment: Alignment.center,
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _borderColorTween.end = theme.dividerColor;
    _headerColorTween
      ..begin = theme.textTheme.subtitle1?.color
      ..end = theme.accentColor;
    _iconColorTween
      ..begin = theme.unselectedWidgetColor
      ..end = theme.accentColor;
    // _backgroundColorTween
    //   ..begin = widget.collapsedBackgroundColor
    //   ..end = widget.backgroundColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    final bool shouldRemoveChildren = closed;

    final Widget result = Offstage(
      child: TickerMode(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildChildren()
            ],
          ),
        ),
        enabled: !closed,
      ),
      offstage: closed
    );

    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildTile,
      child: shouldRemoveChildren ? null : result,
    );
  }
}
