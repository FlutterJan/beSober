import 'dart:convert';
import 'package:be_sober_2/couter.dart';
import 'package:be_sober_2/diff.dart';
import 'package:be_sober_2/home_widget.dart';
import 'package:be_sober_2/notifi_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

final navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification();
  var initialNotification =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (initialNotification?.didNotificationLaunchApp == true) {
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed('/another',
          arguments: initialNotification?.notificationResponse?.payload);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      color: Colors.grey,
      home: MyHomePage(),
    );
  }
}

class Adiction {
  String label;
  String emoji;
  String text;
  int money;
  String day;
  String time;

  Adiction(this.label, this.emoji, this.text, this.money, this.day, this.time);

  Map<String, dynamic> toJson() => {
        'label': label,
        'emoji': emoji,
        'text': text,
        'money': money,
        'day': day,
        'time': time,
      };

  factory Adiction.fromJson(Map<String, dynamic> json) => Adiction(
      json['label'] as String,
      json['emoji'] as String,
      json['text'] as String,
      json['money'] as int,
      json['day'] as String,
      json['time'] as String);
}

List<Adiction> addictions = [
  Adiction('Alcohol', '🍺', "Health", 50, '2015-02-27 00:00:00.000', '00;00'),
  Adiction('Coke', '🥤', "Belly", 10, '2024-06-16 21:30:00.000', '00:00'),
  Adiction('Vaping', '🚬', "Helth and money", 70, '2024-06-01 00:00:00.000',
      '00:20'),
  Adiction(
      'Masturbating', '🍆', 'Well-being', 0, '2022-09-30 00:00:00.000', '00:10')
];

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name = '';
  String? _chosenModel;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 0, minute: 0);
  DateTime _selectedDate1 = DateTime.now();
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _notificationService.initNotification();
    _loadAddictionsFromSharedPrefs();

    // Schedule a notification here for testing purposes
    _notificationService.scheduleRandomNotificationDaily(
      title: "Schedule Notification",
      body: "This is a Scheduled Notification",
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate1,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate1) {
      setState(() {
        _selectedDate1 = picked;
      });
    }
  }

  void addNewAddiction(String name, String emoji, String text, int money,
      String day, String time) {
    setState(() {
      addictions.add(Adiction(name, emoji, text, money, day, time));
    });
    _saveAddictionsToSharedPrefs();
    List<String> days = addictions.map((a) => a.day).toList();
    List<String> names =
        addictions.map((a) => a.emoji + ' ' + a.label).toList();
    updateWidgetFun(days, names);
  }

  Future<void> _loadAddictionsFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = prefs.getString('addictionsList');
    if (encodedList != null) {
      final decodedList = jsonDecode(encodedList) as List;
      setState(() {
        addictions =
            decodedList.map((item) => Adiction.fromJson(item)).toList();
      });
    } else {
      setState(() {
        addictions = [];
      });
    }
    List<String> days = addictions.map((a) => a.day).toList();
    List<String> names =
        addictions.map((a) => a.emoji + ' ' + a.label).toList();
    updateWidgetFun(days, names);
  }

  Future<void> _saveAddictionsToSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList =
        jsonEncode(addictions.map((addiction) => addiction.toJson()).toList());
    await prefs.setString('addictionsList', encodedList);

    List<String> days = addictions.map((a) => a.day).toList();
    List<String> names =
        addictions.map((a) => a.emoji + ' ' + a.label).toList();
    updateWidgetFun(days, names);
  }

  String ending(int day) {
    if (day == 1) {
      return "st";
    }
    if (day == 2) {
      return "nd";
    }
    if (day == 3) {
      return "rd";
    } else {
      return "th";
    }
  }

  bool isAble(List<Adiction> adiction) {
    if (adiction[0].label.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 18, 18, 18),
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    child: IconButton(
                      onPressed: () {
                        if (isAble(addictions)) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  "Would you like to remove something?",
                                  style: TextStyle(
                                      fontFamily: 'PlayfairDisplay',
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic),
                                ),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: screenHeight * 0.5,
                                  child: ListView.builder(
                                    itemCount: addictions.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        leading: Text(
                                          addictions[index].emoji,
                                          style: TextStyle(
                                              fontSize: screenHeight * 0.04),
                                        ),
                                        title: Text(
                                          addictions[index].label,
                                          style: TextStyle(
                                            fontFamily: 'PlayfairDisplay',
                                            fontSize: screenHeight * 0.03,
                                            color: const Color.fromARGB(
                                                190, 19, 19, 19),
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color:
                                                Color.fromARGB(180, 18, 18, 18),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              addictions.removeAt(index);
                                              _saveAddictionsToSharedPrefs();
                                              Navigator.pop(context);

                                              // Update _chosenModel here
                                              if (addictions.isEmpty) {
                                                _chosenModel =
                                                    null; // Set to null if no addictions left
                                              } else {
                                                // You can set it to the first item or another logic
                                                _chosenModel =
                                                    addictions.first.label;
                                              }

                                              List<String> days = addictions
                                                  .map((a) => a.day)
                                                  .toList();
                                              List<String> names = addictions
                                                  .map((a) =>
                                                      a.emoji + ' ' + a.label)
                                                  .toList();
                                              updateWidgetFun(days, names);
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      icon: const Icon(Icons.settings),
                      color: const Color.fromARGB(180, 255, 255, 255),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: screenWidth * 0.5,
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.006),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(60, 200, 200, 200),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color.fromARGB(31, 35, 26, 26)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _chosenModel,
                          items: addictions
                              .map<DropdownMenuItem<String>>((addiction) {
                            return DropdownMenuItem<String>(
                              value: addiction.label,
                              child: Text(
                                '${addiction.emoji} ${addiction.label}',
                                style: const TextStyle(
                                  color: Color.fromARGB(220, 255, 255, 255),
                                  fontSize: 16,
                                  fontFamily: 'PlayfairDisplay',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _chosenModel = newValue;
                            });
                          },
                          hint: const Text(
                            'Choose addiction',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(220, 255, 255, 255),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              fontFamily: 'PlayfairDisplay',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                          dropdownColor: const Color.fromARGB(255, 70, 70, 70),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String newName = '';
                            String newEmoji = '';
                            String text = '';
                            int money = 0;
                            bool isSaveButtonEnabled() {
                              return newName.isNotEmpty &&
                                  newEmoji.isNotEmpty &&
                                  text.isNotEmpty;
                            }

                            return AlertDialog(
                              title: const Text(
                                "Add your addiction",
                                style: TextStyle(
                                    fontFamily: 'PlayfairDisplay',
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      cursorColor:
                                          const Color.fromARGB(200, 0, 0, 0),
                                      maxLength: 12,
                                      onChanged: (value) => newName = value,
                                      decoration: const InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                          ),
                                        ),
                                        focusColor: Colors.black,
                                        hintText: 'name',
                                        hintStyle: TextStyle(
                                          fontFamily: 'PlayfairDisplay',
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'PlayfairDisplay',
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _selectDate1(context);
                                      },
                                      child: const Text(
                                        'Pick start date',
                                        style: TextStyle(
                                          fontFamily: 'PlayfairDisplay',
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                          color:
                                              Color.fromARGB(190, 19, 19, 19),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    TextFormField(
                                      maxLength: 1,
                                      onChanged: (value) => newEmoji = value,
                                      decoration: const InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                          ),
                                        ),
                                        hintText:
                                            'emoji  ( 🚬 , 🍺 , 🥤 , ...)',
                                        hintStyle: TextStyle(
                                          fontFamily: 'PlayfairDisplay',
                                        ),
                                      ),
                                      cursorColor:
                                          const Color.fromARGB(200, 0, 0, 0),
                                      style: const TextStyle(
                                        fontFamily: 'PlayfairDisplay',
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    TextFormField(
                                      onChanged: (value) => text = value,
                                      cursorColor:
                                          const Color.fromARGB(200, 0, 0, 0),
                                      minLines: 1,
                                      maxLines: 3,
                                      maxLength: 80,
                                      decoration: const InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                          ),
                                        ),
                                        hintText:
                                            "Reason for quitting the addiction",
                                        hintStyle: TextStyle(
                                          fontFamily: 'PlayfairDisplay',
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'PlayfairDisplay',
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    TextFormField(
                                      onChanged: (value) =>
                                          money = int.parse(value),
                                      cursorColor:
                                          const Color.fromARGB(200, 0, 0, 0),
                                      maxLength: 5,
                                      decoration: const InputDecoration(
                                        hintText: "Money saved in one day",
                                        hintStyle: TextStyle(
                                          fontFamily: 'PlayfairDisplay',
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'PlayfairDisplay',
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    ElevatedButton(
                                      onPressed: () => _selectTime(context),
                                      child: const Text(
                                        'Time saved in one day',
                                        style: TextStyle(
                                          fontFamily: 'PlayfairDisplay',
                                          fontSize: 16,
                                          color:
                                              Color.fromARGB(190, 19, 19, 19),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.02,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            if (isSaveButtonEnabled()) {
                                              addNewAddiction(
                                                  newName,
                                                  newEmoji,
                                                  text,
                                                  money,
                                                  _selectedDate1.toString(),
                                                  '${_selectedTime.hour}:${_selectedTime.minute}');
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          child: const Text(
                                            'Save',
                                            style: TextStyle(
                                              fontFamily: 'PlayfairDisplay',
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  190, 19, 19, 19),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle,
                      ),
                      color: const Color.fromARGB(180, 255, 255, 255),
                    ),
                  ),
                ],
              ),
            ],
          ),
          test(
            screenHeight,
            screenHeight * 0,
            " hours",
            _chosenModel != null
                ? caluclating(
                    addictions
                        .firstWhere(
                            (addiction) => addiction.label == _chosenModel)
                        .day,
                  )[3]
                : 0,
          ),
          test(
            screenHeight,
            screenHeight * 0.1,
            "  days",
            _chosenModel != null
                ? caluclating(
                    addictions
                        .firstWhere(
                            (addiction) => addiction.label == _chosenModel)
                        .day,
                  )[2]
                : 0,
          ),
          test(
            screenHeight,
            screenHeight * 0.2,
            "months",
            _chosenModel != null
                ? caluclating(
                    addictions
                        .firstWhere(
                            (addiction) => addiction.label == _chosenModel)
                        .day,
                  )[1]
                : 0,
          ),
          test(
            screenHeight,
            screenHeight * 0.3,
            "   years",
            _chosenModel != null
                ? caluclating(
                    addictions
                        .firstWhere(
                            (addiction) => addiction.label == _chosenModel)
                        .day,
                  )[0]
                : 0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    child: IconButton(
                        onPressed: () {
                          List<String> days1 =
                              addictions.map((a) => a.day).toList();
                          List<String> names = addictions
                              .map((a) => a.emoji + ' ' + a.label)
                              .toList();

                          addictions
                              .firstWhere((addiction) =>
                                  addiction.label == _chosenModel)
                              .day = DateTime.now().toString();
                          _saveAddictionsToSharedPrefs();
                          setState(() {});

                          updateWidgetFun(days1, names);
                        },
                        icon: Opacity(
                            opacity: 0.65,
                            child: Icon(
                              Icons.restart_alt,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              size: screenWidth * 0.13,
                            ))),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: screenWidth * 0.1, bottom: screenWidth * 0.1),
                    child: IconButton(
                      onPressed: () {
                        int a = addictions
                                .firstWhere((addiction) =>
                                    addiction.label == _chosenModel)
                                .money *
                            days(addictions
                                .firstWhere((addiction) =>
                                    addiction.label == _chosenModel)
                                .day);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              int b = konwertujNaMinuty(addictions
                                      .firstWhere((addiction) =>
                                          addiction.label == _chosenModel)
                                      .time) *
                                  days(addictions
                                      .firstWhere((addiction) =>
                                          addiction.label == _chosenModel)
                                      .day);
                              return AlertDialog(
                                  title: const Text(
                                    "Savings:",
                                    style: TextStyle(
                                        fontFamily: 'PlayfairDisplay',
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  content: SizedBox(
                                    height: screenHeight * 0.15,
                                    child: Column(
                                      children: [
                                        SizedBox(height: screenHeight * 0.01),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Money: ',
                                              style: TextStyle(
                                                fontSize: screenHeight * 0.025,
                                                fontFamily: 'PlayfairDisplay',
                                              ),
                                            ),
                                            Text(
                                              '$a USD',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: screenHeight * 0.025,
                                                fontFamily: 'PlayfairDisplay',
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.03),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Time: ',
                                              style: TextStyle(
                                                fontSize: screenHeight * 0.025,
                                                fontFamily: 'PlayfairDisplay',
                                              ),
                                            ),
                                            Text(
                                              '$b MIN',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: screenHeight * 0.025,
                                                fontFamily: 'PlayfairDisplay',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ));
                            });
                      },
                      icon: const Opacity(
                          opacity: 0.7,
                          child: Icon(
                            Icons.wallet,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        right: screenWidth * 0.1, bottom: screenWidth * 0.1),
                    child: InkWell(
                      onTap: () {
                        List<String> days =
                            addictions.map((a) => a.day).toList();
                        List<String> names = addictions
                            .map((a) => a.emoji + ' ' + a.label)
                            .toList();
                        updateWidgetFun(days, names);
                        if (isAble(addictions)) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    title: const Text(
                                      "Why u stopped with your addiction?",
                                      style: TextStyle(
                                          fontFamily: 'PlayfairDisplay',
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic),
                                    ),
                                    content: Text(
                                      addictions
                                          .firstWhere((addiction) =>
                                              addiction.label == _chosenModel)
                                          .text,
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.025,
                                        fontFamily: 'PlayfairDisplay',
                                      ),
                                    ));
                              });
                        }
                      },
                      child: Opacity(
                        opacity: 0.7,
                        child: Image.asset(
                          "assets/znakZapytania.png",
                          scale: 3.8,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
