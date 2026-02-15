import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mini_ai_chat_app/feature/chat/data/chat_repository.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import 'chat_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mini AI Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            /// User Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_circle, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user?.isAnonymous == true
                          ? "Guest User"
                          : user?.email ?? "User",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// Empty State
            Expanded(
              child: StreamBuilder(
                stream: context.read<ChatRepository>().getUserConversations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.chat_bubble_outline,
                            size: 72, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No conversations yet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Start a new chat to begin.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    );
                  }

                  final conversations = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final data =
                      conversations[index].data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(data['title'] ?? "Untitled"),
                          subtitle: const Text("Tap to continue"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  conversationId: conversations[index].id,
                                ),
                              ),
                            );
                          },

                        ),
                      );
                    },
                  );
                },
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final chatRepo = context.read<ChatRepository>();
          final conversationId = await chatRepo.createConversation();
          print("Created conversation: $conversationId");
        },
        icon: const Icon(Icons.add),
        label: const Text("New Chat"),
      ),
    );
  }
}

