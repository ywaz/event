import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/http_handler.dart';

class EventItem with ChangeNotifier {
  final String id;
  String title;
  String date;
  String time;
  String place;
  String comment;
  List participants;

  EventItem(
      {@required this.id,
      @required this.title,
      @required this.date,
      this.time,
      @required this.place,
      this.comment,
      @required this.participants});
}

class Events with ChangeNotifier {
  List<EventItem> _eventsList = [];

  //   EventItem(
  //     id: '1',
  //     title: 'Barbecue',
  //     place: 'Nice',
  //     date: '12/06/2020',
  //     comment: 'tchnchit',
  //     participants: [
  //       {'name': 'younes', 'isIn': true},
  //       {'name': 'zakiya', 'isIn': true},
  //       {'name': 'yasser', 'isIn': true},
  //       {'name': 'badr', 'isIn': false},
  //       {'name': 'saad', 'isIn': false}
  //     ],
  //   ),
  //   EventItem(
  //     id: '2',
  //     title: 'Foot',
  //     place: 'Villeneuve',
  //     date: '15/06/2020',
  //     comment: 'Foot à sept',
  //     participants: [
  //       {'name': 'younes', 'isIn': true},
  //       {'name': 'pipou', 'isIn': false},
  //       {'name': 'yasser', 'isIn': false},
  //       {'name': 'Amine', 'isIn': true},
  //       {'name': 'Alex', 'isIn': false}
  //     ],
  //   ),
  //   EventItem(
  //     id: '3',
  //     title: 'Sortie Bateau',
  //     place: 'St laurent du var',
  //     date: '15/08/2020',
  //     comment: 'sortie bateau',
  //     participants: [],
  //   )
  // ];

  List<EventItem> get eventsList {
    return [..._eventsList];
  }

  int get countEvent {
    return _eventsList.length;
  }

  Future<void> fetchEvents() async {
    const url = 'https://flutter-course-b0254.firebaseio.com/events.json';
    List<EventItem> loadedEvents = [];
    try {
      final response = await http.get(url);
      if (response.statusCode > 400) {
        HttpException('Something went wrong');
      }
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        print('no events found');
        return;
      }
      extractedData.forEach((id, event) {
        List<Map<String, dynamic>> eventParticipants = [];
        if ((event['participants'] as List<dynamic>) != null) {
          (event['participants'] as List<dynamic>)
              .map((e) =>
                  eventParticipants.add({'name': e['name'], 'isIn': e['isIn']}))
              .toList();
        }

        loadedEvents.add(EventItem(
            id: id,
            title: event['title'],
            date: event['date'],
            time: event['time'],
            place: event['place'],
            participants: eventParticipants));
      });

      _eventsList = loadedEvents;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addEvent(EventItem value) async {
    const url = 'https://flutter-course-b0254.firebaseio.com/events.json';

    try {
      final response = await http.post(url,
          body: jsonEncode({
            'title': value.title,
            'place': value.place,
            'comment': value.comment,
            'date': value.date,
            'time': value.time,
            'participants': value.participants,
          }));
      if (response.statusCode > 400) {
        HttpException(response.body);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> removeEvent(int id) async {
    String url =
        'https://flutter-course-b0254.firebaseio.com/events/${_eventsList[id].id}.json';
    try {
      final response = await http.delete(url);
      if (response.statusCode > 400) {
        HttpException(response.body);
      }
      _eventsList.removeAt(id);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

//Participants methodds

  Map<String, String> countParticipants(int index) {
    int _i = 0;
    int _j = 0;
    for (var person in _eventsList[index].participants) {
      person['isIn'] ? _i++ : _j++;
    }
    return {'in': _i.toString(), 'out': _j.toString()};
  }

  Future<void> toggleParticipant(
      bool newValue, int eventIndex, int participantIndex) async {
    String url =
        'https://flutter-course-b0254.firebaseio.com/events/${_eventsList[eventIndex].id}.json';
    bool oldValue =
        _eventsList[eventIndex].participants[participantIndex]['isIn'];
    try {
      _eventsList[eventIndex].participants[participantIndex]['isIn'] = newValue;
      notifyListeners();

      final response = await http.patch(url,
          body: jsonEncode(
              {'participants': _eventsList[eventIndex].participants}));
      if (response.statusCode > 400) {
        _eventsList[eventIndex].participants[participantIndex]['isIn'] =
            oldValue;
        HttpException(response.body);
      }
    } catch (error) {
      _eventsList[eventIndex].participants[participantIndex]['isIn'] = oldValue;
      throw error;
    }
  }

  bool equalsIgnoreCase(String string1, String string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  Future<bool> addParticipant(
      String name, bool availability, int eventIndex) async {
    //check if the name exists in the list
    String url =
        'https://flutter-course-b0254.firebaseio.com/events/${_eventsList[eventIndex].id}.json';
    var _search = _eventsList[eventIndex].participants.any((personItem) =>
        equalsIgnoreCase(personItem['name'],
            name)); //equalsIgnorecase checks casesensitivity as well

    if (name.isNotEmpty && !_search) {
      _eventsList[eventIndex]
          .participants
          .add({'name': name, 'isIn': availability});

      try {
        await http.patch(url,
            body: jsonEncode(
                {'participants': _eventsList[eventIndex].participants}));
        notifyListeners();
        return true;
      } catch (error) {
        throw error;
      }
    } else {
      return false;
    }
  }

  Future<void> removeParticipant(int participantIndex, int eventIndex) async {
    String url =
        'https://flutter-course-b0254.firebaseio.com/events/${_eventsList[eventIndex].id}.json';
    var removedParticipant =
        _eventsList[eventIndex].participants[participantIndex];
    _eventsList[eventIndex].participants.removeAt(participantIndex);
    notifyListeners();
    try {
      final response = await http.patch(url,
          body: jsonEncode(
              {'participants': _eventsList[eventIndex].participants}));
      if (response.statusCode > 400) {
        _eventsList[eventIndex]
            .participants
            .insert(participantIndex, removedParticipant);
        notifyListeners();
        HttpException(response.body);
      }
    } catch (error) {
      _eventsList[eventIndex]
          .participants
          .insert(participantIndex, removedParticipant);
      notifyListeners();
      throw error;
    }
    // _eventsList[eventId].participants.removeAt(participantIndex);
    // notifyListeners();
  }
}
