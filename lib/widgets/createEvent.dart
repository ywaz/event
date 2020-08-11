import 'dart:io';

import 'package:EVENT/providers/event.dart';
import 'package:EVENT/screens/tabScreen.dart';
import 'package:EVENT/widgets/eventsList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

class CreateEvent extends StatefulWidget {
  final String routeName = '/CreateEvent';

  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  final _placeFocusNode = FocusNode();
  final _commentFocusNode = FocusNode();
  EventItem createdEvent = EventItem(
      id: null,
      title: null,
      date: null,
      time: null,
      place: null,
      participants: null);

  void _presentDatePicker(BuildContext ctx, TextEditingController controller) {
    showDatePicker(
            context: ctx,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2022))
        .then((value) {
      if (value == null) {
        return;
      }
      controller.text = DateFormat.yMd().format(value);
    });
  }

  void _presentTimePicker(BuildContext ctx, TextEditingController controller) {
    showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      if (value == null) {
        return;
      }
      controller.text = value.format(ctx);
    });
  }

  @override
  void dispose() {
    _placeFocusNode.dispose();
    _commentFocusNode.dispose();
    _dateController.dispose();
    _timeController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
//title textFormField
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: TextFormField(
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.title,
                      ),
                      labelText: 'title'),
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_placeFocusNode),
                  onSaved: (value) {
                    createdEvent.title = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
//place textFormField
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: TextFormField(
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.place,
                      ),
                      labelText: 'place'),
                  focusNode: _placeFocusNode,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_commentFocusNode),
                  onSaved: (value) {
                    createdEvent.place = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter a place';
                    }
                    return null;
                  },
                ),
              ),
//Comment textFormField
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: TextFormField(
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.comment,
                      ),
                      labelText: 'comment'),
                  focusNode: _commentFocusNode,
                  onSaved: (value) {
                    createdEvent.comment = value;
                  },
                ),
              ),
//date textFormField
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  showCursor: false,
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.date_range,
                      ),
                      labelText: 'date'),
                  onTap: () {
                    _presentDatePicker(
                      context,
                      _dateController,
                    );
                    FocusScope.of(context).unfocus();
                  },
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please select a valid date';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    createdEvent.date = value;
                  },
                ),
              ),
//Time textFormField
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  showCursor: false,
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.timer,
                      ),
                      labelText: 'Time'),
                  onTap: () {
                    _presentTimePicker(
                      context,
                      _timeController,
                    );
                    FocusScope.of(context).unfocus();
                  },
                  onSaved: (value) {
                    createdEvent.time = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RaisedButton(
                        onPressed: () async {
                          //submitting the form actions
                          if (_formKey.currentState.validate()) {
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              _formKey.currentState.save();

                              await Provider.of<Events>(context, listen: false)
                                  .addEvent(createdEvent);

                              _formKey.currentState.reset();
                              _dateController.clear();
                              _timeController.clear();
                              Navigator.of(context)
                                  .pushReplacementNamed(EventsList.routeName);
                            } catch (error) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                  'Something went wrong',
                                  style: Theme.of(context).textTheme.bodyText1,
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: Theme.of(context).errorColor,
                              ));

                              throw error;
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                            //Once the event is created, go to events screen

                          } else {
                            return 'Please Correct Form Errors';
                          }
                        },
                        child: Text('Submit'),
                        color: Theme.of(context).accentColor,
                        textColor: Theme.of(context).textTheme.bodyText1.color,
                      ),
              )
            ],
          ),
        ));
  }
}
