# Copilot Instructions for Cooking Master Flutter App

## Project Overview
This is a Flutter application built with clean architecture, featuring:
- Abstracted storage layer for multi-storage support (local and cloud)
- User authorization and authentication system
- Dependency injection for loose coupling
- Repository pattern for data access
- Provider-based state management

## Architecture Layers
- **Presentation Layer**: UI components and state management (AuthProvider)
- **Domain Layer**: Business logic entities and use cases
- **Data Layer**: Repositories, data sources, and models
- **Storage Layer**: Abstract storage interfaces with multiple implementations

## Key Directories
- `lib/presentation/`: Screens and state management
- `lib/domain/`: Entities, repositories interfaces, use cases
- `lib/data/`: Data models, data sources, repository implementations
- `lib/core/`: Shared utilities, storage abstraction, dependency injection

## Storage System
The app supports multiple storage backends:
- **LocalStorageImpl**: In-memory storage (default, for development)
- **CloudStorageImpl**: Template for cloud backends (Firebase, AWS, etc.)

Switch storage type in `main.dart` via `ServiceLocator.initialize(storageType: ...)`

## Authentication Flow
1. **Splash Screen**: Checks authentication status
2. **Login/Register**: User authentication with email/password
3. **Home Screen**: Main app after authentication
4. **Logout**: Clears authentication data

## Dependencies
- `provider: ^6.0.0` - State management
- `shared_preferences: ^2.2.0` - Local storage (ready for integration)

## Running the App
```bash
flutter pub get
flutter run
```

## Setup Progress
- [x] Create .github directory and copilot-instructions.md
- [x] Scaffold Flutter project structure
- [x] Create clean architecture directories
- [x] Implement authentication layer with entities, repositories, use cases
- [x] Implement storage abstraction with multiple implementations
- [x] Create data models with serialization (UserModel)
- [x] Setup pubspec.yaml with dependencies (provider, shared_preferences)
- [x] Verify project compilation (flutter analyze - 0 errors)
- [x] Create comprehensive README documentation

## Architecture Patterns Used
- Clean Architecture (Robert Martin)
- Repository Pattern
- Dependency Injection (Service Locator)
- Provider Pattern for state management
- Use Case pattern for business logic

## Development Notes
- All imports use package: notation for clarity and testability
- Custom exceptions for error handling (AuthenticationException, StorageException, etc.)
- Service Locator manages all dependencies
- AuthProvider handles UI state for authentication
- Storage abstraction allows easy switching between implementations

## Next Steps for Enhancement
- Implement real authentication with API
- Add recipe feature (core functionality)
- Implement real cloud storage integration
- Add unit and widget tests
- Setup CI/CD pipeline
- Add biometric authentication

