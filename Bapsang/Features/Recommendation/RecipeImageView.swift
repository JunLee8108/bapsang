//
//  RecipeImageView.swift
//  Bapsang
//

import SwiftUI

struct RecipeImageView: View {
    let recipe: DefaultRecipe
    let size: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        if let uiImage = UIImage(named: recipe.imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            Text(recipe.emoji)
                .font(.system(size: size * 0.55))
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                )
        }
    }
}
