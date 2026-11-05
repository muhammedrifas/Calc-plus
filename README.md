# OmniCalc

An ad-free, completely offline, all-in-one utility calculator built with Flutter. OmniCalc delivers a clutter-free, responsive experience with modular tools spanning everyday arithmetic, finance, health, and custom utility calculations.

## ✨ Features

- **100% Ad-Free & Offline:** Zero distractions, zero tracking, and no internet connection required.
- **Modular Plugin Architecture:** Built around an isolated plugin engine that allows rapid integration and testing of independent calculator modules.
- **Customizable Dashboard & Pinned Favorites:** Pin frequently used calculators to an instant-access gradient grid directly on the home screen.
- **Universal Search:** Fast, real-time filtering across all categories and modules.
- **Industry-Standard Basic Math Engine:**
  - Real-time expression evaluation with PEMDAS/BODMAS compliance.
  - Consumer-standard business percentage logic (`A + B%`).
  - Intelligent context-aware single-button parenthesis balancing `( )`.
  - Sign toggling (`+/-`), persistent equation history sheet, and backspace controls.
  - Fully responsive, overflow-safe keypad built for edge-to-edge device navigation.

## 🛠 Tech Stack

- **Framework:** Flutter (Android)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Persistence:** `shared_preferences`
- **Parsing Engine:** `math_expressions`
- **Charts & Visualizations:** `fl_chart`