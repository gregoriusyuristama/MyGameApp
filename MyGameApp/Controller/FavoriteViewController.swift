//
//  FavoriteViewController.swift
//  MyGameApp
//
//  Created by Gregorius Yuristama Nugraha on 1/30/23.
//

import UIKit

class FavoriteViewController: UIViewController {

    private let pendingOperations = PendingOperations()
    @IBOutlet weak var favoriteTableView: UITableView!
    private var games: [Game] = []
    private lazy var gameProvider: GameProvider = { return GameProvider() }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        favoriteTableView.dataSource = self
        favoriteTableView.delegate = self
        favoriteTableView.register(
            UINib(nibName: "GameTableViewCell"
                  , bundle: nil)
            , forCellReuseIdentifier: "gameTableViewCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGames()
    }
    private func loadGames() {
        self.gameProvider.getAllGames { result in
            DispatchQueue.main.async {
                self.games = result
                self.favoriteTableView.reloadData()
                if self.games.isEmpty {
                    let alert = UIAlertController(title: "Empty List", message: "No Favorite added yet", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                      self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    private func setupView() {
        favoriteTableView.delegate = self
        favoriteTableView.delegate = self
    }
    fileprivate func startOperations(game: Game, indexPath: IndexPath) {
        if game.state == .new {
            Util.startDownload(game: game, indexPath: indexPath, pendingOperation: pendingOperations, gameTableView: favoriteTableView)
        }
    }
    fileprivate func toggleSuspendOperations(isSuspended: Bool) {
      pendingOperations.downloadQueue.isSuspended = isSuspended
    }
}

extension FavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        games.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "gameTableViewCell", for: indexPath
        ) as? GameTableViewCell {
            let game = games[indexPath.row]
            cell.gameTitle.text = game.title
            cell.gameRank.text = "Rating : "+String(game.rank)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            let releaseDate = dateFormatter.string(from: game.release)
            cell.gameRelease.text = "Release Date: "+releaseDate
            cell.gameImage.image = game.imageDownload
            if game.state == .new {
              cell.indicatorLoading.isHidden = false
              cell.indicatorLoading.startAnimating()
              startOperations(game: game, indexPath: indexPath)
            } else {
              cell.indicatorLoading.stopAnimating()
              cell.indicatorLoading.isHidden = true
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension FavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "moveToDetail", sender: games[indexPath.row])
    }
    override func prepare(
      for segue: UIStoryboardSegue,
      sender: Any?
    ) {
      if segue.identifier == "moveToDetail" {
        if let detaiViewController = segue.destination as? DetailViewController {
          detaiViewController.game = sender as? Game
        }
      }
    }
}

extension FavoriteViewController: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    toggleSuspendOperations(isSuspended: true)
  }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      toggleSuspendOperations(isSuspended: false)
    }
}
