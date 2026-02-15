# Mini AI Chat App

A miniature ChatGPT/Gemini-style chat application built using **Flutter + Firebase + BLoC architecture**.

This app supports:

- Anonymous authentication (Guest mode)
- Google Sign-In
- Account linking (Guest → Google)
- Persistent conversations using Firestore
- Real-time chat with simulated AI streaming
- Clean, scalable architecture

---

## ✨ Features Implemented

### 🔐 Authentication
- Anonymous Sign-In (Guest mode)
- Google Sign-In (Android)
- Anonymous account linking to Google (preserves UID & chat history)
- Secure session persistence

### 💬 Chat System
- Create and list conversations
- Messages stored in subcollections
- Real-time message streaming
- Simulated AI response with typing effect
- Timestamps for messages
- Auto-update conversation title based on first message
- Conversations sorted by last updated time

### 🎨 UI / UX
- Clean login screen
- Empty state handling
- Real-time conversation updates
- Message bubbles (user & assistant)
- Loading and error states
- Logout support

---

## 🏗️ Architecture

This project follows a **feature-based clean architecture** with separation of concerns:
```
lib/   
 │
 ├── features/
 │    ├── auth/
 │    │     ├── bloc/
 │    │     ├── data/
 │    │     ├── presentation/
 │    │
 │    ├── chat/
 │    │     ├── bloc/
 │    │     ├── data/
 │    │     ├── presentation/
```
### Architecture Highlights

- BLoC for state management
- Repository pattern for Firebase abstraction
- Firestore as backend database
- Real-time listeners using streams
- Clean separation between UI, business logic, and data layer

---

## 🗂 Firestore Data Model

users/{uid}
uid
email
isAnonymous
createdAt
updatedAt

conversations/{conversationId}
ownerUid
title
createdAt
updatedAt

conversations/{conversationId}/messages/{messageId}
role (user | assistant)
content
createdAt
status (sent | streaming | done)



---

## 🔐 Firestore Security Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // 👤 Users collection
    match /users/{uid} {
      allow read, write: if request.auth != null
                         && request.auth.uid == uid;
    }

    // 💬 Conversations collection
    match /conversations/{conversationId} {

      // Allow CREATE (use request.resource)
      allow create: if request.auth != null
                    && request.auth.uid == request.resource.data.ownerUid;

      // Allow READ / UPDATE / DELETE (use resource)
      allow read, update, delete: if request.auth != null
                    && request.auth.uid == resource.data.ownerUid;
    }

    // 📨 Messages subcollection
    match /conversations/{conversationId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
  }
}


⚙️ Setup Instructions
1️⃣ Clone Repository

git clone https://github.com/amarnathbaitha/mini_ai_chat_app
cd mini_ai_chat_app

2️⃣ Install Dependencies
flutter pub get


3️⃣ Firebase Setup
Create Firebase Project
Go to Firebase Console
Create new project
Add Android App
Use your app package name (example: com.amar.mini_ai_chat_app)
Add SHA-1 fingerprint:

cd android
.\gradlew signingReport

Download google-services.json
Place it inside:
android/app/


Enable Authentication
Enable Anonymous Sign-In
Enable Google Sign-In

Enable Firestore
Create Firestore Database
Choose region (asia-south1 recommended for India)
Start in test mode
Apply provided security rules
Create Composite Index (if prompted)
When running conversations query, follow Firebase console link to create composite index.

4️⃣ Run App
flutter run

📱 Platform Support
Android: Fully supported
iOS: Structure included (Apple Sign-In requires macOS for full testing)


🧠 Trade-offs & Decisions
AI response is simulated on client (no external API used)
Streaming effect implemented using incremental Firestore updates
Firestore used directly (no Cloud Functions for MVP simplicity)
Real-time listeners used instead of manual polling


🚀 Stretch Goals (Extendable)
Replace simulated AI with real API backend
Move Chat logic to ChatBloc
Add dark mode
Add retry / regenerate response
Add conversation deletion
Add per-user rate limiting

🧪 Testing & Maintainability
Architecture supports unit testing of repositories and blocs
Firebase logic abstracted via repository pattern
Clean separation improves maintainability

📌 Known Limitations
Apple Sign-In requires macOS environment for testing
AI responses are simulated (no real LLM backend)
No offline caching implemented for guest mode


🎯 Assignment Coverage
| Requirement              | Status |
| ------------------------ | ------ |
| Anonymous Auth           | ✅      |
| Google Sign-In           | ✅      |
| Account Linking          | ✅      |
| Persistent Conversations | ✅      |
| Streaming AI Simulation  | ✅      |
| Empty States             | ✅      |
| Secure Firestore Rules   | ✅      |
| Clean Architecture       | ✅      |

👨‍💻 Author
Amarnath Baitha
Flutter Developer

🏆 Summary
This project demonstrates:
Strong Firebase integration
Clean architecture
State management using BLoC
Real-time database usage
Proper authentication flows
Production-style separation of concerns