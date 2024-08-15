import 'package:flutter/material.dart';
// import 'package:library_helper/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class LibraryQR extends StatefulWidget {
  const LibraryQR({
    super.key,
  });

  @override
  State<LibraryQR> createState() => _LibraryQRState();
}

class _LibraryQRState extends State<LibraryQR> {
  List<String> paths = [];

  // 이미지 경로들 저장
  Future getPaths() async {
    // SharedPref 속 이미지 경로 구하기
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.getStringList('path') != null) {
        paths = prefs.getStringList('path') as List<String>;
      }
    });
  }

  Future setPaths() async {
    // SharedPref 속 이미지 경로 업데이트
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('path', paths);
  }

  List<String> names = [];

// name 저장
  Future getNames() async {
    // SharedPref 속 name  구하기
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.getStringList('names') != null) {
        names = prefs.getStringList('names') as List<String>;
      }
    });
  }

  Future setNames() async {
    // SharedPref 속 name  업데이트
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('names', names);
  }

  var name = "";

  @override
  void initState() {
    super.initState;
    getPaths();
    getNames();
  }

  final ImagePicker picker = ImagePicker();
  //ImagePicker 초기화
  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);

    setState(() {
      if (pickedFile?.path != null) {
        paths.add(XFile(pickedFile!.path).path); // paths에 이미지를 추가한다
      }
    });
    setPaths();
  }

  // void initState() {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (var i = 0; i < paths.length; i++)
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: ((context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom),
                                    child: Container(
                                      height: 200,
                                      color: theme.dialogBackgroundColor,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Row(
                                                children: [
                                                  const Text('이름 : '),
                                                  Flexible(
                                                    child: TextFormField(
                                                      initialValue: names[i],
                                                      onChanged: (value) {
                                                        setState(() {
                                                          name = value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        names[i] = name;
                                                      });
                                                      setNames();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child:
                                                        const Icon(Icons.check),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 50),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  names.remove(names[i]);
                                                  paths.remove(paths[i]);
                                                });
                                                setNames();
                                                setPaths();
                                                Navigator.of(context).pop();
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStateProperty
                                                        .all<Color>(theme
                                                            .colorScheme.error),
                                                iconColor: WidgetStateProperty
                                                    .all<Color>(theme
                                                        .colorScheme.onError),
                                              ),
                                              child: const Icon(Icons.delete),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }));
                          },
                          child: Image.file(
                            height: 200,
                            width: double.infinity,
                            File(paths[i]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(names[i]),
                      ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Image.file(
                                            File(paths[i]),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.fullscreen))
                    ],
                  ),
                ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery);
            setState(() {
              names.add('');
            });
            setNames();
          },
          child: const Icon(Icons.image),
        ),
      ],
    );
  }
}
