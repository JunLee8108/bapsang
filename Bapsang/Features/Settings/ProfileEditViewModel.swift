//
//  ProfileEditViewModel.swift
//  Bapsang
//

import Foundation
import Supabase

@Observable
@MainActor
final class ProfileEditViewModel {

    // MARK: - Input State

    var displayName: String = ""
    var selectedSpiceLevel: SpiceLevel = .medium
    var selectedRestrictions: Set<DietaryRestriction> = []

    // MARK: - UI State

    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    var didSave = false

    // MARK: - Load

    func load(userId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let profile: ProfileEditDTO = try await supabase
                .from("users")
                .select("display_name, preferred_spice_level, dietary_restrictions")
                .eq("id", value: userId)
                .single()
                .execute()
                .value

            displayName = profile.displayName
            selectedSpiceLevel = SpiceLevel(rawValue: profile.preferredSpiceLevel) ?? .medium
            selectedRestrictions = Set(
                profile.dietaryRestrictions.compactMap { DietaryRestriction(rawValue: $0) }
            )
        } catch {
            errorMessage = "Failed to load profile."
        }
    }

    // MARK: - Save

    func save(userId: UUID) async {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? "Chef" : trimmedName

        isSaving = true
        defer { isSaving = false }

        do {
            let payload = ProfilePayload(
                displayName: finalName,
                preferredSpiceLevel: selectedSpiceLevel.rawValue,
                dietaryRestrictions: selectedRestrictions.map(\.rawValue).sorted()
            )

            try await supabase
                .from("users")
                .update(payload)
                .eq("id", value: userId)
                .execute()

            didSave = true
        } catch {
            errorMessage = "Failed to save profile. Please try again."
        }
    }
}

// MARK: - DTOs

private struct ProfileEditDTO: Codable {
    let displayName: String
    let preferredSpiceLevel: String
    let dietaryRestrictions: [String]

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case preferredSpiceLevel = "preferred_spice_level"
        case dietaryRestrictions = "dietary_restrictions"
    }
}

private struct ProfilePayload: Encodable {
    let displayName: String
    let preferredSpiceLevel: String
    let dietaryRestrictions: [String]

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case preferredSpiceLevel = "preferred_spice_level"
        case dietaryRestrictions = "dietary_restrictions"
    }
}
