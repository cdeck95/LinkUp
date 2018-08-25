//
//  ViewController.swift
//  AddMe
//
//  Created by Christopher Deck on 2/16/18.
//  Copyright © 2018 Christopher Deck. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAuthUI
import AWSUserPoolsSignIn
import AWSFacebookSignIn
import AWSGoogleSignIn
import AWSCore
import AWSCognito
import AWSCognitoIdentityProviderASF
import GoogleSignIn
import FacebookCore
import GoogleMobileAds
import CDAlertView
import FCAlertView
import Sheeeeeeeeet
import SideMenuSwift

var cellSwitches: [AppsTableViewCell] = []
var apps: [Apps] = []

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, FCAlertViewDelegate, UIScrollViewDelegate {

    var profiles: [Profile]!
    var bannerView: DFPBannerView!
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    @IBOutlet weak var nameLabel: UILabel!
    var identityProvider:String!
    var credentialsManager = CredentialsManager.sharedInstance
    var datasetManager = Dataset.sharedInstance
    var dataset: AWSCognitoDataset!
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet var uploadImageButton: UIBarButtonItem!
    var token: String!
    let imagePicker = UIImagePickerController()
    var gradient: CAGradientLayer!
    let cellSpacingHeight: CGFloat = 15
    var isCellTapped = false
    var selectedSectionIndex = -1
    var customView: UIView!
    var labelsArray: Array<UILabel> = []
    var isDarkModeEnabled = false
    private var themeColor = UIColor.white
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var profileImage: ProfileImage!
    @IBOutlet var pageControl: UIPageControl!
    
    let collectionMargin = CGFloat(16)
    let itemSpacing = CGFloat(10)
    let itemHeight = CGFloat(260)
    
    var itemWidth = CGFloat(0)
    var currentItem = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("----in view did load----")

     
        loadCustomRefreshContents()
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshAppData(_:)), for: .valueChanged)
        imagePicker.delegate = self
        createGradientLayer()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        bannerView = DFPBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "/6499/example/banner"
        bannerView.rootViewController = self
        bannerView.load(DFPRequest())
        
        nameLabel.center = self.view.center
        collectionView.center = self.view.center
        
        collectionView.delegate = self
        collectionView.dataSource = self
        //collectionView.scrollViewDelegate = self
        itemWidth =  UIScreen.main.bounds.width - collectionMargin * 2.0
        
        profiles = []
        let dict1 = ["profileID":"1", "name": "All (Default)", "qrCodeString": "qrCode for profile 1", "info":"All accounts"] as NSDictionary
        let profile = Profile(dictionary: dict1, imageIn: UIImage(named: "dance-floor-of-night-club.png")!)
        profiles.append(profile)
        var dict2 = ["profileID":"2", "name": "Gaming", "qrCodeString": "qrCode for profile 2", "info":"Xbox, PSN, Twitch"] as NSDictionary
        let profile2 = Profile(dictionary: dict2, imageIn: UIImage(named: "dance-floor-of-night-club.png")!)
        profiles.append(profile2)
        let dict3 = ["profileID":"3", "name": "Main Socials", "qrCodeString": "qrCode for profile 3", "info":"Facebook, Instagram, Twitter, Snachat"] as NSDictionary
        let profile3 = Profile(dictionary: dict3, imageIn: UIImage(named: "dance-floor-of-night-club.png")!)
        profiles.append(profile3)
        var dict4 = ["profileID":"4", "name": "Going out", "qrCodeString": "qrCode for profile 4", "info":"Snapchat, Insta"] as NSDictionary
        let profile4 = Profile(dictionary: dict4, imageIn: UIImage(named: "dance-floor-of-night-club.png")!)
        profiles.append(profile4)
