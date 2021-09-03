//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				if response.statusCode != 200 {
					completion(.failure(Error.invalidData))
				} else {
					let decoder = JSONDecoder()
					do {
						let root = try decoder.decode(Root.self, from: data)
						completion(.success(root.feedImages))
					} catch {
						completion(.failure(Error.invalidData))
					}
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct Root: Decodable {
	let items: [Item]

	var feedImages: [FeedImage] {
		items.map { $0.feedImage }
	}
}

private struct Item: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let url: URL

	private enum CodingKeys: String, CodingKey {
		case id = "image_id"
		case description = "image_desc"
		case location = "image_loc"
		case url = "image_url"
	}

	var feedImage: FeedImage {
		FeedImage(id: id, description: description, location: location, url: url)
	}
}
