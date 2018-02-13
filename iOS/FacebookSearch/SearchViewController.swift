//
//  SearchViewController.swift
//  FacebookSearch
//
//  Created by JessicaChen on 17/04/2017.
//  Copyright © 2017 JessicaChen. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SwiftSpinner

class SearchViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var type: String?
    var keyword: String?
    var results: JSON?
    var pageNum = 1
    var latitude: String?
    var longitude: String?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
        
        SwiftSpinner.show("Loading data...")
        
        if let q = keyword, let escaped = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            var url = "http://anqichen-env.us-west-2.elasticbeanstalk.com/?keyword=" + escaped + "&type=" + type!
            if type == "place" {
                if let latValue = latitude, let longValue = longitude {
                    url += "&latitude=" + latValue + "&longitude=" + longValue
                }
                locationManager.stopUpdatingLocation()
                locationManager.delegate = nil
            }
            Alamofire.request(url).responseJSON { response in
                if let data = response.result.value {
                    let json = JSON(data)
                    self.results = json["data"]
                }
                self.tableView.reloadData()
                self.previousButton.isEnabled = false
                if let result = self.results, result.count > 10 {
                    self.nextButton.isEnabled = true
                } else {
                    self.nextButton.isEnabled = false
                }
                SwiftSpinner.hide()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    @IBAction func previous(_ sender: Any) {
        self.pageNum -= 1
        self.previousButton.isEnabled = true
        if (self.pageNum <= 1) {
            self.previousButton.isEnabled = false
        }
        self.tableView.reloadData()
    }

    @IBAction func next(_ sender: Any) {
        self.pageNum += 1
        self.previousButton.isEnabled = true
        if let result = self.results, result.count <= 10 * self.pageNum {
            self.nextButton.isEnabled = false
        }
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetails" {
            let tabBarController = segue.destination as! DetailsTabBarViewController
            
            if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell), let json = self.results {
                let index = (pageNum - 1) * 10 + indexPath.row
                tabBarController.id = json[index]["id"].stringValue
                tabBarController.type = self.type
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        latitude = String(format: "%.8f", newLocation.coordinate.latitude)
        longitude = String(format: "%.8f", newLocation.coordinate.longitude)
//        print("didUpdateLocations \(newLocation)")
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let json = self.results {
            let count = json.count
            if (10 * pageNum >= count) {
                return count - (10 * (pageNum - 1))
            } else {
                return 10
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        
        if let json = self.results {
            let index = (pageNum - 1) * 10 + indexPath.row
            if let url = URL(string: json[index]["picture"]["data"]["url"].stringValue) {
                do {
                    let imgData = try Data(contentsOf: url)
                    cell.profileImage.image = UIImage(data: imgData)
                } catch {
                    print("Cannot load image")
                }
            }
            cell.nameLabel.text = json[index]["name"].stringValue
            
            if let id = json[index]["id"].string, (UserDefaults.standard.data(forKey: id) != nil) {
                cell.favoriteButton.setImage(UIImage(named: "filled.png"), for: .normal)
            } else {
                cell.favoriteButton.setImage(UIImage(named: "empty.png"), for: .normal)
            }
        }
        
        return cell
    }

}
