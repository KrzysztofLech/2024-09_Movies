//  Language.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

enum Language {
	case pl, us

	var code: String {
		switch self {
		case .pl: "pl-PL"
		case .us: "en-US"
		}
	}
}
