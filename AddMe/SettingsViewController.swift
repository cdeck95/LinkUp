//
//  SettingsViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/25/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSCognito

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    // Test fields for DB
    @IBOutlet var userIdTextBox: UITextField!
    @IBOutlet var displayNameTextBox: UITextField!
    @IBOutlet var platformTextBox: UITextField!
    @IBOutlet var urlTextBox: UITextField!
    
    let collectionView: UICollectionView = {
        let frame = CGRect(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2, width: UIScreen.main.bounds.size.width / 2, height: UIScreen.main.bounds.size.height / 2)
        let col = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        col.layer.borderColor = UIColor.red.cgColor
        col.layer.borderWidth = 1.0
        col.backgroundColor = UIColor.yellow
        return col
    }()
    
    let switchView = UISwitch()

    
    
    @IBOutlet var settingsAppsTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("SETTINGS tableView() return cellSwitches.count")
        return cellSwitches.count
    }
    
    // This is where the table cells on the main page are modeled from.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("creating cells for table view in settings")
        let cell:SettingsTableViewCell = settingsAppsTableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTableViewCell
        cell.appName.text = cellSwitches[indexPath.row].NameLabel.text! + ""
        return cell
    }
    
    var sideMenuViewController = SideMenuViewController()
    var isMenuOpened:Bool = false
    var dataset: AWSCognitoDataset!
    var credentialsManager = CredentialsManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuViewController = storyboard!.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
        sideMenuViewController.view.frame = UIScreen.main.bounds
        let syncClient = AWSCognito.default()
        dataset = syncClient.openOrCreateDataset("AddMeDataSet\(credentialsManager.identityID)")
        dataset.synchronize().continueWith {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            return nil
            
        }
       self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
        ////////////////////////////
        if (cellSwitches.count > 0){
            for index in 0...cellSwitches.count - 1{
                var isSelectedForQRCode = cellSwitches[index].appSwitch.isOn
                var app = cellSwitches[index].NameLabel.text! + ""
                print(app)
                print(isSelectedForQRCode)
            }
        }
        ////////////////////////////
        
        switchView.frame = CGRect(x: 0, y: 20, width: 10, height: 5)
        switchView.addTarget(self, action: #selector(switched), for: .valueChanged)
        
        view.addSubview(switchView)
        //view.addSubview(collectionView)
    }
    
    @objc func switched(s: UISwitch){
        let origin: CGFloat = s.isOn ? view.frame.height : 50
        UIView.animate(withDuration: 0.35) {
            self.collectionView.frame.origin.y = origin
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        print("----in settings view will appear----")
        if(isMenuOpened == true){
            isMenuOpened = false
            sideMenuViewController.willMove(toParentViewController: nil)
            sideMenuViewController.view.removeFromSuperview()
            sideMenuViewController.removeFromParentViewController()
        }
        //cellSwitches = []
        self.tabBarController?.tabBar.isHidden = false
        settingsAppsTableView.reloadData()
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
        settingsAppsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Send in info
    @IBAction func updateStuff(_ sender: Any) {
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/setUserInfo.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(userIdTextBox.text!)&b=\(displayNameTextBox.text!)&c=\(platformTextBox.text!)&d=\(urlTextBox.text!)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var responseOne = responseString
            print(responseOne!)
        })
        task.resume()
    }
    
    // Send in user Id to get back all the info for that user
    @IBAction func GetUserInfo(_ sender: Any) {
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/getUserInfo.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(userIdTextBox.text!)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var responseOne = responseString
            print(responseOne!)
        })
        task.resume()
    }
    
    @IBAction func addUser(_ sender: Any) {
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/addNewUser.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(displayNameTextBox.text!)&b=\(platformTextBox.text!)&c=\(urlTextBox.text!)&d=\(userIdTextBox.text!)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var responseOne = responseString
            print(responseOne!)
        })
        task.resume()
    }
    
    // Just here
    //https://tommillerswebsite.000webhostapp.com/AddMe/addNewUser.php      SEND IN ALL BUT ID
    //https://tommillerswebsite.000webhostapp.com/AddMe/getUserInfo.php     SEND IN ID
    //https://tommillerswebsite.000webhostapp.com/AddMe/setUserInfo.php     SEND IN ALL 4
    
    
    @IBAction func menuClicked(_ sender: Any) {
        if(isMenuOpened){
            isMenuOpened = false
            sideMenuViewController.willMove(toParentViewController: nil)
            sideMenuViewController.view.removeFromSuperview()
            sideMenuViewController.removeFromParentViewController()
        }
        else{
            isMenuOpened = true
            self.addChildViewController(sideMenuViewController)
            self.view.addSubview(sideMenuViewController.view)
            sideMenuViewController.didMove(toParentViewController: self)
        }
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
    }
    
    // Going to connect this to a button on the Settings view.
    // Will delete all apps that the user has selected.
    func deleteSelectedApps()
    {
        // Planning on having a tableview with the custom cells on the screen.
        // It will be populated from the cellSwitches array.
        // The custom cells will have a toggle switch, a label for the name (facebook,etc.)
        // and a button to launch another view for editting the info about that selected cell.
    }
    
    // TODO: Probably should add a Confirm Delete? button.
    @IBAction func deleteApps(_ sender: Any) {
        let idString = self.credentialsManager.identityID!
        print(idString)
        var request = URLRequest(url:URL(string: "https://tommillerswebsite.000webhostapp.com/AddMe/deleteUser.php")!)
        request.httpMethod = "POST"
        let postString = "a=\(idString)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            } else {
                print("---no error----")
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(responseString)
            
        })
        task.resume()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
