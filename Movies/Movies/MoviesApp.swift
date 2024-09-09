//  MoviesApp.swift
//  Created by Krzysztof Lech on 09/09/2024.

import SwiftUI

@main
struct MoviesApp: App {
	var body: some Scene {
		WindowGroup {
			let mainViewModel = MainViewModel()
			MainView(viewModel: mainViewModel)
				.preferredColorScheme(.dark)
		}
	}
}
