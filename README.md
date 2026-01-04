
# Project Structure Folder
Ini struktur projectnya, Kita pakai MVVM. Secara umum strukturnya bisa berubah setiap ada pertambahan fitur, jadi disesuaikan aja sama penempatannya. 

```
Talangin
├── App
│   ├── TalanginApp.swift        # Entry point aplikasi (App lifecycle)
│   └── ContentView.swift        # Root view / initial routing
│
├── DesignSystem                 # Centralized UI design system
│   ├── Color
│   │   └── Color.swift          # Color palette & semantic colors
│   │
│   ├── Typography
│   │   └── Font.swift           # Font styles & text tokens
│   │
│   ├── Spacing
│   │   └── Spacing.swift        # Layout spacing constants
│   │
│   └── SharedComponents
│       └── Button.swift         # Reusable UI components
│
├── Domain                       # Core business logic (UI-independent)
│   ├── Model
│   │   ├── User.swift           # User domain model
│   │   └── Item.swift           # Expense item model
│   │
│   └── Logic
│       └── BalanceExpenses.swift # Expense balancing algorithm
│
├── Presentation                 # UI layer (MVVM)
│   └── Features
│       ├── Auth
│       │   ├── Component
│       │   │   └── AuthTextField.swift
│       │   ├── View
│       │   │   ├── SignInView.swift
│       │   │   └── SignUpView.swift
│       │   └── ViewModel
│       │       └── AuthViewModel.swift
│       │
│       ├── AddFriends
│       │   ├── Component        # Feature-specific UI components
│       │   ├── View             # Feature views
│       │   └── ViewModel        # Feature view models
│       │
│       ├── Home                 # Home screen feature
│       ├── Group                # Group & activity management
│       └── Profile              # User profile feature
│
├── Services                     # External services & integrations
│   ├── CloudKit                 # CloudKit sync & collaboration
│   ├── OCR                      # OCR service (receipt scanning)
│   └── Persistence              # Local storage (CoreData / SwiftData)
│
├── Utils                        # Utility layer
│   ├── Extensions               # Swift extensions (non-business logic)
│   └── Helpers                  # Helper / utility functions
│
├── Resources
│   └── Assets.xcassets          # App assets (icons, images, colors)
│
├── Info.plist                   # App configuration & capabilities
└── Talangin.xcodeproj           # Xcode project file
```
Kalau ada pertanyaan tanya aja di grup.
