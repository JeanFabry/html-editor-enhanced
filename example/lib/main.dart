import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(HtmlEditorExampleApp());

class HtmlEditorExampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      //theme: ThemeData(),
      //darkTheme: ThemeData.dark(),
      home: HtmlEditorExample(title: 'Flutter HTML Editor Example'),
    );
  }
}

class HtmlEditorExample extends StatefulWidget {
  HtmlEditorExample({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HtmlEditorExampleState createState() => _HtmlEditorExampleState();
}

class _HtmlEditorExampleState extends State<HtmlEditorExample> {
  String result = '';
  final HtmlEditorController controller = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!kIsWeb) {
          controller.clearFocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0,
          actions: [
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  if (kIsWeb) {
                    controller.reloadWeb();
                  } else {
                    controller.editorController!.reload();
                  }
                })
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.toggleCodeView();
          },
          child: Text(r'<\>',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              HtmlEditor(
                controller: controller,
                htmlEditorOptions: HtmlEditorOptions(
                  hint: 'Your text here...',
                  shouldEnsureVisible: true,
                  initialText: test,
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                  toolbarPosition: ToolbarPosition.aboveEditor, //by default
                  toolbarType: ToolbarType.nativeScrollable, //by default
                  onButtonPressed:
                      (ButtonType type, bool? status, Function? updateStatus) {
                    print(
                        "button '${describeEnum(type)}' pressed, the current selected status is $status");
                    return true;
                  },
                  onDropdownChanged: (DropdownType type, dynamic changed,
                      Function(dynamic)? updateSelectedItem) {
                    print(
                        "dropdown '${describeEnum(type)}' changed to $changed");
                    return true;
                  },
                  mediaLinkInsertInterceptor:
                      (String url, InsertFileType type) {
                    print(url);
                    return true;
                  },
                  mediaUploadInterceptor:
                      (PlatformFile file, InsertFileType type) async {
                    print(file.name); //filename
                    print(file.size); //size in bytes
                    print(file.extension); //file extension (eg jpeg or mp4)
                    return true;
                  },
                ),
                otherOptions: OtherOptions(height: 550),
                callbacks: Callbacks(onBeforeCommand: (String? currentHtml) {
                  print('html before change is $currentHtml');
                }, onChangeContent: (String? changed) {
                  print('content changed to $changed');
                }, onChangeCodeview: (String? changed) {
                  print('code changed to $changed');
                }, onChangeSelection: (EditorSettings settings) {
                  print('parent element is ${settings.parentElement}');
                  print('font name is ${settings.fontName}');
                }, onDialogShown: () {
                  print('dialog shown');
                }, onEnter: () {
                  print('enter/return pressed');
                }, onFocus: () {
                  print('editor focused');
                }, onBlur: () {
                  print('editor unfocused');
                }, onBlurCodeview: () {
                  print('codeview either focused or unfocused');
                }, onInit: () {
                  print('init');
                },
                    //this is commented because it overrides the default Summernote handlers
                    /*onImageLinkInsert: (String? url) {
                    print(url ?? "unknown url");
                  },
                  onImageUpload: (FileUpload file) async {
                    print(file.name);
                    print(file.size);
                    print(file.type);
                    print(file.base64);
                  },*/
                    onImageUploadError: (FileUpload? file, String? base64Str,
                        UploadError error) {
                  print(describeEnum(error));
                  print(base64Str ?? '');
                  if (file != null) {
                    print(file.name);
                    print(file.size);
                    print(file.type);
                  }
                }, onKeyDown: (int? keyCode) {
                  print('$keyCode key downed');
                  print(
                      'current character count: ${controller.characterCount}');
                }, onKeyUp: (int? keyCode) {
                  print('$keyCode key released');
                }, onMouseDown: () {
                  print('mouse downed');
                }, onMouseUp: () {
                  print('mouse released');
                }, onNavigationRequestMobile: (String url) {
                  print(url);
                  return NavigationActionPolicy.ALLOW;
                }, onPaste: () {
                  print('pasted into editor');
                }, onScroll: () {
                  print('editor scrolled');
                }),
                plugins: [
                  SummernoteAtMention(
                      getSuggestionsMobile: (String value) {
                        var mentions = <String>['test1', 'test2', 'test3'];
                        return mentions
                            .where((element) => element.contains(value))
                            .toList();
                      },
                      mentionsWeb: ['test1', 'test2', 'test3'],
                      onSelect: (String value) {
                        print(value);
                      }),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.undo();
                      },
                      child:
                          Text('Undo', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.clear();
                      },
                      child:
                          Text('Reset', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        var txt = await controller.getText();
                        if (txt.contains('src=\"data:')) {
                          txt =
                              '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                        }
                        setState(() {
                          result = txt;
                        });
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.redo();
                      },
                      child: Text(
                        'Redo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(result),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.disable();
                      },
                      child: Text('Disable',
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        controller.enable();
                      },
                      child: Text(
                        'Enable',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.insertText('Google');
                      },
                      child: Text('Insert Text',
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.insertHtml(
                            '''<p style="color: blue">Google in blue</p>''');
                      },
                      child: Text('Insert HTML',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        controller.insertLink(
                            'Google linked', 'https://google.com', true);
                      },
                      child: Text(
                        'Insert Link',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.insertNetworkImage(
                            'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
                            filename: 'Google network image');
                      },
                      child: Text(
                        'Insert network image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.addNotification(
                            'Info notification', NotificationType.info);
                      },
                      child:
                          Text('Info', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.addNotification(
                            'Warning notification', NotificationType.warning);
                      },
                      child: Text('Warning',
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        controller.addNotification(
                            'Success notification', NotificationType.success);
                      },
                      child: Text(
                        'Success',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        controller.addNotification(
                            'Danger notification', NotificationType.danger);
                      },
                      child: Text(
                        'Danger',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      onPressed: () {
                        controller.addNotification('Plaintext notification',
                            NotificationType.plaintext);
                      },
                      child: Text('Plaintext',
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        controller.removeNotification();
                      },
                      child: Text(
                        'Remove',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String test = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>MD 1</title>
</head>
<body style="width: 21cm; margin: auto">
    <div style="width: 21cm;align-content: center" align="center"><img style="height: 4cm" src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAASABIAAD/4QBqRXhpZgAATU0AKgAAAAgAAgESAAMAAAABAAEAAIdpAAQAAAABAAAAJgAAAAAAA5KGAAcAAAASAAAAUKACAAQAAAABAAACdqADAAQAAAABAAAA5gAAAABBU0NJSQAAAFNjcmVlbnNob3T/4QkhaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLwA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+IDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiLz4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8P3hwYWNrZXQgZW5kPSJ3Ij8+AP/tADhQaG90b3Nob3AgMy4wADhCSU0EBAAAAAAAADhCSU0EJQAAAAAAENQdjNmPALIE6YAJmOz4Qn7/4g0kSUNDX1BST0ZJTEUAAQEAAA0UYXBwbAIQAABtbnRyUkdCIFhZWiAH5wAGABsADgA5ADRhY3NwQVBQTAAAAABBUFBMAAAAAAAAAAAAAAAAAAAAAAAA9tYAAQAAAADTLWFwcGwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABFkZXNjAAABUAAAAGJkc2NtAAABtAAAAe5j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tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9sAQwABAQEBAQECAQECAwICAgMEAwMDAwQGBAQEBAQGBwYGBgYGBgcHBwcHBwcHCAgICAgICQkJCQkLCwsLCwsLCwsL/9sAQwECAgIDAwMFAwMFCwgGCAsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsL/90ABAAo/9oADAMBAAIRAxEAPwD+/iiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD/0P7+KKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/R/v4ooooAKKKKACiiigAooooAKKKKACiiigAooooAKKrTXlnbzxW08qJLOSI0ZgGcqMkKOpwOTjtVmgAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/S/v4ooooAKKKKACiiigAooooAKKKKACiiigAryP41fGvwT8CPBcnjLxnJI+91gs7K2XzLu9uZOEggjHLyMegHAHJwATVb43fHHwf8C/Co17xH5l3fXj/Z9M0y1G+81C6YfJDCgySxOMn7qjkkCvyY8R+K/H/jLxzqXi3xTq1rpviXT7d/7d192EuleBbBx/x6WecLNqcq8NIDlWPHTFAGf8UvF2peNPHM/iv4w6XrmseJNCVb64XwvMTF4GtGI8tsqQtzfZIadBn92GX7o4/RH9nD9pGbxlPa/DT4l3drN4hltftum6nZcWGuWGcC4tz/AAyDgTQn5o29unyh8IPgZ8bPHPg6Lxl8EtVuPhxoWlO1x4ctLuPzbjXZ2P7y+1fdh2FyvCpwyI2favIb/TYtSstUurDw9d6bNpd0LvxP4MtH26loN4P+YzojjBaM/eeNRtkQ+tAH7sUV8Tfs3ftJ/wDCTPZ/Dr4i6lb3+oXcRl0PXbdfLtNftFx+8jHSO5T7s8BwytyBg19s0AFFFFABRRRQAUhIBwTyaWvx/wD23PE3iPSf24fgppOl39zbWt3dRCaGKVkjkH2pB8yggHjjntQB+wFISB14pa/Mb/grJruu+Hv2X4b7w9fT6fOdYtU823kaJ9rK+RlSDj2oA/TfevqKUEEZFfi38OP+CfnhPxr4H0HxFdfF3xFHeatYWty8CX6krJPGrlQN2eCcDvX6Up4Gb4Tfs333gaz1K61A6Ro15Gl7ctm4ciN2DMw7jPB9qAPePOh3bdwye2akr+bH9h79lHVv2sfhPr3xB174g69o2pabqUtjbtFMXiVUiSQO2WDnBfnDjgV9sf8ABKj44/FX4h6Z4z+GnxH1N9fh8J3MMdnqMjGRmWQyKyGQ8sPkDJk5Az2xQB+u1RJNDIxWN1YjqAc1+Sv7dfxq+KvjL43+F/2KvgZqb6Lf6+qTarqMRIkihk3YQMpDKFRS7YILZUAjmvNfjP8A8E+/G3wE+Gt/8Y/gX8R/EDeIfD0JvpkuZhsuEhG6TbsC4IHID7wQMH1oA/bknHJpAQwyOa+Qf2N/jkf2rP2adP8AGXieNRfzLNpuqpFlFaeMbWZcHK+YjK+AflLYHTNfEf7NHjnxh+yH+1p4g/ZO+MGq3F54d8RMdR8O6jfzM+Bg7V3ueAyKUfsJI+OCSQD9miQOppa/GX4LeIPGH7cP7aerfFu2vbu2+G/w/cWdhDFK8UV5cISULAEBtzZlbPRNinqDX7NUAFRtNCjiN3AY9ATya4f4pa7r/hf4ba94j8KwfatSsbC4ntYsbt8saEqMd+R071+F/wCzD8EfCH7Unwn1b45/Gv4n6xH4qku7lXSC9SI2XkjIxG2Tlh8wClRtIAwcmgD+gyivi/8AYv8A2ivhz8Zvhn/Zng68vZYvDtyNGSfWZUN9fNBFGxnKh2Pz7/Unjn0H2hQAUwSRk4DDPpVfUCRYTkcERt/Kv5zv2O/2Zdc/awj8ba7rfj/X9Gu9H1M29t9mnLoN5chmBIY4KjowoA/o8pGZUUs5wB1Jr8e/+Cdnxc+Mll8cfH37KnxU1x/FEXhNZJLXUJCXZfImWFl3klir7wwDElSpGea9T/4KjfGfWPAPwNtfhd4IMj+JPHd2un2sUP8ArTAhDSlR33EpHjuHOOlAH6ZAgjIpCQoyxwK+IP8Agnr8aLj4y/s1aTJrcjPrPh8nSNQVzmQS24Gwt7tGVJ968Z/4K6a/rvhv9lqz1Dw9ez2M5161QyW8jRsVMNxkEqRkZAOPagD9Q1kjk+4wP0NOJAGTX88Pxe/ZX8WfAL9l/T/2p/h98T9ctNXitNPvpLa6nISVr3ywUjKkcqX3AMrZA59a/Uf4aL4i/bB/Yp0ZfG2oXWiaj4msIWub2w/dTBoJgxdPQSeXzjsxxQB9rb19RShlPANfzT/tz/s2a3+yzc+CofCvj/xHqA8TXk9tP9pumHlrEYsFdrDk+YevpX6r/BL9gex+C3xO0z4lW/j7xFrJ00zEWV9PvglEsTxYcZOdu/cP9oCgD9AsjOKQkAZNfiB/wUu/aI+JX7OP7TPw98ceALqTbb6dK1xZF2+z3UZmIdJEBwcrxnqOCOQK+hP2o/2g/D3xp/4J0eIvjH8K7+W2FxBZ58qQpcWs4uoRJExUghlyQexBz0NAH6eAgjIpu9fUV8rfsQ6hqGq/smeBtR1SeS5uJdNBeWVy7sd7clmJJP1NfjP+y78Cz+034z8fT+OfiLrWgLo2qvFbxwXpRWV3fPDt2x2oA/pCDKehzTXkjj5dgv1OK+M/2Yf2TdJ+AGs3/ijSPGereKY9RgEG2/nE0abWzuUgnntX5y/tf+FtZ+L/APwUn8OfA+fxBqej6TrWlwiX7DMVKlI7iTKqcrklADx0oA/ehWVhuU5HtS1/P/rmk/FP9gz9r7wD4D8E+N9R8U6J4uubeC602+cyMsc0ywtuXcyg4bejKFORzxnP6N/8FFfit8QPg7+y3rHiv4bSPbahLNBaNdRjL20UxIeRfQ8BQe27I5xQB9wiaEyGIOCw7Z5qSvxB/Zw/Yb8J/F74X+FvjX4S+K+uz67dLbXepSw3O+NZshpoCAVlR1+ZMs55+YqRxX7fAYGKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD/0/7+KKKKACiiigAooooAKKKKACiiigArxH44/Hbwp8DfD8F9q0U2patqcv2bStIs18y8v7luiRp6Dq7nCoOSag+OHx48O/BjTbS0NvLrHiPWWaDR9FtPmur6cDOFH8KL1eRsKo6mvzL8HeEPiz+0J8TNVGjasra9dBrPxT4vtctbaNbfxaRou7gyfwz3I5zk9cCgBmiaD8Zvj18WL+20rUY38ZDMGveJbf8AfWHhixk+9pmk5+WS9ZTiWcY2nJzXo37MHwR8I/Gq/k1DU7NdO8BeBNVmstJ8LO2+WbUrV8SX+qEjMs7t80aNuAHPoK/Sr4afDTwV8IfBVj8P/h/YpYaXp6bI415ZifvO7HlnY8sx5Jr46LR/s5/toJF/qvDXxhQgEjCQ67Zr0/7eIu3dhQB+gCqqKEQYA4AHavmP9ob9n+L4lRW/xC8C6kPC/jvQFMmma2i5AVeWguV/5a279HU5x1HPX6dr45/bP8Y+I4fAenfBb4fy+X4k+It4uiWrrndb2rjN3ccdBFDu56ZIoA+DNO8Fat8RPgzb/tE+GfDMx0HVJ5bjxF4b0xyssV7bMU/tjQ5BgxzBlL7BjzV4OTwfsn9mf9po60mlfDr4k6pFqdzqUTPoPiGNfLg1mBOqSLwIb6P7s8BwdwJUYr7H8D+DdA+Hfg7S/AnhWEW+m6RbR2ltGP4Y4lCjPqeMk9zX5/ftO/stzab/AGr8QPhhpD6zo2sSLceJPDFu/kSTSR8rqGnSA5gv4cAjbgSjg89QD9KqK/Pz9mf9p9byLS/AfxG1hNXt9TZoPD/iQp5K6iYeGtrpDjyNQi+7LGQNxGQOa/QOgAooooAK/GT9u3A/bw+BhJwPtUX/AKVR1+zdfEn7U/7C/wAOf2sfEekeJ/Gesappdxo0Lwwf2e8aAh23ZO9GOcjsRQB9q/aIDxvX8xX5bf8ABX5Fk/ZThRuh1q0B/J6reG/+CTPwl8NeIbHxFbeMvE80lhcR3CJJcRFGaJgwBHldMivtD9pn9m7wl+1H8OV+GnjO+u7CzW6juvMsigkLRhgB86uMfN6ZoA+Of2ef+Cdn7OGlaD4K+Lls+pDV47XTtVAN2PL+0bEl+7szt3ds9OK/Q74rMG+FfiVlOQdKvOR/1xavzLT/AII9fByJFij8beKVVQAALiEAAdB/qq/R3wj8I9H8H/Bq2+CtpeXNxY22mtpguZirXDRshTcSAF3YPpigD+ZX9nb9lXx/8Y/2T/GnxO+GfiDUbfVNG1OVDo1vIywXkUcUbvwpGZCrHAwc4x3r9mP+CWnif4K65+zbBp3wt09NK1WwlEev25YvM97jHnMzfMUkAyg6Jyg+6a+jv2Wv2WvBf7J/gzUPBPgi/vdQttRvmv5HvihdZGREIGxEGMIOozmuV+HP7Fvw++Efx71j48fDnU9Q0uTXi5vdJjMX9nv5nLYTy94+f5xhvlJwMLxQB8C/Gq7tPhH/AMFZ/C3j3xkwtdK8QWMMcNzN8sSu8TW2Nx4BDqM+m4etfpb+1x8SfC/wx/Zy8XeIfEtzHDHPpdzawK7AGWa4jMaKo/iJLdB2qf8AaQ/Zd+FX7UfhGPwt8SbeRZLVmezvbVglzbO3UoxDAg4GVYEHAPUAj4l8Mf8ABJH4U2+u2mofEbxbrvimwsWDQ2FxII4sDorEbmx/uFD70AdV/wAEkPBes+Ef2R4r/V43iGuatdahArggmHbHCDg9iYmI9Rz0Nct/wV9+HvhnXP2drT4g3cJXVtC1CGK1uE4dY7o7ZEJxnacA49QPev1T0jSNL0DSrbQ9Et47Szs4lhghiUKkcaDCqoHAAAwBXjH7Rv7P/hf9pb4ay/DDxfeXVlZS3ENwZLQqJN0JyB86sMHvxQByf7Fnw68L/DL9mPwfonhWDyY7vToL+4Y8tLcXSLJI7HucnA9FAHQV9SVyngXwlY+AfBWk+B9Mkkmt9Hs4bOKSXG9kgQIC2ABkgc4AFdXQB47+0J4u13wD8DfFnjTwwM6jpmlXNxb4GcSIhKnHsea/Fn9in9if9nz48fsy3fxg+IH2jVvElzcag9z5dyU8l4ydisqY5YASc9d/pX7+39hZapYzaZqMSz29wjRSxuMq6OMMpHcEHBr8ptW/4JI/CqLxHe6l8P8Axhr/AIa03UGLTafaSqUAP8KsQDtHbeHPuaAPnD/gkr+zh8J/F+haj8ZNatpm8ReGfEUkNm6zsqpEsETLuQHDfMz9ev4V++dfmL8Kv+CXvw3+DPxQ074geBvF2vxWen3MF2dOkljMc8sByPNZEQMpPUbM89a/TqgCnqP/ACD5/wDrm38jX80/7FvwC/aI+Mo8cSfB74jzeCdPh1YxXkMIkLSli+GGxl6AEdR1r+l+eJZ4XgY4DqVJHvXzN+zV+yv4L/ZgtddtfBt/e3y6/di7m+2FCUcbuF2IvHzd80Acp+yJ+xn4N/ZP0nUp7LUZ9e8Qa2yvqGp3K7Gk2kkKibm2rkljlmZj1OAAPyV+Mn7SGj+K/wDgo9F8RNU0bVvE3hv4bk2ltbaPB9pb7TEHw55CgfaCWByDhAOa/om1K0kv9OnsYZmt3mjZBKmNyFgRuGcjI6jIIr5m/Zh/ZM8Bfss6drVt4Rvb3VLnX7pbm7u78o0zFAdq5REG0FmbkZyxoA/JX9hP4+6X4L/bf8TeBotO1DQPDvxHkkudPs9ViNvNFcqWkjyuSuGzJGCv3iVHavrP/gsd/wAmnWf/AGMFp/6JuK+ov2hv2OPAX7Q/jvwx8TNW1PUNF1vwo260utOaMM211kTd5iP9xgSuMfeOc8Y7D9pz9mvwj+1R8OYfhp42vruxs4b2O+ElkUWQvEjoAd6uMEOT0zkCgD+f748fsyar8CfC3wx+M/jK/wBU8b/DvUIrCXVbCed0Nq0iK5jUqxCoyEiNhjBXB6jP9Knw01XwRrfw+0bVfhsYToE9nE1h9nGIxBtGwAdsDgjqCMHmud1X4LeCvEXwYHwJ8TRNqGiHTY9MfzceY0cSBFfIAAkBUMGAGGAIrkf2av2dtJ/Zl8CP8OfDet6jq+mCZprdNQMbG33/AHlQoifKTzg5wScUAfmp/wAFiP8Aj++Ev/YUu/521ftnXyj+05+yN4G/ann8OTeNNRv7A+GbiW4txZGMb2l8vO/ej8DyxjGOpr6uoA/GL9uS0tNQ/wCCgXwOsL6JZoJ5IY5I3AZXRrrBBB4IIOCK+KP24fg98Q/2LG8U+FPh8Gm+GXxJWMeS2WS0uYJVmCf7LrswjfxRkg5K5H7mfFr9lHwl8Xfjd4P+OWsand2t/wCDXje2t4QnkymOXzRv3KW5PBwRx71698XvhN4K+N/w81L4Z/EC1F1pupR7GHG+NxykiE52ujYZT6jnIyKAPEv2Ef8Ak0DwF/2DB/6G1fj1+xZ+yH8Hv2l/GvxJv/ic14smmauyQfZbgQjEjyZyCpz0r96/gr8L7L4L/CrRPhZp1299Botv9nSeRQjuMk5IHA61+dWrf8Ehvgtqev3/AIgj8W+JLSXUZ3uJVgmhRdzkntF0GaAP0P8Agt8I/BnwM8AWvw18BPM2nWTSOn2iTzZMysWOWwO544r8Uv2wvhqPi9/wVE8LfDs6rdaJ/aWlQqL2yO2eIpFcuCpyOu3B56E1+nH7L37FXgn9lfWdV1rwrr2r6xJq0McEi6lKkioI2LArtRcE5963fE37IvgXxR+09o/7VF7qV/HrWjQLBFaoY/srKqSR/MChfOJSeHHIHvQB+Tn7Lvw98N/s0/t9Xnw2/aNWTV9auR/xS+u3sjMr78+WcMSA8ikoCc7HBUE5BP70+NtK8H674UvtE8fxW0+jXkfkXUd5t8h0kIXa27jkkAe+Mc18+ftPfshfDX9qe00k+MLi80vUdEmMtpqGnMsdygPVNzK3y5Ab1BGQa634vfs+6L8cPgmfgp481jUZIJIoFlv4HSK6mkgwVd8J5ZLMAzLsCk9AOMAH5Dfta/s7ar+wA9n+0p+yp4kuNGsZr+KC70WeQywuZMlQoJ/eRnaQyPlhnIb0/cL4a+Lz8QfhzoHj0wG1Ot6da3/kk5Mf2mJZNue+N2K/NbwZ/wAEmPhVpniGy1T4jeK9a8WWGnOHg067cJbkr0D43Er7KVz9OK/Vi2treyto7O0jWKKJQiIgwqqowAAOAAOgoAnooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA/9T+/iiiigAooooAKKKKACiiigAr5/8Ajr8fNJ+D9tY6BpVo+u+LteZodG0W3P765kHV3PSOCPrJK2FUe9Vfjt8e7f4XSWHgfwhZNr/jjxDvj0jR4T8zbR8085/5ZW8fV5G+gya/Nfxh8NPj+nxDuNC1vQPEOot4kiC+MvFulwwme6t8fLpulrJKhtrUZw0mA7cnGaAL/gTwD8Sf2ivHGs22i65591dv9l8V+NrbIWCJT82kaGTnZGvKzTjG4k9TX64/D/4f+D/hb4QsfAngOxj07S9OjEcMMYwAB1JPVmJ5ZjyTya+cfBHxTsfhx4TsPA/gn4UeLNP0rTIVgtreK0tgqIvT/l55Pck8k8muq/4aJ1z/AKJr4w/8Bbb/AOSaAPpavm/9q/4N3fxt+C2peG/D8gtvEFgU1LRLocPb6jaHzIWVu24jY3+yxqH/AIaJ1v8A6Jr4w/8AAS2/+Sa7/wCFfxh8OfFiDUY9LtrzTNQ0e4+zX2n6jEIbq3kIDLuUFhtZTlWDEEUAZf7PHxag+Nfwg0fx+V8m8mi8m/gPWC9gOyeM+hVwfwxXiPwjjT4z/tIeJvjq7edpHhhH8M6IeqGRWDXkyduXxHleoUg9K+cfi94/8Tfsf/E7xT4B8A2El0/xWUXfheNFzHFrs7pBOjYHC4cXBP8AskdTX3/8OfB/hP8AZw+CVpoFzcCOw8O2LT312/WR1BkuJ3PUl33Oe/NAHtFFfN+nftCavrGnwatpfw78VS2t1Gs0MhhtE3RuMqdrXasuQQcMAR3ANXP+F5+Jf+iceKf+/dl/8mUAfOX7TH7L05n1T4j/AAx0hdas9WAfxH4WD+SmomPlbu0cY8jUIcZSRcb8AE561v2Zv2ooLaz0jwP8RdZk1jTNUla00PxJdp5Ms1wnBsNQT/lhfxYKkNgS4yMkmvpb/hefiX/onHin/v3Zf/JlfBn7Qvw98T+KdbvvHHww+Fmv3EniNooPE2h3os4rLVYE4WZXW6JgvIeDHOozwAaAP13or4J+EvxV8c/BG60X4Z/H8Xa6LrRSDw9reoBftEbkfLY6iyMyC4XG1JQdkuOu4197UAFFFFABRRRQAUUUUAFFFFABRRX59v8AFH9oT4y/HDxz8OPhHr2jeFofA0ttbiC/s2vLm7edA5lcCRNkXZdoJIIOaAP0EoqtZrdJaRLfMrzBFEjKMKWxyQOcDPSvmSP4t+L2/bQl+BZMP9gp4NTXANn777W160B+fP3NgHy4685oA+pKK8y+NHizVfAnwk8SeNNC2fbdK064uoPMXcnmRIWXIyMjI5Ga+T7P9sK48cfsYeJPjv4RiXT/ABP4d0uWS8sLlCTbXscYcZRtpMUgIeNujIR3BAAPv2iuT8Baze+IvA+j6/qO37RfWVvPLtGF3yIGOBzgZNfJXjD4wfGb4ofHPWPgR+zzPYaRF4Tgt5tc1vUIGulSa6G6O3giVkBYqCWYtgYIxkcgH3DRXnHwt0v4oaP4ZNj8W9VstZ1RZn23NjbtaxtDxtDIzv8AN1yQcV4P+2F8Ufid8NtC8G2PwnvLOw1LxR4ns9Ea4vYDcRRx3Ucp3bAy5wyKevTIoA+v6K+bfhL4Z/ae0nxO958XvF2i67pPkOot9P01rWUTErtYuZXGAN2RjnI9K+kqACiivif9sn9p3xn+z94QuZvAHhm51a8jghnn1CVdunWMdxMIEMjkgySFz8sSfNj5jhaAPtiiqenTSXGnwXEvLPGrHHqQCa+Svjr8Vfiinxi8Lfs9/B2ey0vU9etbnUrrU7+I3CQWtrgbY4gyb5HbjlsKOeaAPsGivlb9m74s+OvGGseL/hb8VGtLjxF4Kvo7aa7sUMUN3BcJ5kUojYsUbGVZckZGR1rG/bS+MXjX4MeAPDureBdRsdIuNZ8SWGjz32oxiW3tre7EgeVgWQAJtDElgMA/WgD7Cor5s/Zy17xl4p0m+17xB490Lx5ZSOiW0+hwLFHCy53q7JNKGJyMDjH416v8StO+IereD7mx+Fmp2uka25j8i6vbc3MKAMC+6MMhOVyBzwTmgDvKK/N3wz40/a7079qLQ/gl4i8V6HrtoLJ9W1s2eltbta2ittjTcZX+eZuFGBgAtzjFfpFQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAH/9X+/iiiigAooooAKKKKACiiuc8XaDc+JvDt1odlqFxpc06ER3dq22WJuzLng4PY8HoeKAPlzxN+w38F/FnxDv8A4qand67Hr2pDZPdW+qTwMY+0Y2MMRjsg4FN/4Ye+FH/Qa8U/+Dy7/wDi6+JvFkf7YX7PviK4m+O/iTxR4j8Iu7GDXvCqwyPboO13ZvEZBjrvjYr/ACr6K+GD+DvjJYpffDv4861flxkwedbR3CY4IeJ4VdSD6rQB6f8A8MPfCn/oNeKf/B5d/wDxdH/DD3wp/wCg14p/8Hl3/wDF1uj9nXx6eR8VPE//AH1b/wDxmg/s6+PRyfip4n/76t//AIzQBhf8MPfCj/oNeKf/AAeXf/xdfMtz/wAJJ+yb8azqV7d3F9pVlbbpnuHae4v/AA8X+eRmOTJcaXI25ifma2f0WvXPiBpvhv4W2zXHjz476zYFVLCJp7V5mA/uxLCXbr2BryDwb8M/iz8dvFlj400KfXIdJsFljs9f8YhPtKRXKbJzY6YsaKGlQ7fOusjb91DQB+nV74d8H+M59H8U3ttBqD6bJ9t024ID+W8sbJ5kZ/2kcjI7GviX9r34jtqOoW3wz061k1CG1uLSSWzTO3U9Tnf/AEHTyQf9XuU3Fz2EMeDjdX2t4A8FaR8OPBemeBNAaVrLSoEt4TM299idMnj9AAOgAFfEnx9/Zd8dz+IX+I3wmmOqgXb6nLo0101jcLeMnltcWN8oYwysgCGOVWhcDBxyaAOv0X9iPwvcaXBdeP8AxR4l1PXJl8y/uodXubeKW4fmRkiRgqJuJ2qBwuBWn/ww98Kf+g14p/8AB5d//F14B4E+LPgPxJqx8IePPiF4w8C+I4sLLpfiF4rR93fy5TH5Uq+jI3NfV1j8FdT1O3W6074k+IbiJgCHjuYWUg9ORGRQByH/AAw98Kf+g14p/wDB5d//ABdH/DD3wp/6DXin/wAHl3/8XXd/8KF8Rf8ARQvEv/f+L/41VO++C2p6Xbtd6l8SfENvEoJLy3UKKAPcxgUAebeIP+CfXwJ8V6W+ieJ73xFqNlIQXt7jWbqSJipyCVZyDg8jI4NfXngzwrZeB/C1j4R02e4ubbT4hDFJdymeYovQNI3LYHAJ5wK/PDxj4uij1D/hEPg14y8X+PvEMoAS20ieD7LDk4DXF48RghTrkks3HCk19L/sz/DP45+A9Cur/wCPfjCTxLq18wZbZMG2sowSQiPsRpH5wzkKDjhRQB9PUUUUAFFFFABRRRQAUUUUAFflh+2J4q/ZI1HV9e1B9ck0P4r+GIRFY3OmCeDUXuTGHghBRQLhGLKrD5goJBxg1+p9Z0uj6RcX6arPawvdRDCTMimRR7NjI/OgDifg9feNNT+FHhrUfiPF5HiCfTLWTUY8bSt00amUEdiGzkdq+V4Uf/h5hcSYO3/hW0QzjjP9pPX3fUflReb520b8Y3Y5x6ZoA8S/aZVn/Z58aogJJ0a8AA6n921fm58c/gp4vl/Y8sPjB8IUxqt34Jt9K8Q2QUsNQ037ONrlRyZ7Xlo2+9s3LyMCv2SdFkUo4BB4IPINJ5cYj8raNmMbccY9MUAcF8Jhj4W+Gx/1DLT/ANFLXwVo/j/QP2Sv2r/HyfGWRtK8OfER7TVNI1mRGNt58EbJPbyuoIRwTlc4G0ZONwr9M0RI0EcYCqowAOABVTUNN07VrY2Wq28dzC3JjlQOpx7EEUAebfCb41fDz436Xfa78Nbt7+wsLprQ3JhkiildVDExM6rvUZxuXjIPtn44/wCCksXgyXwZ8Oh8RlVvD48b6cdS8wOU+yiG48zd5fzY25zt5r9F7e3t7SBLa0jWKNBhUQBVAHYAcCie3t7ldlzGsijnDAEZ/GgD45/Ze8bfsa297e/Dr9mC7tEnuQ2oXNrbLcAsI9kZkJmHbKjg/hX2ZVWGxsrZ/Mt4UjbGMqoBx+FWqACviP8A4KLRyS/sheKI4lLMZdOwAMn/AI/YK+3KZJFHMhjmUMp6gjIoAo6R/wAgm1/64p/6CK+X/wBq7wN8IbjwxbfGX4k6te+Grrwdvls9Y0yUxXkZnwhhQAN5nmkhBGVOScdzn6xqKe3guY/KuUWRcg4YZGQcg4PoRkUAfA/7Avwc8R+BfCfiH4peNVvYtV8dX/28RalIZb2O0QEQCdzjMhBLEYG3IHavof8AaB174EeG/Cunan+0LFaSaKNSgWBr63a4gjvCr+WzgK4UAbhvcbRnkjNe7VDcW9vdwtbXSLLG4wyuAyke4PFAH5y/srL4M8RftRfEX4gfA+3jh8DT2On2nnWkXk2VzqMe4yNCoCq21ThmUYJOec1+hut6xp/h3RrvX9XkENpYwyXE0jdFjiUsxP0AJq7bW1vZwLa2kaxRIMKiAKoHsBwKkdEkUxyAMrDBB5BFAHxB+xHo+q+JvDmv/tI+Lomj1f4iX73iJIPng06AmO0h9tqAsR0yxI619w01ESNQkYCqOABwBTqACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA//9b+/iiiigAooooAKKKKACiiigAIzwa+eviL+yj+zz8Vbg3/AIz8K2U13yftUKm3uMnqfMiKN+tfQtFAHxR/ww34HsNieFPGHjDRIkBAjtNZkKYPbEok/SrCfsQ+BbyNofFXizxdriPwUvNYlCkemIhHxX2fRQB4d8Ov2bPgZ8Kisvgfw1Z2twpyLh086fPr5shZ/wBa9xoooAKKKKAOW8WeBvBvjzTjpPjTSrXVbY8+XdRLKvHpuBx+FfMM37CnwGtbyW/8GrqvhiSY5b+x9SuLVM+oQOUH4LX2PRQB8XJ+xfaK4ZviV46ZQc7Tq4wR6cRA/rmul0z9jL4HW9/HqniS3v8AxHPC25G1m/nvVU/7jvs/8dr6sooAytF0LRPDlgmleH7OGxto/uxQRrGg+gUAVq0UUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQB//X/v4ooooAKK+T/wBrX9qnTv2UfC2jeK9T0O41yLVL82jx20gjeGJInmkl5Vt2xIydvH1FcH4v/bo8J6H8c3+CnhzSzqgTQ7jV21X7R5VqskNo16sJxG7HdD5bFxnaJAdp7gH3ZRXydpX7YXwjvNK0XTr3U7dPFGtaHbazHplv508a/abf7QiNOIlRA4B2eYI2cchecVzfwM/bq+BvxZ+Fx8caxrVrpN/pmlRaprVo/mhbNHO07XeNRKof5Mx7vnwv3iBQB9q0V8i3H7XXgfXNe8E2PwxePWrPxPr0+hXcjiW2mspYLZ7ghoZUWQP8q/K6rw2RXoWlfHK11P4seN/hb/Zzo3gvT7C/e58wEXAvklfaE2jbs8rGcnOe2KAPeKK/NLRP+ChOoav8D7v45N4OtRZxyadFb20OuwTTM+oT+SonCx5ttv3v3i8gH0JrqdH/AG87XxB4Ohn0Twjc3niy78Sz+FbXRoLyGSGa8toxNLIt6P3RgSM5aQAkHjbjmgD9BKK+BpP25Bofh3UdW8e+ELjRbrwv4hs9E8TwPdpMulwX4BhvRKibZoDuXP3GGc4x1+jvgD8YT8ePh6vxMtNKk0vTb27uU00zPue6s4XKR3BXapQS7Syoc4XByc0Ae10V8+ftE/HDUfgbofh680TQT4i1DxLrlroNpaC5W0Hn3SSMrGRlcAZjxyO/WuE8K/tmfDWXwjq+u/FeGbwXqXh/Vhoeoabd/wClTLeuoeNIPswc3AkQ7kMa5IBOMDNAH19RXyrrv7bn7LXhvw9pPinWPF0CWGuQTXNlIkFxKZY7ZxHKdqRMymNuHVgGXBJGASMq/wD20vg5rHhq4174U6rZeIWsdW0zTLtJHmtVj/tOYRxurGBy4YZMZVSj4++OtAH1/RXzPof7Xn7P/i/xLfeBvBniKC/12yivXNm0c0IZrDImTzHi27kIywXcwX5gCpBritN/br/Z+07wr4d1T4k69aaLqev6Zb6n9kgFxeJHHc8JmVIBgMwIXeqM3YUAfZtFeOxfH74Qz6kujx60huW1yXw0E8qUf8TSGLzngzsxkR/Nuzs7bs8VV+Gf7RnwV+MWu3nhv4ba9Fql7YxefJGscsYeHeY/NiaRFWaPeCvmRFkzxmgD2yivjbVP2vtP0v4M/Ej4wvoUjx/DvW9Q0V7UXADXbWEiR+YH2fIH35wQ2MdTXnviH9uLxF4d8M+G9Vn8IafcXvie/vLO1ig8RWr2qx2dutw0j3YTykJyy7GwQQMn5hQB+hdFfBGkftwXXxC03wja/BXwTe+Itf8AFWjS682nT3cVgtnYwym3LyTSBlO+YFYwq/MOTtFcrqX/AAUg8D6F4T0jxz4i8O3ljpmtaZqckDSSDzRrOlyGOTTWUKQHfAMUm7DZxtBzQB+kNFc94S1TWNb8LabrXiCwOlX93axTXFkZPNNvLIoZoi4ChihO0kAAkV8x/tA/tdaB+z38UfBfw88Q6RNdWviyVkm1BJQkdgnnRQLJIpU7l3zKCdy4Hr0oA+vaK+KPC/7bvgTxB8bfHPwqu7GWx0zwNZy3dxrTuXim+zSJDOqRIhb93KzJkFizIQBmuvvP21/2Y9O8Jp42v/E4gsHv30seZZ3SzC8jQSGFoDD5yvsIIDIN2QBkmgD6oorxnwd+0H8HfiD4+1H4YeDdbTUNb0lZGuoI4pdkfksiyL5pQRMyM6h0Vyyk4IFeF2H7ZlhfaJAB4flXxBL42bwQ+lfaQWS5RyXnMmzmJYB52dnTjPegD7aor87/AAd+3ldeK/AHjD4nHwpbw6V4UsNQvNiazBNeTPYSmLY9ssYkhEm1iHYEYA65FP8ADv7fVpq3w1+IPjbVPCr2t98P7Gy1Ce0hv4ruC4iv0LxBLmJSFcAHerJleOvOAD9DaK+M/E/7Zfhjwx+0F4X+BNxpM0ieIIbT7RqiyDyLG71BJntLeRdvLzeS235hwQcHnHmPiP8A4KLeDfDPiX4keEL/AECdb/wC6iBWnCpqarNFDMY22YRojNGxX5iVbPHNAH6NUV8i/C/9qaf4rfHPxL8JdB8PpFY+F7240+7vZdRhW7EtuB+8+wkCXyHY7UlDEE9hzj66oAKK/O9v2z/i3Dd/EPS9X+Gi6dL8ONJl1LVJH1iKdEZrKW7tkCpEC4l2BSVJ2bsnpiuz0T9uT4YeMPhlaeNvAl1aajfpd6NZalZTSTWotJNXdUXDNAxkGS2xlXY+37woA+3aK+dYv2tP2eJ9X1zQ4vE0LXHh22vLy+HlTbFh0/8A4+Wjfy9k3k4+cRM5HpXHv+3d+ykkFjc/8JWGXUkkltdtldsZY4mKs6gQklQVPzYwRyDg0AfXVFeWeE/jR8NfH+pJofgXVYtTvZtJt9bjjjVwpsrzIgkLldq7yDhSd4HJXFfPvgT9svS/H2k/D7+zNAlj1nxxqt/pk+mvON+m/wBlCQ3byNs+fyti4XC7vMXkdwD7Vor4f+Gv7b3hX4keJviB4ds9Gntl8GWl1qFlO8oK6vZ2cs0Es0PyjaizQlM5bkj0IrI+BH7enhL47z+CNO0jRZrG98WXGpWtzbzTAvp72FuLpSRsBkWeJ1ZGAUc98GgD73or4c+K37Ymv/Df4heLfC2leBbvX9J8C2Fnqet39rexRyw2t2juXS3kCmTYsbFgJBwO1Y3xE/bz8OeDLbxPqGh6G2q2ug23h26t5mu1tku4/ERIiJLofKEYAZi2cg9sUAfflFfn14h/bf13Q77wj4Yg8IWV3rni2K7uLeFNftFs2jtZBFthvCvlTTuxOIhtwRgtXd+Hf2lfirrX7Q118BLz4efZTYwx31xf/wBrwuqWE0rxRziMRgksUJ8sNuHegD7Koor4gg/bC1nxF4+utC8A+DjqXh+w1l9Cm1a61W1sHluYHWO4NrbTHfOkJYZIZdx4XJoA+36K8Hvf2m/gbp0TS3evKoS91PTjiCZj9q0eN5byMBYySYkRjkcNjCkkgV0vhP40fDXx/qSaH4F1WLU72bSbfW4441cKbK8yIJC5Xau8g4UneByVxQB6nRXxV4E/bL0vx9pPw+/szQJY9Z8carf6ZPprzjfpv9lCQ3byNs+fyti4XC7vMXkd6nw1/be8K/EjxN8QPDtno09svgy0utQsp3lBXV7Ozlmglmh+UbUWaEpnLckehFAH3BRXwR8CP29PCXx3n8EadpGizWN74suNStbm3mmBfT3sLcXSkjYDIs8TqyMAo574NanxW/bE1/4b/ELxb4W0rwLd6/pPgWws9T1u/tb2KOWG1u0dy6W8gUybFjYsBIOB2oA+46K+IPDX7ZcXjn48zfB7wTolrd2MC6ZMdSuNVhtZZYNTtUu0khtJE8yXZG3zKpzxzjNc/wDAz9u2z+MfxO0v4dXfhd9LXXRqn9n3Md/Fdsf7KkMcv2iFVWSANj5CwIboM8kAH3/RXx0P2q9Qvf2m9V/Z00fw/ayf2LNYxXN9catDbSst7AtxuhtXTzJvLUncEY9O2a8w+HP/AAUD0nxZ8Hte+PHirw9DpPh3RLE3eLbVYL6+eQzeRHE9sqo8LSPwhkIB47c0AfopRXwL4r/bW8R/CLR9I8Q/tDeBJfBljq1+lss0mpQ3QSFreWcuREm7zE8oIYiASzjax6VQ8S/tweJ/DVt4Jg1DwNHYal41sbzUorXVdZg08W1vbsgj82SWPYJJUdX8vqv3Tkg4AP0Jor86PFv/AAUQ8LeCfHHxA+HfiDw7PBqXgjTmvoA1wvl6i8MUUs8Mb7MK8QlU/wAWVy2B0r9DbG6F7ZQ3qjaJkV8em4ZoAtUV4D8V/j9ofwj+InhHwT4gtSbXxPFq88t9vwtnFpFr9qkYoFZn3KCMAgj36V5/8YP2v/APgb4cXPjDwJNFrt/FZaLqsVowkhD6frV3FbQz7inAIcsF+9kYIGaAPr6ivn5f2qP2fm8Yan4EbxNbpqWjpdyXaukiRILBd9yBMyCJ2gXmVEdmQA7gMGrB/aJ8A6t8E/EPxz8DPLq+maBY3d6ytDNZvL9kg+0bVE8aNh027X2lSGBGRQB7zRX5ln/go3HY+CNa8QeIPBUtjqmlQaJeR2Z1GF4JrXXWVYHNwExEVDZdXQED2yR3njn9r/4n+CvBHh3x0nw9ttUtPEN9Fpkb2XiC2niW7uJzBCgkSNlcMR8zDAQ5B5BoA++KK/P3xZ+2j498LWXjlz8OzPdfDqDT7nWoBq0SiKK9szdMUbyiH8rGzC53dRjpXdad+1R4ht77wFpXjjwe2j3XjyLVLiCNb9LkQQadaC7VyUQBjKp27eCh5OelAH2RRXwT8K/24bfx78FfEXx58RaBa6RouhaX/aQSDV4b65ckOVhkiRFaB3KbU3jkn2rH1b9v/TNI/Zkj/aDm8JXhvo9bOgX2g+eBc2t6kjI0bN5fLABWC7ATuA4oA/Q6ivnf4L/tG+Fvjn4q1/RfB0Jew0a00i9hvfMDC5j1aBp1+TGUMYXawJJz6YxX0RQAUUUUAFFFFAH/0P7+KKKKAPn/AOOXwE0v453/AIWfW7sQ2Xh7UJby4tmi8wXkU1tLbPETvXZkSk7sN0xjnNfJfw//AOCcGneAPDmi6PB4tkvLrTIfEENxdzWeXuf7as47KL/lsdi2sMSALkh8cbM1+mlFAHwP8Ov2NPGHwr1t5vBvjhYtM1XQ9J0jWrWXTFke6fR7H7FHJFKZswq6gMyYcgg4bnI5DVf+Cdema54Hh8Ean4qfy4fBNr4REsVmFYyWd6l9HdYMx43oFaHuM/PzX6T0UAfBfw9/Yofwfe+GNYvNZsBd6B4il16b+z9Ne2S68y0NqI28y6nYMM7zIWbP3Qoxmu51b9nHx9/wvvX/AIw+EfGMGm6f4ptbGz1TS5dLFw8kVkjoBHcfaE8ssJG58s496+u6KAPzR8Of8E/Na0z4IN8Bte8V6Xe6SJ9MlWWDw+ltNKun3AmK3LC6fz/MXKZbG3JPPSulH7Cdz4f0+O2+G3i06FLoXie48R+GMWCzQ6Wl4hS4szGZQJbdyWIAMZTPfv8AoTRQB8X6R+yLOfhZ8R/CnjPxIdZ8SfE6OcanrDWaxRRs0HkQeVbByAkC4Kgybif4hxj3SD4MeDbz4Nad8EfFsC6ppFlYWdjIg3W6yizCbGAjYFPmQNgNx0yRXrlFAHy/8b/2cZviP4G8H+D/AIdazH4Uk8EavYatpsslqdQjX+z4pI44mjaaIkYcclyfl5znNePTfsP6vFpkPiSw8ayP48TxMvimXXLqxSSCa5WE24hNosiBYREdqgSblPO7tX6A0UAfnXpv7AUGnaKbB/FbT3Vx4f8AEmkXlw9kB5114jffJcqiygIsZyFiGcj+MdToX37Ca3kkjr4o2B4PCcOBZdP+EXYtn/Xf8vGcf9M/9uv0EooA+EvDn7FC+H9Q8OX/APwknmnQL3xRd4+x7fO/4SQMNufOO3yM9efMx0SvmP4sf8E+/in4W+EN5ovwb8SDVprvR9B0nUtLeyijbUDo1wpjkimknAtwELOyfNnbgHJ4/YmigD8/Lj9iDWrj4uSeNP8AhMyPDb+KpvFp0Y6epkN5dWxtpV+1CUNt24KYTC85DHBG5+yr+xhB+zN4gl1RdVstXSKwfTLSZbBre+Fu8qy7ZpjcSo+NoGEijBI3HnivueigD879a/Yj8e6t4Y+JPw7j8fwReGviJqOo6q1odHDTWlzfypLnz/tQ8xUCBduxN3XI6Vq3v7D0PjWy8K6P8XdU0jWdO8NX2oXL2VloaadbXUN9afZwhjWeQLJG/wC9EvJJwAAVDV9915v8ZPGd/wDDj4Q+KviHpUUc91oOj32owxy58t5LWF5VVsEHaSoBwQcUAfH2gfsX/EvwLD4T1/4ffEf7H4o8M6JL4Zk1G60pbqK70ozmaCNoDOu2SD5Qrhzu28qASK6tP2J/Dlv8JfA3wsg1hpz4R8T2nii5vbu2WaTULiKZ551ZQyiMTNIVyN21cDDV4ppP/BQ4eMI5h4Eisr6TT/h1qHiu/V4biLydUs40b7ON+zdDliCV3E44evQvHX7XnjjwtofhjVLPTbGR9c+H2q+Lpg4kwl3YWkVwka4cfumZyGzlsYwQaAPsL4ifCf4ffFi1s7L4g6cNRi0+cXNupkkj2SgY3fu2XPHY5FeFftF/sm6R+0Vr8eqa5qv2O3TQNT0XyRb+aRJftE8dwG3rgwPCrBcHce4xXh3hD9sz4i+I/jd4U+HGvwaH4bsNe0nR9QhbUlukk1Z9QgWWdbCZcwq0LsI1jkyztwD6eb2n7f8A8VP+FaeO/G+r2egWWs+FpYI/+EamS7j1Oz87UIrXNyJCqSoYpA4khKqrlQRzQB654f8A2BLnwl4euNM8L+N7uw1C58HyeGpNShtyty13PevezXxfzt2ZHkZTHncFP+spfhT+wTc/DvxBpPiTUvFUV9Np3iZvEjxxWDxRuzWX2TyVMl1M4wfnDsznsRnmrHgX9rH4heMf2g/GHwykfQrbTvC1/f2q2hgvDqFxFaW/mLIJQTbLlyAwYhtoOB0NeFfBX/god8Zfib4Z8R6pZeGtL8SXeleFW19ItCFyDbXfm+WlncrJvzIy7pQImJKoQBnkAH3D8DvgF4w+CfizXvsfipb/AMJ6rfX+p2+ktYKk8F1qEqysWuvMJkVMMEHlqcP8xO0VzFl+x9o1n+1tP+0+NYc28sTSpovk4iTUngW1a7Em/GTACpXy85Jbd2o+Bn7RWufEr9nPXPjFe6hoOs3umRXcyDRluIoUMECyiG4iuP3sUqvuDLnBXawPzYHz1pX7bPxw8OeDtJ8SfFLQtEYeMfBuqeKPD82mSThVm0yzF41vdRSknBRl+dH68d8gA7Xwh+wn4k8LfDPxh8JX8XabNpXimw1G0SaPQVhvoZL+Yyh5bgXRadY9zKIyFyMcjGDQ13/gn5qUHhLxV8Ofhd4xh8M+G/GcenJqWnppSyxh7WExXEkH79BE1zhHbCnDJ3Br3T9kH43+MPj34Ak8beK7rR594tykekwXcHkPJGJHjl+1feZdygNGSvXk15V8Nv2vfHPjT4v+HPh3qGm2MVrrPiHxfpEskYk8xYvDwjMDLlyN0m8+ZkEf3QKAMjxp/wAE7tH8aXHibxVceL9Qt/FGrava6npuoR+YtvYLpwjWzje0E4iuGhjRlErbT85IC9Kg+Lv/AATn0L4uaFrMF/4kay1fUfFdz4lt9Qis8m3ivIYIZ7Qp5w3o4gVt25eQPlIBzyXjL9ur4o6H4G03xRFp2k6XbXfinW9Cu9Zv4bqbTbCLTZDHbmdYCZA9wfl35CKQTjHT1K3+OH7T99+0LoPwlsB4OudL1vSP+EgS8gN3LmwjlijcI4YKzsJN0bbdhGCaAO0sf2VNfu/2nbD9ozxn4ltb59Fa/Gn29rpUdlctFeoY0iu7pJCbhLeM7Y8opzyTnOfonQvhP8PvDXjrU/iVomnCDW9ZQJeXQkkYyqNvG1mKD7o+6o6V8FeDP2yPjb8W4/CXgj4ZaPokfirxF/bd3cz6i04sLWx0m7e1QhI2MrySlR0YAHnGDx0UX7U3xjT9pu2/Z917/hG9KltrfRpL1WivrmS4mvVLXKWskYCKE2kRtOqg5Gc80Ae0a9+y/wD23qPxi1D+3PK/4Wzplvpu37Nu+weRZPZ78+YPOzv34/d4xjPevMdW/YYXU7ua5XxP5Qmi8KRbRZZx/wAIw5bP+uH+vzj/AKZ/7dfS3jH9o34AfD3X5fCvjvxromjanbhWltLy+hhmQOAylkdgwypBGRyDXkP7Rn7R/iP4ea54b8DfC+LTJtQ8QWd/q0mparJJ/Z1lpunRrLLO4gzJJuDAIqEZ6k4oA8T8P/8ABOmy8OjxVplrr9nJY65p+uWNjNLprvf2X9tq6sTN9q8uRY954WGMuOCwxX0t4R/ZutPDHxO0H4hT6kl3FongxfCBs2tgqyqJYpDPu3kKCI9vl7Tw33uMH5G8afty/ELw94f+Hk+m6j4RuX8Xy61HdatDHf3WmoNL8vZ5ccYFwGfeVdSrBWHXHNQeNP27/in4O/aLk+C0VjoWpG2v9AsBZQi6TUL3+1beOWeW2+9GEgZicSAfJjJzmgD2P9gv9mrXP2f9A8W3niq2mtbvWdYljsYbiVJpYdGsiyWMbMjOoIVnbAbgMOhzWp4Y/YuTwX8bfG/xp8M+JXgm8SW9/wD2TaNa749IvtTWL7TcqfNHmtJJErbQI+MrnnNeU+Hf25PF0njL4lyeJxoy6N8PLnXUbToIbsancQaTkRuJm3WoMjbQQTkcnGK1vEv7Tf7S/wAMvgNH8ffilpXhqDTdSbR5rSGya6lmtodQnRZFnBwHdIXyGjON4I2kYJAJPCf/AATn8NfDyTw/eeA/FN/bXOn6FqGhambrzbuK+i1CEqxjjecLbBbgm42R5UscH+9XR/D79grw98OvjV4E+NOja6wuvCegQaLf2y222PUprazNkl0T5p8p/LIBGHyFAyOSeQuf20PHnxBsPit4h+AK6Le6V8OobK/hn1KG7jN1avZT3Fyu3KMJRLEFjyqrtznPBrkPE37ZX7RHgnw94B1PxvB4U0WDxxZ/2imsXcd9/ZUKyxwvBaSuhYwztvctI5MYUDAODQB7j8V/2PvGfxE+InjLxPoHjxtA0fx9p1npWs2MOmpNcPbWqPGyxXLzYj8xJHBPksQDWD8Rv2CdO8X2/iiw8N+IU0m11y18N2tpDLY/a0tE8OMSgcGZPOWUYUg7MY/izXL/ABF/bE+NfgjxD8RfFem6JoupeCvhvqNlaX0Ylmi1OWC6jidpYmy0LFPNztIXIHXNbvw//a38feOvj34t+HaSaFb6X4avb63jtWt7w6hcw21v5qSiUE2y5dgGViG2g4GcGgCz8Uv2L/iF8XPhpY/CfxR4w0WPSIgy3Edr4Zhh2FpTJ5tn/pDG2lKnYzAuD97AJOfpDw18Do/Dfx21D40Q6m8yXugWWhLZvHllFnI8nmtNv+YtvwRsHTOTnFfOnhr9rzxvrPhD4NeI7rTbFZfiPb6jNfqokCwGzs5LhRDlyRlkAO7dx78182/DH/gol8cfiN4E8U6/o2jaBqt3oXhNvEpawF15NnLFMA1ndK7cyvCJJE8uT+HoecAH6qad8J/h9pPxGv8A4tadpwj8Q6nALa5vPMkJkiUIAuwsUHEachQePc18P+Kf+CflzrHjAT6L4sgtvDP/AAko8UR6dc6THc3dpdPMk88dreeajxRTug3JsOAB1rgvEf8AwUoay8WeObDQ9Ltp9J0fw1Fqeg3TBz9t1KSO1c2zEMAwVryIFUAbAPPIr1P4rftkeL/hZ8b/AAl8Mr/SrKfTWj0xPFt8rN/xL7nV3eK3EfzYCiRCzbg3yEdDzQBo+HP2Jtb0L42W3xFuPGK3fh6y8Rax4jg0R9OXd52twvHOj3Pm5ZVL5T930yCDkESfsF/s1a5+z/oHi288VW01rd6zrEsdjDcSpNLDo1kWSxjZkZ1BCs7YDcBh0OaPE37Yur6D+19Y/A2PTbZvCRuLbRb3VWLedHrV9BLcwQr820qyIin5SQzde1eZfD39uf4ieLf2pZvgdJp+j3lmviXWNDa2s/tA1K2tdN3bb2UtuhMTEbT907ulAHsPhj9i5PBfxt8b/Gnwz4leCbxJb3/9k2jWu+PSL7U1i+03KnzR5rSSRK20CPjK55zXB+E/+Cc/hr4eSeH7zwH4pv7a50/QtQ0LUzdebdxX0WoQlWMcbzhbYLcE3GyPKljg/wB6sv4F/tj/ABr8Vp8OvFHxU0TRl8O/Ey6urCxm0qSZbmzuoPN2CeOXcrrJ5RAKMNvU+h8t8Lf8FBvi3rf7NPif4/Tp4bkuNGgtWTTYre+R4Hub5LUGeR2EbrsLMPKckHGe4oA+ifh9+wV4e+HXxq8CfGnRtdYXXhPQINFv7ZbbbHqU1tZmyS6J80+U/lkAjD5CgZHJOn8V/wBj7xn8RPiJ4y8T6B48bQNH8fadZ6VrNjDpqTXD21qjxssVy82I/MSRwT5LEA14A/7ffxYPwWv/AIi2mk6RcwWHilNCk8RW0V5Poq2Ri8x7wxKBclI2xG2Dt3Hhux/S34XeKLjxr8OtF8WXd3p9/LqFpHM9xpTtJZSMw5aFnwxQnpu5HQ80AfLHhT9jq/8Ah98ebn4teBte06DSrpdKgOm3ejLdXMNvpdqloqQXrXCtEXReWEZ68g45zPgr+wzp3wO8deHPiF4V12NNR04avDrLx2Ii/ti11KZp4Y5SJSVa2crtc7ywUDAGAPveigD42i/Zc8SaZ+07rP7Q2h+ItOWDXp9PlubC70Vbm5jWxt1tysF4bhWiMigkkRnGcYOOfJfAX/BPyXw98Ddd/Z58XeJ7LUtA1exNtHNZaKlhfpMs/wBoilluPtEpn8t+iso47iv0jooA+APF/wCxn48+M2kaJoH7RvjuHxbY6PqCXXkJpCWYmhFvNA6kpMzCWQyhzJkhSg2qCSaxdU/Yd8fajbeBpZvHllqOoeBrG90yG41jQU1BLm1uWQxeZG10i+ZCiBPM53dcA5z+jNFAH5u/Gv8A4J3aR8btC8Uw614mNprGv6zDrFrqMNlzZkWkVpPDs84GSOdEJYb0xlc528/afi74O/D34gR6L/wm+njUZNAdZrJ2kkj8uVdvzYRlB+6OGyOK9PooA+S/i5+zLqnxk+LmmeOvEviQxaHo+l6pYWmlw2iiVZtWtmtZ5WuC53ARnKp5fDDrjivnbTv+CefiyXwnqHhvxb8QV1J7nRtC0K1lTSVgFvaaDdpcxDaLg7y6psYkghiWyRha/T2igD86PDf7Alr4V+Imv+MNP1jTrq11SXWbm0S/0o3Nzay6xFJG6mRroRSQqZDlDCrSL8jNjmvSfhh+ybf+AP2cvF3wDvfEn2tfFMeoxQyx28iWumx38HkiK3glnlcRRnLhDNyScbc19nUUAfCviH9hTwDL+zdH8BPADWHh26ZtLnvNVi01JPttxprI/mTw+YhfzCpyrSnbuPJ5z2Wufs06/wCLPhV4b+HfiTX7FLjw94gstcE+m6StjbSJZT+eIVtlnYRl+QXDnk7tp6V9cUUAfIPi39lP/hKLj4w3H9veR/wtiys7PH2Xd9g+yWhtd3+tHnbs78fu8dMnrSan+y/rut/E3wb4y1jxQH0rwRo9zp1hpyWQR2uLy1+ySzPN5hJUoAVj28H+LFfX9FAH5meHP+CfXiLT/g3D8A/EHjSxn8Nm60570afoY0+8vbWwlMphluEunZmdtuJCCUwcA547DTP2DbDw7rl63h3xVdDRLrxTonitbG+je+mW60s5nDXMs++Q3WFyzAlNv8Q4r9A6KAPkH9mH9kXQP2XvFPjfVfCuqPdaZ4su4Li1sGh2DTooTKRCj723oDKdvyrtAA5OTX19RRQAUUUUAFFFFAH/0f7+KKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACuS8feDdM+IvgTWvh9rcksVlrthc6dcPAQsqxXUbROULBgGAY4JBGeoNdbRQB81p+yt8M21HS72/kvLuPS/Ccvg0W8sieVNp0wQOZNqKxlIQDcrKvJ+Xpjzjwx+wn8ONB0++03VvEPiHXUn8PXXhayOpXUUp03TLtNjpbBYUUNtwA8gc4UDoCD9t0UAfHzfsZ+C7rXvDF9q/iXxDf6V4Rl06607Rri5iaxjutLhWCCbAhEgOEDsquqNIS23kiuU1X9gL4ceKIdZfx54o8S+Ib3V9PttKF9f3UMlzb2Vrdx3ixRsIADuliXe8gdyOAQSTX3ZRQB8v+HP2WtE8KfETXvHuheKvEEMHiW9udQ1DRxNbHTpZ7qHyWbb9n80bVClf3vDKM5GQeR0D9iD4deD4dLfwTr+v6Le6X4f/wCEbW9srmKK4mtVmE8byN5BBljcfKwABUlWUqcV9nUUAfOnw3/Zn8GfDfwV4n8IQ6hqOqz+Mpri41fUr6SNru4luY/KZspGka4X7oEYA6nNeWeFv2CvhT4e0WbRtW1vxBr4Hh+58M2Mup3cUjabp93F5Mi2qRwxxI5TA3sjHAAORkH7eooA8G+FvwJPwq8CXfw+sfF/iDVrSW0SytJdQmt2msIo4zGn2doreIKVBBBcPyo98+QQ/sL/AA7sPC+iaVoviLxBYa1oOpX+rW/iCC5iGpNdap/x9FyYTCyyjAZfKHAHvn7YooA+ONQ/Yt8GyfCyx+EHh7xT4k0bSoUvo782l3EZdUGpMGuGuzLDIruxzh1VSu5guAcV6j4b/Z48AeEfHPh3x14fa6t5fC/h3/hGbG28xWgFlujYbsqXMi+UoDb8YzkE817tRQB8T/8ADCvw1sNF8P2nhLX9f0HVPDM2oy2Wr2FzFHe+XqkzTTwyEwtE8e5ztBjyuBznJPUaR+yZpHh/4lRfFLQ/Gvii21BrfTbW+T7Vbyx6jHpY2x/ajJbPI5cFvMKyKW3HG2vrCigDHvPD3h/UJzdahY288pwC8kSsxx7kE1478Zf2e/CvxlvNE1+41HUvD+ueG3lfTNV0eZYLq3E6hZU+dJEaOQABlZCCB25r3qigD4etv2EfAemaR4Vs/D3izxLpd/4SuNVurXU7W4thdyy6yVa5Mpe2dDu28bUXAJ610HiX9iv4a+K77Wtc1jVtYfVdbvdE1JtQEsIube80GIRQTQnyNqu6g+blWBLHaF4A+waKAPkzQ/2P/Bmia14quD4h1270TxndanearoE81udNll1UFZyFW3WYYB+TE2Rgcmud0/8AYh8IweCR8OtY8ZeKtW0eCTT2sra9vYpEs002ZZokiAgAxlAhLhm2DaCK+1aKAPAb/wDZy8EajqnxH1ae6vhJ8T7GGw1UK8e2GOC1e0U2/wC7+VjG5JLlxuwcAcVwvxA/Y+8KfEPwNo/wwv8AxP4hsvDml6XbaPPp1rcxLBfW1pt2eeGhbEh2jc8Xlkjj0x9cUUAfE+v/ALCHwm8TeK9Y1vVtX11tI8QXdpeaj4fS6jj0q5eySOOJZEWESsgEakqZSCRXoHhD9mLRPA/xO1n4j6D4n15IPEF/PqWoaI0tu2mTz3EXlMWT7P5uAoUged1UZyMg/TFFAHxd8PP2Gvhn8O9e0zVbXW9e1Oz8PQ3sGh6bf3aS2mlrqCsk3kARK5OxiqmV32qfXmt3wB+xn8KPhxf6TfaFcahJ/ZvhyTwtMk0kRS+sJHLj7SFiXc6Enay7MA4IIr60ooA/PzRP+CbP7P2h+GfCHhaO51eeHwbq8ms28k08RkuZZWhZorgiEB4v3EQ2qEOEHzV2fxA/YL/Z++KN94u13x1aT6hrPi6dZn1SQxm8sPLjSONLN/LxGqCMYDBySTkkcV9oUUAfDV//AME9/gHqlnf3epfbp/El/rA1s+JXeE6vFcrMswEcvk7FjBQKE8sgKT35rtLH9jn4Y6Z4qs/G+nXupQ6rY+Kr/wAWxXCyRBxcamu25tj+6/49ZFABT7/A+evrGigD4w+EP7Dfww+EGsaBqtvrWva/H4U+0HRbTVrqOS1sHut3mPFFDDEC53MAz7iM8c4xkaN+wX4F0j4RX3wKk8YeKL3wteJEkdjcXFoyWvk3SXYaEraqQTImDuLDaxGAcEfc1FAHyTqn7Ifhxr3xLeeC/FniLwsPFWpnVryHSriBIBPJD5M22OSCQETjDvv3HeAVK9K91+FPwy8K/Br4daR8L/BMckel6LALeAStvkIySWZuMszEscADJ4AHFeg0UAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAf/0v7+KKKKACiiigAooooAKKKKACiiigAooooAKKKKACkJAGTwBS18Jf8ABRb4jal4K/Zrv/CfhpJ5ta8bXEPh2xhtI2nuH+2E+dsiT5nPkLIAF53EDvQB91RyRyoJImDKehByKfX4C/Bz45/Ef4B/s9+OvA3w6j1LTT8K/Etrq8en61ZeTf3HhfUZSWheGZdyMCzSO64IBBBAPPbeKP22f2iNf0zS/EXgi/Npofj7xZq1loN3Da2hmh0rSkVY9n2x4YDJcylyfPfI2ELyQtAH7iUV+K8f7QP7ani2Twr4LPiLTvC+s3PhTWdW1G4itbTUkll0u5dI2Ty3eJXkVFSQB2VCX+XcABf0z9un4kJbWWr+MtcsdIg1H4QXHiO3EscMaS+IY7h4kMZcZZmVMiEEqf7tAH7M0V+Evi39s79rPW5/Deg/D29httQTwRpHiGYvDp6R6hd3iK8zTNeTQCOAcri3G5WyTxgD7r/a3+OHxM+Hnww8Bt4W1C08J6l401zTdJvdVuEjuoNLS6jZ5XAcmJypXALHYRk5HDAA+2tL13Q9ba5TRbyC8NlO1tcCCRZDFMmC0b7SdrjIyp5Gat319ZaXZTanqcyW9tbo0sssrBEjRBlmZjgAADJJ4Ar+evwF+0F8V/hN4B8R2PgTW4NS1Lxb8WNSsbrxDZwWpSVRbwuZLeO4kS1VrgjKb5CgGQM8Gv0N0fxr8WvHn/BP7x5q/wAbEt/7eh0LxBbPNbvbuJ44oJQkjC1kliSQjh0VuGB4FAH6C6fqFhq1hBqulTx3VrcxrLDNEweOSNxlWVhkFSDkEHBFWyQBk9BX8/3jv9rr4nfBn4J+CdN+E/iaa3uPDngXw1fXOmf2ZZyWZ+0RRr+/ubidZ28xSAqW0RK9SeuPs/8A4KJa3Be+FPhnoPjO7k03wP4i8T2Vv4llSRoYzaMpYRTSLgrExyWORjbntQB+l0E8FzEJ7Z1kRujKcg/iKlr8lfGnjH4b/A3UPCHwU/Y28SaP4R0bxtr16ura3FKmp2unT2tpFIIkWaR4UknUoApOM84yTXOfCj9tr4m3fiT4Ww/E/wAQ6dDoOo614t0nV9XMcVtaajDpECNaXAdvliDSNj5GCsRj2oA/Y2ivxS+GP7SH7Vfxzsvg/wCGvDPjK20S98bw+I5tR1FtNgucppd0wi2RFVXPlrs4IGGLHLAVa8N/th/HfVPHmgeMJPFGmy2mufEFvCEvglLSL7Ta2O9o/tDTZ8/zEADMTiPLDoOKAP2jor8Z/gt+0v8AtRat42+H/inxn4mtNR8PeL/FGr+HZNKXT4oXjjtDJ5cxnXDFwRjaAq7VGdxJNYHwL/av/aonk+GPxC8f6/a+IdI8fxeJYzo8WnxW0kT6HHK0biZPmZ5XjwRgKF4wScgA/beivyO/Yd/aV/ae+NHj/StT8fXNvqPhnX9NurqRcafbmzuYpPkW2SC4e6kiA+R/PTeG5OK/RTRviJ4y1L4o33gO98G6jZaTaRs8Wuyy25tLggLhURZDKCdxA3IPumgD1hp4FDMzqAhw2T0PvUtfzo+LpYL39snxR4W+LzPF8KdS8fwrrDx8Ry6ilsDZQ3bEjFszZJ7HBLYwCPqjxv8AtJftO+F4vjh8VtL161uND+G+oyaXp2iNp8bGR7jykSWSddrhbffvC87/AJgxwBQB+w1FfiJ4o/bN+Pvwi0nx/osPi3S/iI2k6FpGp2euwWcUMFjPqVzHbuki25KOqq5kTd83A3ZGRT/Gn7Wv7RXw70T4keEtE8bad4zuvDEvh2TT/EUFjAkWdVmVJYJY4d0TDGdpX5wMnOcYAP2i1jXtC8PW8d3r97BYxSypAj3EixK0shwiAsQCzHgAck9K1q/Cn4w/EP4xapp3iL4N/GPXIfEt34J+IXhJLfUorNLEyR34M20xRkqAmMA5J9SeK7Pwn+2z8Rrn9pvTNHi8VS6r4M1a91+1mW60q0tYbdNMhklRrbyZ5LyQR7QHadUEg+6Mn5QD9o6K/BrwZ+3J8e7seMfs3iWbWbNfAV94k0u6v9MsLOWG6tpRGjRw20tx+5YE4S4PmHAJGOv2B+yn8Yfj/q3xyb4Z/GTxBa+IrfWPBmn+LrZoLFLP7G13II2t12EmRRn7zkk4HTkUAfo8bq2W4Fo0iiVhuCZG4gd8dcUv2iAyeSHXf/dzz+Vfhp+2Tp/gnwr+1P4P+J2iwaKuzxlpg1DUNK1N7nxE86qFa3e1dwkcPygFVzxjgbiGauneDPgJ+2TF458Saf4W8YS+NPGeomyv9K1CabWtJMuUYS24HlbYSG3jDFWLAngUAfuZHdWssz20UitJHjeoILLnpkdRmp6/m8/4J/Pbab+078PtavDEbfxFa+Ixp1/aSrJqWplXeQtrMYmkMZVFJjAH3gvJwSP6Q6AGSSxwoZZmCqOpJwBTZZ4IFDTuqBiFBY4yT0H1Nfml/wAFW/DvhLV/2U9W1bxDqctte6b5cunWa3ZhiupnnhRi0II84xoWKg5C7icV88/tW3Xwp+JfxzttJ+LOo2t14Qs/hXqGp6Iz3IFq2srM0bPEysFeZY04AJOVHGaAP2ykuIIiFldVJ6AnFK08KyrAzqJHBKqTyQOuB7V/OB8SfD8MPw18GftMfF238LeM00vwLotleaFrepzW+sMTNIySxJGBuaSKRSGcncNxwcc2fi1rOheLPEvxF+LOpyvbfFCw8baBB4ZhlmZL6Czk8sxRRRZHysjOXAXBIyeaAP6OWdFYIxALdAepxTq/Pb9qpHk/a1/Z+jjkMLNfa+BIMEoTZLyMgjjryCK+DvC3/BQT9opvDXj/AFLUNZ0/U5fAei3D6e8doqLr7yaibRdRQbFxBbpjKRkBmGWz8wAB+8mta9oXhqwOq+Ir2DT7VWVDNcyLFGGchVG5iBliQAO5OKNK17QtdNyNDvYLw2U72tx5EiyeTPHjdG+0na65GVOCM8ivwd+JvxU+P3xB/Zm8Zad8YrmPVNOtdS8MXOl3zHT0umFzdL5iyRafPMipuTMTHBYZyScgXP8AhfHxK+DGn+OdH+GUhsrrxV8add0+a/WO3lkgjWKF9sQu3jt/MkPCmVgoAPfGAD97KK/D3xl+1d+1v4O+HPhXxV8Q9ZttEsbaS9j12+0mPTNSv2VZxFbTSWnnsnlHJWUQOGDhuR8or9Ufir8Qfi94YTTLj4ReBv8AhNYrxHed/wC04dN+zgbSnE6kvvBPTG3bz1oA9xJAGTWJq/ibw54e0ubXNf1C2sbK3AMtxcSrFEgYhRudiFGSQBk8k4r5j8ceLPiX4t/ZZ+ImpfFDwp/wh9/HomrRxWn2+LUPMiFoxEnmQgKuWLLtPI2571+NFv4L8MaJ/wAE2vGfiO30zwrZ6lfaFoP+kaNfSXGpTxte27SG+icBYn3bDhMjcSOwoA/pOor8e/E37Xfxs+Gnxr8d6R4w1Nbm3srHXLzwxpdlbWt1p91FpVu0gE1xFJ9qhuImQmaNxg4KgKdufNfCn7W/7XkXwS8afETXNTgureLwpb61pt/LHpgmt755okeNLe1mmLwFJCVeeMOCuGCtwQD9zqK/E/xh+1x+1H8EvDnxJsfFms2XibU9L0PQtX026SwS1jsW1eVYpFKK2JEi35RpGJJALcEivsv9iz4kfHbx0nirTvjNOl/b6dPavpV87WC3c0NwjF1mi0+eaJNjKNhyC6tnnBAAPuWiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/0/7+KKKKACiiigAooooAKKKKACiiigAooooAKKKKACuf1jwl4V8Q6jp+r69plrfXekymexmuIUkktpWG0vEzAlGI4JUg4roKKAOL1D4b/DvV9T1DW9W0HTrq81azOn308trG8lzaHrBKxUl4v9hiV9qyNS+DHwg1jwXb/DfVfCukXHh60O6DTJLKFrSI5JykRTYpyxOVAOSfWvS6KAPO9J+EPwn0FbRND8MaTZiwtJbC2ENnDH5NrOxaSFNqDbG7Es6D5WJyQTWXqnwF+B2t2Wl6brPg3RLu30SMxafFNp8Dpaxt1WJShCKe4UAZr1iigDyTxD8AvgZ4utNNsPFPg3Q9Rg0aFbewjudPglW2hTAWOIMhCIMDCLhfaux8V+BfBXjvw8/hLxrpFlq+lybd1neQJPAdn3fkcFfl7ccdq6qigDyo/An4JHwrceBf+EP0QaJdzC5msBYQC2knVQokaIJsLhVUBiMgADPFdHo/w6+H/h7we/w90HQ7Cy0CSKSF9Ngto47Ro5siRTEqhCHydwI+bJznNdlRQB49rf7PXwD8TNZv4j8EaDfnTrRLC1+0adby+RaxjCQx7kO2NRwqDAA6CvQvEPhTwv4t0KXwv4q0211PTJ1CSWl3Ck0DqOQGjcFSBgYyK36KAPIv+Gf/AIE/8Id/wrz/AIQzQ/7B877R/Z32CD7N52MeZ5ezbvxxuxux3rR1b4LfB7X/AA1YeC9c8KaPeaPpTh7KxmsYXtrdhnBiiKbE6n7oHU16ZRQBwWjfCr4YeHLjTrvw94c0uwl0gXC2D29pFE1qLo7phEVUeWJWJL7cbjyc1WtPg98JbDxtJ8SrHwvpMPiKUsX1RLOFbxiwwSZgu8kjgnOSODXwP/wUE1jx+vxM+Evg3wTLr0qa1c6wtzp3h/UzpVzeeTbxug87eiDYct85PGQOTivk34cfGX4sfF/wf8E/2ffFfjXV9JfxDrHiCw8SanFMbfU/M0jEkNl9q+8WZZER3HLllHJBBAP2ysvhV8L9NSwj07w3pcC6XdSXtkI7OJRb3M2fMliwvySPk7nXDHPJqrb/AA4+EPhG10mW00LSNLg8PySnTClrDCtlJdkiUwEKBE0pYh9mC5POc1+THx88GfELwF8efAfwM8C69448X6dJpeqXb2dn4h+xX7kSAqHuXeNWWEHCh8ttwAa+i/jbpz/Ef4xfBv8AZSQ3MtppSR+LNeW7m+03H2XSlEdstxJk+aZbglZGJO5hu5oA+2PC3wW+D3gbxHc+MPBfhXSNI1a8DLPeWdlDBPIHO5gzogYhiAW55PJ5r0yvwT/ZL+LXxP8Ai5+0TpPwl+I/irVdM0bR9W1vWLEm8m8zXbm3uSq2rS7v9RbICxgyQwBypUjHGfBP4s/GnRPjL4O8beIda8UR6DrHjvUdAvL+91Nr3SroSu629olmzs0bhhgSEKFHIzjgA/dzU/hH8Kdbs9V07WfDOlXdvrsyXGpRTWcMiXk0eNjzhkIkZcDDPkjHFatp4A8CWEGqWtjothDFrjtJqKJbRqt47rsYzALiQlRtJfORx0r8PpdZ+JHjz9k/xj+25qPxI8QaT4u0vVbprOwtr8xaZZrb3Kxx2bWn+rbepGQ3LblJ3c7v161Txj8WLv4WeGfFfgfS7G51jVDpr39vfTG3jiguQpuCh6l0z8q85Pr0IB1Ph34LfB7wh4fvvCfhTwrpGm6XqmRe2dtZQxQXAIxiWNUCuMHGGB446VX0z4F/BTRvC8vgnSfCGi22jTzJcy2MVhAtvJNGQySNGE2s6kAhiCQQMdK+KP8Agofrfjmz1T4X+G/Bdxrf/E516W3uLPQdQOm3V4ghJEYm3oo55G84FfBKfFn42eK/gx8O/BF5rXie/wBftvHeq6Bqthaam1jqrC3TclpJeF0WV0VgfMc7cnHagD949Q+FPwv1W9u9S1Tw3pdzcX9zb3l1LLZxO81xaDEEsjFSWeIcRsclB0IrI0/4FfBLSvFMnjnTPB+i2+tSyvO9/HYQLcmWUMrv5oTfuYMwY5yQxz1NfH/7Q/ivx/8AAH/gnjrPiPwy2r6Xr9jZQorarfDUdRtmvrtI3L3QZw7xrK2xlY7QFx0r4c+MXi/4nfA2L4s/BTwR4/1u/tbW28NXGmT3l7Nc6g91fsPOtre4UPJG90uWXHAx2BJoA/ZTSP2df2fvD6XceheBtAsxqEEtrdCHTbePzoJyDJG+EG5H2jcpyDgccV3Wm+BfBOjaxH4i0jR7G11CKyTTkuYbeNJls4juSAOqhhEp5WPO0HoK/A7QP2ovFvw/+FfiX4L+KPFGp+Etd8Q+K5NLiTW7ua6vPDOlLEkk8n2twGkd0OIQh+825SDzXXaX8RtM8d/8E5vCvjfxR8RfE48VWB1PS7S00fUZFvdT1y4mJtIpzhppvKQxsFDYVH9dooA/Z9/gp8HJfG//AAsyTwppDeIgwk/tM2UJvN4GA3nbN+4DjdnOOM07R/gt8HvD3jKf4iaD4V0iy1+6Z3m1KCyhjunaXO9jKqhyXydxzlu+a8M0TTf2hdG/YwTw3dXpu/ijH4Zl8t3kVpzfeUdmWY7WkUlVLsSpcZJIOa+BP2U7741a78Zte+Aja54z8Mm+8EWl/fzeI5FvL211dbmOKea1EryhI5kaQISFOfm2/KtAH62eFPgp8HPAniC48W+CfCmkaRql3uE13Z2UME7hzlgXRAxDHkjPJ5NenV+M/wALrT9ob4xf8E4tEj8AanrWseJ312Uz3EWqm01Cazg1CUSqLuWRdp8sYGWI6cEcV9g/sO+PvDvib4X6rpFrJr8N/oOu3ek6jB4mvxqN5DfQhN8S3GSHQZG0DHO76kA+nPHHwt+GXxOht7f4leHNL8Qx2ZZoF1OziuxEXwGKCVW2k4GcYzisDUvgF8C9Y0HTvC2q+DNDudM0dnaws5NPgaC1Mjbn8qMptTc3LbQMnk1+c3wl0jxlJ+3PeaX8HfG3iTxT4Z0Cwu08W3Gq3xubH+0pw/k21uMCNZImKEhB8iqVyDkHm/2SYvit4H+IEnwI+NmoeMdE+JGueGbuW0vtS1qPXNM/1gH2iK33yIk0ZUbQ5bIDA4DDIB+pGv8AwS+DXivxJa+MfE/hPR9R1axVFt7y5sYZZ4lj5QK7KWAQ8rg/L2q/f/Cf4W6p40g+JGp+G9LuPENsAIdTltInvE28DbMVLjA4GDwOlfIX/BPLU/Fl58PvHOleL9c1DxDPo3jjWNNivNTnaedobbylUFm4A6naoCgk4Ar79oA5fX/BHgvxVfWep+KNIstSudO80Wkt1AkzweeuyXy2cEpvT5X243Dg8Vzlv8F/g9aLapa+FNHjFjaSafbBbGECG0mz5kCYT5Yn3Hcg+U5ORya9LooA8g0f9nv4DeH9Eu/DWh+CtCtNOv5Yp7m1i0+BIZpIG3RM6BNrGNuUJHynpitfU/g58I9a0XUPDer+FtJutP1a8fUb22lsoXiubx8bp5UK4eU4GZGBbjrXpFFAHjMn7Of7P0ttpllJ4H0BodFLGwQ6dblbYs28+UNmEy3zHHVuevNezUUUAU9Q0+w1ewn0rVYI7q1uo2imhlUPHJG4wyspyGVgSCCMEV5Hp/7N/wCzxpOn32k6V4C8O2trqcaxXkMOl2yR3EaOJFWRVjAdVdQwDZAYA9RXtFFAHnGl/B34S6H4qvvHWjeGNKtNa1MOLu/hs4kuZxJy++QLubeeWyfm75rE0n9nj4BaDZalpuieCNBtLbWU8q/ih063RLmMHdtlUJh1Dc7WBGea9iooA4m4+Gnw5u5726uvD+myy6lapYXbvaxMbi1jzshkJX541zwjZUelReBPhd8NfhbZTab8NfD+neH7e5cSTR6dax2yyOBgFhGq7iBwCegru6KACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP//U/v4ooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAPEvjH+zp8Hvj8dLf4r6U+pPoryvZPHd3Fo8LTgK+Gt5YidwUDknpXJ6v+xx+zRrfwxsfg7feE7YeH9MnN1aQRPLFLDO3WRZ0cTbz/ExclsAHIAr6ZooA+O7z9gX9lC/0zS9KuPDEgj0cTi1ePUr6KVftLb5S0kdwruXbklyx7DArqvhF+zZpXwq+KviX4nR6g18dWstN0nTLZ0bOm6bpsQjWASySSPKXb53diCWGTzk19NUUAfOdt+yX+z9Z2+kW9p4fEf9g6zLr9g63NwJYNQnYPJIJPN3lXYDdGSYzgZXAFYHhf8AYj/Ze8HeOIviNoXhZF1e3u3v4ZJ7u6uI4rqRtzSpDNM8SPu5BVAVPTGBX1XRQB8lav8AsK/sp6747m+I2q+EIJtRubr7dOhnnFpLc5z5j2okFuzE5JzGQSSTkmvdPiP8LPAnxa0i00H4gWP2+0sb231GBPMki23Nq26N8xspO09iSD3Br0GigDxv4xfs/wDwl+Ptlp+n/FbS31KPSZzc2hjuri1eKVl2lg9vJE3TjBOK841H9iL9l3U/A2m/DifwqkWkaRdyX9rFb3d1byLdSrteVpoplld2UAEu7HAHoK+q6KAPJrD4G/C3T/hM/wADV0vz/C0kMtu9ldTS3O6OZ2kcGWV3lJ3MSCXypxtIwMeVaZ+xB+y9pPw/1T4Y2nhaM6TrU0NxeCW5uJLiSS24hb7Q8pmXyhkIFcBQSB945+rqKAPFfhZ+zx8Hfgzo15oXw/0VLaLUZjcXck8kl3PPKRt3PLO8kh46DdgdgMmvL9a/YR/ZV8Q+E/DngfVfC7PpnhIXI0mJL+8ia3+1uJJTvjnV3LMAcuzEYwMCvrqigD5w0f8AZJ+AOgrGumaJIpi0W78Oqz3t1I4029keaaLe8zMdzyMQ5O9c4VgAAKvhj9j79nvwf4V1zwfoWhyR23iURrqczX1093cLCQUBuWmM6hccBZAPbk19M0UAfIelfsJfsvaF4Kuvh9ofh+4tNKvLmG8eKPU77ctxbiQI8bm4LxkCV87CA275geK7HRP2TP2e/DfhvQfCWieHI7ew8Naumv2CLPNuTUowQs7v5m+V8HH71nBAAIwAB9F0UAfIfgz9hD9lf4feIR4p8H+GpbO83TOSNSvnjZp0MchaJ7ho23KxHKn26CtfwP8AsXfs3fDsas3hbw+8U2t6fJpVzPLfXU8/2KUYaGKWSZpIVI/55sp6HOQMfUtFAHz98Gf2XPgd+z5f3+p/CPSJdLm1MYui99dXSyHO7O24mkUMT1YAMe5r6BoooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA//1f7+KKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP/Z" alt=""></div>
    <hr/>
    <table style="width:21cm;font-size: 12px">
        <tr>
            <td colspan="3" style="align-content: end;text-align: right">
                \${#debtorFullName}<br />
                \${#debtorFullAddress}<br />
                <br />
                Bruxelles, le \${#today}
            </td>
        </tr>
        <tr>
            <td style="width: 6.2cm">
                <table style="border-spacing: 0" valign="top">
                    <tr>
                        <td style="border: 1px solid; text-align: center; padding: 0.5cm">
                            Etude ouverte/Kantoor open :<br/>
                            du lundi au vendredi :<br/>
                            van maandag tot vrijdag :<br/>
                            08h00 – 17h00<br/>
                            (16h00 le vendredi/vrijdag)<br />
                        </td>
                    </tr>
                    <tr>
                        <td style="border: 1px solid; text-align: center; padding: 0.5cm">
                            Tel : 02/626.86.99<br />
                            Fax : 02/626.86.89<br />
                            Email :<br />amiap@leroy-partners.be
                        </td>
                    </tr>
                    <tr>
                        <td style="border: 1px solid; text-align: center; padding: 0.5cm">
                            <p style="text-align: center"><b>Vos identifiants/Uw identificatiesgegevens :</b></p>
                            <p style="text-align: center">Référence structurée/Gestructureerde mededeling :</p>
                            <p style="text-align: center"><b>\${#fileOgm}</b></p>
                            <p style="text-align: center">Dossier : \${#fileReference}</p>
                        </td>
                    </tr>
                    <tr>
                        <td style="border: 1px solid; text-align: center; padding: 0.5cm">
                            <img style="width:5cm " src="data:image/png;base64,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" /><br />
                            <p style="text-align: center">
                                <b>Paiement en ligne sécurisé</b>
                            </p>
                            <p style="text-align: center">
                            <b>Beveiligde online betaling</b><br />
                            </p>
                            <p style="text-align: center;text-decoration: underline">
                            www.leroy-partners.be
                            </p>
                        </td>
                    </tr>
                    
                </table>
            </td>
            <td colspan="2" style="vertical-align: top;padding-left: 1cm">
                <h2 style="text-align: center;border: 1px solid" >MISE EN DEMEURE</h2>
                <p style="text-align: center;">
                    <b>Cette lettre concerne un recouvrement amiable et non un recouvrement judiciaire (assignation au tribunal ou saisie).
                </b>
                </p>
                <p>
                    <b>En cause de :</b>\${#clientFullname}/\${#debtorFullName}
                </p>
                <p>
                    <b>Référence client :</b>\${#clientReferences}
                </p>
                <p>
                    Mon client, \${#clientFullname}, inscrit à la Banque Carrefour des Entreprises sous le numéro \${#clientBce} et ayant son siège social \${#clientFullAddress} (tél. : \${#clientPhone}), 
                    me charge de vous réclamer le paiement des montants repris au présent décompte :
                </p>
                <p style="font-size: 10px">
                    Les éventuels frais de recouvrement amiable repris au présent décompte, le sont conformément à l’article 5 de la loi du 20 décembre 2002 relative au recouvrement amiable des dettes du consommateur.
                </p>
                <p>
                    Ce solde doit être versé dans les quinze jours de la réception de la présente. A défaut, mon client m’a donné instruction de poursuivre la procédure de recouvrement, ce qui risque d’engendrer des frais supplémentaires qui pourraient être légalement mis à votre charge.
                </p>
                <div style="display: flex;justify-content: center">
                    <table style="border-spacing: 0;width: 100%">
                        <tr>
                            <td style="border: 2px solid black;width: 40%">Montant à payer :</td>
                            <td style="width: 60%; border-right: 2px solid black;border-bottom: 2px solid black;border-top: 2px solid black">\${#fileDebtRemaining}</td>
                        </tr>
                        <tr>
                            <td style="border: 2px solid black">Numéro de compte :</td>
                            <td style="border-right: 2px solid black;border-bottom: 2px solid black;border-top: 2px solid black">\${#clientIban}</td>
                        </tr>
                        <tr>
                            <td style="border: 2px solid black">Référence structurée :</td>
                            <td style="border-right: 2px solid black;border-bottom: 2px solid black;border-top: 2px solid black">\${#fileOgm}</td>
                        </tr>
                    </table>
                </div>
                <p>
                    Toute consultation de votre dossier, demande de plan d’apurement et/ou paiement en ligne peut se faire via notre site www.leroy-partners.be ou par email.
                    Veuillez agréer,  l’expression de mes salutations distinguées
                </p>
                \${if[\${#fileDebtRemaining}<1200]}
                <p style="text-align: right">
                    Michel LEROY,<br />
                    Huissier de Justice
                </p>
                \${endif}
                <table>
                    <tr>
                        <td>Référence créance</td>
                        <td>Date d'échéance</td>
                        <td>Principal</td>
                        <td>Intérêt</td>
                        <td>Frais administratif</td>
                    </tr>
                    \${#debtList}
                </table>
            </td>
        </tr>
    </table>
</body>
</html>""";
