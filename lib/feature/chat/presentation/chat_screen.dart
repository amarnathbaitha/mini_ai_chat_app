import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    final messageId = const Uuid().v4();

    /// 1️⃣ Add user message
    await _firestore
        .collection('conversations')
        .doc(widget.conversationId)
        .collection('messages')
        .doc(messageId)
        .set({
      'role': 'user',
      'content': text,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'sent',
    });

    await _firestore
        .collection('conversations')
        .doc(widget.conversationId)
        .update({
      'title': text.length > 20 ? text.substring(0, 20) : text,
    });


    /// Simulate AI response
    _simulateAIResponse("This is a simulated AI response to: $text");
  }

  Future<void> _simulateAIResponse(String fullText) async {
    final aiMessageId = const Uuid().v4();

    final docRef = _firestore
        .collection('conversations')
        .doc(widget.conversationId)
        .collection('messages')
        .doc(aiMessageId);

    await docRef.set({
      'role': 'assistant',
      'content': 'Typing...',
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'streaming',
    });


    String accumulated = "";

    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      accumulated += fullText[i];

      await docRef.update({
        'content': accumulated,
      });
    }

    await docRef.update({
      'status': 'done',
    });

    await _firestore
        .collection('conversations')
        .doc(widget.conversationId)
        .update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('conversations')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data =
                    messages[index].data();
                    final isUser = data['role'] == 'user';

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.deepPurple
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                             data['status'] == 'streaming'
                                 ? "Typing..."
                                 : data['content'] ?? '',
                        style: TextStyle(
                                color: isUser ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (data['createdAt'] != null)
                              Text(
                                _formatTimestamp(data['createdAt']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isUser ? Colors.white70 : Colors.black54,
                                ),
                              ),
                          ],
                        )

                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

}
