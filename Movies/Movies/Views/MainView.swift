//  MainView.swift
//  Created by Krzysztof Lech on 09/09/2024.

import SwiftUI

struct MainView: View {
	@ObservedObject var viewModel: MainViewModel

	var body: some View {
		NavigationView {
			ZStack {
				Color.background.ignoresSafeArea()

				if viewModel.isDataLoading {
					DataLoadingView()
				} else {
					contentView
				}
			}
			.navigationTitle(viewModel.navigationBarTitle)
			.searchable(text: $viewModel.searchText, prompt: Strings.searchPrompt)
		}

		.task {
			await viewModel.fetchMoviesInCinemasData()
		}

		.alert(Strings.Alert.title, isPresented: $viewModel.showAlert) {
			Button(Strings.Alert.buttonTitle, role: .cancel) {
				viewModel.onTryAgain()
			}
		}
	}

	@ViewBuilder private var contentView: some View {
		if viewModel.isSearchActive {
			SearchList(movies: viewModel.searchMovies)
		} else {
			GridView()
				.environmentObject(viewModel)
		}
	}
}

#Preview {
	MainView(
		viewModel: MainViewModel(
			dataService: DataService(
				remoteDataService: RemoteDataService(),
				localDataService: LocalDataService()
			)
		)
	)
	.preferredColorScheme(.dark)
}
