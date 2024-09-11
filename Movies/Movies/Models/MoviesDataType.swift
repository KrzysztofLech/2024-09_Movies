//  MoviesDataType.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

enum MoviesDataType {
	case nowInCinemas
	case search(String)

	var path: String {
		switch self {
		case .nowInCinemas:
			"https://api.themoviedb.org/3/movie/now_playing"
		case .search:
			"https://api.themoviedb.org/3/search/movie"
		}
	}
}
