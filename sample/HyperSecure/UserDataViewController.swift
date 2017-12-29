//
//  UserDataViewController.swift
//  HyperSecure
//
//  Created by Srinija on 02/11/17.
//  Copyright © 2017 Hyperverge. All rights reserved.
//

import UIKit
import HyperSecureSDK

///The view between the initial view and the camera view. Lets the user set various parameters required to start HVFrCamera in CameraViewController
class UserDataViewController: UIViewController {
    
    @IBOutlet weak var autoCapture: UISwitch!
    
    @IBOutlet weak var useFrontCam: UISwitch!
    
    @IBOutlet weak var timeOut: UITextField!
    
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var label1: UILabel! //'Endpoint' in capture mode and 'Tenant ID' in others
    
    @IBOutlet weak var userID: UITextField!
    
    @IBOutlet weak var groupID: UITextField!
    
    @IBOutlet weak var userInfo: UITextField!
    
    var mode = FRMode.FACE_AUTHENTICATION
    var autoCapVal = true
    var useFrontCamVal = true
    var userData = [String:AnyObject]()
    var timeOutVal = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textField1.text = Constants.TenantID
        
        switch mode {
        case .FACE_AUTHENTICATION:
            disable(groupID)
            disable(userInfo)
        case .FACE_ADD,.REGISTER:
            break
        case .RECOGNITION:
            disable(userID)
            disable(userInfo)
        case .VERIFICATION:
            disable(groupID)
            disable(userInfo)
        case .CAPTURE:
            label1.text = "End Point"
            textField1.text = "/image/recognize"
        }
        
        if(groupID.isEnabled){
            groupID.text = Constants.GroupID
        }
        
    }
    
    func disable(_ textField:UITextField){
        textField.isEnabled = false
        textField.alpha = 0.25
    }
    
    @IBAction func onSubmitTap(_ sender: UIButton) {
        autoCapVal = autoCapture.isOn
        useFrontCamVal = useFrontCam.isOn
        userData = [String:AnyObject]()
        if let text = timeOut.text, text != "", let timeoutInt = Int(text){
            timeOutVal = timeoutInt
        }else{
            timeOutVal = 0
        }
        if(mode != .CAPTURE){
            if let text = textField1.text, text != ""{
                userData["tenantId"] = text as AnyObject
            }
        }
        if let text = userID.text, text != ""{
            userData["userId"] = text as AnyObject
        }
        if let text = groupID.text, text != ""{
            userData["groupId"] = text as AnyObject
        }
        if let text = userInfo.text, text != ""{
            userData["userInfo"] = text as AnyObject
        }
        performSegue(withIdentifier: "showCamera", sender: "sender")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showCamera"){
            let vc = segue.destination as! CameraViewController
            vc.mode = self.mode
            vc.userData = userData
            vc.autoCaptureOn = autoCapVal
            vc.useFrontCam = useFrontCamVal
            vc.timeout = timeOutVal
            vc.endPoint = textField1.text!
        }
    }
    
    /**
     Dismiss keyboard when tapped outside
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
}
