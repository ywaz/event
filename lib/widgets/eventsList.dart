import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/participantsList.dart';
import '../providers/event.dart';

class EventsList extends StatefulWidget {
  static const String routeName = '/EventsList';

  @override
  _EventsListState createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  bool _isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _isLoading = true;
    Provider.of<Events>(context, listen: false).fetchEvents().then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          'Something went wrong',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
      throw error;
    });
    // setup a listner on the image url focusNode

    super.initState();
  }

  Future _dialogAlert(BuildContext ctx) {
    return showDialog(
        context: ctx,
        barrierDismissible: true,
        builder: (ctx) {
          return AlertDialog(
            elevation: 5,
            title: Text(
              'Are you sure?',
              textScaleFactor: 2,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text('Yes'))
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          );
        });
  }

  Widget _buildTrailing(
      Map<String, String> items, int index, List<EventItem> events) {
    return FittedBox(
      child: Row(children: <Widget>[
        Text(
          items['in'],
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          width: 4,
        ),
        Icon(
          Icons.check,
          color: Colors.green,
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          items['out'],
          style: TextStyle(fontSize: 18),
        ),
        Icon(
          Icons.close,
          color: Colors.red[400],
        ),
      ]),
    );
  }

  Widget _buildSubtitle(String date, String place, String time) {
    return Row(
      children: <Widget>[
        Text(date),
        if (time != null)
          SizedBox(
            width: 7,
          ),
        if (time != null) Text(time),
        SizedBox(
          width: 10,
        ),
        Icon(Icons.place),
        SizedBox(
          width: 5,
        ),
        Flexible(
            fit: FlexFit.tight,
            child: Text(
              place,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _displayedEvents = Provider.of<Events>(context);

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemBuilder: (context, index) {
              return ChangeNotifierProvider.value(
                value: _displayedEvents.eventsList[index],
                child: Dismissible(
                  background: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).errorColor,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete,
                        size: 30,
                      ),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _displayedEvents.removeEvent(index);
                  },
                  confirmDismiss: (direction) {
                    return _dialogAlert(context).then((value) {
                      if (value != null && value) {
                        return true;
                      } else {
                        return false;
                      }
                    });
                  },
                  key: UniqueKey(),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Text(_displayedEvents.eventsList[index].title),
                      subtitle: _buildSubtitle(
                        _displayedEvents.eventsList[index].date,
                        _displayedEvents.eventsList[index].place,
                        _displayedEvents.eventsList[index].time,
                      ),
                      trailing: _buildTrailing(
                          _displayedEvents.countParticipants(index),
                          index,
                          _displayedEvents.eventsList),
                      onTap: () => Navigator.of(context).pushNamed(
                          ParticipantsList.routeName,
                          arguments: index),
                    ),
                  ),
                ),
              );
            },
            itemCount: _displayedEvents.countEvent,
          );
  }
}
