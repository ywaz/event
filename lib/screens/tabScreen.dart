import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/createEvent.dart';
import '../widgets/eventsList.dart';
import '../providers/event.dart';

class TabScreen extends StatelessWidget {
  int initialIndexTab = 0;
  TabScreen(this.initialIndexTab);
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndexTab,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Manage Your Events',),
            centerTitle: true,
            elevation: 4,
            bottom: TabBar(tabs: <Widget>[
              Tab(
                iconMargin: EdgeInsets.all(1),
                icon: Icon(
                  Icons.create,
                ),
                text: 'Create',
                
              ),
            Tab(
                iconMargin: EdgeInsets.all(1),
                icon: Icon(Icons.event),
                text: 'Events',
              )
            ]),
          ),
          body: TabBarView(children: <Widget>[
            CreateEvent(),
            EventsList(),
          ]),
        ));
  }
}
