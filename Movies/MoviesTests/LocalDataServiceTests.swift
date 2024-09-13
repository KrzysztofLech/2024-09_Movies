//  LocalDataServiceTests.swift
//  Created by Krzysztof Lech on 12/09/2024.

import XCTest
@testable import Movies

final class LocalDataServiceTests: XCTestCase {

	var tempFileURL: URL!
	var localDataService: LocalDataService!

    override func setUpWithError() throws {
		try super.setUpWithError()

		let tempDirectory = FileManager.default.temporaryDirectory
		tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString)

		localDataService = LocalDataService(fileURL: tempFileURL)
    }

    override func tearDownWithError() throws {
		try? FileManager.default.removeItem(at: tempFileURL)
		try super.tearDownWithError()
    }

	func testFavoriteMovieIdsInitiallyEmpty() throws {
		XCTAssertTrue(localDataService.favoriteMovieIds.isEmpty, "favoriteMovieIds should be empty!")
	}

	func testSaveFavoriteMovieIds() throws {
		let sampleIds = [1, 2, 3]
		let data = try JSONSerialization.data(withJSONObject: sampleIds, options: [])
		try data.write(to: tempFileURL)

		let retrievedMovieIds = localDataService.favoriteMovieIds
		XCTAssertEqual(retrievedMovieIds, sampleIds, "Retrieved and saved data should be the same!")
	}

	func testSaveAndRetrieveFavoriteMovieIds() throws {
		let movieIdsToSave = [101, 202, 303]

		localDataService.favoriteMovieIds = movieIdsToSave
		let retrievedMovieIds = localDataService.favoriteMovieIds

		XCTAssertEqual(retrievedMovieIds, movieIdsToSave, "Retrieved and saved data should be the same!")
	}

	func testOverwriteFavoriteMovieIds() throws {
		let initialMovieIds = [1, 2, 3]
		localDataService.favoriteMovieIds = initialMovieIds

		let newMovieIds = [4, 5, 6]
		localDataService.favoriteMovieIds = newMovieIds

		let retrievedMovieIds = localDataService.favoriteMovieIds
		XCTAssertEqual(retrievedMovieIds, newMovieIds, "The initial list should be overwritten!")
	}

	func testHandleCorruptedFile() throws {
		let corruptedData = "corrupted data".data(using: .utf8)!
		try corruptedData.write(to: tempFileURL)

		let retrievedMovieIds = localDataService.favoriteMovieIds

		XCTAssertTrue(retrievedMovieIds.isEmpty, "The list should be empty!")
	}
}
