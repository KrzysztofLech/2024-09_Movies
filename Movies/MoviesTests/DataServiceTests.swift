//  DataServiceTests.swift
//  Created by Krzysztof Lech on 13/09/2024.

import XCTest
@testable import Movies

class RemoteDataServiceMock: RemoteDataServiceProtocol {
	var morePagesAvailable: Bool = true
	var moviesDataToReturn: Movies?
	var errorToThrow: Error?

	func getMoviesData(_ dataType: MoviesDataType, language: Language, region: Region) async throws -> Movies {
		if let error = errorToThrow {
			throw error
		}
		return moviesDataToReturn ?? Movies(page: 1, movies: [], totalPages: 1, totalResults: 0)
	}
}

class LocalDataServiceMock: LocalDataServiceProtocol {
	var favoriteMovieIds: [Int] = []
}

class DataServiceTests: XCTestCase {
	var dataService: DataService!
	var remoteDataServiceMock: RemoteDataServiceMock!
	var localDataServiceMock: LocalDataServiceMock!

	let movie1 = Movie(
		id: 1,
		title: "Movie 1",
		overview: "",
		posterPath: nil,
		backdropPath: nil,
		originalTitle: "",
		releaseDate: "",
		voteAverage: 5,
		favorite: false
	)

	let movie2 = Movie(
		id: 2,
		title: "Movie 2",
		overview: "",
		posterPath: nil,
		backdropPath: nil,
		originalTitle: "",
		releaseDate: "",
		voteAverage: 4,
		favorite: false
	)

	override func setUpWithError() throws {
		remoteDataServiceMock = RemoteDataServiceMock()
		localDataServiceMock = LocalDataServiceMock()
		dataService = DataService(remoteDataService: remoteDataServiceMock, localDataService: localDataServiceMock)
	}

	override func tearDownWithError() throws {
		dataService = nil
		remoteDataServiceMock = nil
		localDataServiceMock = nil
	}

	func testGetMoviesInCinemas_WithFavorites() async throws {
		let movies = [movie1, movie2]
		let moviesData = Movies(page: 1, movies: movies, totalPages: 1, totalResults: 2)
		remoteDataServiceMock.moviesDataToReturn = moviesData
		localDataServiceMock.favoriteMovieIds = [1]

		let result = try await dataService.getMoviesInCinemas()

		XCTAssertEqual(result.movies.count, 2)
		XCTAssertTrue(result.movies[0].favorite, "Movie 1 should be marked as favorite")
		XCTAssertFalse(result.movies[1].favorite, "Movie 2 should not be marked as favorite")
	}

	func testGetMoviesInCinemas_NoFavorites() async throws {
		let movies = [movie1]
		let moviesData = Movies(page: 1, movies: movies, totalPages: 1, totalResults: 1)
		remoteDataServiceMock.moviesDataToReturn = moviesData
		localDataServiceMock.favoriteMovieIds = []

		let result = try await dataService.getMoviesInCinemas()

		XCTAssertEqual(result.movies.count, 1)
		XCTAssertFalse(result.movies[0].favorite, "Movie 1 should not be marked as favorite")
	}

	func testSearchMovie_Success() async throws {
		let movies = [movie1]
		let moviesData = Movies(page: 1, movies: movies, totalPages: 1, totalResults: 1)
		remoteDataServiceMock.moviesDataToReturn = moviesData

		let result = try await dataService.searchMovie(withText: "Movie 1")

		XCTAssertEqual(result.movies.count, 1)
		XCTAssertEqual(result.movies[0].title, "Movie 1")
	}

	func testSearchMovie_Failure() async throws {
		remoteDataServiceMock.errorToThrow = NetworkingError.invalidResponse

		do {
			_ = try await dataService.searchMovie(withText: "Search Query")
			XCTFail("Expected to throw an error but succeeded")
		} catch {
			XCTAssertEqual(error as? NetworkingError, NetworkingError.invalidResponse)
		}
	}

	func testSaveFavoriteMovies() {
		let movie3 = Movie(
			id: 3,
			title: "Movie 3",
			overview: "",
			posterPath: nil,
			backdropPath: nil,
			originalTitle: "",
			releaseDate: "",
			voteAverage: 2,
			favorite: true
		)

		let movies = [movie1, movie2, movie3]
		dataService.saveFavoriteMovies(movies)

		XCTAssertEqual(localDataServiceMock.favoriteMovieIds, [3], "Only Movie 3 should be saved as favorite")
	}
}
