//
//  FavoriteViewController.swift
//  FacebookSearch
//
//  Created by JessicaChen on 22/04/2017.
//  Copyright © 2017 JessicaChen. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var type: String?
    var favorites = [[String: String?]]()

    func loadFavorites() {
        favorites.removeAll()
        let userDefaultDic = UserDefaults.standard.dictionaryRepresentation()
        for (_, value) in userDefaultDic {
            if let data = value as? Data, let favoriteEntry = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: String?] {
                if let favoriteType = favoriteEntry["type"], favoriteType == self.type {
                    favorites.append(favoriteEntry)
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
        
        loadFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadFavorites()
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetails" {
            let tabBarController = segue.destination as! DetailsTabBarViewController
            
            if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
                let favoriteEntry = self.favorites[indexPath.row]
                if let id = favoriteEntry["id"], let idValue = id {
                    tabBarController.id = idValue
                }
                tabBarController.type = self.type
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        let favoriteEntry = self.favorites[indexPath.row]
        
        if let picURL = favoriteEntry["picURL"], let urlValue = picURL, let url = URL(string: urlValue) {
            do {
                let imgData = try Data(contentsOf: url)
                cell.profileImage.image = UIImage(data: imgData)
            } catch {
                print("Cannot load image")
            }
        }
        if let name = favoriteEntry["name"], let nameValue = name {
            cell.nameLabel.text = nameValue
        }
        
        return cell
    }

}
