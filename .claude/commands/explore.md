# Explore Codebase

You are exploring the Health Flare codebase to answer questions or gather context.

## Input

The user will ask:
- How something works
- Where something is implemented
- What patterns are used
- How to accomplish a task

## Process

### 1. Search for Relevant Code

Use these strategies:
- **File patterns:** Search `lib/**/*.dart` for relevant files
- **Text search:** Search for keywords, function names, class names
- **Feature files:** Check `docs/features/*.feature` for behavior specs

### 2. Read and Understand

For each relevant file:
1. Read the full file (or key sections)
2. Understand its purpose
3. Note connections to other files

### 3. Trace the Flow

For understanding a feature:
1. Start with the screen (entry point)
2. Find the providers it uses
3. Find the data models involved
4. Check the routes

### 4. Summarize

Provide a clear explanation with:
- Relevant file paths and line numbers
- How the pieces connect
- Example code if helpful

## Key Locations

| Looking for... | Check... |
|----------------|----------|
| Screens | `lib/features/<feature>/screens/` |
| Widgets | `lib/features/<feature>/widgets/` |
| State/Logic | `lib/core/providers/` |
| Database | `lib/data/database/` |
| Models | `lib/models/` (domain), `lib/data/models/` (Isar) |
| Routes | `lib/core/router/app_router.dart` |
| Theme | `lib/core/theme/` |
| Behavior specs | `docs/features/*.feature` |
| Tests | `test/` |

## Output

Provide:
1. Direct answer to the question
2. Relevant file paths with line numbers
3. Code snippets if helpful
4. Connections to other parts of the codebase

## User Input

$ARGUMENTS
