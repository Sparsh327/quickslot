# Flutter Production Boilerplate

> Read this file before generating any new Flutter project. Every section below maps directly to files or conventions to generate. Follow the architecture strictly — do not deviate unless the user explicitly asks.

---

## Stack

| Concern | Package | Version |
|---|---|---|
| State management | `flutter_bloc` | ^9.x |
| Value equality | `equatable` | ^2.x |
| Navigation | `go_router` | ^14.x |
| Networking | `dio` | ^5.x |
| HTTP logging | `talker_dio_logger` | ^5.x |
| DI | `get_it` | ^9.x |
| Responsive sizing | `flutter_screenutil` | ^5.x |
| Functional error handling | `fpdart` | ^1.x |
| Date formatting | `intl` | ^0.20.x |
| Network connectivity | `connectivity_plus` | ^6.x |

---

## Project Structure

```
lib/
├── core/
│   ├── di/
│   │   └── injection_container.dart       # GetIt setup — only file that knows all layers
│   ├── error/
│   │   └── failure.dart                   # Typed failure hierarchy
│   ├── presentation/
│   │   └── screen_state.dart              # Generic ScreenState<T> + ScreenStatus
│   ├── network/
│   │   └── api_client.dart                # Dio wrapper — single place for HTTP concerns
│   └── services/
│       └── [session.dart, ...]            # In-memory app-level services
│
├── domain/                                # Pure Dart — zero Flutter, zero HTTP imports
│   ├── entities/
│   │   └── [entity].dart                  # Immutable value objects, no JSON parsing
│   ├── repositories/
│   │   └── [feature]_repository.dart      # Abstract contracts returning Either<Failure, T>
│   └── usecases/
│       └── [action]_usecase.dart          # One class per action, calls one repo method
│
├── data/
│   ├── models/
│   │   └── [entity]_model.dart            # JSON parsing + toEntity() mapper
│   ├── data_sources/
│   │   └── remote/
│   │       └── [feature]_remote_ds.dart   # ApiClient calls; returns models or throws Failure
│   └── repositories/
│       └── [feature]_repository_impl.dart # Implements domain interface; returns Either
│
├── presentation/
│   └── [feature]/
│       ├── cubit/
│       │   ├── [feature]_cubit.dart
│       │   └── [feature]_state.dart       # Separate state file for non-trivial states
│       └── screens/
│           └── [feature]_screen.dart
│
├── router/
│   ├── app_router.dart                    # GoRouter definition
│   └── app_routes.dart                    # Route path constants
│
├── values/
│   └── network_constants.dart             # Base URL + endpoint helpers
│
└── main.dart
```

---

## Architecture — Layer Rules

```
Presentation  →  Domain  ←  Data
     ↓              ↑
   Cubit        UseCase
                   ↓
              Repository (abstract)
                   ↑
           RepositoryImpl (concrete)
                   ↓
             RemoteDataSource
                   ↓
               ApiClient
```

**Hard rules:**
- `domain/` imports nothing from `data/` or `presentation/`
- `domain/entities/` has no `fromJson` — that lives in `data/models/`
- `data/models/` maps to entities via `toEntity()` — presentation never sees raw models
- Cubits depend on use cases, not repositories directly
- `core/di/injection_container.dart` is the only file that imports across all layers

---

## pubspec.yaml

```yaml
name: your_app_name
description: "App description"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.5.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # state management
  flutter_bloc: ^9.1.1
  equatable: ^2.0.8

  # navigation
  go_router: ^14.0.0

  # networking
  dio: ^5.9.0
  talker_dio_logger: ^5.1.1
  connectivity_plus: ^6.0.0

  # DI
  get_it: ^9.1.1

  # functional error handling
  fpdart: ^1.1.0

  # UI
  flutter_screenutil: ^5.9.3

  # utilities
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
```

---

## Core Layer

### `core/error/failure.dart`

```dart
abstract class Failure implements Exception {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

// Add project-specific subclasses:
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Check your internet connection']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Conflict']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}
```

### `core/presentation/screen_state.dart`

