//  RemoteDataService.swift
//  Created by Krzysztof Lech on 10/09/2024.

import Foundation

protocol URLSessionProtocol {
	func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

protocol RemoteDataServiceProtocol {
	var morePagesAvailable: Bool { get }
	func getMoviesData(_ dataType: MoviesDataType, language: Language, region: Region) async throws -> Movies
}

final class RemoteDataService: RemoteDataServiceProtocol {
	private let session: URLSessionProtocol
	private let token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3YjllODZmNzNkMzJhMmNkNTIwYjhjNzU3ZmU4N2MzYiIsInN1YiI6IjY0ZTFhMjUyNGE1MmY4MDEzYmQzZTUzNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.7-WFMTGY1C2Tq5XKMvMNVAwZF7U-JZkrgkZkM4qRf_A"
	private var currentPage = 0

	var morePagesAvailable: Bool = true

	init(session: URLSessionProtocol = URLSession.shared) {
		self.session = session
	}

	func getMoviesData(_ dataType: MoviesDataType, language: Language, region: Region) async throws -> Movies {
		guard let urlRequest = getUrlRequestFor(dataType, andLanguage: language, region: region) else {
			throw NetworkingError.invalidRequest
		}

		Logger.log(info: "Request: \(urlRequest)")

		guard
			let (data, response) = try? await session.data(for: urlRequest),
			let httpResponse = response as? HTTPURLResponse,
			httpResponse.statusCode == 200
		else {
			throw NetworkingError.invalidResponse
		}

		do {
			let movies = try JSONDecoder().decode(Movies.self, from: data)
			currentPage = movies.page
			morePagesAvailable = currentPage < movies.totalPages
			return movies
		} catch {
			if let decodingError = error as? DecodingError {
				throw NetworkingError.parseJSON(decodingError)
			}
			throw NetworkingError.unknown(error)
		}
	}

	private func getUrlRequestFor(_ dataType: MoviesDataType, andLanguage language: Language, region: Region) -> URLRequest? {
		var urlComponents = URLComponents(string: dataType.path)

		switch dataType {
		case .nowInCinemas:
			urlComponents?.queryItems = [
				URLQueryItem(name: "language", value: language.code),
				URLQueryItem(name: "region", value: region.code),
				URLQueryItem(name: "page", value: String(currentPage + 1)),
			]

		case .search(let text):
			urlComponents?.queryItems = [
				URLQueryItem(name: "query", value: text),
				URLQueryItem(name: "language", value: language.code)
			]
		}

		guard let url = urlComponents?.url else { return nil }

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
