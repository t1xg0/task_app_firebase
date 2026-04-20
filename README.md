# Task App Firebase

A Flutter task management app with **offline-first** architecture. Tasks are stored locally with SQLite (via Drift) and synced to Firebase Firestore when online.

---

## Architecture

```
lib/
├── main.dart                    # App entry point, dependency wiring
├── models/
│   └── task_model.dart          # Plain Dart model shared across layers
├── data/
│   └── app_database.dart        # Drift database — tables, queries, streams
├── services/
│   ├── task_repository.dart     # Orchestrates local DB + remote sync
│   └── task_remote_service.dart # Firestore read/write
├── pages/
│   └── tasks_page.dart          # Main UI screen
└── widgets/
    ├── task_tile.dart            # Single task row widget
    └── task_form_dialog.dart     # Add task dialog
```

### Data flow

```
TasksPage
  └── TaskRepository
        ├── AppDatabase (Drift / SQLite)   ← source of truth for the UI
        └── TaskRemoteService (Firestore)  ← remote backup / sync
```

The UI always reads from the **local Drift database** via a reactive stream (`watchTasks()`). Firebase is used only for syncing — writes go local first, then push to Firestore. Reads from Firestore pull remote tasks into the local DB.

---

## Database schema

**Table: `tasks`**

| Column         | Type     | Notes                              |
|----------------|----------|------------------------------------|
| `id`           | INTEGER  | Primary key, auto-increment        |
| `title`        | TEXT     | Required                           |
| `description`  | TEXT     | Required                           |
| `completed`    | BOOLEAN  | Default `false`                    |
| `updated_at`   | DATETIME | Required                           |
| `pending_sync` | BOOLEAN  | `true` until synced to Firestore   |

---

## Key dependencies

| Package           | Purpose                                     |
|-------------------|---------------------------------------------|
| `drift`           | Type-safe SQLite ORM with reactive streams  |
| `drift_flutter`   | Platform-aware Drift setup for Flutter      |
| `firebase_core`   | Firebase initialization                     |
| `cloud_firestore` | Firebase Firestore remote storage           |
| `path_provider`   | Resolve app directories on native platforms |

---

## Prerequisites

### Firebase

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add your target platform (Android / iOS / Web) via **Project Settings → Add app**
3. Run FlutterFire CLI to regenerate `lib/firebase_options.dart`:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
4. In Firestore, create a collection named **`tasks`**. For development, open rules can be used:
   ```
   rules_version = '2';
   service cloud.firestore.rules {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```
   Deploy the included `firestore.rules` file via CLI:
   ```bash
   npm install -g firebase-tools   # only needed once
   firebase login
   firebase deploy --only firestore:rules --project t1xg0-flutter
   ```

### Web-specific assets

Running on Chrome requires two binary files in `web/`:

| File                       | Purpose                          |
|----------------------------|----------------------------------|
| `web/sqlite3.wasm`         | SQLite compiled to WebAssembly   |
| `web/drift_worker.dart.js` | Compiled Drift web worker        |

Generate them from the project root:

```bash
# 1. Copy sqlite3.wasm from the drift pub cache (adjust version if needed)
cp ~/.pub-cache/hosted/pub.dev/drift-2.32.1/extension/devtools/build/sqlite3.wasm web/sqlite3.wasm

# 2. Create the worker entry point (only needed once)
cat > web/drift_worker.dart << 'EOF'
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
EOF

# 3. Compile the worker to JavaScript
dart compile js web/drift_worker.dart -o web/drift_worker.dart.js -O2
```

> If you upgrade the `drift` package, repeat step 1 with the new version path and re-run step 3.

---

## Running the app

```bash
# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Run on a connected Android or iOS device
flutter run

# Run on macOS desktop (requires Xcode)
flutter run -d macos
```

---

## Code generation (Drift)

Drift generates `lib/data/app_database.g.dart` from the table definitions in `app_database.dart`. Re-run whenever you change the schema:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Sync behavior

| Action           | Local DB           | Firestore                                        |
|------------------|--------------------|--------------------------------------------------|
| Add task         | Insert immediately | Pushed immediately (failure silently ignored)    |
| Toggle completed | Update immediately | Pushed immediately (failure silently ignored)    |
| App start        | Stream from local  | Remote tasks pulled and upserted into local DB   |
| Pull-to-refresh  | Updated from remote| Fetched and upserted locally                     |

Tasks with `pendingSync = true` display a **"Sync pendiente"** chip in the UI. Once successfully pushed to Firestore, they are marked as synced (`pending_sync = false`).

> **Note:** Firestore document IDs are the local integer `id` cast to string (e.g. `"1"`, `"2"`). Documents created manually in the Firestore console with non-integer IDs will be silently skipped during sync.
