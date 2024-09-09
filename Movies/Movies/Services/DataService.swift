//  DataService.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

protocol DataServiceProtocol {
	func getMoviesInCinemas() async throws -> Movies
}

final class DataService: DataServiceProtocol {
	private let token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3YjllODZmNzNkMzJhMmNkNTIwYjhjNzU3ZmU4N2MzYiIsInN1YiI6IjY0ZTFhMjUyNGE1MmY4MDEzYmQzZTUzNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.7-WFMTGY1C2Tq5XKMvMNVAwZF7U-JZkrgkZkM4qRf_A"

	func getMoviesInCinemas() async throws -> Movies {
		try await getMoviesData(.nowInCinemas, language: .pl, region: .pl)
	}

	private func getMoviesData(_ dataType: MoviesDataType, language: Language, region: Region) async throws -> Movies {
		guard let urlRequest = getUrlRequestFor(dataType, andLanguage: language, region: region) else {
			throw NetworkingError.invalidRequest
		}

		let session = URLSession.shared
		guard
			let (data, response) = try? await session.data(for: urlRequest),
			let httpResponse = response as? HTTPURLResponse,
			httpResponse.statusCode == 200
		else {
			throw NetworkingError.invalidResponse
		}

		do {
			return try JSONDecoder().decode(Movies.self, from: data)
		} catch {
			if let decodingError = error as? DecodingError {
				throw NetworkingError.parseJSON(decodingError)
			}
			throw NetworkingError.unknown(error)
		}
	}

	private func getUrlRequestFor(_ dataType: MoviesDataType, andLanguage language: Language, region: Region) -> URLRequest? {
		let fullUrlString = dataType.path + "?language=\(language.code)&region=\(region)&page=1"			//// page !!!!
		guard let url = URL(string: fullUrlString) else { return nil }

		let headers = [
			"accept": "application/json",
			"Authorization": "Bearer \(token)"
		]

		var urlRequest = URLRequest(
			url: url,
			cachePolicy: .useProtocolCachePolicy,
			timeoutInterval: 10.0
		)
		urlRequest.httpMethod = "GET"
		urlRequest.allHTTPHeaderFields = headers

		return urlRequest
	}
}

