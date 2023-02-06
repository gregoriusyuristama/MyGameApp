//
//  ImageDownloader.swift
//  MyGameApp
//
//  Created by Gregorius Yuristama Nugraha on 1/27/23.
//

import UIKit

class GameImageDownloader: Operation {
  private let game: Game
  init(game: Game) {
    self.game = game
  }
    override func main() {
        if isCancelled {
          return
        }
        guard let imageData = try? Data(contentsOf: self.game.image) else { return }
        if !imageData.isEmpty {
          self.game.imageDownload = UIImage(data: imageData)
          self.game.state = .downloaded
        } else {
          self.game.imageDownload = nil
          self.game.state = .failed
        }
    }
}

class PendingOperations {
  lazy var downloadInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
      var queue = OperationQueue()
      queue.name = "com.gregoriusYuristama.imagedownload"
      queue.maxConcurrentOperationCount = 2
      return queue
    }()
}
