//  FavoriteIcon.swift
//  Created by Krzysztof Lech on 09/09/2024.

import SwiftUI

struct FavoriteIcon: View {

	let isFavourite: Bool
	let size: CGFloat

    var body: some View {
		Image(systemName: isFavourite ? "heart.fill" : "heart")
			.resizable()
			.foregroundColor(.light)
			.shadow(color: .black, radius: 10, x: 0, y: 0)
			.frame(width: size, height: size)
    }
}
