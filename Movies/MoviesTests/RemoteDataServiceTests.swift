//  RemoteDataServiceTests.swift
//  Created by Krzysztof Lech on 13/09/2024.

import XCTest
@testable import Movies

class URLSessionMock: URLSessionProtocol {
	var data: Data?
	var response: URLResponse?
	var error: Error?

	func data(for request: URLRequest) async throws -> (Data, URLResponse) {
		if let error = error {
			throw error
		}

		guard let data = data, let response = response else {
			throw NetworkingError.invalidResponse
		}

		return (data, response)
	}
}

class RemoteDataServiceTests: XCTestCase {
	var remoteDataService: RemoteDataService!
	var urlSessionMock: URLSessionMock!

	override func setUpWithError() throws {
		urlSessionMock = URLSessionMock()
		remoteDataService = RemoteDataService(session: urlSessionMock) // Używamy mocka w testach
	}

	override func tearDownWithError() throws {
		remoteDataService = nil
		urlSessionMock = nil
	}

	func testGetMoviesData_Success() async throws {
		let jsonString = """
		{
			"page": 1,
			"results": [],
			"total_pages": 2,
			"total_results": 35
		}
		"""
		let jsonData = jsonString.data(using: .utf8)!

		urlSessionMock.data = jsonData
		urlSessionMock.response = HTTPURLResponse(
			url: URL(string: "https://example.com")!,
			statusCode: 200,
			httpVersion: nil,
			headerFields: nil
		)

		let moviesData = try await remoteDataService.getMoviesData(.nowInCinemas, language: .pl, region: .pl)

		XCTAssertEqual(moviesData.page, 1)
		XCTAssertTrue(remoteDataService.morePagesAvailable)
	}

	func testGetMoviesData_Failure_InvalidResponse() async throws {
		urlSessionMock.data = nil
		urlSessionMock.response = HTTPURLResponse(
			url: URL(string: "https://example.com")!,
			statusCode: 404,
			httpVersion: nil,
			headerFields: nil
		)

		do {
			_ = try await remoteDataService.getMoviesData(.nowInCinemas, language: .pl, region: .pl)
			XCTFail("Expected NetworkingError.invalidResponse")
		} catch let error as NetworkingError {
			XCTAssertEqual(error, NetworkingError.invalidResponse)
		}
	}

	func testGetMoviesData_Failure_InvalidJSON() async throws {
		let invalidJSONString = """
		{
			"page": 1,
			"totalPages": 2
		"""
		let jsonData = invalidJSONString.data(using: .utf8)!

		urlSessionMock.data = jsonData
		urlSessionMock.response = HTTPURLResponse(
			url: URL(string: "https://example.com")!,
			statusCode: 200,
			httpVersion: nil,
			headerFields: nil
		)

		do {
			_ = try await remoteDataService.getMoviesData(.nowInCinemas, language: .pl, region: .pl)
			XCTFail("Expected NetworkingError.parseJSON")
		} catch let error as NetworkingError {
			switch error {
			case .parseJSON:
				XCTAssertTrue(true, "Parse JSON error received")
			default:
				XCTFail("Expected Parse JSON error, but received: \(error)")
			}
		}
	}
}
