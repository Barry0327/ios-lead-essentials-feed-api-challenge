//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Chen Yi-Wei on 2021/9/3.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedImagesMapper {
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

	private static var validCode: Int { 200 }

	static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == validCode,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.feedImages)
	}
}
