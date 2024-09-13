//  NetworkingError.swift
//  Created by Krzysztof Lech on 09/09/2024.

import Foundation

enum NetworkingError: LocalizedError, Equatable {
	case noData
	case invalidRequest
	case invalidResponse
	case parseJSON(DecodingError)
	case api(statusCode: Int, message: String?)
	case unknown(Error)

	var errorDescription: String {
		switch self {
		case .noData:
			return "No Data!"

		case .invalidRequest:
			return "Invalid Request"

		case .invalidResponse:
			return "Invalid Response"

		case let .parseJSON(error):
			var errorContext: DecodingError.Context?
			switch error {
			case .dataCorrupted(let context):
				errorContext = context
			case .keyNotFound(_, let context):
				errorContext = context
			case .typeMismatch(_, let context):
				errorContext = context
			case .valueNotFound(_, let context):
				errorContext = context
			default: ()
			}

			guard let errorContext else { return "Data parsing error!" }

			let codingPath = String(describing: errorContext.codingPath)
			let debugDescription = String(describing: errorContext.debugDescription)
			return "Data parsing error!\ncodingPath: \(codingPath)\ndescription \(debugDescription)"

		case let .api(statusCode, message):
			guard let message = message, !message.isEmpty else {
				return "API problem, status code: \(statusCode)"
			}
			return "\(message), status code: \(statusCode)"

		case let .unknown(error):
			return error.localizedDescription
		}
	}

	static func == (lhs: NetworkingError, rhs: NetworkingError) -> Bool {
		switch (lhs, rhs) {
		case (.noData, .noData):
			return true
		case (.invalidRequest, .invalidRequest):
			return true
		case (.invalidResponse, .invalidResponse):
			return true
		case (.parseJSON(let lhsError), .parseJSON(let rhsError)):
			return lhsError.localizedDescription == rhsError.localizedDescription
		case (.api(let lhsStatusCode, let lhsMessage), .api(let rhsStatusCode, let rhsMessage)):
			return lhsStatusCode == rhsStatusCode && lhsMessage == rhsMessage
		case (.unknown(let lhsError), .unknown(let rhsError)):
			return (lhsError as NSError).domain == (rhsError as NSError).domain && (lhsError as NSError).code == (rhsError as NSError).code
		default:
			return false
		}
	}
}
