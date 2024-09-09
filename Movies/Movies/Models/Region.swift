//  Region.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

enum Region {
	case pl, us

	var code: String {
		switch self {
		case .pl: "PL"
		case .us: "US"
		}
	}
}
