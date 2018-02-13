//
//  PostViewController.swift
//  FacebookSearch
//
//  Created by JessicaChen on 19/04/2017.
//  Copyright © 2017 JessicaChen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var type: String?
    var id: String?
    var name: String?
    var picture: JSON?
    var posts: JSON?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        
        self.noDataLabel.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let postJSON = self.posts {
            let postList = postJSON["data"]
            if postList.count <= 0 {
                self.noDataLabel.isHidden = false
            } else {
                self.noDataLabel.isHidden = true
            }
            return postList.count
        } else {
            self.noDataLabel.isHidden = false
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        if let postJSON = self.posts {
            if let message = postJSON["data"][indexPath.row]["message"].string {
                cell.postLabel.text = message
            } else if let story = postJSON["data"][indexPath.row]["story"].string {
                cell.postLabel.text = story
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let date = dateFormatter.date(from: postJSON["data"][indexPath.row]["created_time"].stringValue)
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss"
            cell.dateLabel.text = dateFormatter.string(from: date!)
            
            if let picJSON = self.picture, let picURL = picJSON["data"]["url"].string, let url = URL(string: picURL) {
                do {
                    let imgData = try Data(contentsOf: url)
                    cell.profileImage.image = UIImage(data: imgData)
                } catch {
                    print("Cannot load image")
                }
            }
        }
        
        return cell
    }

}
