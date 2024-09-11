//  MainViewModel.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Combine
import Foundation

final class MainViewModel: ObservableObject {

	private let dataService: DataServiceProtocol
	private var cancellables = Set<AnyCancellable>()
	private var allMoviesCount: Int = 0

	@Published private(set) var isDataLoading: Bool = true
	@Published var showAlert: Bool = false
	@Published private(set) var movies: [Movie] = []

	@Published var searchText = ""
	@Published private(set) var isSearchActive = false
	@Published private(set) var searchMovies: [Movie] = []

	var navigationBarTitle: String {
		var title = Strings.navigationBarTitle
		if allMoviesCount > 0 {
			title += String(format: " (%i/%i)", movies.count, allMoviesCount)
		}
		return title
	}

	var showNextPageProgressView: Bool {
		dataService.morePagesAvailable
	}

	init(dataService: DataServiceProtocol) {
		self.dataService = dataService

		setupSearch()
	}

	private func setupSearch() {
		$searchText
			.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
			.sink { text in
				self.isSearchActive = !text.isEmpty
				self.searchMovie(withText: text)
			}
			.store(in: &cancellables)
	}

	func fetchMoviesInCinemasData() async {
		do {
			let moviesData = try await dataService.getMoviesInCinemas()
			Logger.log(okText: "Downloaded \(moviesData.movies.count) 'Movies in cinemas'")

			await MainActor.run {
				movies.append(contentsOf: moviesData.movies)
				allMoviesCount = moviesData.totalResults
				isDataLoading = false
			}
		} catch {
			if let error = error as? NetworkingError {
				Logger.log(error: error.errorDescription)
				await MainActor.run { showAlert = true }
			}
		}
	}

	private func searchMovie(withText text: String) {
		guard !text.isEmpty else {
			searchMovies = []
			return
		}

		Task {
			do {
				let moviesData = try await dataService.searchMovie(withText: text)
				Logger.log(okText: "Searched \(moviesData.movies.count) movies")
				await MainActor.run {
					searchMovies = moviesData.movies
				}
			} catch {
				if let error = error as? NetworkingError {
					Logger.log(error: error.errorDescription)
					await MainActor.run { showAlert = true }
				}
			}
		}
	}

	func onTryAgain() {
		Task {
			await fetchMoviesInCinemasData()
		}
	}

	func loadNextPageDataIfNeeded(atIndex index: Int) {
		guard
			index == movies.count - 1,
			dataService.morePagesAvailable
		else { return }

		Task {
			await fetchMoviesInCinemasData()
		}
	}

	func favoriteChanged(atIndex index: Int) {
		movies[index].favorite.toggle()
		dataService.saveFavoriteMovies(movies)
	}
}

