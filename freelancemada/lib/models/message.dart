class Message {
  final int id;
  final int senderId;
  final String senderNom;
  final int receiverId;
  final String receiverNom;
  final String contenu;
  final String date;
  final bool lu;

  Message({
    required this.id,
    required this.senderId,
    required this.senderNom,
    required this.receiverId,
    required this.receiverNom,
    required this.contenu,
    required this.date,
    required this.lu,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender'],
      senderNom: json['sender_nom'] ?? '',
      receiverId: json['receiver'],
      receiverNom: json['receiver_nom'] ?? '',
      contenu: json['contenu'] ?? '',
      date: json['date'] ?? '',
      lu: json['lu'] ?? false,
    );
  }
}
