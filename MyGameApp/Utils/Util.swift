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

    static func getGames() async -> [Game] {
        let network = NetworkService()
        do {
            return try await network.getGames()
        } catch {
            fatalError("Connecction Failed")
        }
    }
    static func getDetails(gameId: String) async -> String {
        let network = NetworkService()
        do {
            let gameDescription = try await network.getGameDetails(gameId: gameId)
            return gameDescription.htmlToString
        } catch {
            fatalError("Connection Failed")
        }
    }
}