```dart
import 'package:equatable/equatable.dart';

enum ScreenStatus { initial, loading, success, failure }

class ScreenState<T> extends Equatable {
  final ScreenStatus status;
  final T? data;
  final String? errorMessage;

  const ScreenState({
    this.status = ScreenStatus.initial,
    this.data,
    this.errorMessage,
  });

  bool get isInitial  => status == ScreenStatus.initial;
  bool get isLoading  => status == ScreenStatus.loading;
  bool get isSuccess  => status == ScreenStatus.success;
  bool get isFailure  => status == ScreenStatus.failure;

  ScreenState<T> copyWith({
    ScreenStatus? status,
    T? data,
    String? errorMessage,
  }) =>
      ScreenState<T>(
        status: status ?? this.status,
        data: data ?? this.data,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, data, errorMessage];
}
```

### `core/network/api_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import '../error/failure.dart';
import '../../values/network_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({String? authToken}) {
    _dio = Dio(BaseOptions(
      baseUrl: NetworkConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      TalkerDioLogger(),
      // Add auth interceptor here if needed:
      // _AuthInterceptor(authToken),
    ]);
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<Response<dynamic>> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<Response<dynamic>> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Failure _toFailure(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    final code = e.response?.statusCode;
    final msg =
        e.response?.data?['error'] as String? ?? e.message ?? 'Unknown error';
    return switch (code) {
      401 => UnauthorizedFailure(msg),
      404 => NotFoundFailure(msg),
      409 => ConflictFailure(msg),
      _   => ServerFailure(msg),
    };
  }
}
```

---

## Domain Layer

### Entities — `domain/entities/[entity].dart`

Entities are plain immutable Dart objects. No `fromJson`. No dependency on any package except `equatable`.

```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  @override
  List<Object?> get props => [id, name, email];
}
```

### Repository Interfaces — `domain/repositories/[feature]_repository.dart`

All methods return `Either<Failure, T>` from fpdart. Never throw.

```dart
import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';
import '../../core/error/failure.dart';

abstract class UserRepository {
  Future<Either<Failure, List<User>>> getUsers();
  Future<Either<Failure, User>> getUserById(String id);
}
```

### Use Cases — `domain/usecases/[action]_usecase.dart`

One class per user action. Implements `UseCase<ReturnType, Params>`. Cubits call use cases, not repositories.

```dart
// Base interface — all use cases implement this
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// For use cases with no parameters
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
```

```dart
// Example: domain/usecases/get_users_usecase.dart
import 'package:fpdart/fpdart.dart';
import '../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUsersUseCase implements UseCase<List<User>, NoParams> {
  final UserRepository _repository;
  const GetUsersUseCase(this._repository);

  @override
  Future<Either<Failure, List<User>>> call(NoParams params) =>
      _repository.getUsers();
}
```

```dart
// Example with params: domain/usecases/create_booking_usecase.dart
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/error/failure.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CreateBookingParams extends Equatable {
  final String slotId;
  const CreateBookingParams({required this.slotId});
  @override
  List<Object?> get props => [slotId];
}

class CreateBookingUseCase implements UseCase<Booking, CreateBookingParams> {
  final BookingRepository _repository;
  const CreateBookingUseCase(this._repository);

  @override
  Future<Either<Failure, Booking>> call(CreateBookingParams params) =>
      _repository.createBooking(params.slotId);
}
```

---

## Data Layer

### Models — `data/models/[entity]_model.dart`

Models handle JSON parsing and map to domain entities via `toEntity()`.

```dart
import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;

  const UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String? ?? '',
      );

  // Maps to domain entity — this is the only place the mapping lives
  User toEntity() => User(id: id, name: name, email: email);
}

