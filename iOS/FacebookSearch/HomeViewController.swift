//
//  HomeViewController.swift
//  FacebookSearch
//
//  Created by JessicaChen on 12/04/2017.
//  Copyright © 2017 JessicaChen. All rights reserved.
//

import UIKit
import CoreLocation
import EasyToast

class HomeViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        menuButton.target = self.revealViewController()
        menuButton.action = Selector("revealToggle:")
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    func hideKeyboard() {
        textField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func clear() {
        textField.text = ""
    }

    @IBAction func search() {
        if (textField.text == nil || textField.text == "") {
            self.view.showToast("Enter a valid query!", position: .bottom, popTime: 5, dismissOnTap: true)
        } else {
            let authStatus = CLLocationManager.authorizationStatus()
            if authStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
                return
            }
            performSegue(withIdentifier: "search", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search" {
            
            let navigationController = segue.destination as! UINavigationController
            let tabBarController = navigationController.topViewController as! UITabBarController
            
            let userViewController = tabBarController.viewControllers?[0] as! SearchViewController
            let pageViewController = tabBarController.viewControllers?[1] as! SearchViewController
            let eventViewController = tabBarController.viewControllers?[2] as! SearchViewController
            let placeViewController = tabBarController.viewControllers?[3] as! SearchViewController
            let groupViewController = tabBarController.viewControllers?[4] as! SearchViewController
            userViewController.type = "user"
            userViewController.keyword = textField.text
            
            pageViewController.type = "page"
            pageViewController.keyword = textField.text
            
            eventViewController.type = "event"
            eventViewController.keyword = textField.text
            
            placeViewController.type = "place"
            placeViewController.keyword = textField.text
            placeViewController.locationManager.delegate = placeViewController
            placeViewController.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            placeViewController.locationManager.startUpdatingLocation()
            
            groupViewController.type = "group"
            groupViewController.keyword = textField.text
        }
    }
}
