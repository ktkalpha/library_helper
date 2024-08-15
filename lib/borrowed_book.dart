import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:library_helper/main.dart';
// import 'globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

class BorrowedBook extends StatefulWidget {
  const BorrowedBook({
    super.key,
  });

  @override
  State<BorrowedBook> createState() => _BorrowedBookState();
}

class _BorrowedBookState extends State<BorrowedBook> {
  DateTime date = DateTime.now().copyWith(day: DateTime.now().day + 14);
  var title = "";
  List<String> borrowedBooks = [];
  List<String> alarmTime = [];
// //
//   Future pushDaysLater(int days) async {
//     tz.initializeTimeZones();
//     tz.setLocalLocation(tz.getLocation("Asia/Seoul"));
//     tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime remind = now.add(const Duration(days: days));
//     NotificationDetails details = const NotificationDetails(
//       android: AndroidNotificationDetails(
//         '1',
//         'test',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//     );
//     await globals.local.zonedSchedule(
//       1,
//       "title",
//       "body",
//       remind,
//       details,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: null,
//     );
//   }

//   //
  Future getBorrowedBooks() async {
    // 빌린 책 sharedpref에 저장
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      borrowedBooks = prefs.getStringList('bb') ?? [];
      alarmTime = prefs.getStringList('at') ?? [];
    });
  }

  Future setBorrowedBooks() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList('bb', borrowedBooks);
    prefs.setStringList('at', alarmTime);
  }

  @override
  void initState() {
    super.initState;
    getBorrowedBooks();
  }

  final ImagePicker picker = ImagePicker();
  //ImagePicker 초기화
  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);

    setState(() {
      if (pickedFile?.path != null) {
        borrowedBooks.add(XFile(pickedFile!.path).path); // paths에 이미지를 추가한다
      }
    });
    setBorrowedBooks();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var smallText = theme.textTheme.labelLarge!
        .copyWith(color: theme.colorScheme.onPrimary);
    return Column(
      children: [
        // ElevatedButton(
        //   onPressed: () {
        //     pushTest();
        //   },
        //   child: Text('heh'),
        // ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  getImage(ImageSource.camera);
                  setState(() {
                    alarmTime.add(date.toString());
                  });
                },
                child: const Icon(Icons.camera),
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year,
                        DateTime.now().month + 3, DateTime.now().day),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      date = selectedDate;
                    });
                  }
                },
                child: Text(
                    '반납일: ${date.year.toString()}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (var i = 0; i < borrowedBooks.length; i++)
                Card(
                  color: theme.colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.file(
                              File(borrowedBooks[i]),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                              style: smallText,
                              "반납까지 ${DateTime.parse(alarmTime[i]).difference(DateTime.now()).inDays}일"),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                borrowedBooks.remove(borrowedBooks[i]);
                                alarmTime.remove(alarmTime[i]);
                              });
                              setBorrowedBooks();
                            },
                            child: Icon(
                                color: theme.colorScheme.error, Icons.delete))
                      ],
                    ),
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }
}
