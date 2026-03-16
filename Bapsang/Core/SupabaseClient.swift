//
//  SupabaseClient.swift
//  Bapsang
//
//  Created by Jun Lee on 3/16/26.
//

import Supabase
import Foundation

let supabase = SupabaseClient(
    supabaseURL: Config.supabaseURL,
    supabaseKey: Config.supabaseAnonKey,
    options: .init(
        auth: .init(
            redirectToURL: URL(string: "bapsang://login-callback"),
            emitLocalSessionAsInitialSession: true
        )
    )
)
