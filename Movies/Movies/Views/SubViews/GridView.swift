//  GridView.swift
//  Created by Krzysztof Lech on 11/09/2024.

import SwiftUI

struct GridView: View {
	@EnvironmentObject var viewModel: MainViewModel

	private let spacing: CGFloat = 16
	private var itemWidth: CGFloat {
		(UIScreen.main.bounds.width - spacing * 3) / 2
	}

    var body: some View {
		ScrollView(.vertical) {
			LazyVGrid(
				columns: [GridItem(.fixed(itemWidth), spacing: spacing), GridItem(.fixed(itemWidth))],
				spacing: spacing,
				content: {
					ForEach(Array(viewModel.movies.enumerated()), id: \.offset) { index, movie in
						NavigationLink(
							destination: MovieDetailsView(
								movie: movie,
								changeFavoriteAction: {
									viewModel.favoriteChanged(atIndex: index)
								}
							),
							label: {
								ZStack(alignment: .topTrailing) {
									posterImage(index: index, movie: movie)
									favoriteIconButton(index: index, movie: movie)
								}
							}
						)
						.onAppear {
							viewModel.loadNextPageDataIfNeeded(atIndex: index)
						}
					}
				}
			)
			.padding(.horizontal, 16)

			if viewModel.showNextPageProgressView {
				ProgressView()
			}
		}
    }

	private func posterImage(index: Int, movie: Movie) -> some View {
		PosterImageView(
			imageUrl: movie.smallPosterUrl,
			title: movie.title,
			width: itemWidth,
			titleVisible: true
		)
		.cornerRadius(6)
		.shadow(color: .light.opacity(0.5), radius: 8, x: 0, y: 0)
		.overlay {
			RoundedRectangle(cornerRadius: 6)
				.stroke(.light.opacity(0.5), lineWidth: 1)
		}
	}

	private func favoriteIconButton(index: Int, movie: Movie) -> some View {
		Button(
			action: {
				viewModel.favoriteChanged(atIndex: index)
			},
			label: {
				FavoriteIcon(isFavourite: movie.favorite, size: 20)
			}
		)
		.frame(width: 48, height: 48)
	}
}
