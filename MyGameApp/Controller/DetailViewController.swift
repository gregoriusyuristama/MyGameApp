//
//  DetailViewController.swift
//  MyGameApp
//
//  Created by Gregorius Yuristama Nugraha on 1/27/23.
//

import UIKit

class DetailViewController: UIViewController {
    private lazy var gameProvider: GameProvider = { return GameProvider() }()
    var game: Game?
    private var gameDescription: String = ""
    private var isFavorite = false
    private var gameId: Int32?

    @IBOutlet weak var gameDesc: UITextView!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
    private lazy var favorite: UIBarButtonItem = {
        let btn = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(self.onButtonFavClicked))
        return btn
    }()
    private lazy var favoriteFill: UIBarButtonItem = {
        let btn = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(self.onButtonFavClicked))
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let result = game {
            gameTitle.text = result.title
            gameImage.image = result.imageDownload
            gameId = result.id
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        isGameFavorited()
            indicatorLoading.isHidden = false
            indicatorLoading.startAnimating()
        loadGame(gameId: gameId!) { (result) in
            switch result {
            case .success(let game):
                self.gameDesc.text = game.description?.htmlToString
                self.indicatorLoading.stopAnimating()
                self.indicatorLoading.isHidden = true
            case .failure(let error):
                    print("Error on: \(error.localizedDescription)")
            }
        }
    }
    func loadGame(gameId: Int32, completion: @escaping (Result<GameResponse, GameError>) -> Void) {
        NetworkService().getGameDetailsAF(gameId: gameId) { (result) in
            switch result {
            case .success(let game):
                completion(.success(game))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    @objc private func onButtonFavClicked() {
        if isFavorite {
            guard let id = gameId else { return }
            deleteFavorite(id)
        } else {
            addFavorite()
        }
        isFavorite = !isFavorite
        setIconFavorite()
    }

//    private func getDetails(gameId: String) async {
//        let network = NetworkService()
//        do {
//            gameDescription = try await network.getGameDetails(gameId: gameId)
//            gameDesc.text = gameDescription.htmlToString
//        } catch {
//            fatalError("Connection Failed")
//        }
//    }
    private func addFavorite() {
        let id = gameId
        let title = game!.title
        let gameDesc = gameDesc.text!
        let gameImage = game!.image.absoluteString
        let rank = game!.rank
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let releaseDate = game!.release
        gameProvider.saveGameToFavourite(id!, title, rank, releaseDate, gameImage, gameDesc
        ) {
        }
    }
    private func deleteFavorite (_ id: Int32) {
        gameProvider.deleteFavouriteGame(id) {
        }
    }
    private func setIconFavorite() {
        if isFavorite {
            navigationItem.rightBarButtonItem = favoriteFill
        } else {
            navigationItem.rightBarButtonItem = favorite
        }
    }

    private func isGameFavorited() {
        guard let id = gameId else { return }
        gameProvider.isGameFavorited(id) { (isGameAsFavorite) in
            self.isFavorite = isGameAsFavorite
            DispatchQueue.main.async { self.setIconFavorite() }
        }
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
