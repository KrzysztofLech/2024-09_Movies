//  MainViewModel.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

final class MainViewModel: ObservableObject {

	@MainActor @Published private(set) var isDataLoading: Bool = true
	@MainActor @Published var showAlert: Bool = false
	private(set) var movies: [Movie] = []
	
	private let dataService: DataServiceProtocol

	init(dataService: DataServiceProtocol) {
		self.dataService = dataService
	}

	var showNextPageProgressView: Bool {
		dataService.morePagesAvailable
	}

	func fetchMoviesInCinemasData() async {
		guard dataService.morePagesAvailable else { return }

		do {
			let moviesData = try await dataService.getMoviesInCinemas()
			Logger.log(okText: "Downloaded \(moviesData.movies.count) 'Movies in cinemas'")

			await MainActor.run {
				movies.append(contentsOf: moviesData.movies)
				isDataLoading = false
			}
		} catch {
			if let error = error as? NetworkingError {
				Logger.log(error: error.errorDescription)
				await MainActor.run { showAlert = true }
			}
		}
	}

	func onTryAgain() {
		Task {
			await fetchMoviesInCinemasData()
		}
	}
}

