//
//  InitialViewController.swift
//  HyperSecure
//
//  Created by Srinija on 18/10/17.
//  Copyright © 2017 Hyperverge. All rights reserved.
//

import UIKit
import HyperSecureSDK

/// The initial view controller of the Application. Lets the user select an FR Mode or make a generic request
class InitialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Initializes the SDK. Make sure the constants in 'Constants.swift' are set.
        HyperSecureSDK.initialize(tenantId: Constants.TenantID, tenantKey: Constants.TenantKey, adminToken: Constants.AdminToken)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(Constants.TenantID == "" && Constants.TenantKey == "" && Constants.AdminToken == ""){
            let alert = UIAlertController(title: "Initializing the SDK", message: "Please make sure the values in 'Constants.swift' are set", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .`default`))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func faceRecognition(_ sender: UIButton) {
        performSegue(withIdentifier: "showUserData", sender: "faceRecognition")
    }
    
    @IBAction func faceVerification(_ sender: UIButton) {
        performSegue(withIdentifier: "showUserData", sender: "faceVerification")
    }
    
    @IBAction func addFace(_ sender: UIButton) {
        performSegue(withIdentifier: "showUserData", sender: "addFace")
    }
    
    @IBAction func faceRegistration(_ sender: UIButton) {
        performSegue(withIdentifier: "showUserData", sender: "faceRegistration")
    }
    
    
    @IBAction func faceAuthentication(_ sender: UIButton) {
        performSegue(withIdentifier: "showUserData", sender: "faceAuthentication")
        
    }
    
    @IBAction func faceCapture(_ sender: UIButton) {
        performSegue(withIdentifier: "showUserData", sender: "faceCapture")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sender = sender as? String{
            let vc = segue.destination as! UserDataViewController
            if(sender == "addFace"){
                vc.mode = FRMode.FACE_ADD
            }else if(sender == "faceAuthentication"){
                vc.mode = FRMode.FACE_AUTHENTICATION
            }else if(sender == "faceRecognition"){
                vc.mode = FRMode.RECOGNITION
            }else if(sender == "faceVerification"){
                vc.mode = FRMode.VERIFICATION
            }else if(sender == "faceRegistration"){
                vc.mode = FRMode.REGISTER
            }else if(sender == "faceCapture"){
                vc.mode = FRMode.CAPTURE
            }
        }
    }
    
    @IBAction func makeGenericRequest(_ sender: UIButton) {
        
        let params = ["userId" : "userName"] as [String:AnyObject]
        let endPoint = "/user/get"
        
        let requestId = HVOperationManager.makeRequest(endPoint: endPoint, request: params as [String : AnyObject]){(error, result) in
            guard error == nil else{
                print(error!.code)
                print(error!.userInfo)
                return
            }
            print("Success")
            print(result!)
        }
        //Uncomment this to cancel the request.
        //        let cancelReturn = HVOperationManager.cancelRequest(requestId)
        //        print("Cancelled the request: \(cancelReturn)")
        
        //Note: For an example usage of 'makeRequest' with images, check CameraViewController, Capture Mode.
    }
}
