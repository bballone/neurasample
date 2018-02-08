//
//  ViewController.swift
//  Push Notifications Test
//
//  Created by Neura on 7/10/16.
//  Copyright © 2016 Neura. All rights reserved.
//

import UIKit
import NeuraSDK

class ViewController: UIViewController {
    //MARK: Properties
    let neuraSDK = NeuraSDK.shared
    let subManager = SubscriptionsManager()
    
    //MARK: IBOutlets
    
    @IBOutlet weak var approvedPermissionsListButton: RoundedButton!
    @IBOutlet weak var permissionsListButton: RoundedButton!
    @IBOutlet weak var devicesButton: RoundedButton!
    @IBOutlet weak var simulateEvent: RoundedButton!
    @IBOutlet weak var loginButton: RoundedButton!
    
    @IBOutlet weak var neuraStatusLabel: UILabel!
    @IBOutlet weak var sdkVersionLabel:  UILabel!
    @IBOutlet weak var appVersionLabel:  UILabel!
    
    @IBOutlet weak var neuraSymbolTop:    UIImageView!
    @IBOutlet weak var neuraSymbolBottom: UIImageView!
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
       // self.simulateEvent.isHidden = true
        self.permissionsListButton.isHidden = true
        subManager.checkSubscriptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateSymbolState()
        self.updateButtonsState()
        self.updateAuthenticationLabelState()
        self.updateAuthenticationButtonState()
    }
    
    // MARK: - UI Updated based on authentication state
    func updateSymbolState() {
        let isConnected = NeuraSDK.shared.isAuthenticated()
        self.neuraSymbolTop.alpha = isConnected ? 1.0 : 0.3
        self.neuraSymbolBottom.alpha = isConnected ? 1.0 : 0.3
    }
    
    func updateAuthenticationButtonState() {
        let authState = NeuraSDK.shared.authenticationState()
        var title = ""
        switch authState {
        case .authenticatedAnonymously, .authenticated:
            title = "Disconnect"
            
        case .accessTokenRequested:
            title = "Connecting..."
            
        default:
            title = "Connect to Neura"
        }
        self.loginButton.setTitle(title, for: .normal)
    }

    func updateButtonsState() {
        let title = NeuraSDK.shared.isAuthenticated() ? "Edit Subscriptions" : "Permissions List"
        self.permissionsListButton.setTitle(title, for: .normal)
    }
    
    func updateAuthenticationLabelState() {
        let authState = NeuraSDK.shared.authenticationState()
        var text = ""
        var color = UIColor.black
        switch authState {
        case .accessTokenRequested:
            color = .blue
            text = "Requested tokens..."
        case .authenticated, .authenticatedAnonymously:
            color = UIColor(red: 0, green: 0.4, blue: 0, alpha: 1.0)
            if let neuraUserId = NeuraSDK.shared.neuraUserId() {
                text = "Connected (\(neuraUserId))"                
            } else {
                text = "Connected"
            }
            
        case .failedReceivingAccessToken:
            color = .red
            text = "Failed receiving tokens"
        default:
            color = .darkGray
            text = "Disconnected"
        }
        self.neuraStatusLabel.text = text
        self.neuraStatusLabel.textColor = color
    }
    
    //MARK: Authentication
    func loginToNeura() {
        self.showBlockingProgress()
        
        let request = NeuraAnonymousAuthenticationRequest()
        NeuraSDK.shared.authenticate(with: request) { result in
            if let error = result.error {
                // Handle authentication errors if required
                NSLog("login error = %@", error);
                self.showAlert(title: "Login error", message: error.localizedDescription)
                self.hideBlockingProgress()
                return
            }
            
            // Handle success failure
            if result.success {
                // Successful authentication
                // (access token will be received by push)
                self.neuraAuthStateUpdated()
            } else {
                // Handle failed login.
                self.showAlert(title: "Login failed", message: nil)
            }
            self.hideBlockingProgress()
        }
    }
    
    func logoutFromNeura(){
        guard NeuraSDK.shared.isAuthenticated() else { return }
        self.showBlockingProgress()
        NeuraSDK.shared.logout { result in
            // Handle errors if required
            self.hideBlockingProgress()
            self.neuraAuthStateUpdated()
        }
    }
    
    //
    // MARK: - NeuraAuthenticationStateDelegate
    //
    
    func neuraAuthStateUpdated() {
        self.updateAuthenticationLabelState()
        self.updateSymbolState()
        self.updateAuthenticationButtonState()
        self.updateButtonsState()
    }
    
    //
    // MARK: - User alerts
    //
    func showUserNotLoggedInAlert() {
        self.showAlert(title: "The user is not logged in", message: nil)
    }
    
    func showAlert(title: String?, message: String?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    //
    // MARK: - Blocking progress
    //
    func showBlockingProgress() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func hideBlockingProgress() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    //
    // MARK: - UI Setup
    //
    func setupUI() {
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor(red: 0.2102, green: 0.7655, blue: 0.9545, alpha: 1).cgColor

        //Get the SDK and app version
        let sdkText = "SDK Version: \(neuraSDK.getVersion()!)"
        self.sdkVersionLabel.text = sdkText
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        let appVersion = nsObject as! String
        self.appVersionLabel.text = appVersion
        
        // Auth State
        self.neuraAuthStateUpdated()
    }
    
    //
    // MARK: - IBAction Functions
    //
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        if neuraSDK.isAuthenticated() {
            self.logoutFromNeura()
            self.loginButton.setTitle("Connect and request permissions", for: UIControlState())
        } else {
            self.loginToNeura()
        }
    }
    
    @IBAction func approvedPermissionsListButtonPressed(_ sender: AnyObject) {
        //openNeuraSettingsPanel shows the approved permissions. This is a view inside of the SDK
        if neuraSDK.isAuthenticated() {
            neuraSDK.openNeuraSettingsPanel()
        } else{
            let alertController = UIAlertController(title: "The user is not logged in", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func permissionsListButtonPressed(_ sender: AnyObject) {
        if !neuraSDK.isAuthenticated() {
            self.performSegue(withIdentifier: "permissionsList", sender: self)
        } else {
            self.performSegue(withIdentifier: "subscriptionsList", sender: self)
        }
    }
    
    @IBAction func devicesButtonPressed(_ sender: AnyObject) {
        if neuraSDK.isAuthenticated() {
            self.performSegue(withIdentifier: "deviceOperations", sender: self)
        }
        else {
            let alertController = UIAlertController(title: "The user is not logged in", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func simulateEventPressed(_ sender: RoundedButton) {
                self.performSegue(withIdentifier: "simulateEventSegue", sender: self)
    }
    
    @IBAction func sendLogPressed(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "NeuraSdkPrivateSendLogByMailNotification"), object: nil)
    }
}
