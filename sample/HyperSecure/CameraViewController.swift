//
//  CameraViewController.swift
//  HyperSecure
//
//  Created by Srinija on 14/10/17.
//  Copyright © 2017 Hyperverge. All rights reserved.
//

import UIKit
import AVFoundation
import HyperSecureSDK

///This sets up and starts the HVFrCamera with the data from UserDataViewController. Once the completion handler for startCamera is reached, a popup with the corresponding result/error is shown. Capture mode also makes a 'makeRequest' call with the captured images.
class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraView: HVFrCamera!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var bottomToolBar: UIView!
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView5: UIImageView!
    
    @IBOutlet weak var processingAlert: UIView!
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var processingActivity: UIActivityIndicatorView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var processingImage: UIImageView!
    
    var faceSize: CGSize?
    var mode = FRMode.FACE_AUTHENTICATION
    var userData = [String:AnyObject]()
    var useFrontCam:Bool = true
    var autoCaptureOn:Bool = true
    var timeout = 0
    var error : NSError?
    var result : [String:AnyObject]?
    var timer = Timer()
    var localFaceUrls = [String]()
    var taskId = 0
    var endPoint = ""
    
    //Results popup timer value
    var timerValue = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Uncomment this for the HVFrCameraDelegate code from the app to take over
//                cameraView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = true
        alertView.isHidden = true
        processingAlert.isHidden = true
                cameraView.frame = self.view.frame //To set camera dimensions in autolayout, comment this line.
        cancelButton.isHidden = true
        
        switch mode {
        case .FACE_AUTHENTICATION, .RECOGNITION, .VERIFICATION,.CAPTURE:
            
            if(autoCaptureOn){
                bottomToolBar.isHidden = true
            }else{
                submitButton.isHidden = true
                clearButton.isHidden = true
                bottomToolBar.isHidden = false
            }
        case .FACE_ADD,.REGISTER:
            submitButton.isHidden = false
            clearButton.isHidden = false
            bottomToolBar.isHidden = false
            
        }
        
        if(mode == .CAPTURE){
            cancelButton.isHidden = false
        }
        
        
        let completionHandler : (NSError?, [String : AnyObject]?) -> Void = {(error, result) in
            self.cameraView.pauseFR()
            self.showAlertView(error: error, result: result)
            
            if(self.mode == .CAPTURE){
                //'makeRequest'call made with the images captured in 'capture' mode.
                if let result = result{
                    let taskId = HVOperationManager.makeRequest(endPoint: self.endPoint,images: result["imageUri"] as! [String], request:self.userData ){error,result in
                        if(error != nil){
                            self.textView.text = "Error Code : \(error!.code)\n\n Error Description : \(error!.userInfo[NSLocalizedDescriptionKey]!)"
                        }else{
                            self.textView.text = result?.debugDescription
                        }
                    }
                    self.taskId = taskId
                    
                }
            }
        }
        cameraView.startCamera(userData: userData, mode: mode, timeout: timeout, autoCaptureEnabled: autoCaptureOn, useFrontCam: useFrontCam,completionHandler: completionHandler)
    }
    
    override func viewWillLayoutSubviews() {
        cameraView.updateCameraOrientation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraView.stopCamera()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    /**
     Popup to show results from different FRModes
     */
    func showAlertView(error:NSError?,result:[String:AnyObject]?){
        if(error != nil){
            successLabel.text = "Failed!"
            textView.text = "Error Code : \(error!.code)\n\n Error Description : \(error!.userInfo[NSLocalizedDescriptionKey]!)"
            if let imageUri = error?.userInfo["imageUri"] as? [String]{
                localFaceUrls = imageUri
                setUpFaces()
            }else if let imageUri = error?.userInfo["imageUri"] as? String{
                localFaceUrls = [imageUri]
                setUpFaces()
            }else{
                clearFaces()
            }
        }else{
            textView.text = ""
            successLabel.text = "Success!"
            for (key,value) in result! {
                if(key == "imageUri"){
                    if let value = value as? [String] {
                        localFaceUrls = value
                        setUpFaces()
                    }
                    if let value = value as? String {
                        localFaceUrls = [value]
                        setUpFaces()
                    }
                }else{
                    let valueStr = value.description!
                    textView.text = textView.text + "\(key) : \(valueStr)\n\n"
                }
            }
        }
        self.view.bringSubview(toFront: alertView)
        alertView.isHidden = false
        if(timerValue > 0){
            //Timer to hide the results popup after some time(timerValue). Setting the variable to zero will disable it.
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(timerValue), target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
        }
    }
    
    
    @objc func timerAction(){
        closePopup()
    }
    
    
    @IBAction func cancelRequest(_ sender: UIButton) { //This button is visible in 'Capture' Mode only
        let cancelResult = HVOperationManager.cancelRequest(taskId)
        print("Cancel result: \(cancelResult)")
        if(cancelResult){
            textView.text = "Request cancelled"
        }
    }
    
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraView.capture(){(error, isSuccess) -> Void in
            guard isSuccess == true else{
                print("Error in capture Image: \(error!)")
                return
            }
            print("Capture image successful")
            
        }
    }
    
    @IBAction func onSubmitTap(_ sender: UIButton) {
        cameraView.submit()
    }
    
    @IBAction func onClearTap(_ sender: UIButton) {
        let result = cameraView.clearCapturedImages()
        print("Clear images returned:\(result)")
    }
    
    @IBAction func onCloseAlertTap(_ sender: UIButton) {
        closePopup()
    }
    
    func closePopup(){
        alertView.isHidden = true
        timer.invalidate()
        if let error = error{
            if(error.code != 1 && error.code != 2){
                cameraView.resumeFR()
            }
        }else{
            cameraView.resumeFR()
        }
    }
    
    /**
     Updates the imageViews in the popup with the images returned.
     */
    func setUpFaces(){
        clearFaces()
        
        setWidth(imageView: imageView1)
        imageView1.image = UIImage(contentsOfFile: localFaceUrls[0])
        if(localFaceUrls.count > 1){
            setWidth(imageView: imageView2)
            imageView2.image = UIImage(contentsOfFile: localFaceUrls[1])
            if(localFaceUrls.count > 2){
                setWidth(imageView: imageView3)
                imageView3.image = UIImage(contentsOfFile: localFaceUrls[2])
            }
            if(localFaceUrls.count > 3){
                setWidth(imageView: imageView4)
                imageView4.image = UIImage(contentsOfFile: localFaceUrls[3])
            }
            if(localFaceUrls.count > 4){
                setWidth(imageView: imageView5)
                imageView5.image = UIImage(contentsOfFile: localFaceUrls[4])
            }
            
            
        }
    }
    
    func clearFaces(){
        imageView1.image = nil
        imageView2.image = nil
        imageView3.image = nil
        imageView4.image = nil
        imageView5.image = nil
        
    }
    
    func setWidth(imageView:UIImageView){
        if(UIDevice.current.userInterfaceIdiom == .phone){
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        }else{
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200).isActive = true
        }
    }
}

extension CameraViewController: HVFrCameraDelegate {
    
    func willStartProcessingImage(_ hvfrcamera: HVFrCamera) {
        processingLabel.text = "Processing image.."
        processingAlert.isHidden = false
        processingActivity.startAnimating()
        let imagePaths = hvfrcamera.getlocalImagePaths()
        if imagePaths.count > 0{
            processingImage.image = UIImage(contentsOfFile: imagePaths[0])
        }else{
            processingImage.image = UIImage()
        }
    }
    
    func didCompleteProcessingImage(_ hvfrcamera: HVFrCamera) {
        processingAlert.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        print("Memory warning received!")
    }
    
}



