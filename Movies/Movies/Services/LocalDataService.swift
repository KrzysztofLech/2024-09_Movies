//  LocalDataService.swift
//  Created by Krzysztof Lech on 10/09/2024.

import Foundation

protocol LocalDataServiceProtocol {
	var favoriteMovieIds: [Int] { get set }
}

struct LocalDataService: LocalDataServiceProtocol {

	private let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("favorites.txt")

	var favoriteMovieIds: [Int] {
		get {
			do {
				let data = try Data(contentsOf: fileURL)
				let savedIds = (try JSONSerialization.jsonObject(with: data, options: []) as? [Int]) ?? []
				Logger.log(okText: "Favorite movie IDs read! \(savedIds.count) items")
				return savedIds
			} catch {
				Logger.log(error: "Error loading favorite movie IDs: \(error)")
				return []
			}
		}
		set {
			do {
				let data = try JSONSerialization.data(withJSONObject: newValue, options: [])
				try data.write(to: fileURL)
				Logger.log(okText: "Favorite movie IDs saved! \(newValue.count) items")
			} catch {
				Logger.log(error: "Error saving favorite movie IDs: \(error)")
			}
		}
	}
}
