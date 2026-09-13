# Connected App REST — Flutter

Application Flutter complète connectée à une API REST réelle (DummyJSON), démontrant une architecture Clean Feature-First avec gestion de l'authentification JWT, mise en cache locale Hive, mode hors-ligne et tests unitaires.

---

## Architecture

Architecture **Feature-First** (Clean Architecture) :

```
lib/
+-- core/
¦   +-- api/
¦   ¦   +-- api_client.dart          # Client Dio + intercepteur JWT
¦   ¦   +-- api_exceptions.dart      # Exceptions typées (Network, Unauthorized, Server)
¦   +-- storage/
¦   ¦   +-- local_storage.dart       # Service Hive + FlutterSecureStorage
¦   +-- di.dart                      # Providers Riverpod (injection de dépendances)
¦
+-- features/
¦   +-- auth/
¦   ¦   +-- data/
¦   ¦   ¦   +-- auth_repository_impl.dart   # Implémentation repository auth
¦   ¦   ¦   +-- user_model.dart             # Modèle de données utilisateur
¦   ¦   +-- domain/
¦   ¦   ¦   +-- auth_repository.dart        # Interface repository (abstraction)
¦   ¦   ¦   +-- user_entity.dart            # Entité domaine utilisateur
¦   ¦   +-- presentation/
¦   ¦       +-- auth_controller.dart        # StateNotifier + AuthState
¦   ¦       +-- login_screen.dart           # Écran de connexion
¦   ¦       +-- register_screen.dart        # Écran d'inscription
¦   ¦
¦   +-- posts/
¦   ¦   +-- data/
¦   ¦   ¦   +-- post_repository_impl.dart   # Implémentation + fallback cache
¦   ¦   ¦   +-- post_model.dart             # Modèle de données article
¦   ¦   +-- domain/
¦   ¦   ¦   +-- post_repository.dart        # Interface repository
¦   ¦   ¦   +-- post_entity.dart            # Entité domaine article
¦   ¦   +-- presentation/
¦   ¦       +-- posts_controller.dart       # StateNotifier + FutureProvider
¦   ¦       +-- post_list_screen.dart       # Liste articles + recherche + offline
¦   ¦       +-- post_detail_screen.dart     # Détail article avec AsyncValue
¦   ¦       +-- user_profile_screen.dart    # Profil utilisateur connecté
¦   ¦
¦   +-- todos/
¦       +-- data/
¦       ¦   +-- todo_repository_impl.dart   # Implémentation + cache offline
¦       ¦   +-- todo_model.dart             # Modèle de données todo
¦       +-- domain/
¦       ¦   +-- todo_repository.dart        # Interface repository
¦       ¦   +-- todo_entity.dart            # Entité domaine todo
¦       +-- presentation/
¦           +-- todos_controller.dart       # StateNotifier avec optimistic update
¦           +-- todos_screen.dart           # Liste todos + stats + toggle
¦
+-- main.dart                          # ProviderScope + navigation principale
```

---

## Fonctionnalités

### Authentification (JWT)
- Login / Register / Logout avec l'API DummyJSON
- Token JWT stocké de façon sécurisée via `flutter_secure_storage`
- Injection automatique du token dans chaque requête via **intercepteur Dio**
- Persistance de session : reconnexion automatique si token valide

### 3 Écrans de données API REST
1. **Articles (Posts)** — liste + recherche full-text + détail complet
2. **Tâches (Todos)** — liste avec statistiques + toggle optimiste
3. **Profil utilisateur** — données réelles issues de `/auth/me`

### Mise en cache locale (Hive)
- Posts mis en cache dans une `Box<String>` Hive
- Todos mis en cache dans une `Box<String>` Hive
- Profil utilisateur mis en cache localement

### Mode hors-ligne
- Détection automatique des erreurs réseau (Dio)
- Fallback transparent sur les données Hive si pas de connexion
- Bannière visuelle informant l'utilisateur du mode hors-ligne

### Gestion d'erreurs
- Exceptions typées : `NetworkException`, `UnauthorizedException`, `ServerException`
- États `loading`, `error`, `data` dans chaque écran
- Bouton "Réessayer" sur chaque écran d'erreur
- SnackBars informatifs sur les actions

---

## Providers Riverpod

| Provider | Type | Rôle |
|---|---|---|
| `localStorageProvider` | `Provider<LocalStorageService>` | Service Hive + SecureStorage (injecté via override) |
| `apiClientProvider` | `Provider<ApiClient>` | Client Dio avec intercepteur JWT |
| `authRepositoryProvider` | `Provider<AuthRepository>` | Repository d'authentification |
| `postRepositoryProvider` | `Provider<PostRepository>` | Repository des articles |
| `todoRepositoryProvider` | `Provider<TodoRepository>` | Repository des tâches |
| `authNotifierProvider` | `StateNotifierProvider<AuthNotifier, AuthState>` | État d'authentification global |
| `postsNotifierProvider` | `StateNotifierProvider<PostsNotifier, PostsState>` | État liste + recherche des posts |
| `postDetailFutureProvider` | `FutureProvider.family<PostEntity, int>` | Chargement asynchrone du détail |
| `todosNotifierProvider` | `StateNotifierProvider<TodosNotifier, TodosState>` | État liste todos + optimistic update |

---

## Technologies utilisées

| Technologie | Version | Usage |
|---|---|---|
| Flutter | SDK stable | Framework UI |
| `flutter_riverpod` | ^3.3.x | State management |
| `dio` | ^5.11.x | HTTP client + intercepteurs |
| `hive_flutter` | ^1.1.x | Cache local des données |
| `flutter_secure_storage` | ^11.x | Stockage sécurisé du JWT |

---

## API utilisée

**DummyJSON** — `https://dummyjson.com`

- `POST /auth/login` — Authentification JWT
- `GET /auth/me` — Profil utilisateur courant
- `POST /users/add` — Inscription
- `GET /posts?limit=30` — Liste des articles
- `GET /posts/search?q={query}` — Recherche d'articles
- `GET /posts/{id}` — Détail d'un article
- `GET /todos?limit=30` — Liste des tâches
- `PUT /todos/{id}` — Mise à jour d'une tâche

Compte test : **username** `emilys` / **password** `emilyspass`

---

## Tests unitaires

```bash
flutter test test/repositories/
```

13 tests répartis sur 3 fichiers :
- `post_model_test.dart` — sérialisation/désérialisation PostModel
- `user_model_test.dart` — sérialisation/désérialisation UserModel + fullName
- `todo_model_test.dart` — sérialisation/désérialisation TodoModel + roundtrip

---

## Installation et lancement

```bash
git clone https://github.com/ILBOUDOChristian/App-connectee-backend-reel.git
cd connected_app
flutter pub get
flutter run
```
