//
//  AlbumViewController.swift
//  FacebookSearch
//
//  Created by JessicaChen on 18/04/2017.
//  Copyright © 2017 JessicaChen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class AlbumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var type: String?
    var id: String?
    var name: String?
    var picture: JSON?
    var albums: JSON?
    
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
        
        self.noDataLabel.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let albumJSON = self.albums {
            let albumList = albumJSON["data"]
            if albumList.count <= 0 {
                self.noDataLabel.isHidden = false
            } else {
                self.noDataLabel.isHidden = true
            }
            return albumList.count
        } else {
            self.noDataLabel.isHidden = false
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
        
        if let albumJSON = self.albums {
            cell.albumLabel.text = albumJSON["data"][indexPath.row]["name"].stringValue
            
            if let photoURL = albumJSON["data"][indexPath.row]["photos"]["data"][0]["picture"].string, let url = URL(string: photoURL) {
                do {
                    let imgData = try Data(contentsOf: url)
                    cell.albumImage1.image = UIImage(data: imgData)
                } catch {
                    print("Cannot load image")
                }
            }
            
            if let photoURL = albumJSON["data"][indexPath.row]["photos"]["data"][1]["picture"].string, let url = URL(string: photoURL) {
                do {
                    let imgData = try Data(contentsOf: url)
                    cell.albumImage2.image = UIImage(data: imgData)
                } catch {
                    print("Cannot load image")
                }
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath
        if indexPath == selectedIndexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
        
        var indexPaths: Array<IndexPath> = []
        if let previous = previousIndexPath {
            indexPaths += [previous]
        }
        if let current = selectedIndexPath {
            indexPaths += [current]
        }
        if indexPaths.count > 0 {
            tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! AlbumCell).watchFrameChanges()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! AlbumCell).ignoreFrameChanges()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedIndexPath {
            return AlbumCell.expandedHeight
        } else {
            return AlbumCell.defaultHeight
        }
    }
    
}
