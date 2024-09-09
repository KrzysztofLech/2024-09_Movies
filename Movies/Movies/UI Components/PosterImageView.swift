//  PosterImageView.swift
//  Created by Krzysztof Lech on 09/09/2024.

import SwiftUI

struct PosterImageView: View {
	let imageUrl: URL?
	let title: String
	let width: CGFloat

	private let imageAspectRatio: CGFloat = 1.5

	var body: some View {
		AsyncImage(
			url: imageUrl,
			content: { phase in
				if let image = phase.image {
					image
						.resizable()
						.aspectRatio(contentMode: .fill)
				} else if phase.error != nil {
					placeholderView
				} else {
					ProgressView()
						.tint(.accent)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
				}
			}
		)
		.frame(height: width * imageAspectRatio)
		.clipped()
	}

	private var placeholderView: some View {
		VStack(alignment: .center, spacing: width / 10) {
			Image(systemName: "photo")
				.resizable()
				.scaledToFit()
				.foregroundColor(.light)
				.frame(width: width / 3)

			Text(title)
				.foregroundStyle(.light)
				.font(.system(size: width / 10, weight: .light))
				.multilineTextAlignment(.center)
				.padding(.horizontal, 16)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.background)
	}
}

#Preview {
	PosterImageView(
		imageUrl: URL(string: "https://image.tmdb.org/t/p/w200/9YtiecEbDSx4MEt2HUS2fKcJ9Dq.jpg"),
		title: "Hrabia Monte Christo",
		width: 600
	)
}
