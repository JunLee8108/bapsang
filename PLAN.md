# Recommendation Landing Page — Implementation Plan

## Current State
- Login (Apple/Google) ✅ Done
- RootView → routes to MainTabView when authenticated ✅ Done
- MainTabView "Recommend" tab → PlaceholderView (temporary) ⏳ Needs replacement

## Goal
Build the **RecommendationView** — the first screen users see after login.
Entry point for selecting ingredients and getting AI-powered Korean recipe recommendations.

---

## Implementation Steps

### Step 1: RecipeCategory Model
**File**: `Bapsang/Models/RecipeCategory.swift`

- `RecipeCategory` struct (id, name, icon, description)
- Default Korean food categories: Soup/Stew, Stir-fry, Rice, Noodles, Side Dishes, One-Plate

### Step 2: RecommendationViewModel
**File**: `Bapsang/Features/Recommendation/RecommendationViewModel.swift`

- `@Observable` class
- Time-based greeting (Good morning / Good afternoon / Good evening)
- Category data
- Prepared for future Supabase integration (recent recipes, etc.)

### Step 3: CategoryCard Component
**File**: `Bapsang/Components/CategoryCard.swift`

- Reusable card UI: icon + name + short description
- Orange gradient + `.ultraThinMaterial` style (matches existing design)
- Tap action ready for Phase 2 navigation

### Step 4: EmptyStateView Component
**File**: `Bapsang/Components/EmptyStateView.swift`

- Shown when no recent recipes exist
- Icon + message + optional action button

### Step 5: RecommendationView
**File**: `Bapsang/Features/Recommendation/RecommendationView.swift`

- Greeting section (time-based)
- **"Select Ingredients" CTA button at the top**
- **"Today's Recommended Categories" grid below**
- Recent recipes section (empty state for now)
- Stagger animation on card appearance

### Step 6: MainTabView Update
**File**: `Bapsang/Core/MainTabView.swift`

- Replace first tab's PlaceholderView → RecommendationView
- Keep NavigationStack

---

## File Summary

| Action | File | Type |
|--------|------|------|
| Create | `Models/RecipeCategory.swift` | New |
| Create | `Features/Recommendation/RecommendationViewModel.swift` | New |
| Create | `Components/CategoryCard.swift` | New |
| Create | `Components/EmptyStateView.swift` | New |
| Create | `Features/Recommendation/RecommendationView.swift` | New |
| Modify | `Core/MainTabView.swift` | Replace PlaceholderView |

---

## UI Wireframe

```
┌──────────────────────────────────┐
│  NavBar: "What Should I Eat?"    │
├──────────────────────────────────┤
│                                  │
│  Good evening!                   │
│  What shall we cook today?       │
│                                  │
├──────────────────────────────────┤
│  ┌──────────────────────────┐    │
│  │  🥕  Select Ingredients  │    │
│  │      (CTA Button)        │    │
│  └──────────────────────────┘    │
│                                  │
├──────────────────────────────────┤
│  Today's Recommended Categories  │
│                                  │
│  ┌──────────┐ ┌──────────┐      │
│  │ 🍲       │ │ 🥘       │      │
│  │Soup/Stew │ │ Stir-fry │      │
│  └──────────┘ └──────────┘      │
│  ┌──────────┐ ┌──────────┐      │
│  │ 🍚       │ │ 🍜       │      │
│  │   Rice   │ │ Noodles  │      │
│  └──────────┘ └──────────┘      │
│  ┌──────────┐ ┌──────────┐      │
│  │ 🥗       │ │ 🍳       │      │
│  │  Sides   │ │One-Plate │      │
│  └──────────┘ └──────────┘      │
│                                  │
├──────────────────────────────────┤
│  Recent Recipes                  │
│  ┌──────────────────────────┐    │
│  │  📭 No recipes yet       │    │
│  │     Start exploring!      │    │
│  └──────────────────────────┘    │
│                                  │
├──────────────────────────────────┤
│ [🍽 Recommend] [📖 Saved] [⚙ Settings] │
└──────────────────────────────────┘
```

## Design Principles
- Match existing orange gradient + `.ultraThinMaterial` style from LoginView
- `@Observable` pattern (iOS 17+)
- **English UI text**
- Stagger animation on card appearance
