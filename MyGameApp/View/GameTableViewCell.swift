//
//  GameTableViewCell.swift
//  MyGameApp
//
//  Created by Gregorius Yuristama Nugraha on 1/27/23.
//

import UIKit

class GameTableViewCell: UITableViewCell {

    @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameRelease: UILabel!
    @IBOutlet weak var gameRank: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
