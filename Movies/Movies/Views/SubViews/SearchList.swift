//  SearchList.swift
//  Created by Krzysztof Lech on 11/09/2024.

import SwiftUI

struct SearchList: View {
	let movies: [Movie]

    var body: some View {
		List(movies) { movie in
			NavigationLink(
				destination: MovieDetailsView(
					movie: movie,
					changeFavoriteAction: nil
				),
				label: {
					HStack(alignment: .center, spacing: 16) {
						PosterImageView(
							imageUrl: movie.smallPosterUrl,
							title: movie.title,
							width: 50,
							titleVisible: false
						)
						.frame(minHeight: 75)
						.overlay {
							Rectangle()
								.stroke(.light.opacity(0.5), lineWidth: 1)
						}

						VStack(alignment: .leading, spacing: 6) {
							Text(movie.title)
								.foregroundStyle(.text)
								.font(.system(size: 14, weight: .regular))
								.multilineTextAlignment(.leading)
								.lineLimit(2)

							Text(movie.releaseDate.prefix(4))
								.foregroundStyle(.text).opacity(0.5)
								.font(.system(size: 10, weight: .bold))
						}
					}
				}
			)
		}
		.listStyle(.plain)
    }
}
