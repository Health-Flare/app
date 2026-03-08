# Add Screen

You are adding a new screen to Health Flare.

## Input

The user will describe:
- The purpose of the screen
- What UI elements it should have
- How to navigate to it

## Process

### 1. Check Feature File

Read the relevant feature file in `docs/features/` to understand:
- What the screen should display
- User interactions required
- Expected behaviors

### 2. Read Similar Screens

Find a similar existing screen in `lib/features/` and match its patterns:
- Widget structure
- Provider usage
- Navigation handling

### 3. Create the Screen

Create `lib/features/<feature>/screens/<name>_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NameScreen extends ConsumerWidget {
  const NameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Title'),
      ),
      body: // Screen content
    );
  }
}
```

For screens with local state, use `ConsumerStatefulWidget`:

```dart
class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  // Local state here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
    );
  }
}
```

### 4. Add Route

Update `lib/core/router/app_router.dart`:

```dart
// Add route constant
static const nameScreen = '/name';

// Add GoRoute
GoRoute(
  path: nameScreen,
  builder: (context, state) => const NameScreen(),
),
```

### 5. Add Navigation

From calling code:

```dart
context.push(AppRouter.nameScreen);
// or
context.go(AppRouter.nameScreen);
```

### 6. Extract Widgets

If the screen is complex, extract widgets to:
`lib/features/<feature>/widgets/<widget_name>.dart`

## Output

Provide:
1. Screen file created
2. Route added
3. Navigation example
4. Any widgets extracted

## User Input

$ARGUMENTS
