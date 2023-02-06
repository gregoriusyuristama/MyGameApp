//
//  NetworkService.swift
//  MyGameApp
//
//  Created by Gregorius Yuristama Nugraha on 1/28/23.
//

import Foundation

private var apiKey: String {
    return getApiKey()
}

private func getApiKey() -> String {
    guard let filePath = Bundle.main.path(forResource: "RAWG-Info", ofType: "plist") else {
      fatalError("Couldn't find file 'RAWG-Info.plist'.")
    }
    // 2
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "API_KEY") as? String else {
      fatalError("Couldn't find key 'API_KEY' in 'RAWG-Info.plist'.")
    }
    return value
}

class NetworkService {
  func getGames() async throws -> [Game] {
    var components = URLComponents(string: "https://api.rawg.io/api/games")!
    components.queryItems = [
      URLQueryItem(name: "key", value: apiKey)
    ]
    let request = URLRequest(url: components.url!)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      fatalError("Error: Can't fetching data.")
    }
    let decoder = JSONDecoder()
    let result = try decoder.decode(GameResponses.self, from: data)
    return gamesMapper(input: result.games)
  }
    func getGameDetails(gameId: String) async throws -> String {
        var components = URLComponents(string: "https://api.rawg.io/api/games/"+gameId)!
        components.queryItems = [
          URLQueryItem(name: "key", value: apiKey)
        ]
        let request = URLRequest(url: components.url!)
        let (data, response) =  try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("error")
        }
        let decoder = JSONDecoder()
        let result = try decoder.decode(GameDetail.self, from: data)
        return result.desc
    }
}
extension NetworkService {
  fileprivate func gamesMapper(
    input gameResponses: [GameResponse]
  ) -> [Game] {
    return gameResponses.map { result in
      return Game(
        title: result.title,
        image: result.backgroundImage,
        id: Int32(result.id),
        rank: result.rank,
        release: result.releaseDate,
        description: ""
      )
    }
  }
}
