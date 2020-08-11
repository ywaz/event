import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/event.dart';

class ParticipantsList extends StatelessWidget {
  static const String routeName = '/ParticipantsList';

  String validateName(String name) {
    if (name.isEmpty) {
      return 'Please Enter a name';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<Events>(context);
    final routeArguments = ModalRoute.of(context).settings.arguments as int;
    final EventItem _displayedEvent = events.eventsList[routeArguments];

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            _displayedEvent.title,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: _displayedEvent.participants.length,
          itemBuilder: (BuildContext ctx, index) {
            return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) =>
                  events.removeParticipant(index, routeArguments),
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
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: _displayedEvent.participants[index]['isIn']
                    ? Theme.of(context).canvasColor
                    : Colors.red[100],
                elevation: 5,
                child: CheckboxListTile(
                  title: Text(
                    _displayedEvent.participants[index]['name'],
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.8,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _displayedEvent.participants[index]['isIn']
                      ? true
                      : false,
                  onChanged: (tmp) =>
                      events.toggleParticipant(tmp, routeArguments, index),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController nameController =
              TextEditingController(); //the nameController takes every information of name input field below
          bool checkBoxValue = false;
          bool errorText = false;

          return showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    elevation: 5,
                    title: Text(
                      'Wanna Join?',
                      textScaleFactor: 1.5,
                      textAlign: TextAlign.center,
                    ),
                    content: Row(children: <Widget>[
                      Flexible(
                        flex: 7,
                        child: TextField(
                          controller: nameController,
                          showCursor: false,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            icon: Icon(Icons.person),
                            errorText: errorText ? 'Name used or empty' : null,
                          ),
                        ),
                      ),
                      Flexible(
                          flex: 2,
                          child: Checkbox(
                              value: checkBoxValue,
                              onChanged: (tmp) {
                                setState(() {
                                  checkBoxValue = tmp;
                                });
                              }))
                    ]),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            //verify if the name field isn't empty & add the name to the participants list with 'isin' value set to checkbox's
                            events
                                .addParticipant(nameController.text,
                                    checkBoxValue, routeArguments)
                                .then((value) {
                              if (value) {
                                Navigator.of(context)
                                    .pop(); //get rid of the message box
                                nameController.clear();
                              } else {
                                setState(() {
                                  errorText = true;
                                });
                              }
                            });
                          },
                          child: Text('Ok'))
                    ],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  );
                });
              });
        },
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            'Join',
            textScaleFactor: 1.2,
            textAlign: TextAlign.center,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 7,
        backgroundColor: Theme.of(context).accentColor,
        splashColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
