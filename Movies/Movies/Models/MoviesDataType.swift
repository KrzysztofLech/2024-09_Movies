//  MoviesDataType.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

enum MoviesDataType {
	case nowInCinemas

	var path: String {
		switch self {
		case .nowInCinemas:
			"https://api.themoviedb.org/3/movie/now_playing"
		}
	}
}
