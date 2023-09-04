class ChatModel {
  ChatModel({
      this.id, 
      this.email, 
      this.text, 
      this.createdAt,});

  ChatModel.fromJson(dynamic json) {
    id = json['id'];
    email = json['email'];
    text = json['text'];
    createdAt = json['createdAt'];
  }
  num? id;
  String? email;
  String? text;
  String? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['email'] = email;
    map['text'] = text;
    map['createdAt'] = createdAt;
    return map;
  }

}