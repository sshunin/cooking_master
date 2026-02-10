# Cooking Master

A sophisticated Flutter cooking application built with clean architecture principles.

## Overview

Cooking Master is a feature-rich Flutter app designed to help users explore, manage, and discover recipes. The app is built using clean architecture to ensure maintainability, testability, and scalability.

## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns across four layers:

### 📦 Presentation Layer (`lib/presentation/`)
- **Screens**: UI components for different app views
  - `SplashScreen`: Initial loading screen with authentication check
  - `LoginScreen`: User login interface
  - `RegisterScreen`: User registration interface
  - `HomeScreen`: Main app interface after authentication
  
- **Providers**: State management using Provider pattern
  - `AuthProvider`: Manages authentication state and operations

### 🎯 Domain Layer (`lib/domain/`)
Business logic and use cases - independent of frameworks.

- **Entities**: Core business objects
  - `User`: User entity with id, email, name, and creation timestamp
  
- **Repositories**: Abstract interfaces for data operations
  - `AuthRepository`: Interface for authentication operations
  
- **Use Cases**: Business logic operations
  - `LoginUseCase`: Handle user login
  - `RegisterUseCase`: Handle user registration
  - `LogoutUseCase`: Handle user logout
  - `CheckAuthUseCase`: Check authentication status

### 💾 Data Layer (`lib/data/`)
Concrete implementations of repositories and data sources.

- **Models**: Data models with serialization
  - `UserModel`: User data model with JSON serialization
  
- **Data Sources**: Interfaces and implementations for data operations
  - `AuthLocalDataSource`: Local storage for authentication data

- **Repositories**: Concrete implementations
  - `AuthRepositoryImpl`: Implementation of AuthRepository

### 🔧 Core Layer (`lib/core/`)
Utilities and cross-cutting concerns.

- **Storage** (`lib/core/storage/`): Abstract storage interface
  - `Storage`: Abstract interface for storage operations
  - `LocalStorageImpl`: In-memory implementation (development)
  - `CloudStorageImpl`: Template for cloud backends (Firebase, AWS, etc.)
  
- **Dependency Injection** (`lib/core/di/`): Service Locator pattern
  - `ServiceLocator`: Manages all dependencies
  
- **Exceptions** (`lib/core/exceptions/`): Custom exception types
  - `AuthenticationException`: Authentication-related errors
  - `StorageException`: Storage-related errors
  - `AppException`: General application errors

## Features

- ✅ User Authentication (Login/Register/Logout)
- ✅ Session Management
- ✅ Multi-Storage Support (Local, Cloud-ready)
- ✅ Clean Architecture
- ✅ Dependency Injection
- ✅ Provider State Management
- 🔄 Recipe Management (Coming Soon)
- 🔄 Cloud Integration (Coming Soon)

## Project Structure

```
lib/
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── home_screen.dart
│   └── providers/
│       └── auth_provider.dart
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       └── auth_usecases.dart
├── data/
│   ├── models/
│   │   └── user_model.dart
│   ├── datasources/
│   │   └── auth_local_datasource.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── core/
│   ├── storage/
│   │   └── storage.dart
│   ├── di/
│   │   └── service_locator.dart
│   └── exceptions/
│       └── exceptions.dart
└── main.dart
```

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd cooking-master
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Dependencies

- **provider**: ^6.0.0 - State management
- **shared_preferences**: ^2.2.0 - Local persistent storage (ready for integration)

## Authentication Flow

1. **App Launch**: SplashScreen checks authentication status
2. **Unauthenticated**: Routes to LoginScreen
3. **Login/Register**: User provides credentials
4. **Authenticated**: Routes to HomeScreen
5. **Logout**: Clears session and returns to LoginScreen

## Switching Storage

The app supports multiple storage backends. Change the storage type in `main.dart`:

```dart
// Use local storage (development)
ServiceLocator.initialize(storageType: 'local');

// Use cloud storage (when implemented)
ServiceLocator.initialize(storageType: 'cloud');
```

## Development Notes

- All imports use `package:` notation for clarity and testability
- Custom exceptions provide detailed error information
- Service Locator pattern enables easy testing and component replacement
- Provider pattern simplifies state management across the app
- Storage abstraction allows seamless switching between implementations

## Future Enhancements

- [ ] Real API authentication with JWT tokens
- [ ] Recipe feature (add, edit, delete, search recipes)
- [ ] Cloud storage integration (Firebase/AWS)
- [ ] Unit and widget tests
- [ ] CI/CD pipeline
- [ ] Biometric authentication
- [ ] Recipe categories and filtering
- [ ] User profile management
- [ ] Social features (sharing, recommendations)
- [ ] Offline support with sync

## License

This project is licensed under the MIT License.

## Author

Created as part of Flutter clean architecture demonstration.
