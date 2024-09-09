//  DataLoadingView.swift
//  Created by Krzysztof Lech on 09/09/2024.

import SwiftUI

struct DataLoadingView: View {
	var body: some View {
		ProgressView {
			Text(Strings.progressViewLabel)
		}
		.scaleEffect(1.2)
		.tint(.accent)
		.foregroundColor(.accent)
	}
}

#Preview {
	DataLoadingView()
}
