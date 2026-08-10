/// Pesan percakapan chat dengan asisten AI
class ChatMessageModel {
  final String id;
  final String sender; // 'user' | 'ai'
  final String text;
  final String timestamp;

  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
  });
}
