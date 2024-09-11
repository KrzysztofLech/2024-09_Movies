//  DataService.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

protocol DataServiceProtocol {
	var morePagesAvailable: Bool { get }
	func getMoviesInCinemas() async throws -> Movies
	func searchMovie(withText text: String) async throws -> Movies
	func saveFavoriteMovies(_ movies: [Movie])
}

final class DataService: DataServiceProtocol {

	private let remoteDataService: RemoteDataServiceProtocol
	private var localDataService: LocalDataServiceProtocol

	init(remoteDataService: RemoteDataServiceProtocol, localDataService: LocalDataServiceProtocol) {
		self.remoteDataService = remoteDataService
		self.localDataService = localDataService
	}

	var morePagesAvailable: Bool {
		remoteDataService.morePagesAvailable
	}

	func getMoviesInCinemas() async throws -> Movies {
		var moviesData = try await remoteDataService.getMoviesData(.nowInCinemas, language: .pl, region: .pl)

		let favoriteMovieIds = localDataService.favoriteMovieIds

		for index in 0..<moviesData.movies.count {
			if favoriteMovieIds.contains(moviesData.movies[index].id) {
				moviesData.movies[index].favorite = true
			}
		}

		return moviesData
	}

	func searchMovie(withText text: String) async throws -> Movies {
		let encodedString = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		return try await remoteDataService.getMoviesData(.search(encodedString), language: .pl, region: .pl)
	}

	func saveFavoriteMovies(_ movies: [Movie]) {
		let favoriteMovieIds = movies.filter { $0.favorite }.map { $0.id }
		localDataService.favoriteMovieIds = favoriteMovieIds
	}
}
