//  Movies.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

struct Movies: Codable {
	private enum CodingKeys: String, CodingKey {
		case page
		case movies = "results"
		case totalPages = "total_pages"
		case totalResults = "total_results"
	}

	let page: Int
	let movies: [Movie]
	let totalPages: Int
	let totalResults: Int
}
