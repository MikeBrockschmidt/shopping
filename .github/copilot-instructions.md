# Shopping App - AI Agent Instructions

## Architecture Overview

This is a **Flutter + Firebase multi-group collaboration app** with shared lists and health tracking.

**Layered structure** (with clear separation):
- **Data Layer** (`lib/src/data/`): `AuthRepository` + `DatabaseRepository` handle all Firebase I/O
- **Features** (`lib/src/features/`): Modular features (auth, group, todo, shopping_list, memory) with `domain/` models + `presentation/` screens
- **State Management**: `Provider` for app-level singletons (auth, db, theme) + `ChangeNotifierProvider` for feature-level state
- **Theme**: Centralized `AppTheme` + `ThemeProvider` for light/dark mode toggling

**Critical flows**:
1. **Auth**: `LoginScreen` → email verification → `GroupSelectionScreen` (StreamBuilder watches `authRepository.authStateChanges()`)
2. **Group Navigation**: `GroupSelectionScreen` uses `StreamBuilder<List<Group>>` to load user's groups, navigates to `GroupDetailScreen` with nested MultiProvider for feature providers
3. **Feature Screens**: Uses `MultiProvider` to inject feature-specific `ChangeNotifierProvider`s (e.g., `ShoppingListProvider`, `MemoryProvider`)

## Key Files & Patterns

### Repository Pattern
- [lib/src/data/auth_repository.dart](lib/src/data/auth_repository.dart): Wraps FirebaseAuth with custom `AuthException` for localized German error messages
- [lib/src/data/database_repository.dart](lib/src/data/database_repository.dart): All Firestore operations (CRUD for todos, groups, shopping items, memory, diet history)

### Provider Setup
- Root-level (main.dart): `AuthRepository`, `DatabaseRepository`, `ThemeProvider` 
- Feature-level (group_detail_screen.dart): `ShoppingListProvider`, `MemoryProvider` created in `MultiProvider`
- **Pattern**: Use `context.read<>()` for one-time access, `context.watch<>()` for reactive rebuilds

### State Management Conventions
- `ChangeNotifierProvider` screens use `_XyzProviderListener()` callbacks in `initState` to handle side effects (snackbars, navigation)
- Remove listeners in `dispose()` to prevent memory leaks
- Example: [lib/src/features/shopping_list/presentation/shopping_list_screen.dart#L27-L50](lib/src/features/shopping_list/presentation/shopping_list_screen.dart#L27-L50)

### Feature Patterns
- **Shopping List**: Items stored per group in Firestore, provider handles add/remove/complete, images stored in Firebase Storage
- **Memory (Diet Tracking)**: 7-day rolling view with medication + diet status (traffic light: green/yellow/red) + triggers + notes; `DietHistoryProvider` manages multi-day form state
- **Todo**: Ordered by dueDate, completion toggles delete from Firestore
- **Groups**: Collaborative spaces with members; each feature (todo, shopping, memory) scoped to groupId

## Developer Workflows

### Running the App
```bash
flutter pub get
flutter run  # iOS simulator or device
```

### Testing Firestore Locally
- Current `firestore.rules` are **permissive for dev** (allow all authenticated operations)
- Replace before production with proper document ownership checks

### Adding New Features
1. Create `lib/src/features/feature_name/{domain,presentation}/`
2. Extend `DatabaseRepository` with feature CRUD methods
3. Create `FeatureProvider extends ChangeNotifier` for state in `presentation/`
4. Wire in `GroupDetailScreen` MultiProvider if group-scoped, or root `main()` if global

### Localization
- App uses **German** UI text throughout (hardcoded in screens)
- Errors use custom exceptions with German messages (e.g., `AuthException`)

## Important Conventions

- **No singleton pattern**: Providers are injected via MultiProvider, never instantiated directly
- **Firestore structure**: Collections nested (e.g., `/groups/{groupId}/todos`, `/groups/{groupId}/shopping_items`) with UUID for IDs
- **Images**: Shopping items can have Firebase Storage references OR Material icons (from `shopping_icons.dart`)
- **Date handling**: Uses `DateTime` + string formatting (YYYY-MM-DD) for diet history queries
- **TextEditingController**: Dispose all controllers in widget's `dispose()` method

## Integration Points

- **Firebase**: Auth (email/password + verification), Firestore (docs), Storage (images)
- **External packages**: `provider`, `firebase_*`, `image_picker`, `fl_chart`, `google_fonts`
- **Material 3**: Uses `ThemeData.from(colorScheme:)` for automatic dark/light mode

## Common Pitfalls

1. **Provider access without context**: Always use `context.read()` or `context.watch()`
2. **Forgetting MultiProvider scoping**: Feature providers must be created at feature entry point, not globally
3. **Unmanaged listeners**: Add `dispose()` cleanup for all listeners and TextEditingControllers
4. **Hardcoded groupId strings**: Always pass as constructor parameter; never assume from route

