import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chatgpt/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HomeVM extends GetxController {
  final List<MessageModel> messages = [];
  late OpenAI? chatGPT;
  bool useDalle = false;
  bool replyLoading = false;
  bool sendButton = false;
  TextEditingController msgController = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  void connectOpenAI() {
    chatGPT = OpenAI.instance.build(
        token: dotenv.env["API_KEY"],
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 30)));
  }

  void sendMessage() async {
    if (msgController.text.isEmpty) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text("Please enter a message"),
        ),
      );
      return;
    }

    MessageModel message = MessageModel(
      id: messages.length + 1,
      msg: msgController.text,
      time: DateTime.now().toString(),
      isImage: useDalle,
    );
    messages.add(message);
    insertDataIntoDB(message);
    replyLoading = true;
    update();

    msgController.clear();

    if (useDalle) {
      final request = GenerateImage(message.msg, 1, size: "256x256");
      final response = await chatGPT!.generateImage(request);
      print(response!.data!.last!.url!);
      insertData(response.data!.last!.url!, isImage: true);
    } else {
      final request = ChatCompleteText(
        messages: [
          Map.of({"content": message.msg, "role": "user"}),
        ],
        model: kChatGptTurbo0301Model,
      );
      final response = await chatGPT!.onChatCompletion(request: request);
      print(response!.choices.first.message.content);
      insertData(
        response.choices.first.message.content,
        isImage: false,
      );
    }
    replyLoading = false;
    update();
  }

  void insertData(String data, {bool isImage = false}) {
    MessageModel message = MessageModel(
      id: messages.length + 1,
      msg: data.trim(),
      isBot: true,
      time: DateTime.now().toString(),
      isImage: isImage,
    );
    messages.add(message);
    insertDataIntoDB(message);
    update();
  }

  void scrollControllerAtLast() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  // write program to find time in 12 hours fromat from DateTime.now()

  String getTime(String time) {
    String hour = time.substring(11, 13);
    String min = time.substring(14, 16);
    String ampm = "AM";
    if (int.parse(hour) > 12) {
      hour = (int.parse(hour) - 12).toString();
      ampm = "PM";
    }
    return "$hour:$min $ampm";
  }

  Database? db;

  Future initializedDB() async {
    String path = await getDatabasesPath();
    db = await openDatabase(
      join(path, 'chat.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE chat(id INTEGER PRIMARY KEY , msg TEXT NOT NULL,time TEXT NOT NULL,isImage BOOLEAN NOT NULL, isBot BOOLEAN NOT NULL)",
        );
      },
    );
    update();
  }

  // insert data into database

  bool loadMessages = false;

  Future<void> insertDataIntoDB(MessageModel message) async {
    try {
      await db!.insert(
        'chat',
        message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> getMessages() async {
    loadMessages = true;
    update();
    List<MessageModel> chats = await getChats();
    // print("mmmmmmmm length ${chats.length}");
    messages.addAll(chats);
    loadMessages = false;
    update();
  }

  Future<List<MessageModel>> getChats() async {
    List<MessageModel> data = [];
    try {
      List<Map> maps = await db!.query("chat", orderBy: "time");
      data = List.from(maps.map((e) => MessageModel.fromMap(e)));
      update();
    } catch (e) {
      print("error at get chats $e");
    }
    return data;
  }

  Future<void> deleteFromDb(int id) async {
    try {
      await db!.delete("chat", where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print(e);
    }
  }

  Future<int> updateDb(MessageModel chat) async {
    return await db!
        .update("chat", chat.toMap(), where: 'id = ?', whereArgs: [chat.id]);
  }

  Future close() async => db!.close();

  @override
  void onInit() async {
    super.onInit();
    connectOpenAI();
    await initializedDB();
    await getMessages();
  }

  @override
  void onClose() {
    super.onClose();
    chatGPT?.close();
    chatGPT?.genImgClose();
  }
}
