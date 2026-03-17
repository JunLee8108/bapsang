//
//  DefaultRecipeData.swift
//  Bapsang
//

import Foundation

// swiftlint:disable function_body_length file_length

enum DefaultRecipeData {
    static let all: [String: [DefaultRecipe]] = [

        // ──────────────────────────────────────
        // MARK: - Soup / Stew
        // ──────────────────────────────────────
        "Soup/Stew": [
            DefaultRecipe(
                id: UUID(), categoryName: "Soup/Stew",
                name: "Kimchi Jjigae", koreanName: "김치찌개", emoji: "🍲", imageName: "kimchi_jjigae",
                difficulty: .easy, cookingTime: 25, servingSize: 2,
                description: "Spicy kimchi stew with pork and tofu",
                ingredients: [
                    "1 cup aged kimchi, chopped",
                    "150g pork belly, sliced",
                    "1/2 block soft tofu",
                    "1 tbsp gochugaru (red pepper flakes)",
                    "1 tsp sesame oil",
                    "2 cups water or anchovy broth",
                    "1 green onion, sliced",
                ],
                steps: [
                    "Heat sesame oil in a pot over medium heat. Stir-fry pork belly until lightly browned.",
                    "Add chopped kimchi and gochugaru, stir-fry for 2-3 minutes.",
                    "Pour in water or broth and bring to a boil.",
                    "Reduce heat and simmer for 15 minutes until flavors meld.",
                    "Add tofu in large chunks and simmer for another 5 minutes.",
                    "Garnish with green onions and serve with steamed rice.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Soup/Stew",
                name: "Doenjang Jjigae", koreanName: "된장찌개", emoji: "🫕", imageName: "doenjang_jjigae",
                difficulty: .easy, cookingTime: 20, servingSize: 2,
                description: "Fermented soybean paste stew with vegetables",
                ingredients: [
                    "2 tbsp doenjang (fermented soybean paste)",
                    "1/2 block firm tofu, cubed",
                    "1 zucchini, sliced",
                    "1 potato, cubed",
                    "1/2 onion, sliced",
                    "2 green chili peppers, sliced",
                    "2 cups anchovy broth",
                ],
                steps: [
                    "Bring anchovy broth to a boil in a pot.",
                    "Dissolve doenjang paste into the broth, stirring well.",
                    "Add potato cubes and cook for 5 minutes.",
                    "Add zucchini, onion, and tofu. Simmer for 10 minutes.",
                    "Add green chili peppers and cook for 2 more minutes.",
                    "Serve hot with steamed rice.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Soup/Stew",
                name: "Sundubu Jjigae", koreanName: "순두부찌개", emoji: "🥘", imageName: "sundubu_jjigae",
                difficulty: .easy, cookingTime: 20, servingSize: 2,
                description: "Soft tofu stew with seafood or pork",
                ingredients: [
                    "1 pack soft (sundubu) tofu",
                    "100g pork or shrimp",
                    "1 tbsp gochugaru",
                    "1 tsp soy sauce",
                    "1 egg",
                    "1 green onion, sliced",
                    "1 tsp sesame oil",
                    "1.5 cups water",
                ],
                steps: [
                    "Heat sesame oil in a stone pot. Sauté pork or shrimp until cooked.",
                    "Add gochugaru and soy sauce, stir for 30 seconds.",
                    "Pour in water and bring to a boil.",
                    "Gently add soft tofu, breaking it into large pieces.",
                    "Simmer for 8-10 minutes.",
                    "Crack an egg on top just before serving. Garnish with green onion.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Soup/Stew",
                name: "Budae Jjigae", koreanName: "부대찌개", emoji: "🍲", imageName: "budae_jjigae",
                difficulty: .medium, cookingTime: 30, servingSize: 3,
                description: "Army stew with sausage, spam, and ramyeon",
                ingredients: [
                    "1 can spam, sliced",
                    "2 sausages, sliced diagonally",
                    "1 pack ramyeon noodles",
                    "1/2 cup kimchi",
                    "1 slice cheese",
                    "1 tbsp gochugaru",
                    "2 cups water or broth",
                    "1/2 block tofu, sliced",
                    "1 green onion, sliced",
                ],
                steps: [
                    "Arrange spam, sausages, kimchi, tofu, and baked beans neatly in a wide pot.",
                    "Mix gochugaru, soy sauce, and minced garlic with a bit of broth to make sauce. Pour over.",
                    "Add water or broth and bring to a boil.",
                    "Once boiling, add ramyeon noodles.",
                    "Place a slice of cheese on top.",
                    "Cook until noodles are done. Garnish with green onion.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Soup/Stew",
                name: "Tteokguk", koreanName: "떡국", emoji: "🥣", imageName: "tteokguk",
                difficulty: .easy, cookingTime: 30, servingSize: 2,
                description: "Rice cake soup traditionally eaten on New Year's",
                ingredients: [
                    "2 cups sliced rice cakes (tteok), soaked",
                    "200g beef brisket",
                    "4 cups water",
                    "1 egg, beaten",
                    "1 tbsp soy sauce",
                    "1 green onion, sliced",
                    "Dried seaweed (gim), crumbled",
                ],
                steps: [
                    "Boil beef brisket in water for 20 minutes to make broth. Remove and slice beef thinly.",
                    "Strain broth and return to pot. Season with soy sauce.",
                    "Add soaked rice cakes and cook until soft (about 5 minutes).",
                    "Drizzle beaten egg into the boiling soup, stirring gently.",
                    "Serve topped with sliced beef, green onion, and crumbled seaweed.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Soup/Stew",
                name: "Samgyetang", koreanName: "삼계탕", emoji: "🐔", imageName: "samgyetang",
                difficulty: .hard, cookingTime: 60, servingSize: 2,
                description: "Ginseng chicken soup with rice stuffing",
                ingredients: [
                    "1 small whole chicken (Cornish hen)",
                    "1/3 cup sweet rice (glutinous rice), soaked 1 hour",
                    "4-5 garlic cloves",
                    "2-3 dried jujubes",
                    "1 small ginseng root",
                    "6 cups water",
                    "Salt and pepper to taste",
                    "Green onion for garnish",
                ],
                steps: [
                    "Stuff the chicken cavity with soaked sweet rice, garlic, jujubes, and ginseng.",
                    "Tie the legs with kitchen string to close.",
                    "Place in a large pot, cover with water, and bring to a boil.",
                    "Reduce to a simmer and cook for 45-50 minutes until chicken is tender.",
                    "Season broth with salt and pepper.",
                    "Serve in a stone bowl, garnished with green onion. Season individually with salt.",
                ]
            ),
        ],

        // ──────────────────────────────────────
        // MARK: - Stir-fry
        // ──────────────────────────────────────
        "Stir-fry": [
            DefaultRecipe(
                id: UUID(), categoryName: "Stir-fry",
                name: "Jeyuk Bokkeum", koreanName: "제육볶음", emoji: "🥩", imageName: "jeyuk_bokkeum",
                difficulty: .easy, cookingTime: 20, servingSize: 2,
                description: "Spicy stir-fried pork with gochujang",
                ingredients: [
                    "300g pork shoulder or belly, thinly sliced",
                    "2 tbsp gochujang",
                    "1 tbsp soy sauce",
                    "1 tbsp sugar",
                    "1 tbsp minced garlic",
                    "1/2 onion, sliced",
                    "1 green onion, sliced",
                    "1 tsp sesame oil",
                ],
                steps: [
                    "Mix gochujang, soy sauce, sugar, garlic, and sesame oil to make the sauce.",
                    "Marinate pork slices in the sauce for 10 minutes.",
                    "Heat a pan over high heat. Stir-fry marinated pork for 5-6 minutes.",
                    "Add onion slices and cook until softened.",
                    "Garnish with green onion and serve with rice and lettuce wraps.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Stir-fry",
                name: "Tteokbokki", koreanName: "떡볶이", emoji: "🌶️", imageName: "tteokbokki",
                difficulty: .easy, cookingTime: 20, servingSize: 2,
                description: "Spicy stir-fried rice cakes",
                ingredients: [
                    "2 cups cylinder rice cakes, soaked",
                    "3 tbsp gochujang",
                    "1 tbsp gochugaru",
                    "1 tbsp sugar",
                    "1 tbsp soy sauce",
                    "2 cups anchovy broth or water",
                    "2 fish cakes, sliced",
                    "1 green onion, sliced",
                    "1 hard-boiled egg (optional)",
                ],
                steps: [
                    "Bring broth to a boil in a pan.",
                    "Add gochujang, gochugaru, sugar, and soy sauce. Stir well.",
                    "Add rice cakes and fish cakes.",
                    "Cook on medium heat for 10-12 minutes, stirring occasionally, until sauce thickens.",
                    "Garnish with green onion and serve with a hard-boiled egg.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Stir-fry",
                name: "Ojingeo Bokkeum", koreanName: "오징어볶음", emoji: "🦑", imageName: "ojingeo_bokkeum",
                difficulty: .medium, cookingTime: 15, servingSize: 2,
                description: "Spicy stir-fried squid with vegetables",
                ingredients: [
                    "1 whole squid, cleaned and sliced into rings",
                    "1/2 onion, sliced",
                    "1 carrot, julienned",
                    "1 zucchini, sliced",
                    "2 tbsp gochujang",
                    "1 tbsp soy sauce",
                    "1 tbsp sugar",
                    "1 tsp minced garlic",
                ],
                steps: [
                    "Mix gochujang, soy sauce, sugar, and garlic to make sauce.",
                    "Heat oil in a wok over high heat. Stir-fry squid for 1-2 minutes.",
                    "Add vegetables and stir-fry for 2 minutes.",
                    "Pour in the sauce and toss everything together for 2-3 minutes.",
                    "Serve immediately with steamed rice.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Stir-fry",
                name: "Dakgalbi", koreanName: "닭갈비", emoji: "🍗", imageName: "dakgalbi",
                difficulty: .medium, cookingTime: 25, servingSize: 2,
                description: "Spicy stir-fried chicken with cabbage and rice cakes",
                ingredients: [
                    "300g boneless chicken thigh, cubed",
                    "2 tbsp gochujang",
                    "1 tbsp gochugaru",
                    "1 tbsp soy sauce",
                    "1 tbsp sugar",
                    "2 cups cabbage, chopped",
                    "1/2 sweet potato, sliced",
                    "1 cup rice cakes",
                    "1 green onion, sliced",
                ],
                steps: [
                    "Mix gochujang, gochugaru, soy sauce, sugar, and garlic to make sauce.",
                    "Marinate chicken in the sauce for 10 minutes.",
                    "Heat a large pan. Add chicken and cook for 5 minutes.",
                    "Add cabbage, sweet potato, and rice cakes. Cook on medium heat for 12-15 minutes, stirring occasionally.",
                    "Garnish with green onion. Optionally add fried rice to the pan at the end.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Stir-fry",
                name: "Japchae", koreanName: "잡채", emoji: "🍜", imageName: "japchae",
                difficulty: .medium, cookingTime: 30, servingSize: 3,
                description: "Glass noodles stir-fried with vegetables and beef",
                ingredients: [
                    "200g sweet potato glass noodles",
                    "100g beef, thinly sliced",
                    "1 carrot, julienned",
                    "1 cup spinach, blanched",
                    "5 shiitake mushrooms, sliced",
                    "1/2 onion, sliced",
                    "3 tbsp soy sauce",
                    "1 tbsp sugar",
                    "1 tbsp sesame oil",
                    "Sesame seeds for garnish",
                ],
                steps: [
                    "Cook glass noodles according to package. Drain and cut into shorter lengths.",
                    "Stir-fry beef with 1 tbsp soy sauce until cooked. Set aside.",
                    "Stir-fry each vegetable separately with a pinch of salt. Set aside.",
                    "In a large bowl, combine noodles, beef, and all vegetables.",
                    "Add remaining soy sauce, sugar, and sesame oil. Toss well.",
                    "Sprinkle sesame seeds and serve warm or at room temperature.",
                ]
            ),
        ],

        // ──────────────────────────────────────
        // MARK: - Rice
        // ──────────────────────────────────────
        "Rice": [
            DefaultRecipe(
                id: UUID(), categoryName: "Rice",
                name: "Bibimbap", koreanName: "비빔밥", emoji: "🍚", imageName: "bibimbap",
                difficulty: .medium, cookingTime: 30, servingSize: 2,
                description: "Mixed rice with vegetables, meat, and gochujang",
                ingredients: [
                    "2 bowls steamed rice",
                    "100g ground beef, seasoned",
                    "1 cup spinach, blanched",
                    "1 carrot, julienned and sautéed",
                    "1 zucchini, julienned and sautéed",
                    "1 cup bean sprouts, blanched",
                    "2 fried eggs",
                    "2 tbsp gochujang",
                    "1 tsp sesame oil",
                ],
                steps: [
                    "Prepare each vegetable topping separately — blanch or sauté with salt and sesame oil.",
                    "Season ground beef with soy sauce, sugar, garlic, sesame oil. Cook in a pan.",
                    "Place steamed rice in a bowl.",
                    "Arrange vegetables and beef on top of rice in sections.",
                    "Top with a fried egg and a spoonful of gochujang.",
                    "Mix everything together before eating.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Rice",
                name: "Kimchi Fried Rice", koreanName: "김치볶음밥", emoji: "🍳", imageName: "kimchi_fried_rice",
                difficulty: .easy, cookingTime: 15, servingSize: 1,
                description: "Fried rice with kimchi topped with a fried egg",
                ingredients: [
                    "1.5 cups cold leftover rice",
                    "1/2 cup kimchi, chopped",
                    "2 tbsp kimchi juice",
                    "1 tbsp gochujang",
                    "1 tsp sesame oil",
                    "1 fried egg",
                    "1 green onion, sliced",
                    "Sesame seeds",
                ],
                steps: [
                    "Heat sesame oil in a pan over high heat.",
                    "Add chopped kimchi and stir-fry for 2 minutes.",
                    "Add rice and kimchi juice. Break up clumps and stir-fry for 3-4 minutes.",
                    "Add gochujang and mix evenly.",
                    "Plate the rice, top with a fried egg and green onion. Sprinkle sesame seeds.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Rice",
                name: "Tuna Mayo Rice", koreanName: "참치마요덮밥", emoji: "🐟", imageName: "tuna_mayo_rice",
                difficulty: .easy, cookingTime: 10, servingSize: 1,
                description: "Simple tuna and mayo over steamed rice",
                ingredients: [
                    "1 bowl steamed rice",
                    "1 can tuna, drained",
                    "2 tbsp mayonnaise",
                    "1 tsp soy sauce",
                    "1/2 tsp sesame oil",
                    "Sesame seeds",
                    "Dried seaweed (gim), crumbled",
                ],
                steps: [
                    "Mix drained tuna with mayonnaise, soy sauce, and sesame oil.",
                    "Place steamed rice in a bowl.",
                    "Top with the tuna mayo mixture.",
                    "Garnish with sesame seeds and crumbled seaweed.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Rice",
                name: "Omurice", koreanName: "오므라이스", emoji: "🥚", imageName: "omurice",
                difficulty: .medium, cookingTime: 20, servingSize: 1,
                description: "Fried rice wrapped in a soft omelette",
                ingredients: [
                    "1.5 cups cooked rice",
                    "2 tbsp ketchup",
                    "1/4 onion, diced",
                    "1/4 cup diced ham or chicken",
                    "3 eggs",
                    "Salt and pepper",
                    "1 tbsp butter",
                    "Ketchup for drizzle",
                ],
                steps: [
                    "Sauté onion and ham in a pan. Add rice and ketchup, stir-fry until well mixed. Set aside.",
                    "Beat eggs with a pinch of salt.",
                    "Melt butter in a non-stick pan over low heat. Pour in eggs.",
                    "When eggs are just set on bottom but still soft on top, place rice on one half.",
                    "Fold the omelette over the rice and slide onto a plate.",
                    "Drizzle ketchup on top and serve.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Rice",
                name: "Dolsot Bibimbap", koreanName: "돌솥비빔밥", emoji: "🔥", imageName: "dolsot_bibimbap",
                difficulty: .medium, cookingTime: 35, servingSize: 1,
                description: "Hot stone pot bibimbap with crispy rice",
                ingredients: [
                    "1.5 cups steamed rice",
                    "Assorted vegetables (spinach, carrot, zucchini, bean sprouts, mushroom)",
                    "100g beef, seasoned",
                    "1 egg",
                    "2 tbsp gochujang",
                    "1 tsp sesame oil",
                    "Sesame seeds",
                ],
                steps: [
                    "Prepare vegetables as you would for regular bibimbap.",
                    "Brush inside of a stone pot (dolsot) with sesame oil.",
                    "Add rice to the stone pot. Arrange vegetables and beef on top.",
                    "Place the stone pot on heat. Cook on medium for 5-7 minutes until rice crackles.",
                    "Crack a raw egg on top and add gochujang.",
                    "Mix well before eating — the bottom rice should be crispy and golden.",
                ]
            ),
        ],

        // ──────────────────────────────────────
        // MARK: - Noodles
        // ──────────────────────────────────────
        "Noodles": [
            DefaultRecipe(
                id: UUID(), categoryName: "Noodles",
                name: "Kalguksu", koreanName: "칼국수", emoji: "🍜", imageName: "kalguksu",
                difficulty: .medium, cookingTime: 30, servingSize: 2,
                description: "Hand-cut knife noodles in anchovy broth",
                ingredients: [
                    "200g kalguksu noodles (or wide flour noodles)",
                    "1 zucchini, sliced",
                    "1 potato, cubed",
                    "4 cups anchovy & kelp broth",
                    "1 tbsp minced garlic",
                    "Salt to taste",
                    "1 green onion, sliced",
                ],
                steps: [
                    "Make broth: simmer dried anchovies and kelp in water for 15 minutes. Strain.",
                    "Bring broth to a boil. Add potato cubes and cook 5 minutes.",
                    "Add noodles and stir to prevent sticking.",
                    "Add zucchini and garlic. Cook until noodles are tender (about 6-8 minutes).",
                    "Season with salt. Garnish with green onion and serve hot.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Noodles",
                name: "Bibim Guksu", koreanName: "비빔국수", emoji: "🥢", imageName: "bibim_guksu",
                difficulty: .easy, cookingTime: 15, servingSize: 1,
                description: "Spicy cold mixed noodles",
                ingredients: [
                    "1 bundle somyeon (thin wheat noodles)",
                    "2 tbsp gochujang",
                    "1 tbsp sugar",
                    "1 tbsp vinegar",
                    "1 tbsp soy sauce",
                    "1 tsp sesame oil",
                    "1/2 cucumber, julienned",
                    "1 hard-boiled egg",
                ],
                steps: [
                    "Cook somyeon according to package. Rinse under cold water and drain well.",
                    "Mix gochujang, sugar, vinegar, soy sauce, and sesame oil to make sauce.",
                    "Toss cold noodles with the sauce.",
                    "Top with julienned cucumber and half a hard-boiled egg.",
                    "Mix well before eating.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Noodles",
                name: "Japchae", koreanName: "잡채", emoji: "🍝", imageName: "japchae_noodles",
                difficulty: .medium, cookingTime: 30, servingSize: 3,
                description: "Sweet potato glass noodles with vegetables",
                ingredients: [
                    "200g sweet potato glass noodles",
                    "1 carrot, julienned",
                    "1 cup spinach, blanched",
                    "5 shiitake mushrooms, sliced",
                    "1/2 onion, sliced",
                    "3 tbsp soy sauce",
                    "1 tbsp sugar",
                    "1 tbsp sesame oil",
                ],
                steps: [
                    "Cook glass noodles per package. Drain, cut shorter, and toss with sesame oil.",
                    "Sauté each vegetable separately with a pinch of salt.",
                    "Combine noodles and all vegetables in a large bowl.",
                    "Season with soy sauce, sugar, and sesame oil. Toss well.",
                    "Serve warm or at room temperature, topped with sesame seeds.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Noodles",
                name: "Jjajangmyeon", koreanName: "짜장면", emoji: "🍜", imageName: "jjajangmyeon",
                difficulty: .medium, cookingTime: 25, servingSize: 2,
                description: "Noodles in black bean sauce",
                ingredients: [
                    "2 portions jjajang noodles (or thick wheat noodles)",
                    "3 tbsp chunjang (black bean paste)",
                    "200g pork belly, diced",
                    "1 potato, diced",
                    "1 onion, diced",
                    "1/2 zucchini, diced",
                    "1 tbsp sugar",
                    "1 tbsp cornstarch + 2 tbsp water",
                ],
                steps: [
                    "Fry chunjang paste in oil for 1 minute to remove bitterness. Set aside.",
                    "Stir-fry diced pork until browned. Add vegetables and cook 3-4 minutes.",
                    "Add the fried chunjang and sugar. Stir to coat.",
                    "Add 1 cup water and simmer for 5 minutes.",
                    "Add cornstarch slurry to thicken the sauce.",
                    "Cook noodles, drain, and top with the black bean sauce. Serve with pickled radish.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Noodles",
                name: "Ramyeon", koreanName: "라면", emoji: "🍜", imageName: "ramyeon",
                difficulty: .easy, cookingTime: 10, servingSize: 1,
                description: "Korean instant noodles with egg and scallions",
                ingredients: [
                    "1 pack Korean ramyeon",
                    "2 cups water",
                    "1 egg",
                    "1 green onion, sliced",
                    "1 slice cheese (optional)",
                    "Kimchi on the side (optional)",
                ],
                steps: [
                    "Bring 2 cups of water to a boil.",
                    "Add the soup base and flakes from the ramyeon packet.",
                    "Add noodles and cook for 3-4 minutes, stirring occasionally.",
                    "Crack an egg into the pot in the last minute.",
                    "Top with green onion and cheese if desired. Serve immediately.",
                ]
            ),
        ],

        // ──────────────────────────────────────
        // MARK: - Side Dishes
        // ──────────────────────────────────────
        "Side Dishes": [
            DefaultRecipe(
                id: UUID(), categoryName: "Side Dishes",
                name: "Gyeran Mari", koreanName: "계란말이", emoji: "🥚", imageName: "gyeran_mari",
                difficulty: .easy, cookingTime: 10, servingSize: 2,
                description: "Rolled egg omelette with vegetables",
                ingredients: [
                    "4 eggs",
                    "2 tbsp finely diced carrot",
                    "2 tbsp finely diced green onion",
                    "Pinch of salt",
                    "1 tsp cooking oil",
                ],
                steps: [
                    "Beat eggs with salt. Mix in diced carrot and green onion.",
                    "Oil a rectangular pan (or regular pan) over low heat.",
                    "Pour a thin layer of egg mixture. When half-set, roll it to one side.",
                    "Pour another thin layer, letting it flow under the roll. Roll again.",
                    "Repeat until all egg mixture is used.",
                    "Let it rest 2 minutes, then slice into bite-size rounds.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Side Dishes",
                name: "Gamja Jorim", koreanName: "감자조림", emoji: "🥔", imageName: "gamja_jorim",
                difficulty: .easy, cookingTime: 20, servingSize: 2,
                description: "Braised potatoes in sweet soy glaze",
                ingredients: [
                    "2 medium potatoes, cubed",
                    "2 tbsp soy sauce",
                    "1 tbsp sugar",
                    "1 tbsp corn syrup (or honey)",
                    "1 tsp minced garlic",
                    "1/2 cup water",
                    "Sesame seeds and sesame oil",
                ],
                steps: [
                    "Place potato cubes in a pan. Add water, soy sauce, sugar, and corn syrup.",
                    "Bring to a boil, then reduce to medium heat.",
                    "Cook for 12-15 minutes, stirring occasionally, until potatoes are tender.",
                    "Add garlic and continue cooking until sauce is thick and glossy.",
                    "Drizzle sesame oil and sprinkle sesame seeds before serving.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Side Dishes",
                name: "Sigeumchi Namul", koreanName: "시금치나물", emoji: "🥬", imageName: "sigeumchi_namul",
                difficulty: .easy, cookingTime: 10, servingSize: 2,
                description: "Seasoned spinach side dish",
                ingredients: [
                    "1 bunch spinach",
                    "1 tsp soy sauce",
                    "1 tsp sesame oil",
                    "1/2 tsp minced garlic",
                    "Pinch of salt",
                    "Sesame seeds",
                ],
                steps: [
                    "Bring a pot of water to a boil. Blanch spinach for 30 seconds.",
                    "Immediately transfer to ice water. Squeeze out excess water.",
                    "Cut spinach into 2-inch lengths.",
                    "Toss with soy sauce, sesame oil, garlic, and salt.",
                    "Sprinkle sesame seeds and serve at room temperature.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Side Dishes",
                name: "Kongnamul Muchim", koreanName: "콩나물무침", emoji: "🌱", imageName: "kongnamul_muchim",
                difficulty: .easy, cookingTime: 10, servingSize: 2,
                description: "Seasoned soybean sprouts",
                ingredients: [
                    "2 cups soybean sprouts",
                    "1 tsp sesame oil",
                    "1/2 tsp soy sauce",
                    "1/2 tsp minced garlic",
                    "1 green onion, sliced",
                    "Pinch of salt",
                    "Sesame seeds",
                    "Gochugaru (optional)",
                ],
                steps: [
                    "Boil soybean sprouts in salted water for 5-6 minutes. Do not open the lid.",
                    "Drain and rinse under cold water.",
                    "Toss with sesame oil, soy sauce, garlic, salt, and green onion.",
                    "Optionally add gochugaru for a spicy version.",
                    "Top with sesame seeds and serve.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "Side Dishes",
                name: "Eomuk Bokkeum", koreanName: "어묵볶음", emoji: "🍢", imageName: "eomuk_bokkeum",
                difficulty: .easy, cookingTime: 10, servingSize: 2,
                description: "Stir-fried fish cake with soy sauce",
                ingredients: [
                    "2 sheets fish cake, sliced into strips",
                    "1 tbsp soy sauce",
                    "1 tsp sugar",
                    "1 tsp gochugaru (optional)",
                    "1 tsp sesame oil",
                    "1 green onion, sliced",
                    "Sesame seeds",
                ],
                steps: [
                    "Blanch fish cake strips in hot water for 1 minute. Drain.",
                    "Heat sesame oil in a pan. Stir-fry fish cake for 2 minutes.",
                    "Add soy sauce, sugar, and gochugaru. Toss well for 2-3 minutes.",
                    "Garnish with green onion and sesame seeds. Serve as a side dish.",
                ]
            ),
        ],

        // ──────────────────────────────────────
        // MARK: - One-Plate
        // ──────────────────────────────────────
        "One-Plate": [
            DefaultRecipe(
                id: UUID(), categoryName: "One-Plate",
                name: "Kimchijeon", koreanName: "김치전", emoji: "🥞", imageName: "kimchijeon",
                difficulty: .easy, cookingTime: 15, servingSize: 2,
                description: "Crispy kimchi pancake",
                ingredients: [
                    "1 cup kimchi, chopped",
                    "1/2 cup all-purpose flour",
                    "1/4 cup water",
                    "1 egg",
                    "2 tbsp kimchi juice",
                    "Vegetable oil for frying",
                ],
                steps: [
                    "Mix flour, water, egg, and kimchi juice to make batter.",
                    "Fold in chopped kimchi.",
                    "Heat oil in a flat pan over medium-high heat.",
                    "Pour batter and spread flat. Cook for 3-4 minutes until golden.",
                    "Flip and cook the other side for 3 minutes.",
                    "Serve with a soy-vinegar dipping sauce.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "One-Plate",
                name: "Ramyeon", koreanName: "라면", emoji: "🍜", imageName: "ramyeon_one_plate",
                difficulty: .easy, cookingTime: 10, servingSize: 1,
                description: "Quick Korean ramyeon with egg",
                ingredients: [
                    "1 pack Korean ramyeon",
                    "2 cups water",
                    "1 egg",
                    "1 green onion, sliced",
                ],
                steps: [
                    "Boil water, add soup base and flakes.",
                    "Add noodles and cook 3-4 minutes.",
                    "Crack an egg in during the last minute.",
                    "Top with green onion and serve.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "One-Plate",
                name: "Cheese Toast", koreanName: "치즈토스트", emoji: "🧀", imageName: "cheese_toast",
                difficulty: .easy, cookingTime: 10, servingSize: 1,
                description: "Korean street-style cheese toast",
                ingredients: [
                    "2 slices white bread",
                    "1 egg",
                    "1 tbsp sugar",
                    "1 slice cheese",
                    "1 tbsp butter",
                    "Ketchup (optional)",
                ],
                steps: [
                    "Beat egg with sugar.",
                    "Melt butter in a pan. Dip one side of each bread slice in egg mixture.",
                    "Place bread egg-side down in the pan. Toast until golden.",
                    "Flip, add cheese on one slice.",
                    "Sandwich together. Optionally add ketchup inside.",
                    "Cut diagonally and serve warm.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "One-Plate",
                name: "Gyeran Bap", koreanName: "계란밥", emoji: "🍳", imageName: "gyeran_bap",
                difficulty: .easy, cookingTime: 5, servingSize: 1,
                description: "Simple egg over rice with sesame oil and soy sauce",
                ingredients: [
                    "1 bowl hot steamed rice",
                    "1 egg (raw or fried)",
                    "1 tsp sesame oil",
                    "1 tsp soy sauce",
                    "Sesame seeds",
                    "Dried seaweed (gim)",
                ],
                steps: [
                    "Place hot rice in a bowl.",
                    "Crack a raw egg on top (or fry an egg and place on rice).",
                    "Drizzle sesame oil and soy sauce.",
                    "Sprinkle sesame seeds and crumble seaweed on top.",
                    "Mix everything together and enjoy.",
                ]
            ),
            DefaultRecipe(
                id: UUID(), categoryName: "One-Plate",
                name: "Chamchi Gimbap", koreanName: "참치김밥", emoji: "🍙", imageName: "chamchi_gimbap",
                difficulty: .medium, cookingTime: 25, servingSize: 2,
                description: "Tuna kimbap rolls",
                ingredients: [
                    "2 sheets gim (roasted seaweed)",
                    "2 cups cooked rice, seasoned with sesame oil & salt",
                    "1 can tuna, drained and mixed with mayo",
                    "2 strips pickled radish (danmuji)",
                    "1/2 cucumber, cut into strips",
                    "2 strips egg omelette",
                    "1 carrot, julienned and sautéed",
                ],
                steps: [
                    "Lay a seaweed sheet on a bamboo rolling mat, shiny side down.",
                    "Spread seasoned rice evenly on 2/3 of the seaweed.",
                    "Arrange tuna, pickled radish, cucumber, egg, and carrot in a line.",
                    "Roll tightly from the filling side, pressing gently.",
                    "Brush the roll with sesame oil.",
                    "Slice into bite-sized pieces with a wet knife. Serve.",
                ]
            ),
        ],
    ]

    static func recipes(for categoryName: String) -> [DefaultRecipe] {
        all[categoryName] ?? []
    }
}

// swiftlint:enable function_body_length file_length
