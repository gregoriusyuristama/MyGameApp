//
//  NetworkService.swift
//  MyGameApp
//
//  Created by Gregorius Yuristama Nugraha on 1/28/23.
//

import Foundation
import Alamofire

private var apiKey: String {
    return getApiKey()
}

enum GameError: Error, CustomNSError {
    case networkError
    case apiError
    case decodingError
    var localizedDescription: String {
        switch self {
        case .apiError: return "Failed to fetch data"
        case .networkError: return "No internet connection"
        case .decodingError: return "Failed to decode data"
        }
    }
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
    private let baseAPIURL = "https://api.rawg.io/api"
    let jsonDecoder = JSONDecoder()

    func getGamesAF(completion: @escaping(Swift.Result<GameResponses, GameError>) -> Void) {
        AF.request("\(baseAPIURL)/games?key=\(apiKey)").validate().responseJSON { json in
            switch json.result {
            case.failure:
                completion(.failure(.apiError))
            case .success(let jsonData):
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonData, options: .sortedKeys) {
                    do {
                        let decodeData = try  self.jsonDecoder.decode(GameResponses.self, from: jsonData)
                        completion(.success(decodeData))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                } else {
                    completion(.failure(.networkError))
                }
            }
        }
    }
//    func getGameDetails(gameId: String) async throws -> String {
//        var components = URLComponents(string: "https://api.rawg.io/api/games/"+gameId)!
//        components.queryItems = [
//          URLQueryItem(name: "key", value: apiKey)
//        ]
//        let request = URLRequest(url: components.url!)
//        let (data, response) =  try await URLSession.shared.data(for: request)
//        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
//            fatalError("error")
//        }
//        let decoder = JSONDecoder()
//        let result = try decoder.decode(GameDetail.self, from: data)
//        return result.desc
//    }
    func getGameDetailsAF(gameId: Int32, completion: @escaping (Swift.Result<GameResponse, GameError>) -> Void) {
        AF.request("\(baseAPIURL)/games/\(gameId)?key=\(apiKey)").validate().responseJSON { json in
            switch json.result {
            case.failure:
                completion(.failure(.apiError))
            case .success(let jsonData):
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonData, options: .sortedKeys) {
                    do {
                        let decodeData = try  self.jsonDecoder.decode(GameResponse.self, from: jsonData)
                        completion(.success(decodeData))
                    } catch {
                        completion(.failure(.decodingError))
                    }
                } else {
                    completion(.failure(.networkError))
                }
            }
        }
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
        release: result.releaseDate, description: ""
//        description: result.description ?? ""
      )
    }
  }
}
