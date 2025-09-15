# 🌿 Hymnes & Louanges

A beautiful Flutter application for hymns and praises with MIDI audio playback capabilities, featuring a modern clean architecture and elegant Forest Green, Gold, and White design theme.

## ✨ Features

- **📚 Comprehensive Hymn Library**: Browse through an extensive collection of hymns with full lyrics
- **🎵 MIDI Audio Playback**: Listen to hymns with high-quality MIDI audio files
- **🔍 Advanced Search**: Find hymns by title, lyrics, author, composer, or hymn number
- **⭐ Favorites System**: Save and manage your favorite hymns for quick access
- **📱 Modern UI**: Beautiful, responsive design with Forest Green, Gold, and White color scheme
- **🌐 Offline Support**: All content available offline - no internet required
- **🎨 Custom Design**: Elegant typography with Raleway font family
- **📊 Clean Architecture**: Well-structured codebase following Flutter best practices

## 🎨 Design System

The app features a sophisticated color palette inspired by nature and worship:

- **🌲 Forest Green** (`#228B22`) - Primary color for text and UI elements
- **🥇 Gold** (`#FFD700`) - Accent color for highlights and favorites
- **💛 Yellow** (`#FFFFFF00`) - Secondary accent for interactive elements
- **⚪ White** (`#FFFFFF`) - Clean backgrounds and cards
- **📝 Typography**: Raleway font family for elegant readability

## 🏗️ Architecture

This project follows clean architecture principles with a well-organized structure:

```
lib/
├── core/                    # Core functionality
│   ├── models/             # Data models (Hymn, etc.)
│   ├── repositories/       # Data access layer
│   └── services/           # Business logic services
├── features/               # Feature modules
│   ├── hymns/             # Hymns feature with BLoC
│   ├── audio/             # Audio playback feature
│   ├── midi/              # MIDI file handling
│   ├── search/            # Search functionality
│   └── favorites/         # Favorites management
├── presentation/           # UI layer
│   ├── screens/           # Screen widgets
│   └── blocs/             # State management
└── shared/                # Shared components
    ├── constants/         # App constants and colors
    ├── utils/             # Utility functions
    └── widgets/           # Reusable UI components
```

## 🛠️ Technology Stack

- **Flutter**: 3.2.3+ with Dart 3.0.0+
- **State Management**: BLoC pattern with flutter_bloc
- **Navigation**: Go Router for type-safe navigation
- **Storage**: Hive for local data persistence
- **Audio**: Just Audio for MIDI playback
- **UI**: Material Design 3 with custom theming
- **Architecture**: Clean Architecture with Repository pattern

## 📱 Key Screens

- **Home Screen**: Browse and search through all hymns
- **Hymn Detail**: View full lyrics and play MIDI audio
- **Favorites**: Manage your saved hymns
- **Search**: Advanced search with multiple filters

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.2.3 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for mobile development)

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/yourusername/hymnes.git
cd hymnes
```

2. **Install dependencies:**

```bash
flutter pub get
```

3. **Generate code (if needed):**

```bash
flutter packages pub run build_runner build
```

4. **Run the app:**

```bash
flutter run
```

## 📦 Dependencies

### Core Dependencies

- `flutter_bloc: ^8.1.3` - State management
- `equatable: ^2.0.5` - Value equality
- `go_router: ^12.1.3` - Navigation
- `just_audio: ^0.9.36` - Audio playback
- `audio_session: ^0.1.18` - Audio session management
- `hive: ^2.2.3` - Local storage
- `hive_flutter: ^1.1.0` - Hive Flutter integration
- `shared_preferences: ^2.2.2` - Settings storage
- `path_provider: ^2.1.1` - File system access

### UI Dependencies

- `intro_slider: ^4.2.1` - Onboarding screens
- `showcaseview: ^2.0.3` - Feature highlights
- `flutter_launcher_icons: ^0.13.1` - App icons

### Development Dependencies

- `flutter_test` - Testing framework
- `flutter_lints: ^3.0.0` - Code linting
- `hive_generator: ^2.0.1` - Code generation for Hive
- `build_runner: ^2.4.7` - Code generation

## 🎵 Audio Features

- **MIDI Playback**: High-quality MIDI audio files for each hymn
- **Audio Session Management**: Proper audio session handling
- **Background Playback**: Continue playing while using other apps
- **Volume Control**: Adjustable audio levels

## 📊 Data Structure

### Hymn Model

```dart
class Hymn {
  final String number;        // Hymn number
  final String title;         // Hymn title
  final String lyrics;        // Full lyrics
  final String author;        // Author name
  final String composer;      // Composer name
  final String style;         // Musical style
  final String midiFile;      // MIDI file path
}
```

## 🧪 Testing

Run the test suite:

```bash
flutter test
```

## 📦 Building

### Android APK

```bash
flutter build apk --release
```

### iOS App

```bash
flutter build ios --release
```

### Web App

```bash
flutter build web --release
```

## 🎯 Project Status

This project represents a complete modernization of the original Hymnes app:

- ✅ **Architecture**: Migrated from GetX to BLoC pattern
- ✅ **UI/UX**: Implemented modern Material Design 3
- ✅ **Colors**: Applied Forest Green, Gold, and White theme
- ✅ **Structure**: Clean architecture with proper separation of concerns
- ✅ **Audio**: MIDI playback integration
- ✅ **Search**: Advanced search functionality
- 🔄 **Favorites**: In development
- 🔄 **Offline**: Enhanced offline capabilities

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Original Hymn Data**: Traditional hymns and translations
- **Flutter Community**: For excellent packages and support
- **Material Design Team**: For design guidelines and inspiration
- **Open Source Contributors**: For the amazing tools and libraries

## 📞 Support

If you have any questions, need help, or want to report a bug:

- 🐛 **Bug Reports**: Open an issue on GitHub
- 💡 **Feature Requests**: Submit a feature request
- 💬 **Discussions**: Join our community discussions
- 📧 **Contact**: Reach out through GitHub

## 🌟 Star History

If you find this project helpful, please consider giving it a star! ⭐

---

**Built with ❤️ using Flutter**

_"Make a joyful noise unto the Lord, all ye lands!"_ - Psalm 100:1
