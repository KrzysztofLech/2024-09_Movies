//  Logger.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

struct Logger {

	static func log(info: String) {
		#if !DEBUG
			return
		#endif

		let prefix = "ℹ️"
		print(prefix, info)
	}

	static func log(okText: String) {
		#if !DEBUG
			return
		#endif

		let prefix = "👍"
		print(prefix, okText)
	}

	static func log(error: String) {
		#if !DEBUG
			return
		#endif

		let prefix = "‼️"
		print(prefix, error)
	}
}
