//  MainViewModel.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

final class MainViewModel: ObservableObject {

	@MainActor @Published private(set) var isDataLoading: Bool = true
	@MainActor @Published var showAlert: Bool = false

	private let dataService: DataServiceProtocol
	private(set) var movies: [Movie] = []

	init(dataService: DataServiceProtocol) {
		self.dataService = dataService
	}

	func fetchMoviesInCinemasData() async {
		do {
			let moviesData = try await dataService.getMoviesInCinemas()
			print("🙂", moviesData.movies.count)	//////// usunąć
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

