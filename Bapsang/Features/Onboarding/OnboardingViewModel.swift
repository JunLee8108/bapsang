//
//  OnboardingViewModel.swift
//  Bapsang
//

import Foundation
import Supabase

@Observable
@MainActor
final class OnboardingViewModel {

    // MARK: - Input State

    var displayName: String = ""
    var selectedSpiceLevel: SpiceLevel = .medium
    var selectedRestrictions: Set<DietaryRestriction> = []

    // MARK: - UI State

    var isLoading = false
    var errorMessage: String?

    // MARK: - Save

    func save(userId: UUID) async -> Bool {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? "Chef" : trimmedName

        isLoading = true
        defer { isLoading = false }

        do {
            let payload = OnboardingPayload(
                displayName: finalName,
                preferredSpiceLevel: selectedSpiceLevel.rawValue,
                dietaryRestrictions: selectedRestrictions.map(\.rawValue).sorted(),
                hasCompletedOnboarding: true
            )

            try await supabase
                .from("users")
                .update(payload)
                .eq("id", value: userId)
                .execute()

            return true
        } catch {
            errorMessage = "Failed to save profile. Please try again."
            return false
        }
    }

    func skip(userId: UUID) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            try await supabase
                .from("users")
                .update(["has_completed_onboarding": true])
                .eq("id", value: userId)
                .execute()

            return true
        } catch {
            errorMessage = "Something went wrong. Please try again."
            return false
        }
    }
}

// MARK: - Spice Level

enum SpiceLevel: String, CaseIterable, Identifiable {
    case mild
    case medium
    case spicy
    case extraSpicy = "extra_spicy"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .mild:       return "Mild"
        case .medium:     return "Medium"
        case .spicy:      return "Spicy"
        case .extraSpicy: return "Extra Spicy"
        }
    }

    var icon: String {
        switch self {
        case .mild:       return "🫑"
        case .medium:     return "🌶️"
        case .spicy:      return "🔥"
        case .extraSpicy: return "🥵"
        }
    }
}

// MARK: - Dietary Restriction

enum DietaryRestriction: String, CaseIterable, Identifiable {
    case vegetarian
    case vegan
    case glutenFree = "gluten_free"
    case dairyFree = "dairy_free"
    case nutFree = "nut_free"
    case seafoodFree = "seafood_free"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .vegetarian:  return "Vegetarian"
        case .vegan:       return "Vegan"
        case .glutenFree:  return "Gluten-free"
        case .dairyFree:   return "Dairy-free"
        case .nutFree:     return "Nut-free"
        case .seafoodFree: return "Seafood-free"
        }
    }

    var icon: String {
        switch self {
        case .vegetarian:  return "🥬"
        case .vegan:       return "🌱"
        case .glutenFree:  return "🌾"
        case .dairyFree:   return "🥛"
        case .nutFree:     return "🥜"
        case .seafoodFree: return "🐟"
        }
    }
}

// MARK: - Payload

private struct OnboardingPayload: Encodable {
    let displayName: String
    let preferredSpiceLevel: String
    let dietaryRestrictions: [String]
    let hasCompletedOnboarding: Bool

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case preferredSpiceLevel = "preferred_spice_level"
        case dietaryRestrictions = "dietary_restrictions"
        case hasCompletedOnboarding = "has_completed_onboarding"
    }
}
