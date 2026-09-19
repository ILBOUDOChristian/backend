# Projet Flutter - App Connectee avec Backend Reel

Application Flutter complete connectee a une API REST reelle (DummyJSON), concue selon une architecture Clean Feature-First avec gestion complete de l authentification JWT, gestion du refresh token, mise en cache locale Hive, mode hors-ligne reactif et tests unitaires sur la couche repository.

---

## Barēme et Conformite

| Exigence du sujet | Statut | Implementation detaillee |
|---|---|---|
| Authentification (login / register / logout) - JWT | Conforme | DummyJSON (`/auth/login`, `/users/add`), token stocke dans `FlutterSecureStorage` |
| Au moins 3 ecrans de donnees issues d une API REST | Conforme | 1. Flux des Articles (`/posts`), 2. Detail d un Article (`/posts/{id}`), 3. Profil Authentifie (`/auth/me`), 4. Taches Todos (`/todos`) |
| Mise en cache locale des donnees | Conforme | Stockage local persistant avec Hive (`posts_cache_box`, `todos_cache_box`, `user_cache_box`) |
| Mode hors-ligne avec fallback cache | Conforme | Affichage des donnees en cache si absence de reseau ou erreur Dio avec indicateur visuel |
| Gestion d erreurs reseau avec messages utilisateur | Conforme | `ApiException` types (NetworkException, UnauthorizedException, ServerException) et retry UI |
| Architecture Clean / Feature-First | Conforme | Structure `features/{auth, posts, todos}/{data, domain, presentation}` |
| Repository pattern | Conforme | Interfaces abstraites dans le `domain` et implementations dans `data` |
| Client Dio pour les appels reseau | Conforme | `ApiClient` configure avec timeouts et headers standards |
| Intercepteur pour injection de token d auth | Conforme | `QueuedInterceptorsWrapper` injectant `Authorization: Bearer <token>` |
| Gestion du Refresh Token | Conforme | Detection automatique des erreurs HTTP 401, appel `/auth/refresh` et rejeu de requete |
| Au moins 3 tests unitaires sur le Repository | Conforme | Tests valides couvrant le cache local, le fallback hors-ligne et la persistance des tokens |

---

## Architecture du Projet

```text
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart          # Configuration Dio + Intercepteur JWT + Refresh Token
│   │   └── api_exceptions.dart      # Exceptions typēes (Network, Unauthorized, Server)
│   ├── storage/
│   │   └── local_storage.dart       # Service de persistance Hive & SecureStorage
│   └── di.dart                      # Injection de dependances (Riverpod Providers)
├── features/
│   ├── auth/
│   │   ├── data/                    # AuthRepositoryImpl, UserModel
│   │   ├── domain/                  # AuthRepository (interface), UserEntity
│   │   └── presentation/            # AuthController, LoginScreen, RegisterScreen
│   ├── posts/
│   │   ├── data/                    # PostRepositoryImpl (fallback cache Hive), PostModel
│   │   ├── domain/                  # PostRepository (interface), PostEntity
│   │   └── presentation/            # PostsController, PostListScreen, PostDetailScreen, UserProfileScreen
│   └── todos/
│       ├── data/                    # TodoRepositoryImpl (cache offline), TodoModel
│       ├── domain/                  # TodoRepository (interface), TodoEntity
│       └── presentation/            # TodosController, TodosView
└── main.dart                        # Initialisation Hive, ProviderScope et Navigation
```

---

## Fonctionnalites Cles

### 1. Authentification & Refresh Token
- Connexion via `/auth/login` retournant `accessToken` et `refreshToken`.
- Stockage securise des tokens.
- Injection transparente du token dans le header `Authorization`.
- Renouvellement automatique du token en arriere-plan sur code HTTP 401 via `QueuedInterceptorsWrapper`.

### 2. Mode Hors-Ligne & Cache Local (Hive)
- Les donnees recuperees depuis le reseau sont automatiquement serialisees et sauvegardees dans Hive.
- En cas de coupure reseau ou d erreur serveur, l application charge immediatement le cache local sans bloquer l utilisateur.
- Un bandeau informatif signale que les donnees affichees proviennent du cache hors-ligne.

### 3. Gestion Resiliente des Erreurs
- Typage metier des exceptions reseau.
- Interface utilisateur equipee de boutons pour reessayer les requetes.

---

## Execution des Tests

Les tests unitaires couvrent la persistance du stockage, le fallback offline et le repository :

```bash
flutter test test/widget_test.dart
```

Tous les tests passent avec succes.
