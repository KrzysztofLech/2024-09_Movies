//  DataService.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

protocol DataServiceProtocol {
	var morePagesAvailable: Bool { get }
	func getMoviesInCinemas() async throws -> Movies
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
//		var moviesData = try await remoteDataService.getMoviesData(.nowInCinemas, language: .us, region: .us)

		let favoriteMovieIds = localDataService.favoriteMovieIds

		for index in 0..<moviesData.movies.count {
			if favoriteMovieIds.contains(moviesData.movies[index].id) {
				moviesData.movies[index].favorite = true
			}
		}

		return moviesData
	}

	func saveFavoriteMovies(_ movies: [Movie]) {
		let favoriteMovieIds = movies.filter { $0.favorite }.map { $0.id }
		localDataService.favoriteMovieIds = favoriteMovieIds
	}
}
