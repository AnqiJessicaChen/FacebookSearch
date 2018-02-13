//
//  DetailsTabBarViewController.swift
//  FacebookSearch
//
//  Created by JessicaChen on 21/04/2017.
//  Copyright © 2017 JessicaChen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import FacebookShare

class DetailsTabBarViewController: UITabBarController {
    
    var id: String?
    var type: String?
    var name: String?
    var picture: JSON?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        SwiftSpinner.show("Loading data...")
        
        if let entryId = id {
            let url = "http://anqichen-env.us-west-2.elasticbeanstalk.com/?id=" + entryId + "&type=" + type!
            Alamofire.request(url).responseJSON { response in
                let albumViewController = self.viewControllers?[0] as! AlbumViewController
                let postViewController = self.viewControllers?[1] as! PostViewController
                
                if let data = response.result.value {
                    let json = JSON(data)
                    
                    self.name = json["name"].stringValue
                    self.picture = json["picture"]
                    
                    albumViewController.id = self.id
                    albumViewController.type = self.type
                    albumViewController.name = self.name
                    albumViewController.picture = self.picture
                    albumViewController.albums = json["albums"]
                    
                    if albumViewController.isViewLoaded {
                        albumViewController.tableView.reloadData()
                    }
                    
                    postViewController.id = self.id
                    postViewController.type = self.type
                    postViewController.name = self.name
                    postViewController.picture = self.picture
                    postViewController.posts = json["posts"]
                    
                    if postViewController.isViewLoaded {
                        postViewController.tableView.reloadData()
                    }
                } else {
                    albumViewController.noDataLabel.isHidden = false
                    postViewController.noDataLabel.isHidden = false
                }
                SwiftSpinner.hide()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showOptionMenu(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Menu", preferredStyle: .actionSheet)
        
        let addFavoriteAction = UIAlertAction(title: "Add to favorites", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            var favoriteEntry = [String: String?]()
            favoriteEntry["id"] = self.id
            favoriteEntry["type"] = self.type
            favoriteEntry["name"] = self.name
            favoriteEntry["picURL"] = self.picture?["data"]["url"].string
            let data = NSKeyedArchiver.archivedData(withRootObject: favoriteEntry)
            UserDefaults.standard.set(data, forKey: self.id!)
            self.view.showToast("Added to favorites!", position: .bottom, popTime: 5, dismissOnTap: true)
        })
        
        let removeFavoriteAction = UIAlertAction(title: "Remove from favorites", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            UserDefaults.standard.removeObject(forKey: self.id!)
            self.view.showToast("Removed from favorites!", position: .bottom, popTime: 5, dismissOnTap: true)
        })
        
        let shareAction = UIAlertAction(title: "Share", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            let picURL = URL(string: self.picture!["data"]["url"].stringValue)
            let content = LinkShareContent(url: picURL!, title: self.name, description: "FB Share for CSCI 571", quote: nil, imageURL: picURL)
            let shareDialog = ShareDialog(content: content)
            shareDialog.mode = .feedBrowser
            shareDialog.failsOnInvalidData = true
            shareDialog.completion = { result in
                self.view.showToast("Shared!", position: .bottom, popTime: 5, dismissOnTap: true)
            }
            do {
                try shareDialog.show()
            } catch {
                print("Cannot display share dialog")
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UserDefaults.standard.data(forKey: self.id!) == nil {
            optionMenu.addAction(addFavoriteAction)
        } else {
            optionMenu.addAction(removeFavoriteAction)
        }
        optionMenu.addAction(shareAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }

}
