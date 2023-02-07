//
//  Util.swift
//  MyGameApp
//
//  Created by Gregorius Yuristama Nugraha on 2/1/23.
//

import Foundation
import UIKit

class Util {
    static func startDownload(game: Game, indexPath: IndexPath, pendingOperation: PendingOperations, gameTableView: UITableView) {
        guard pendingOperation.downloadInProgress[indexPath] == nil else { return }
        let downloader = GameImageDownloader(game: game)
        downloader.completionBlock = {
            if downloader.isCancelled { return }
            DispatchQueue.main.async {
                pendingOperation.downloadInProgress.removeValue(forKey: indexPath)
                gameTableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        pendingOperation.downloadInProgress[indexPath] = downloader
        pendingOperation.downloadQueue.addOperation(downloader)
    }
    static func getGamesAF(completion: @escaping (Result<[Game], GameError>) -> Void) {
        NetworkService().getGamesAF { (result) in
          switch result {
          case .success(let response):
              completion(.success(gamesMapperUtil(input: response.games)))
          case .failure(let error):
              completion(.failure(error))
          }
        }
    }
    static func getDetailsAF(gameId: Int32, completion: @escaping (Result<String, GameError>) -> Void) {
        NetworkService().getGameDetailsAF(gameId: gameId) { (result) in
          switch result {
          case .success(let response):
              completion(.success(response.description ?? ""))
          case .failure(let error):
              completion(.failure(error))
          }
        }
    }
    static fileprivate func gamesMapperUtil(
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
