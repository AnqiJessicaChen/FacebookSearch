//
//  AlbumCell.swift
//  FacebookSearch
//
//  Created by JessicaChen on 19/04/2017.
//  Copyright © 2017 JessicaChen. All rights reserved.
//

import UIKit

class AlbumCell: UITableViewCell {
    
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var albumImage1: UIImageView!
    @IBOutlet weak var albumImage2: UIImageView!
    class var expandedHeight: CGFloat { get { return 427 } }
    class var defaultHeight: CGFloat { get { return 44} }
    
    var isFrameAdded = false
    
    func checkHeight() {
        albumImage1.isHidden = (frame.size.height < AlbumCell.expandedHeight)
        albumImage2.isHidden = (frame.size.height < AlbumCell.expandedHeight)
    }
    
    func watchFrameChanges() {
        if (!isFrameAdded) {
            addObserver(self, forKeyPath: "frame", options: .new, context: nil)
            checkHeight()
            isFrameAdded = true
        }
    }
    
    func ignoreFrameChanges() {
        if (isFrameAdded) {
            removeObserver(self, forKeyPath: "frame")
            isFrameAdded = false
        }
    }
    
    deinit {
        ignoreFrameChanges()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            checkHeight()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
