//
//  GameModel.swift
//  MyGameApp
//
//  Created by Gregorius Yuristama Nugraha on 1/27/23.
//

import UIKit

enum DownloadState {
  case new, downloaded, failed
}

class Game {
    let title: String
    let image: URL
    let id: Int32
    let rank: Double
    let release: Date
    var imageDownload: UIImage?
    var state: DownloadState = .new
    init(
        title: String,
        image: URL,
        id: Int32,
        rank: Double,
        release: Date,
        description: String
    ) {
        self.title = title
        self.image = image
        self.id = id
        self.rank = rank
        self.release = release
  }
}

struct GameResponses: Codable {
  let count: Int
  let next: String
  let games: [GameResponse]
  enum CodingKeys: String, CodingKey {
    case count
    case next
    case games = "results"
  }
}

struct GameResponse: Codable {
    let id: Int
    let title: String
    let backgroundImage: URL
    let rank: Double
    let releaseDate: Date
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case backgroundImage = "background_image"
        case rank = "rating"
        case releaseDate = "released"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        backgroundImage = try container.decode(URL.self, forKey: .backgroundImage)
        rank = try container.decode(Double.self, forKey: .rank)
        // MARK: Menentukan tanggal rilis.
        let dateString = try container.decode(String.self, forKey: .releaseDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        releaseDate = dateFormatter.date(from: dateString)!
    }
}

struct GameDetail: Codable {
    let desc: String
    enum CodingKeys: String, CodingKey {
        case desc = "description"
    }
    init(
    desc: String
    ) {
        self.desc = desc
    }
}
