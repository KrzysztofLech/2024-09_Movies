//  MoviesApp.swift
//  Created by Krzysztof Lech on 09/09/2024.

import SwiftUI

@main
struct MoviesApp: App {
	var body: some Scene {
		WindowGroup {
			let dataService = DataService()
			let mainViewModel = MainViewModel(dataService: dataService)
			MainView(viewModel: mainViewModel)
				.preferredColorScheme(.dark)
		}
	}
}
