//  MainView.swift
//  Created by Krzysztof Lech on 09/09/2024.

import SwiftUI

struct MainView: View {

	@ObservedObject var viewModel: MainViewModel

    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    MainView(viewModel: MainViewModel())
}
