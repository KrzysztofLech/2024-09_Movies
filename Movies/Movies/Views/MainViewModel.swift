//  MainViewModel.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

final class MainViewModel: ObservableObject {

	private let dataService: DataServiceProtocol
	@MainActor @Published private(set) var isDataLoading: Bool = true
	@MainActor @Published private(set) var movies: [Movie] = []
	@MainActor @Published var showAlert: Bool = false

	init(dataService: DataServiceProtocol) {
		self.dataService = dataService
	}

	func fetchMoviesInCinemasData() async {
		do {
			let moviesData = try await dataService.getMoviesInCinemas()
			print("🙂", moviesData.movies.count)
			await MainActor.run {
				movies = moviesData.movies
				isDataLoading = false
			}
		} catch {
			if let error = error as? NetworkingError {
				print("❗️", error.errorDescription)
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

