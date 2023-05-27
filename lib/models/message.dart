// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MessageModel {
  int id;
  bool isImage;
  String msg;
  bool isBot;
  String time;
  MessageModel(
      {required this.msg,
      required this.id,
      this.isImage = false,
      this.isBot = false,
      required this.time});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isImage': isImage,
      'id': id,
      'msg': msg,
      'isBot': isBot,
      'time': time,
    };
  }

  factory MessageModel.fromMap(Map<dynamic, dynamic> map) {
    return MessageModel(
      id: map['id'] as int,
      isImage: map['isImage'] == 0 ? false : true,
      msg: map['msg'] != null ? map['msg'] as String : '',
      isBot: map['isBot'] == 0 ? false : true,
      time: map['time'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
