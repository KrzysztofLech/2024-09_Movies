//  MainViewModelTests.swift
//  Created by Krzysztof Lech on 13/09/2024.

import XCTest
import Combine
@testable import Movies

class DataServiceMock: DataServiceProtocol {
	var moviesToReturn: Movies?
	var errorToThrow: Error?
	var morePagesAvailable: Bool = false
	var saveFavoriteMoviesHandler: (([Movie]) -> Void)?

	func getMoviesInCinemas() async throws -> Movies {
		if let error = errorToThrow {
			throw error
		}
		return moviesToReturn ?? Movies(page: 1, movies: [], totalPages: 1, totalResults: 1)
	}

	func searchMovie(withText text: String) async throws -> Movies {
		if let error = errorToThrow {
			throw error
		}
		return moviesToReturn ?? Movies(page: 1, movies: [], totalPages: 1, totalResults: 1)
	}

	func saveFavoriteMovies(_ movies: [Movie]) {
		saveFavoriteMoviesHandler?(movies)
	}
}

class MainViewModelTests: XCTestCase {
	var viewModel: MainViewModel!
	var dataServiceMock: DataServiceMock!
	var cancellables: Set<AnyCancellable>!

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
		dataServiceMock = DataServiceMock()
		viewModel = MainViewModel(dataService: dataServiceMock)
		cancellables = Set<AnyCancellable>()
	}

	override func tearDownWithError() throws {
		viewModel = nil
		dataServiceMock = nil
		cancellables = nil
	}

	func testFetchMoviesInCinemas_Success() async throws {
		let movies = [movie1]
		let moviesData = Movies(page: 1, movies: movies, totalPages: 1, totalResults: 1)
		dataServiceMock.moviesToReturn = moviesData

		await viewModel.fetchMoviesInCinemasData()

		XCTAssertEqual(viewModel.movies.count, 1)
		XCTAssertEqual(viewModel.movies.first?.title, "Movie 1")
		XCTAssertFalse(viewModel.isDataLoading)
		XCTAssertEqual(viewModel.navigationBarTitle, "Movies (1/1)")
	}

	func testFetchMoviesInCinemas_Failure() async throws {
		dataServiceMock.errorToThrow = NetworkingError.invalidResponse

		await viewModel.fetchMoviesInCinemasData()

		XCTAssertTrue(viewModel.showAlert)
		XCTAssertTrue(viewModel.isDataLoading)
	}

	func testSearchMovie_Success() async throws {
		let movies = [movie1]
		let moviesData = Movies(page: 1, movies: movies, totalPages: 1, totalResults: 1)
		dataServiceMock.moviesToReturn = moviesData

		let expectation = XCTestExpectation(description: "Search movies updated")

		viewModel.$searchMovies
			.dropFirst()
			.sink { movies in
				XCTAssertEqual(movies.count, 1)
				XCTAssertEqual(movies.first?.title, "Movie 1")
				expectation.fulfill()
			}
			.store(in: &cancellables)

		viewModel.searchText = "Movie"

		await fulfillment(of: [expectation], timeout: 1.0)
	}

	func testSearchMovie_Failure() async throws {
		dataServiceMock.errorToThrow = NetworkingError.invalidResponse
		viewModel.searchText = "Search Query"

		let expectation = XCTestExpectation(description: "Alert should be shown")

		viewModel.$showAlert
			.dropFirst()
			.sink { showAlert in
				XCTAssertTrue(showAlert)
				expectation.fulfill()
			}
			.store(in: &cancellables)

		await fulfillment(of: [expectation], timeout: 1.0)
	}

	func testOnTryAgain() async throws {
		let movies = [movie1]
		let moviesData = Movies(page: 1, movies: movies, totalPages: 1, totalResults: 1)
		dataServiceMock.moviesToReturn = moviesData

		let expectation = XCTestExpectation(description: "Movies should be fetched")

		viewModel.$movies
			.dropFirst()
			.sink { movies in
				XCTAssertEqual(movies.count, 1)
				XCTAssertEqual(movies.first?.title, "Movie 1")
				expectation.fulfill()
			}
			.store(in: &cancellables)

		viewModel.onTryAgain()

		await fulfillment(of: [expectation], timeout: 1.0)
	}

	func testLoadNextPageDataIfNeeded() async throws {
		let movies = [movie1, movie2]
		let moviesData = Movies(page: 1, movies: movies, totalPages: 2, totalResults: 1)
		dataServiceMock.moviesToReturn = moviesData

		let expectation = XCTestExpectation(description: "Movies should be fetched and next page loaded")

		viewModel.$movies
			.dropFirst()
			.sink { loadedMovies in
				XCTAssertEqual(loadedMovies.count, 2)
				XCTAssertEqual(loadedMovies.first?.title, "Movie 1")
				expectation.fulfill()
			}
			.store(in: &cancellables)

		await viewModel.fetchMoviesInCinemasData()

		viewModel.loadNextPageDataIfNeeded(atIndex: 1)

		await fulfillment(of: [expectation], timeout: 1.0)
	}

	func testFavoriteChanged() async throws {
		let movies = [movie1, movie2]
		let moviesData = Movies(page: 1, movies: movies, totalPages: 1, totalResults: 1)

		dataServiceMock.moviesToReturn = moviesData

		let expectation = XCTestExpectation(description: "Favorites should be saved")
		dataServiceMock.saveFavoriteMoviesHandler = { savedMovies in
			XCTAssertTrue(savedMovies.contains(where: { $0.id == 1 && $0.favorite == true }))
			expectation.fulfill()
		}

		await viewModel.fetchMoviesInCinemasData()

		viewModel.favoriteChanged(atIndex: 0)

		XCTAssertTrue(viewModel.movies[0].favorite)
		await fulfillment(of: [expectation], timeout: 1.0)
	}
}
