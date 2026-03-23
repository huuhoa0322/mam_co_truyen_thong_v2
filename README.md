# 📖 Handbook of Traditional Tet Feasts & Recipes

## Project Information

| Field        | Details                          |
|--------------|----------------------------------|
| **Student**  | Do Huu Hoa                                 |
| **Class Code**| SE1873 - JS(IT)                                |
| **Course**   | PRM393 - Mobile Programming                  |

---

## 📌 Overview

**Handbook of Traditional Tet Feasts & Recipes** is a mobile application built with Flutter that serves as a digital cookbook dedicated to Vietnamese traditional Tet holiday dishes. The app allows users to explore, manage, and preserve authentic family recipes across generations.

Key highlights:
- Browse and manage a curated collection of traditional Tet dishes
- View detailed recipes with step-by-step cooking instructions and timers
- Manage a personalized shopping list with estimated budgeting
- Record and preserve **family secret tips** (*Bí kíp gia truyền*) for each dish
- AI-powered suggestions for ingredients, cooking steps, and cost estimations via **Google Gemini**

---

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform UI framework (Android & Web) |
| **Dart** | Primary programming language |
| **SQLite (sqflite)** | Local database for persistent storage |
| **sqflite_common_ffi_web** | SQLite support for Flutter Web |
| **Provider** | State management (ViewModel pattern) |
| **GetIt** | Dependency injection |
| **Google Generative AI (Gemini)** | AI-powered recipe & cost suggestions |
| **flutter_dotenv** | Secure API key management via `.env` |
| **image_picker** | Dish image selection |
| **intl** | Internationalization & date formatting |
| **path_provider** | File system path resolution |

---

## 🗂️ Project Structure

```
mam_co_truyen_thong_v2/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── di.dart                    # Dependency injection setup
│   ├── data/                      # Data layer (models, database helper)
│   ├── domain/                    # Domain entities
│   ├── interfaces/                # Abstract repository interfaces
│   ├── implementations/           # Concrete repository implementations
│   │   └── repositories/
│   ├── viewmodels/                # ViewModels (state & business logic)
│   │   ├── home/
│   │   ├── recipe_details/
│   │   ├── shopping_lists/
│   │   └── family_secret/
│   ├── views/                     # UI screens and widgets
│   │   ├── started.dart           # Splash / onboarding screen
│   │   ├── main_screen.dart       # Bottom navigation shell
│   │   ├── home/                  # Screen 2 – Homepage
│   │   ├── recipe_details/        # Screen 3 – Recipe Detail
│   │   ├── shopping_lists/        # Screen 4 – Shopping List
│   │   └── family_secret/         # Screen 5 – Family Secrets
│   ├── services/
│   │   └── ai_service.dart        # Google Gemini AI integration
│   └── sql/                       # SQL migration scripts
├── assets/
│   ├── images/                    # Dish images
│   └── sql/                       # Bundled SQL assets
├── .env                           # Environment variables (API keys)
├── pubspec.yaml                   # Dependencies & assets config
└── README.md
```

---

## 📱 App Screens

| Screen | Description |
|---|---|
| **1. Started** | Splash / welcome screen |
| **2. Homepage** | Browse featured dishes, collections, and latest additions |
| **3. Recipe Detail** | Full recipe view with ingredients, steps, timers, and family secrets |
| **4. Shopping List** | Auto-generated ingredient list with budget tracking |
| **5. Family Secrets** | Personal cooking tips and secret techniques per dish |

---

## ⚙️ Installation Guide

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.x`
- Dart SDK `^3.11.1`
- Android Studio / VS Code with Flutter & Dart plugins
- A valid **Google Gemini API Key**

### Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mam_co_truyen_thong_v2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**

   Create a `.env` file in the project root:
   ```env
   GEMINI_API_KEY=your_google_gemini_api_key_here
   ```

4. **Run the application**

   - Android:
     ```bash
     flutter run
     ```
   - Web:
     ```bash
     flutter run -d chrome
     ```

---

## 🔑 Environment Variables

| Variable | Description |
|---|---|
| `GEMINI_API_KEY` | Google Gemini API key for AI suggestions |

> **Note:** The `.env` file is bundled as a Flutter asset. Ensure it is listed under `assets` in `pubspec.yaml` and is included in `.gitignore` to keep your API key secure.

---

## 🤖 AI Features

The app integrates **Google Gemini** to assist users with:

- **Recipe Suggestions** – Auto-suggest ingredients and cooking steps for a selected dish
- **Family Secret Tips** – Generate culturally-relevant cooking secret tips
- **Shopping Cost Estimation** – Estimate market prices for ingredients in the shopping list