//        for profile in profiles {
//            profile.loadAccountsInProfile()
//        }
        print("Profiles!... \(profiles!)")
       // addSlideMenuButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("----in view will appear----")
        self.tabBarController?.tabBar.isHidden = false
        presentAuthUIViewController()
        collectionView.reloadData()
       // appsTableView.reloadData()
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
    }
    
    func presentAuthUIViewController() {
        print("presentAuthUIViewController()")
        let config = AWSAuthUIConfiguration()
        config.enableUserPoolsUI = true
        config.addSignInButtonView(class: AWSFacebookSignInButton.self)
        config.addSignInButtonView(class: AWSGoogleSignInButton.self)
        config.logoImage = UIImage(named: "launch_logo")
        config.backgroundColor = UIColor.white
        config.font = UIFont (name: "Helvetica Neue", size: 14)
        config.canCancel = true
        
        print("in present auth ui method")
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            AWSAuthUIViewController
                .presentViewController(with: self.navigationController!,
                                       configuration: config,
                                       completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                        if error != nil {
                                            print("Error occurred: \(String(describing: error))")
                                        } else {
                                            // Sign in successful.
                                        }
                })
        }
        else {
            self.navigationController?.popToRootViewController(animated: true)// Initialize the Cognito Sync client
            credentialsManager.createCredentialsProvider()
            //credentialsManager.credentialsProvider.getIdentityId()
            credentialsManager.credentialsProvider.identityProvider.logins().continueWith { (task: AWSTask!) -> AnyObject! in
                
                if (task.error != nil) {
                    print("ERROR: Unable to get logins. Description: \(task.error!)")
                    
                } else {
                    if task.result != nil{
                    }
                    self.credentialsManager.credentialsProvider.getIdentityId().continueWith { (task: AWSTask!) -> AnyObject! in
                        
                        if (task.error != nil) {
                            print("ERROR: Unable to get ID. Error description: \(task.error!)")
                            
                        } else {
                            print("Signed in user with the following ID:")
                            let id = task.result! as? String
                            self.credentialsManager.setIdentityID(id: id!)
                            print(self.credentialsManager.identityID)
                            self.datasetManager.createDataset()
                            //self.fetchAppData()
                            if AWSFacebookSignInProvider.sharedInstance().isLoggedIn {
                                print("facebook sign in confirmed")
                                self.navigationItem.leftBarButtonItem = nil
                                let params: String = "name,email,picture"
                                self.getFBUserInfo(params: params, dataset: self.datasetManager.dataset)
                            } else {
                                self.profileImage.image = UIImage(named: "launch_logo")
                                self.profileImage.center = self.view.center
                                //self.navigationItem.leftBarButtonItem = self.uploadImageButton
                                //query the db for an image
                            }
                        }
                        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
                        self.profileImage.clipsToBounds = true;
                        return nil
                    }
                    
                    return nil
                }
                return nil
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func getFBUserInfo(params: String, dataset: AWSCognitoDataset) {
        print("getFBUserInfo()")
        let request = GraphRequest(graphPath: "me", parameters: ["fields":params], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
        request.start { (response, result) in
            switch result {
                case .success(let value):
                    print(value.dictionaryValue ?? "-1")
                    let userID = value.dictionaryValue?["id"] as! String
                    dataset.setString(userID, forKey: "userID")
                    let facebookProfileUrl = URL(string: "http://graph.facebook.com/\(userID)/picture?type=large")
                    if let data = NSData(contentsOf: facebookProfileUrl!) {
                        self.profileImage.image = UIImage(data: data as Data)
                        
                    }
                dataset.setString(value.dictionaryValue?["id"] as? String, forKey: "Facebook")
                self.nameLabel.text = value.dictionaryValue?["name"] as? String
            case .failed(let error):
                print(error)
            }
        }
    }
    
    // Goes through the list of table cells that contain the switches for which apps
    // to use in the QR Code being made. It checks their label and UISwitch.
    // If the switch is "On" then it will be included in the QR codes creation.
    @IBAction func createQRCode(_ sender: Any) {
       // loadApps()
        var jsonStringAsArray = "{\n"
        print("createQRCode()")
        if(cellSwitches.count > 0){
            for index in 0...cellSwitches.count - 1{
                let isSelectedForQRCode = cellSwitches[index].appSwitch.isOn
                let appID = cellSwitches[index].id
                print(appID)
                print(isSelectedForQRCode)
                if (isSelectedForQRCode){
                    let app = apps[index]
                    jsonStringAsArray += "\"\(app._displayName!)\": \"\(app._uRL!)\",\n"
                } else {
                    print("app not found to make QR code")
                }
            }
        } else {
            print("no apps - casnnot create code")
        }
        jsonStringAsArray += "}"
        let result = jsonStringAsArray.replacingLastOccurrenceOfString(",",
                                                              with: "")
        print(result)
        if(datasetManager.dataset != nil){
            datasetManager.dataset.setString(result, forKey: "jsonStringAsArray")
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        //Convert string to data
        let stringData = string.data(using: String.Encoding.utf8)
        
        //Generate CIImage
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(stringData, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        guard let ciImage = filter?.outputImage else { return nil }
        
        //Scale image to proper size
        // let scale = CGFloat(size) / ciImage.extent.size.width
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        //Convert to CGImage
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(scaledCIImage, from: scaledCIImage.extent) else { return nil }
        
        //Finally return the UIImage
        return UIImage(cgImage: cgImage)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
       
        segue.destination.modalPresentationStyle = .custom
        segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
    }

    @IBAction func uploadImage(_ sender: Any) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return
        }
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let qrcodeImg = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImage.image = qrcodeImg
            //send image to DB
        }
        else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func createGradientLayer() {
        gradient = CAGradientLayer()
        let gradientView = UIView(frame: self.view.bounds)
        gradient.frame = view.frame
//        gradient.colors = [UIColor(red: 61/255, green: 218/255, blue: 215/255, alpha: 1).cgColor, UIColor(red: 42/255, green: 147/255, blue: 213/255, alpha: 1).cgColor, UIColor(red: 19/255, green: 85/255, blue: 137/255, alpha: 1).cgColor]
//        gradient.locations = [0.0, 0.5, 1.0]
//        gradient.colors = [Color.glass.value.cgColor, Color.coral.value.cgColor, Color.bondiBlue.value.cgColor, Color.marina.value.cgColor]
//        gradient.locations = [0.0, 0.33, 0.66, 1.0]
        gradient.colors = [Color.chill.value.cgColor, Color.chill.value.cgColor]
        gradient.locations = [0.0, 1.0]
        gradientView.frame = self.view.bounds
        gradientView.layer.addSublayer(gradient)
        self.view.addSubview(gradientView)
        self.view.sendSubview(toBack: gradientView)
    }
    
    func addBannerViewToView(_ bannerView: DFPBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            let count = profiles.count + 1
            pageControl.numberOfPages = count
            print(profiles)
            print("--------------------")
            return profiles.count + 1
        }
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as! ProfileCollectionViewCell
        cell.layer.backgroundColor = UIColor.white.cgColor
       // cell.nameLabel.textColor = Color.glass.value
       // cell.descLabel.textColor = Color.glass.value
        if indexPath.item == profiles.count {
            cell.profileImage.image = UIImage(named: "add_more.png")
            //cell.profileImage.frame = cell.bounds
            cell.nameLabel.text = "Add a Profile"
            cell.descLabel.isHidden = true
            cell.openButton.setImage(UIImage(named: "ic_add_circle"), for: .normal)
        } else {
            print(profiles[indexPath.row])
            cell.populateWith(card: profiles[indexPath.row])
        }
        cell.nameLabel.sizeToFit()
        cell.descLabel.sizeToFit()
        cell.layer.cornerRadius = 6.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == profiles.count){
            print("will show add more")
        } else {
            print("will show options")
            let actionSheet = createStandardActionSheet(indexPath: indexPath)
            actionSheet.present(in: self, from: self.view)
        }
    }
//    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        print("snapping")
//        guard let collectionView = scrollView as? UICollectionView else { return }
//        let indexPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
//        collectionView.snapToCell(velocity: velocity, targetOffset: targetContentOffset, spacing: 10, indexPath: indexPath)
//       // contentOffset = targetContentOffset.pointee.x
//    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
//    }
//
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//
//        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
//    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//
//        let pageWidth = Float(itemWidth + itemSpacing)
//        let targetXContentOffset = Float(targetContentOffset.pointee.x)
//        let contentWidth = Float(collectionView!.contentSize.width  )
//        var newPage = Float(self.pageControl.currentPage)
//
//        if velocity.x == 0 {
//            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
//        } else {
//            newPage = Float(velocity.x > 0 ? self.pageControl.currentPage + 1 : self.pageControl.currentPage - 1)
//            if newPage < 0 {
//                newPage = 0
//            }
//            if (newPage > contentWidth / pageWidth) {
//                newPage = ceil(contentWidth / pageWidth) - 1.0
//            }
//        }
//
//        self.pageControl.currentPage = Int(newPage)
//        let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
//        targetContentOffset.pointee = point
//    }
    
//    override func calculateSectionInset() -> CGFloat {
//        return 40
//    }
    
    func createStandardActionSheet(indexPath: IndexPath) -> ActionSheet {
        let title = ActionSheetTitle(title: "Select an option")
        let item1 = ActionSheetItem(title: "View Code", value: "1", image: UIImage(named: "baseline_pageview_black_18pt"))
        let item2 = ActionSheetItem(title: "Edit Profile", value: "2", image: UIImage(named: "baseline_create_black_18pt"))
        let item3 = ActionSheetItem(title: "Share Profile", value: "3", image: UIImage(named: "baseline_share_black_18pt"))
        let button = ActionSheetOkButton(title: "Cancel")
        return ActionSheet(items: [title, item1, item2, item3, button]) { _, item in
            guard let value = item.value as? String else { return }
            if value == "1" {
                let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeViewController") as! QRCodeViewController
                modalVC.qrCodeString = self.profiles[(indexPath.row)].qrCodeString
                self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
                modalVC.modalPresentationStyle = .custom
                modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
                self.present(modalVC, animated: true, completion: nil)
            } else if value == "2" {
                let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountsForProfileViewController") as! AccountsForProfileViewController
                    self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
                    modalVC.accounts = self.profiles[indexPath.row].Accounts
                    modalVC.profileImageImage = self.profiles[indexPath.row].image
                    modalVC.profileID = self.profiles[indexPath.row].id
                    modalVC.profileNameText = self.profiles[indexPath.row].name
                    modalVC.profileDescriptionText = self.profiles[indexPath.row].descriptionLabel
                    modalVC.modalTransitionStyle = .crossDissolve
                    modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
                    self.present(modalVC, animated: true, completion: nil)
            } else if value == "3" {
                let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeViewController") as! QRCodeViewController
//                let encoder = JSONEncoder()
//                encoder.outputFormatting = .prettyPrinted
//                let data = try! encoder.encode(profiles[Apps])
//                print(String(data: data, encoding: .utf8)!)
                modalVC.qrCodeString = self.profiles[(indexPath.row)].qrCodeString
                modalVC.shouldShare = true
                self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: modalVC)
                modalVC.modalPresentationStyle = .custom
                modalVC.transitioningDelegate = self.halfModalTransitioningDelegate
                self.present(modalVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func refreshAppData(_ sender: Any) {
        print("refreshAppData()")
        fetchAppData()
    }
    //
    private func fetchAppData() {
        print("fetchAppData()")
        //load profiles
        //setupActivityIndicatorView()
        self.updateView()
        self.refreshControl.endRefreshing()
        //self.activityIndicatorView.stopAnimating()
    }
    
    private func updateView() {
        print("updateView()")
        let hasProfiles = profiles.count > 0
        print("has apps: \(hasProfiles)")
        collectionView.isHidden = false
        if hasProfiles {
            collectionView.reloadData()
        } else {
        }
    }
    
    func loadCustomRefreshContents() {
//        let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
//
//        customView = refreshContents![0] as! UIView
//        customView.frame = self.view.bounds
//        
//        for i in 0 ..< customView.subviews.count {
//            labelsArray.append(customView.viewWithTag(i + 1) as! UILabel)
//        }
//
//        refreshControl.addSubview(customView)
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }

    }
    
}

extension UICollectionView {
    
    func snapToCell(velocity: CGPoint, targetOffset: UnsafeMutablePointer<CGPoint>, contentInset: CGFloat = 0, spacing: CGFloat = 0, indexPath: IndexPath) {
        // No snap needed as we're at the end of the scrollview
        guard (contentOffset.x + frame.size.width) < contentSize.width else {
            return
        }
  //      let indexPath =  indexPathForItem(at: targetOffset.pointee)
//        guard let indexPath = indexPathForItem(at: targetOffset.pointee) else {
//            print("target offset: \(targetOffset.pointee)")
//            return
//        }
        guard let cellLayout = layoutAttributesForItem(at: indexPath) else {
             print("in cell layout else")
            return
        }
        
        var offset = targetOffset.pointee
        print("made it here in snap")
        if velocity.x < 0 {
            offset.x = cellLayout.frame.minX - max(contentInset, spacing)
        } else {
            offset.x = cellLayout.frame.maxX - contentInset + min(contentInset, spacing)
        }
        
        targetOffset.pointee = offset
    }
}


extension String
{
    func replacingLastOccurrenceOfString(_ searchString: String,
                                         with replacementString: String,
                                         caseInsensitive: Bool = true) -> String
    {
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        
        if let range = self.range(of: searchString,
                                  options: options,
                                  range: nil,
                                  locale: nil) {
            
            return self.replacingCharacters(in: range, with: replacementString)
        }
        return self
    }
    
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