// Extension for list mapping — avoids repetition in repos
extension UserModelListX on List<UserModel> {
  List<User> toEntities() => map((m) => m.toEntity()).toList();
}
```

### Remote Data Sources — `data/data_sources/remote/[feature]_remote_ds.dart`

Data sources call `ApiClient` and return models. They throw `Failure` (caught by the repo impl).

```dart
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';
import '../../../values/network_constants.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient _api;
  const UserRemoteDataSourceImpl(this._api);

  @override
  Future<List<UserModel>> getUsers() async {
    final response = await _api.get(NetworkConstants.users);
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

### Repository Implementations — `data/repositories/[feature]_repository_impl.dart`

Implements the domain interface. Wraps data source calls in `Either` using `TaskEither`.

```dart
import 'package:fpdart/fpdart.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_sources/remote/user_remote_ds.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;
  const UserRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<User>>> getUsers() async {
    try {
      final models = await _remote.getUsers();
      return right(models.toEntities());
    } on Failure catch (f) {
      return left(f);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
```

---

## Presentation Layer

### When to use Cubit vs BLoC

| Use **Cubit** | Use **BLoC** |
|---|---|
| Simple async load + display | Complex multi-step flows |
| CRUD screens | Wizards / multi-page forms |
| Feature has ≤ 3 distinct actions | Actions have preconditions / chaining |
| State transitions are obvious | Need to test event sequencing |

**Default to Cubit.** Only reach for BLoC when you find yourself adding boolean flags to Cubit state to track "what triggered this transition."

### Simple screen — Cubit with `ScreenState<T>`

```dart
// presentation/users/cubit/users_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/presentation/screen_state.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/get_users_usecase.dart';

class UsersCubit extends Cubit<ScreenState<List<User>>> {
  final GetUsersUseCase _getUsers;

  UsersCubit(this._getUsers) : super(const ScreenState());

  Future<void> loadUsers() async {
    emit(state.copyWith(status: ScreenStatus.loading));
    final result = await _getUsers(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: ScreenStatus.failure,
        errorMessage: failure.message,
      )),
      (users) => emit(state.copyWith(
        status: ScreenStatus.success,
        data: users,
      )),
    );
  }
}
```

### Complex screen — custom state class + Cubit

Use a custom state class (not `ScreenState<T>`) when a screen has multiple independent sub-states (e.g., main content loading + a booking action in progress).

```dart
// presentation/venue_detail/cubit/venue_detail_state.dart
import 'package:equatable/equatable.dart';
import '../../../core/presentation/screen_state.dart';
import '../../../domain/entities/slot.dart';
import '../../../domain/entities/venue.dart';

class VenueDetailState extends Equatable {
  final ScreenStatus status;
  final Venue? venue;
  final List<Slot> slots;
  final String selectedDate;
  final String? errorMessage;
  final bool isBooking;
  final String? bookingError;
  final bool bookingSuccess;

  const VenueDetailState({
    this.status = ScreenStatus.initial,
    this.venue,
    this.slots = const [],
    required this.selectedDate,
    this.errorMessage,
    this.isBooking = false,
    this.bookingError,
    this.bookingSuccess = false,
  });

  VenueDetailState copyWith({
    ScreenStatus? status,
    Venue? venue,
    List<Slot>? slots,
    String? selectedDate,
    String? errorMessage,
    bool? isBooking,
    String? bookingError,
    bool clearBookingError = false,
    bool? bookingSuccess,
  }) =>
      VenueDetailState(
        status: status ?? this.status,
        venue: venue ?? this.venue,
        slots: slots ?? this.slots,
        selectedDate: selectedDate ?? this.selectedDate,
        errorMessage: errorMessage ?? this.errorMessage,
        isBooking: isBooking ?? this.isBooking,
        bookingError: clearBookingError ? null : bookingError ?? this.bookingError,
        bookingSuccess: bookingSuccess ?? this.bookingSuccess,
      );

  @override
  List<Object?> get props => [
        status, venue, slots, selectedDate, errorMessage,
        isBooking, bookingError, bookingSuccess,
      ];
}
```

```dart
// presentation/venue_detail/cubit/venue_detail_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failure.dart';
import '../../../core/presentation/screen_state.dart';
import '../../../domain/usecases/get_venue_slots_usecase.dart';
import '../../../domain/usecases/create_booking_usecase.dart';
import 'venue_detail_state.dart';

class VenueDetailCubit extends Cubit<VenueDetailState> {
  final GetVenueSlotsUseCase _getSlots;
  final CreateBookingUseCase _createBooking;

  VenueDetailCubit(this._getSlots, this._createBooking)
      : super(VenueDetailState(selectedDate: _today()));

  static String _today() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadSlots(String venueId, String date) async {
    emit(state.copyWith(status: ScreenStatus.loading, selectedDate: date));
    final result = await _getSlots(GetVenueSlotsParams(venueId: venueId, date: date));
    result.fold(
      (f) => emit(state.copyWith(status: ScreenStatus.failure, errorMessage: f.message)),
      (data) => emit(state.copyWith(status: ScreenStatus.success, venue: data.venue, slots: data.slots)),
    );
  }

  void selectDate(String venueId, String date) => loadSlots(venueId, date);

  Future<void> bookSlot(String venueId, String slotId) async {
    emit(state.copyWith(isBooking: true, clearBookingError: true, bookingSuccess: false));
    final result = await _createBooking(CreateBookingParams(slotId: slotId));
    result.fold(
      (f) {
        emit(state.copyWith(isBooking: false, bookingError: f.message));
        loadSlots(venueId, state.selectedDate);
      },
      (_) {
        emit(state.copyWith(isBooking: false, bookingSuccess: true));
        loadSlots(venueId, state.selectedDate);
      },
    );
  }

  void clearBookingResult() =>
      emit(state.copyWith(clearBookingError: true, bookingSuccess: false));
}
```

### Screen template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/users_cubit.dart';
import '../../../core/presentation/screen_state.dart';
import '../../../domain/entities/user.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UsersCubit, ScreenState<List<User>>>(
        builder: (context, state) {
          if (state.isLoading || state.isInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isFailure) {
            return _ErrorView(
              message: state.errorMessage ?? 'Error',
              onRetry: () => context.read<UsersCubit>().loadUsers(),
            );
          }
          final users = state.data ?? [];
          if (users.isEmpty) return const _EmptyView();
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (_, i) => _UserTile(user: users[i]),
          );
        },
      ),
    );
  }
}

