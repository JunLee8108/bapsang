//
//  DisplayNameTracker.swift
//  Bapsang
//

import Foundation

@MainActor
enum DisplayNameTracker {
    private(set) static var version: Int = 0

    static func notifyChange() {
        version += 1
    }
}

@MainActor
enum SavedItemTracker {
    private(set) static var version: Int = 0

    static func notifyChange() {
        version += 1
    }
}

@MainActor
enum PostEngagementTracker {
    private(set) static var version: Int = 0

    static func notifyChange() {
        version += 1
    }
}
