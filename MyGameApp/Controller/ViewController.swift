//
//  ViewController.swift
//  MyGameApp
//
//  Created by Gregorius Yuristama Nugraha on 1/27/23.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    private let pendingOperations = PendingOperations()
    private var games: [Game] = []
    @IBOutlet weak var gameTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        gameTableView.dataSource = self
        gameTableView.delegate = self
        gameTableView.register(UINib(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier: "gameTableViewCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
//            games = await Util.getGames()
//            gameTableView.reloadData()
            Util.getGamesAF { [weak self] (result) in
                switch result {
                case .success(let data):
                        self?.games = data
                        self?.gameTableView.reloadData()
                        self?.gameTableView.isHidden = false
                case .failure(let error):
                        print("Error on: \(error.localizedDescription)")
                }
            }
        }
    }

    fileprivate func startOperations(game: Game, indexPath: IndexPath) {
        if game.state == .new {
            Util.startDownload(game: game, indexPath: indexPath, pendingOperation: pendingOperations, gameTableView: gameTableView)
        }
    }
    private func refreshImage(indexPath: IndexPath) {
            self.gameTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    fileprivate func toggleSuspendOperations(isSuspended: Bool) {
      pendingOperations.downloadQueue.isSuspended = isSuspended
    }
}

extension ViewController: UITableViewDataSource {
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

extension ViewController: UITableViewDelegate {
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

extension ViewController: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    toggleSuspendOperations(isSuspended: true)
  }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      toggleSuspendOperations(isSuspended: false)
    }
}
