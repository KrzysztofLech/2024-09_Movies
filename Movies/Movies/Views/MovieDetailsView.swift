//  MovieDetailsView.swift
//  Created by Krzysztof Lech on 09/09/2024.

import SwiftUI

struct MovieDetailsView: View {

	@Environment(\.dismiss) private var dismiss
	private let movie: Movie
	@State private var isFavourite: Bool
	private let changeFavoriteAction: () -> Void

	init(movie: Movie, changeFavoriteAction: @escaping () -> Void) {
		self.movie = movie
		self.isFavourite = movie.favorite
		self.changeFavoriteAction = changeFavoriteAction
	}

	var body: some View {
		ZStack(alignment: .topLeading) {
			detailsView
			
			HStack {
				backButton
				Spacer()
				favoriteButton
			}
		}
		.navigationBarHidden(true)
	}

	private var detailsView: some View {
		ScrollView(.vertical) {
			VStack(alignment: .center, spacing: 16) {
				PosterImageView(
					imageUrl: movie.largePosterUrl,
					title: movie.title,
					width: UIScreen.main.bounds.width,
					titleVisible: false
				)
				.shadow(color: .light.opacity(0.5), radius: 8, x: 0, y: 0)

				VStack(alignment: .center, spacing: 8) {
					Text(movie.title)
						.font(.title)
						.multilineTextAlignment(.center)

					Rectangle().fill(.text)
						.frame(height: 1)
						.padding(.horizontal, 80)

					HStack {
						Text(movie.releaseDate)
						Image(systemName: "star.fill").scaleEffect(0.5)
						Text(movie.voteAverage, format: .number.precision(.fractionLength(2)))
					}
					.font(.caption)

					Text(movie.overview)
						.font(.subheadline)
						.multilineTextAlignment(.center)
				}
				.foregroundStyle(.text)
				.padding(.horizontal, 16)
			}
		}
		.ignoresSafeArea(edges: .top)
	}

	private var backButton: some View {
		Button(
			action: {
				dismiss()
			},
			label: {
				Image(systemName: "arrow.backward.circle.fill")
					.resizable()
					.foregroundColor(.light)
					.shadow(color: .black, radius: 10, x: 0, y: 0)
					.frame(width: 40, height: 40)
			}
		)
		.frame(width: 48, height: 48)
		.padding(.leading, 16)
	}

	private var favoriteButton: some View {
		Button(
			action: {
				isFavourite.toggle()
				changeFavoriteAction()
			},
			label: {
				FavoriteIcon(isFavourite: isFavourite, size: 40)
			}
		)
		.frame(width: 48, height: 48)
		.padding(.trailing, 16)
	}
}
