//  Movie.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

struct Movie: Codable, Identifiable {
	private enum CodingKeys: String, CodingKey {
		case id
		case title
		case overview
		case posterPath = "poster_path"
		case backdropPath = "backdrop_path"
		case originalTitle = "original_title"
		case releaseDate = "release_date"
		case voteAverage = "vote_average"
	}

	let id: Int
	let title: String
	let overview: String
	private let posterPath: String?
	private let backdropPath: String?
	let originalTitle: String
	let releaseDate: String
	let voteAverage: Double

	var favorite: Bool = false

	init(
		id: Int,
		title: String,
		overview: String,
		posterPath: String?,
		backdropPath: String?,
		originalTitle: String,
		releaseDate: String,
		voteAverage: Double,
		favorite: Bool
	) {
		self.id = id
		self.title = title
		self.overview = overview
		self.posterPath = posterPath
		self.backdropPath = backdropPath
		self.originalTitle = originalTitle
		self.releaseDate = releaseDate
		self.voteAverage = voteAverage
		self.favorite = favorite
	}
}

extension Movie {
	var smallPosterUrl: URL? {
		guard let posterPath else { return nil }
		let urlsString = "https://image.tmdb.org/t/p/w200\(posterPath)"
		return URL(string: urlsString)
	}

	var largePosterUrl: URL? {
		guard let posterPath else { return nil }
		let urlsString = "https://image.tmdb.org/t/p/w500\(posterPath)"
		return URL(string: urlsString)
	}
}
