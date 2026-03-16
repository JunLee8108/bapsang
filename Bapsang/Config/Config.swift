//
//  Config.swift
//  Bapsang
//
//  Created by Jun Lee on 3/16/26.
//

import Foundation

enum Config {
    
    static let supabaseURL: URL = {
        guard let string = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
              let url = URL(string: string) else {
            fatalError("❌ SUPABASE_URL이 Info.plist에 설정되지 않았습니다. xcconfig 파일을 확인하세요.")
        }
        return url
    }()
    
    static let supabaseAnonKey: String = {
        guard let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String, !key.isEmpty else {
            fatalError("❌ SUPABASE_ANON_KEY가 Info.plist에 설정되지 않았습니다. xcconfig 파일을 확인하세요.")
        }
        return key
    }()
}
