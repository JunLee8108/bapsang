//
//  DefaultRecipeData.swift
//  Bapsang
//

import Foundation

enum DefaultRecipeData {
    static let all: [String: [DefaultRecipe]] = [
        "Soup/Stew": [
            DefaultRecipe(id: UUID(), categoryName: "Soup/Stew", name: "Kimchi Jjigae",     koreanName: "김치찌개",  emoji: "🍲", difficulty: .easy,   cookingTime: 25, description: "Spicy kimchi stew with pork and tofu"),
            DefaultRecipe(id: UUID(), categoryName: "Soup/Stew", name: "Doenjang Jjigae",   koreanName: "된장찌개",  emoji: "🫕", difficulty: .easy,   cookingTime: 20, description: "Fermented soybean paste stew with vegetables"),
            DefaultRecipe(id: UUID(), categoryName: "Soup/Stew", name: "Sundubu Jjigae",    koreanName: "순두부찌개", emoji: "🥘", difficulty: .easy,   cookingTime: 20, description: "Soft tofu stew with seafood or pork"),
            DefaultRecipe(id: UUID(), categoryName: "Soup/Stew", name: "Budae Jjigae",      koreanName: "부대찌개",  emoji: "🍲", difficulty: .medium, cookingTime: 30, description: "Army stew with sausage, spam, and ramyeon"),
            DefaultRecipe(id: UUID(), categoryName: "Soup/Stew", name: "Tteokguk",          koreanName: "떡국",     emoji: "🥣", difficulty: .easy,   cookingTime: 30, description: "Rice cake soup traditionally eaten on New Year's"),
            DefaultRecipe(id: UUID(), categoryName: "Soup/Stew", name: "Samgyetang",        koreanName: "삼계탕",   emoji: "🐔", difficulty: .hard,   cookingTime: 60, description: "Ginseng chicken soup with rice stuffing"),
        ],
        "Stir-fry": [
            DefaultRecipe(id: UUID(), categoryName: "Stir-fry", name: "Jeyuk Bokkeum",     koreanName: "제육볶음",  emoji: "🥩", difficulty: .easy,   cookingTime: 20, description: "Spicy stir-fried pork with gochujang"),
            DefaultRecipe(id: UUID(), categoryName: "Stir-fry", name: "Tteokbokki",        koreanName: "떡볶이",   emoji: "🌶️", difficulty: .easy,   cookingTime: 20, description: "Spicy stir-fried rice cakes"),
            DefaultRecipe(id: UUID(), categoryName: "Stir-fry", name: "Ojingeo Bokkeum",   koreanName: "오징어볶음", emoji: "🦑", difficulty: .medium, cookingTime: 15, description: "Spicy stir-fried squid with vegetables"),
            DefaultRecipe(id: UUID(), categoryName: "Stir-fry", name: "Dakgalbi",          koreanName: "닭갈비",   emoji: "🍗", difficulty: .medium, cookingTime: 25, description: "Spicy stir-fried chicken with cabbage and rice cakes"),
            DefaultRecipe(id: UUID(), categoryName: "Stir-fry", name: "Japchae",           koreanName: "잡채",     emoji: "🍜", difficulty: .medium, cookingTime: 30, description: "Glass noodles stir-fried with vegetables and beef"),
        ],
        "Rice": [
            DefaultRecipe(id: UUID(), categoryName: "Rice", name: "Bibimbap",           koreanName: "비빔밥",     emoji: "🍚", difficulty: .medium, cookingTime: 30, description: "Mixed rice with vegetables, meat, and gochujang"),
            DefaultRecipe(id: UUID(), categoryName: "Rice", name: "Kimchi Fried Rice",  koreanName: "김치볶음밥",  emoji: "🍳", difficulty: .easy,   cookingTime: 15, description: "Fried rice with kimchi topped with a fried egg"),
            DefaultRecipe(id: UUID(), categoryName: "Rice", name: "Tuna Mayo Rice",     koreanName: "참치마요덮밥", emoji: "🐟", difficulty: .easy,   cookingTime: 10, description: "Simple tuna and mayo over steamed rice"),
            DefaultRecipe(id: UUID(), categoryName: "Rice", name: "Omurice",            koreanName: "오므라이스",  emoji: "🥚", difficulty: .medium, cookingTime: 20, description: "Fried rice wrapped in a soft omelette"),
            DefaultRecipe(id: UUID(), categoryName: "Rice", name: "Dolsot Bibimbap",    koreanName: "돌솥비빔밥",  emoji: "🔥", difficulty: .medium, cookingTime: 35, description: "Hot stone pot bibimbap with crispy rice"),
        ],
        "Noodles": [
            DefaultRecipe(id: UUID(), categoryName: "Noodles", name: "Kalguksu",         koreanName: "칼국수",   emoji: "🍜", difficulty: .medium, cookingTime: 30, description: "Hand-cut knife noodles in anchovy broth"),
            DefaultRecipe(id: UUID(), categoryName: "Noodles", name: "Bibim Guksu",      koreanName: "비빔국수",  emoji: "🥢", difficulty: .easy,   cookingTime: 15, description: "Spicy cold mixed noodles"),
            DefaultRecipe(id: UUID(), categoryName: "Noodles", name: "Japchae",          koreanName: "잡채",     emoji: "🍝", difficulty: .medium, cookingTime: 30, description: "Sweet potato glass noodles with vegetables"),
            DefaultRecipe(id: UUID(), categoryName: "Noodles", name: "Jjajangmyeon",     koreanName: "짜장면",   emoji: "🍜", difficulty: .medium, cookingTime: 25, description: "Noodles in black bean sauce"),
            DefaultRecipe(id: UUID(), categoryName: "Noodles", name: "Ramyeon",          koreanName: "라면",     emoji: "🍜", difficulty: .easy,   cookingTime: 10, description: "Korean instant noodles with egg and scallions"),
        ],
        "Side Dishes": [
            DefaultRecipe(id: UUID(), categoryName: "Side Dishes", name: "Gyeran Mari",     koreanName: "계란말이",   emoji: "🥚", difficulty: .easy,   cookingTime: 10, description: "Rolled egg omelette with vegetables"),
            DefaultRecipe(id: UUID(), categoryName: "Side Dishes", name: "Gamja Jorim",     koreanName: "감자조림",   emoji: "🥔", difficulty: .easy,   cookingTime: 20, description: "Braised potatoes in sweet soy glaze"),
            DefaultRecipe(id: UUID(), categoryName: "Side Dishes", name: "Sigeumchi Namul", koreanName: "시금치나물",  emoji: "🥬", difficulty: .easy,   cookingTime: 10, description: "Seasoned spinach side dish"),
            DefaultRecipe(id: UUID(), categoryName: "Side Dishes", name: "Kongnamul Muchim",koreanName: "콩나물무침",  emoji: "🌱", difficulty: .easy,   cookingTime: 10, description: "Seasoned soybean sprouts"),
            DefaultRecipe(id: UUID(), categoryName: "Side Dishes", name: "Eomuk Bokkeum",  koreanName: "어묵볶음",   emoji: "🍢", difficulty: .easy,   cookingTime: 10, description: "Stir-fried fish cake with soy sauce"),
        ],
        "One-Plate": [
            DefaultRecipe(id: UUID(), categoryName: "One-Plate", name: "Kimchijeon",       koreanName: "김치전",    emoji: "🥞", difficulty: .easy,   cookingTime: 15, description: "Crispy kimchi pancake"),
            DefaultRecipe(id: UUID(), categoryName: "One-Plate", name: "Ramyeon",           koreanName: "라면",     emoji: "🍜", difficulty: .easy,   cookingTime: 10, description: "Quick Korean ramyeon with egg"),
            DefaultRecipe(id: UUID(), categoryName: "One-Plate", name: "Cheese Toast",      koreanName: "치즈토스트", emoji: "🧀", difficulty: .easy,   cookingTime: 10, description: "Korean street-style cheese toast"),
            DefaultRecipe(id: UUID(), categoryName: "One-Plate", name: "Gyeran Bap",        koreanName: "계란밥",   emoji: "🍳", difficulty: .easy,   cookingTime: 5,  description: "Simple egg over rice with sesame oil and soy sauce"),
            DefaultRecipe(id: UUID(), categoryName: "One-Plate", name: "Chamchi Gimbap",    koreanName: "참치김밥",  emoji: "🍙", difficulty: .medium, cookingTime: 25, description: "Tuna kimbap rolls"),
        ],
    ]

    static func recipes(for categoryName: String) -> [DefaultRecipe] {
        all[categoryName] ?? []
    }
}