// Use BlocConsumer only when you need both builder + listener (e.g. snackbars)
// Use BlocListener alone for side effects with no UI rebuild needed
```

---

## Router

### `router/app_routes.dart`

```dart
class AppRoutes {
  static const String home = '/';
  // Add all route paths here as constants
  static String detail(String id) => '/items/$id';
}
```

### `router/app_router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection_container.dart';
import '../presentation/users/cubit/users_cubit.dart';
import '../presentation/users/screens/users_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        // Create a fresh cubit per route — do NOT share cubits across routes
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<UsersCubit>()..loadUsers(),
          child: const UsersScreen(),
        ),
      ),
    ],
  );
}
```

---

## Dependency Injection

### `core/di/injection_container.dart`

Register in this order: services → network → data sources → repositories → use cases → cubits.

```dart
import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../../data/data_sources/remote/user_remote_ds.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../presentation/users/cubit/users_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // --- Network ---
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // --- Data Sources ---
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(getIt()),
  );

  // --- Repositories (bind interface → impl) ---
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt()),
  );

  // --- Use Cases (lazySingleton — stateless, safe to share) ---
  getIt.registerLazySingleton(() => GetUsersUseCase(getIt()));

  // --- Cubits (registerFactory — fresh instance per screen) ---
  getIt.registerFactory(() => UsersCubit(getIt()));
}
```

**Rules:**
- `lazySingleton` for everything except cubits
- `registerFactory` for cubits — each GoRouter `builder` gets a fresh instance
- Never inject a cubit into another cubit

---

## `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection_container.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, __) => MaterialApp.router(
        title: 'App Name',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

---

## `values/network_constants.dart`

```dart
class NetworkConstants {
  // iOS Simulator  → localhost
  // Android Emulator → 10.0.2.2
  // Production    → https://your-api.onrender.com
  static const String baseUrl = 'https://your-api.onrender.com';

  // Endpoints
  static const String users    = '/users';
  static const String venues   = '/venues';

  // Parameterised helpers
  static String userById(String id)    => '/users/$id';
  static String venueById(String id)   => '/venues/$id';
}
```

---

## SOLID Principles — How Each Applies

**S — Single Responsibility**
- `ApiClient` only handles HTTP mechanics
- `RemoteDataSource` only maps HTTP responses to models
- `RepositoryImpl` only converts Failures to `Either`
- `UseCase` contains exactly one business action
- `Cubit` only manages UI state transitions

**O — Open/Closed**
- Add new failure types by extending `Failure`, never editing the switch in `ApiClient`
- Add new features by adding new use cases, not editing existing ones
- `ScreenState<T>` is generic — works for any data type without modification

**L — Liskov Substitution**
- Every `RepositoryImpl` is a drop-in replacement for its abstract interface
- Data sources are defined as abstract classes with concrete impls — swap remote for local without changing the repo

**I — Interface Segregation**
- Repository interfaces are feature-scoped (`UserRepository`, `BookingRepository`), not one god interface
- Data sources are feature-scoped too — no single class owns all network calls
- Use cases are one method each — callers only depend on what they use

**D — Dependency Inversion**
- Cubits depend on use case interfaces (`GetUsersUseCase`), not `UserRepositoryImpl`
- Domain layer has zero knowledge of Flutter, Dio, or GetIt
- `injection_container.dart` is the only place that wires concrete → abstract

---

## fpdart Patterns

### Repository impl pattern
```dart
// Always wrap data source calls like this in repo impls:
Future<Either<Failure, T>> _safeCall<T>(Future<T> Function() call) async {
  try {
    return right(await call());
  } on Failure catch (f) {
    return left(f);            // typed failures from ApiClient
  } catch (e) {
    return left(ServerFailure(e.toString()));
  }
}

// Usage:
Future<Either<Failure, List<User>>> getUsers() =>
    _safeCall(() async {
      final models = await _remote.getUsers();
      return models.toEntities();
    });
```

### Cubit fold pattern
```dart
// Always fold in cubits — never use result.isRight() / result.isLeft()
final result = await _useCase(params);
result.fold(
  (failure) => emit(state.copyWith(
    status: ScreenStatus.failure,
    errorMessage: failure.message,
  )),
  (data) => emit(state.copyWith(
    status: ScreenStatus.success,
    data: data,
  )),
);
```

### TaskEither for chained async operations
```dart
// Use TaskEither when you need to chain multiple Either operations:
import 'package:fpdart/fpdart.dart';

Future<Either<Failure, BookingSummary>> bookAndNotify(String slotId) =>
    TaskEither(() => _bookingRepo.createBooking(slotId))
        .flatMap((booking) => TaskEither(() => _notifyUser(booking)))
        .run();
```

---

## Coding Conventions

### Naming
| Artifact | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `venue_detail_cubit.dart` |
| Classes | `PascalCase` | `VenueDetailCubit` |
| Variables/methods | `camelCase` | `loadVenues()` |
| Constants | `camelCase` | `baseUrl` |
| Private fields | `_camelCase` | `_repository` |

### State management
- Emit `loading` before every async call
- Always emit a terminal state (`success` or `failure`) — never leave a cubit in `loading`
- Use `BlocConsumer` only when you need both a UI rebuild and a side effect (snackbar, navigation)
- Use `BlocBuilder` for pure UI
- Use `BlocListener` for pure side effects

### Error handling
- Data sources throw `Failure` — never raw exceptions
- Repository impls catch and wrap in `Either`
- Cubits fold `Either` — never catch inside a cubit
- Screens display `state.errorMessage` — never format errors in the UI layer

### Comments
- Write no comments unless the WHY is non-obvious
- Never comment what the code already says

### UI
- All sizing via `flutter_screenutil`: `.w`, `.h`, `.sp`, `.r`
- Design size: `Size(375, 812)` (iPhone 14 baseline)
- Never hardcode colours inline — define them in a theme or constants file
- Split large `build()` methods into private widget classes (`_SectionHeader`, `_ItemCard`) — not methods

---

## What QuickSlot Did That This Boilerplate Fixes

| Issue in QuickSlot | Fix in this boilerplate |
|---|---|
| Domain repo interfaces import from `data/models/` | Domain only imports its own `entities/` |
| No entities — models used everywhere | Separate `Entity` classes; models only in data layer |
| No use cases — cubits call repos directly | Every cubit action maps to one use case |
| `catch (e)` loses type info in cubits | Fold on `Either` — failure type is always known |
| `ScreenState<T>` missing `copyWith` | `copyWith` added — cleaner state updates |
| `ApiClient` throws raw exceptions | `ApiClient` throws typed `Failure` subclasses only |
| No abstract `RemoteDataSource` interface | Abstract + impl — swappable for testing/local |

---

## Testing Strategy

```
unit/
├── domain/usecases/   → test use case logic with mocked repo
├── data/repositories/ → test Either wrapping with mocked data source
└── presentation/      → test cubit state transitions with mocked use case

widget/
└── presentation/      → test screen rendering per ScreenState

integration/
└── app_test.dart      → golden path flows end to end
```

Mock with `mocktail`. Never mock the real API — mock the data source or repository boundary.

```dart
// Example cubit test
class MockGetUsersUseCase extends Mock implements GetUsersUseCase {}

void main() {
  late UsersCubit cubit;
  late MockGetUsersUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetUsersUseCase();
    cubit = UsersCubit(mockUseCase);
  });

  test('emits [loading, success] when getUsers succeeds', () async {
    when(() => mockUseCase(const NoParams()))
        .thenAnswer((_) async => right([testUser]));

    await cubit.loadUsers();

    expect(
      cubit.state,
      ScreenState<List<User>>(status: ScreenStatus.success, data: [testUser]),
    );
  });
}
```
