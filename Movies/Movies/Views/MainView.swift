//  MainView.swift
//  Created by Krzysztof Lech on 09/09/2024.

import SwiftUI

struct MainView: View {
	@ObservedObject private var viewModel: MainViewModel

	init(viewModel: MainViewModel) {
		self.viewModel = viewModel
	}

	private let spacing: CGFloat = 16
	private lazy var itemWidth: CGFloat = {
		(UIScreen.main.bounds.width - spacing * 3) / 2
	}()

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
			.navigationTitle(Strings.navigationBarTitle)
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

	private var contentView: some View {
		let inset: CGFloat = 16
		let itemWidth = (UIScreen.main.bounds.width - inset * 3) / 2

		return ScrollView(.vertical) {
			LazyVGrid(
				columns: [GridItem(.fixed(itemWidth), spacing: spacing), GridItem(.fixed(itemWidth))],
				spacing: spacing,
				content: {
					ForEach(Array(viewModel.movies.enumerated()), id: \.offset) { index, movie in
						NavigationLink(
							destination: MovieDetailsView(movie: movie),
							label: {
								PosterImageView(
									imageUrl: movie.smallPosterUrl,
									title: movie.title,
									width: itemWidth
								)
								.cornerRadius(6)
								.shadow(color: .light.opacity(0.5), radius: 8, x: 0, y: 0)
								.overlay {
									RoundedRectangle(cornerRadius: 6)
										.stroke(.light.opacity(0.5), lineWidth: 1)
								}

								.onAppear {
									if index == viewModel.movies.count - 1 {
										Task {
											await viewModel.fetchMoviesInCinemasData()
										}
									}
								}
							}
						)
					}
				}
			)
			.padding(.horizontal, 16)

			if viewModel.showNextPageProgressView {
				ProgressView()
			}
		}
	}
}

#Preview {
	MainView(viewModel: MainViewModel(dataService: DataService()))
		.preferredColorScheme(.dark)
}
