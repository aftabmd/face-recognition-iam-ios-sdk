## Face Recognition Framework Documentation


### Introduction
HyperSecure is an iOS Framework of HyperVerge's Face Recognition based Identity and Access Management (IAM) System. This documentation explains how to use the framework to build your own app.
<br></br>

![](https://media.giphy.com/media/P7hZDbHqQAKxG/giphy.gif)
<br>

#### Overview
In the context of HyperVerge's face recognition based IAM system, there are 3 entities: User, Group and Organization. Users are the people enrolled for Face Recognition having registered with their face image. A Group can represent a team or site or location or building or any other collection of people. An Organization can thus have multiple Groups and each Group can have multiple Users.

A high-level overview of the Face Recognition workflow is as follows:

- Enroll Users into a Group of the Organization, with their face images captured from Camera in Registration Mode
- To recognize who a person is, capture their face image from the Camera in Recognition Mode
- To verify if a person is actually who they're claiming to be, capture their face from the Camera in Verification Mode along with the userId
- To add more faces to a person to improve recognition accuracy, capture their face images from the Camera in Face Add Mode

#### Prerequisites
- Minimum iOS Deployment Target - iOS 8.0
- Base SDK - iOS 11.1

---

### Integration Steps

#### 1. Getting SDK credentials

- **Using HyperSecure within your own organization**: Please use the `tenantId`, `tenantKey` and `adminToken` supplied by HyperVerge. If you don't have them already, then drop a mail to contact@hyperverge.co
- **Using HyperSecure for other organizations**: Channel Partners using HyperSecure as part of solutions for other organizations shall use a dashboard or an API provided by HyperVerge to create a client organization. Upon creation, they will receive a `tenantId`, `tenantKey` and `adminToken` unique to each client organization, which shall be used in the SDK initialization as described later.
    - **tenantId**: An id unique to each client of the Channel Partner. It will be used to identify the client organization and will let HyperVerge know which logical organization entity is being referred to for performing operations such as face enrollment, verification or recognition
    - **tenantKey**: A token used to authenticate a client of the Channel Partner. This will help HyperVerge ensure that all the communication to the server is secure and authenticated.
    - **adminToken**: A unique Admin Token for each client organisation's admin user. This token will let HyperVerge authorize the FR operations requested by the SDK at the Server

#### 2. Setting up an Xcode Project
- Add the framework to your Xcode project
- Navigate to Targets -> General and include the framework under 'Embedded Binaries' and 'Linked Frameworks and Libraries'.
- Navigate to Targets -> 'Your App name' -> Build Settings. Ensure that 'Always Embed Swift Standard Libraries' is set to 'Yes'. 
- Add this import statement in all files using the framework.<br/>
    Objective C: `@import HyperSecureSDK;`
    Swift: `import HyperSecureSDK`<br/>

**Permissions**: To request the user for camera permissions, add this key-value pair in your application's info.plist file.<br/>
    Key: Privacy - Camera Usage Description<br/>
    Value: "Please enable camera access"

The same in xml would be:
```
<key>NSCameraUsageDescription</key>
<string>"Please enable camera access"</string>
```

 **SDK Initialization**: Add the following line to your code for initializing the Library. This must be called before launching the camera. So, preferably in 'viewDidLoad' of the ViewController or 'applicationDidFinishLaunching' in the AppDelegate.</br>

 Objective C:
 ```
 [HyperSecureSDK initializeWithTenantId:@<tenantId> tenantKey:@<tenantKey> adminToken:@<adminToken>];
 ```

 Swift:
 ```
 HyperSecureSDK.initialize(tenantId: <tenantId>, tenantKey: <tenantKey>, adminToken: <adminToken>)

 ```

#### 3. Enrolling, Verifying or Recognizing User from Camera feed
The functionality for enrolling, verifying and recognizing a user is implemented in the SDK as a View called `HVFrCamera`. This View includes a camera preview, local face detection and execution of corresponding APIs for enrollment, verification (1:1) and recognition (1:N).

##### Adding HVFrCamera View to your Application
- **Adding via Storyboard/xib**:<br/>
    Add a UIView to the storyboard/xib. Under identity inspector, set the class name to 'HVFrCamera' and module to 'HyperSecureSDK'.  Add an @IBOutlet of this view to your ViewController class. Set layout constraints/frame(using autoLayout/code).
    <br/>
    Please note: The default camera selected is the front camera. If you want to use the back camera instead, include the following line in `viewDidLoad`(This extra step is not required if the view is created in code).</br>
    
    Objective C:
    ```
    [_hvfrcamera shouldUseFrontCam:false]
    ```
    Swift:
    ```
    hvfrcamera.shouldUseFrontCam(false)
    ```

- **Adding via Code**:<br/>
    Create a HVFRCamera instance by calling the following.<br/>
    
    Objective C:
    ```
    HVFrCamera *hvfrcamera = [[HVFrCamera alloc] initWithFrontCam:<true/false>]
    [self.view addSubview:hvfrcamera];
    ```
    Swift:
    ```
    let hvfrcamera = HVFrCamera(frontCam: <true/false>)
    self.view.addSubview(hvfrcamera)
    ```
    Set layout constraints/frame of hvfrcamera.

##### Starting Face Recognition
 To start the camera and face detection, add the following to the 'viewWillAppear' function of the corresponding ViewController.<br/>

 Objective C:

 ```
 [_hvfrcamera startCameraWithUserData:userData mode:mode timeout:timeout autoCaptureEnabled:isAutoCaptureEnabled useFrontCam:useFrontCam completionHandler:completionHandler];
 ```

 Swift:

 ```
 hvfrcamera.startCamera(userData: userData, mode: mode, timeout: timeout, autoCaptureEnabled: isAutoCaptureEnabled, useFrontCam: useFrontCam,completionHandler: completionHandler)
 ```

 The arguments accepted by the start camera function are the Configuration variables for HVFrCamera. The `startCamera()` method will set these variables and set HVFrCamera to start processing the camera feed. The details of the variables are given below.

 - `mode` can have a value among FRMode.REGISTER, FRMode.FACE_ADD, FRMode.RECOGNITION, FRMode.VERIFICATION and FRMode.CAPTURE
 - `userData` is the JSONObject having userDetails (explanation below)
 - `timeout` is the maximum time in milliseconds since startCamera() or resumeCamera() after which if the registration/recognition is not done, the onError will be called with Timeout Error. A value of 0 will disable the timeout
 - `isAutoCaptureEnabled` is a boolean value that specifies if automatic capture of image should happen for recognition when a face matching the desired size is detected. Please note that auto-capture is not supported for Registration mode or Face Add mode
 - `useFrontCam` is a boolean value that specifies if the front camera should be used. If set to false, then the back camera will be used for processing
 - `completionHandler` - discussed in the next section.

 **UserData Dictionary**:
 - Enroll Mode:
     - `tenantId`: Used to identify the organization where enroll should be performed. Should be same as the one used to initialize the SDK
     - `groupId`: Group to which the user should be enrolled (Optional)
     - `userId`: Unique id of the user who is getting enrolled
     - `userInfo`: Some more information about the user
 - Face Add Mode:
     - `tenantId`: Used to identify the organization where face add should be performed. Should be same as the one used to initialize the SDK
     - `userId`: Unique id of the user whose face is getting added
 - Verification Mode:
     - `tenantId`: Used to identify the organization where Verification should be performed. Should be same as the one used to initialize the SDK
     - `groupId`: Group where Verification should be performed (Optional)
     - `userId`: Unique id of the user on whom Verification should performed
 - Recognition Mode:
     - `tenantId`: Used to identify the organization where Recognition should be performed. Should be same as the one used to initialize the SDK
     - `groupId`: Group where Recognition should be performed
 - Capture Mode:
     - An empty dictionary

 **Please note:** the group will have to be created before use in HVFrCamera. If no groupId is passed, we will assume that `default` group is being used. The `default` group is by default created for all tenants upon creation of the tenant

##### Implementing the Completion Handler
HVFrCamera communicates with your application through the closure you pass to the `startCamera` method. </br>
This closure should be of type  `error:NSError?, result:[String:AnyObject]?) -> Void` and should be implemented in the application. </br>

The values of `error` and  `result` received by the closure determine whether the call was a success or failure. </br>
 - `error`: If the call was successful, the error is set to `nil`. Otherwise, it is an `NSError` object with following information
    - `code`: Error code stating type of error. (discussed later)
    - `userInfo`: A dictionary of type `[String:Any]`.
        - The key `NSLocalizedDescriptionKey`  has the error description.
        - If the error is received after capture, this dictionary also contains `imageUri` - an array of strings representing the local paths of the captured face images.
 - `result`: If the call failed, this is set to `nil`. Otherwise, it is of type `[String:AnyObject]`. Following are the values obtained in various modes.

**Please note:**  In case of an error in `REGISTRAION` or `FACE_ADD` modes, the captured images won't be cleared internally by the SDK. This essentially means that the state of images captured will be preserved and if `submit` method is called again, the same images will be processed and uploaded to the server.
If these captured images need to be cleared, `clearCapturedImages` method(described later) should be called to manually clear them.

- **Result Dictionary**:
    - Enroll Mode:
        - `tenantId`: Used to identify the organization where enroll has been performed.
        - `groupId`: Group to which the user has been enrolled
        - `userId`: Unique id of the user who has been enrolled
        - `userInfo`: Some more details about the user
        - `imageUri`: Array of local file paths(String) of the face images that have been used for enrolling
        - `faceIds`:  Array of faceIds of the faces enrolled
    - Face Add Mode:
        - `tenantId`: Used to identify the organization where face add has been performed.
        - `userId`: Unique id of the user whose face is getting added
        - `imageUri`: Array of local file paths(String) of the face images that have been added to the user's facelist
        - `faceIds`: Array of faceIds of the faces added to the user
    - Verification Mode:
        - `tenantId`: Used to identify the organization where verification has been performed.
        - `userId`: Unique id of the user on whom verification has been performed
        - `userInfo`: Some more details about the user
        - `imageUri`: Array with one string that represents the local file path of the face image on which Verification has been performed
    - Recognition Mode:
        - `tenantId`: Used to identify the organization where Recognition has been performed.
        - `groupId`: Group in which Recognition has been performed
        - `userId`: Unique id of the user recognized by Recognition
        - `userInfo`: Some more details about the user
        - `imageUri`: Array with one string that represents the local file path of the face image on which user has been recognized
    - Capture Mode:
        - `imageUri`: Array with one string that represents the local file path of the face image captured


##### Pausing or resuming processing
To pause or resume processing the camera feed for face detection and recognition, the following functions can be used.

- `hvfrcamera.pauseFR()` or `[hvfrcamera pauseFR]` will pause the Face Detection and auto-capture of faces
- `hvfrcamera.resumeFR()` or `[hvfrcamera resumeFR]` will resume the Face Detection and auto-capture of faces(if applicable).

##### Changing the configuration variables at runtime
If any of the configuration variables need to be changed at runtime, after `startCamera()` has been called, we can use the setter functions corresponding to the variables after the face processing has been safely paused with `pauseFR()`.

Objective C:
```
[hvfrcamera pauseFR]
[hvfrcamera setUserData:userData]
[hvfrcamera setMode:mode]
[hvfrcamera setTimeout:timeout]
[hvfrcamera setAutoCaptureEnabled:isAutoCaptureEnabled]
[hvfrcamera setCompletionHandler:completionHandler]
[hvfrcamera shouldUseFrontCam:useFrontCam]
[hvfrcamera resumeFR]
```
Swift:
```
hvfrcamera.pauseFR()
hvfrcamera.setUserData(userData)
hvfrcamera.setMode(mode)
hvfrcamera.setTimeout(timeout)
hvfrcamera.setAutoCaptureEnabled(isAutoCaptureEnabled)
hvfrcamera.setCompletionHandler(completionHandler)
hvfrcamera.shouldUseFrontCam(useFrontCam)
hvfrcamera.resumeFR()
```

##### Capturing Face Image Manually
To trigger on-demand capture of image and start Face Recognition/Registration on the captured frame, following method can be called:

   Objective C:
   
   ```
    [hvfrcamera capture:onCaptureHandler];
   ```
    
   Swift:
   
   ```
    hvfrcamera.capture(onCaptureHandler)
   ```
   
Here, `onCaputureHandler` is a closure of type `(_ error:NSError?, _ isSuccess:Bool) -> Void` in Swift and `^(NSError * _Nullable, BOOL)` in Objective C

If the capture is successful,  `isSuccess` is set to `true` and `error` is set to `nil`. Otherwise, `isSuccess` is `false` and `error` is an `NSError` object with the following information.
- `code`: Error code stating type of error. (discussed later)
- `userInfo`: A dictionary of type `[String:Any]`.It has only one key,  `NSLocalizedDescriptionKey`  which has the error description.

**Please note:**
- For registration/face add mode, no auto-capture will happen and this method should be explicitly called.

##### Submitting Captured image to Server
Once the required images have been captured, to start the transaction of Face Enrolling or Adding, following method should be called:

   Objective C:
   
   ```
    [hvfrcamera submit];
   ```
    
   Swift:
   
   ```
    hvfrcamera.submit()
   ```
**Please note:**
- this method can be called only for registration/face add mode
- after this method is complete, the completionHandler passed in `startCamera` is called with the results/error of the User Enroll or Face Add operation.

##### Clearing the images captured so far for REGISTRATION and FACE_ADD Mode
The following method can be called to clear the images that have been captured via `hvfrcamera.capture(onCaptureHandler)` method:

   Objective C:
    
   ```
    [hvfrcamera clearCapturedImages];
   ```
    
   Swift:
    
   ```
    hvfrcamera.clearCapturedImages()
   ```
**Please note:**
- This method will clear the reference of the images and delete the images from the disk as well.
- This method will clear only images that are yet to be submitted (or when a submission has failed).
- This method will work with only REGISTRATION and FACE_ADD Modes.
- This method will return an integer value which can be used to determine if the images were successfully cleared. Following are the values that can be returned:
    - `HVFrCamera.SUCCESS_CLEAR_CAPTURED_IMAGES`: This means that the images were cleared successfully
    - `HVFrCamera.ERROR_CLEAR_CAPTURED_IMAGES_INVALID_MODE`: This means that this method is called for an invalid mode. As mentioned above, this method only works for REGISTRATION and FACE_ADD mode.
    - `HVFrCamera.ERROR_CLEAR_CAPTURED_IMAGES_CAMERA_NOT_FREE`: This means that an image capture is in progress. Hence the images cannot be cleared now. When this error occurs, please retry after some time.
    - `HVFrCamera.ERROR_CLEAR_CAPTURED_IMAGES_PROCESSING_STARTED`: This means that an image upload is already in progress and hence the images cannot be cleared now. Please retry once the processing is done and the completion handler is called with an appropriate result.

##### Stopping the camera
- Add the following to the `viewWillDisappear` method of the ViewController (or anywhere apporpriate) to stop the camera and face recognition.

    Objective C:
    
    ```
    [hvfrcamera stopCamera];
    ```
    
    Swift:
    
    ```
    hvfrcamera.stopCamera()
    ```

##### Description of the Error Codes in the `error` parameter of the `completionHandler`  in  `startCamera` method:

|Error Code|Description|Explanation|Action|
|----------|-----------|-----------|------|
|1|Initialization Error|Occurs when SDK has not been initialized properly.|Check if the initialization of SDK is happening before any functionality is being used.|
|2|Input Error|Occurs when input provided to the specific flow(Recognition, Registration, Verification etc) is not correct.|Check if all the parameters provided are proper and as per the documentation|
|3|Network Error|Occurs when the internet is either non-existant or very patchy.|Check internet and try again. If Internet is proper, contact HyperVerge|
|4|Timeout Error|Occurs when the timeout(provided by user) is hit and the operation has not yet completed.|Try again|
|5|Authentication Error|Occurs when the request to server could not be Authenticated/Authorized. Happens when the tenantId, tenantKey and adminToken while initializing SDK are not correct.|Make sure tenantId, tenantKey and adminToken are correct|
|6|Internal Server Error|Occurs when there is an internal error at the server.|Notify HyperVerge|
|7|Request Error|Occurs when the request to server is missing some parameters.| Confirm if all the parameters are passed to the method properly|
|8|Internal SDK Error|Occurs when an unexpected error has happened with the HyperSecure SDK.|Notify HyperVerge|
|9|Face Recognition Error|Occurs when there is an error with the Face Recognition. This mosly happens when a Face Recognition/Verification flow is run on a person not already enrolled, face detected by the device is not very clear, unknown person is trying the recognition/verification.| Try again after ensuring that the person is already enrolled and the lightening is also proper.|
|10|Hardware Error|Occurs when there is an error setting up the camera.| Make sure the camera is accessible and only one instance of HVFrCamera is running.|
|11|Camera Permission Denied|Occurs when the user has denied permission to access camera.| In the settings app, give permission to access camera and try again.|


##### Description of the Error Codes in `onCaptureCallback` callback method of the `capture` method is given below:
|Error Code|Description|Explanation|Action|
|----------|-----------|-----------|------|
|1|Initialization Error|Occurs when SDK has not been initialized properly.|Check if the initialization of SDK is happening before any functionality is being used.|
|2|Input Error|Occurs when input provided to the specific flow(Recognition, Registration, Verification etc) is not correct.|Check if all the parameters provided are proper and as per the documentation|
|3|Camera Not Free Error|Occurs when the capture method is called even before the last capture is not complete. This error can be avoided by waiting for `onCaptureCallback` call before `calling` capture again|Try again|
|4|Face Detection Error|Occurs when the captured frame doesnot have any face in it.|Make sure the face is present in the frame. Also, the movement of camera and the face should be kept minimal while capturing. Also ensure that lightening is proper|
|5|Maximum Image Clicked Error|Occurs when the capture method is called after the number of valid captured images reach a threshold of `5`.|No more images can be clicked. Captured images should be submitted using `submit` method|

##### HVFrCameraDelegate:
- HVFrCamera view is equipped with a default alert view that is shown when a captured image is being processed. If this is to be overriden with your own design, please implement the `HVFrCameraDelegate`. Following are the steps required:
    - Confirm your `ViewController` class to the  `HVFrCameraDelegate` protocol:
    
        Objective C (ViewController.m file):
    
         ```
         @interface ViewController : UIViewController<HVFrCameraDelegate>
         ```
    
        Swift:
    
        ```
        class ViewController: UIViewController,HVFrCameraDelegate {
        ```
    
    - Set the ViewController as hvfrcamera's delegate in `viewDidLoad`:
    
        Objective C, Swift:
    
        ```
        hvfrcamera.delegate = self
        ```
    
    - Implement the methods of `HVFrCameraDelegate`:
    
        Objective C:
    
        ```
        -(void)willStartProcessingImage:(HVFrCamera*)hvfrcamera {}
        
        -(void)didCompleteProcessingImage:(HVFrCamera*)hvfrcamera {}

        ```
        
        Swift:
    
        ```
        func willStartProcessingImage(_ hvfrcamera: HVFrCamera) {}
        
        func didCompleteProcessingImage(_ hvfrcamera: HVFrCamera) {}
        ```

    **Please note:**
    Implementing the delegate is completely optional.

#### 4. Other operations
 - **Managing Users, Groups and UserData**

    Management of Users, Groups and UserData requires the ability to perform operations such as creating/deleting a Group, adding/removing a User from a Group, adding/removing a face registered to a User, etc. A complete list of such operations is given in the table below.
    
    | End Point | Request  | Result |
    |-----------|----------------|--------|
    |/user/edit|{<br/> "userId" : String,<br/> "details" : String<br/>}|{<br/>}|
    |/user/get|{<br/> "userId" : String <br/>}|{<br/> "userId" : String,<br/> "roles" : [roles],<br/> "createdDate" : Int, <br/> "details"     : String, <br/>"groups" : [{<br/>"groupId" : String,<br/>"role" : String<br/>}],<br/>"faces" : [faceId]<br/>}|
    |/user/remove|{<br/> "userId" : String<br/>}|{<br/>}|
    |/user/removeFace|{<br/> "userId" : String,<br/> "faceId" : String<br/> }|{<br/>}|
    |/user/fetchFaces|{<br/> "userId" : String <br/>}|{<br/> "faces": [String] <br/>}|
    |/user/fetchFaceUrls|{<br/> "userId" : String <br/>}|{<br/> "faceUrls": [String] <br/>}|
    |/user/auth|{<br/> "userId" : String,<br/> "otp" : String, <br/> "permanent" : true/false /\*Default false\*/ <br/>}|{<br/> "token" : string <br/>}|
    |/user/getOTP|{<br/> "userId" : String <br/>}|{<br/> "otp": String <br/>}|
    |/group/create|{<br/> "groupname" : String,<br/> "sizeLimit" : number <br/>}|{<br/> "groupId" : String <br/>}|
    |/group/get|{<br/> "groupId" : String <br/>}|{<br/>"groupname" : String,<br/> "sizeLimit" : String,<br/> "createdDate" : Int <br/>}|
    |/group/edit|{<br/> "groupId" : String,<br/> "params" : {<br/> "groupname" : String,<br/> "sizeLimit" : Int <br/>} <br/>}|{<br/>}|
    |/group/remove|{<br/> "groupId" : String <br/>}|{<br/>}|
    |/group/addUser|{<br/> "groupId" : String,<br/> "userId" : String <br/>}|{<br/>}|
    |/group/removeUser|{<br/> "groupId" : String,<br/> "userId" : String <br/>}|{<br/>}|
    |/group/userRole|{<br/> "groupId" : String,<br/> "userId" : String,<br/> "groupRole" : groupRole,/* "user" or "groupAdmin" \*/ <br/>}|{<br/>}|
    |/group/listUsers|{<br/> "groupId" : String <br/>}|{<br/> "users":[{<br/> "userId" : String,<br/> "details" : String,<br/> "createdTime" : Int ,<br/> faces : [faceId]<br/>}] <br/>}|
    
    <br/>
    - Any of the operations mentioned in the table above can be performed using the following method:
    
      Objective C:
       
      ```
        NSInteger requestId = [HVOperationManager makeRequestWithEndPoint:endpoint request:requestParameters           completionHandler:completionHandler]
      ```
        
      Swift:
       
      ```
        let requestId = HVOperationManager.makeRequest(endpoint:endpoint, request:requestParameters, completionHandler:completionHandler)
      ```
    
    The completionHandler is similar to the one from the `startCamera` method. i.e, it is of type `error:NSError?, result:[String:AnyObject]?) -> Void` in Swift and `^(NSError * _Nullable, NSDictionary<NSString *,id> * _Nullable)` in Objective C.
    
    The result object has been decribed in the previous table. The error codes are in the next secion.

 - **Process captured images**

    To perform an operation that requires one or more locally present images to be uploaded to the server, one of the following operation can be used. These operations can enable the developer to enroll a user using one or more face images, add one or more face images to a user, perform face based authentication using a face image, perform 1:1 recognition or 1:N recognition using an image saved in the device.
    
    | End Point | Request  | Number of Images | Result |
    |-----------|----------------|-----|--------|
    |/user/faceauth|{<br/> "userId" : String<br/>}| 1 |{<br/> "token" : String<br/>}|
    |/user/enroll|{<br/>"userId" : String,<br/> <br/>"groupId" : String,<br/> <br/> "details" : String<br/>}| 1 to 5 |{<br/> "faceIds" : [String],<faceId><br/> <br/> "faceId" : [String : AnyObject]<br/>}|
    |/user/addFace|{<br/> "userId" : String<br/>}| 1 to 5 |{<br/> "faceIds" : [String],<faceId><br/> <br/> "faceId" : [String : AnyObject]<br/>}|
    |/image/verify|{<br/> "userId" : String<br/>}| 1 |{<br/> "faceId" : String,<br/> <br/> "personId" : String,<br/> <br/> "conf" : Integer<br/>}|
    |/image/recognize|{<br/> "groupId" : String<br/>}| 1 |{<br/> "faceId" : String,<br/> <br/> "personId" : String,<br/> <br/> "userDetails" : [String:AnyObject],<br/> <br/> "details" : String,<br/> <br/> "exists" : Boolean,<br/> <br/> "conf" : Integer<br/>}|
    
    <br/>
    
    - The above operations can also be performed in a way similiar to that mentioned in the last section
    
      Objective C:
        
        ```
        NSInteger requestId = [HVOperationManager makeRequestWithEndPoint:endpoint images:imagesUri request:requestParameters completionHandler:completionHandler]
        ```
        
      Swift:
        
        ```
        let requestId = HVOperationManager.makeRequest( endpoint:endpoint, images:imagesUri, request:requestParameters, completionHandler:completionHandler)
        ```
        Here, 
        - `endpoint` is a String and has been described in the table above
        - `imagesUri` is an array of Strings, representing the local image path.
        - `requestParameters` is a Dictionary and is represented by the `Request` column in the table above
        - `completionHandler` is same as the `completionHandler` mentioned in the `makeRequest` method mentioned above
        
    To `cancel` an operation started using HVOperationManager's `makeRequest` method, following method can be used.
    
    Objective C:
       
    ```
      Boolean isCancelled = [HVOperationManager cancelRequest:requestId];
    ```
        
    Swift:
       
    ```
      let isCancelled = HVOperationManager.cancelRequest(requestId)
    ```
        
    where `requestId` was returned by the corresponding `makeRequest` method that is needed to be cancelled.

    ##### Description of the Error Codes returned from the completionHandler mentioned above has been given below:

    |Error Code|Description|Explanation|Action|
    |----------|-----------|-----------|------|
    |1|Initialization Error|Occurs when SDK has not been initialized properly.|Check if the initialization of SDK is happening before any functionality is being used.|
    |2|Network Error|Occurs when the internet is either non-existant or very patchy.|Check internet and try again. If Internet is proper, contact HyperVerge|
    |3|Authentication Error|Occurs when the request to server could not be Authenticated/Authorized. Happens when the tenantId, tenantKey and adminToken while initializing SDK are not correct.|Make sure tenantId, tenantKey and adminToken are correct|
    |4|Internal Server Error|Occurs when there is an internal error at the server.|Notify HyperVerge|
    |5|Internal SDK Error|Occurs when an unexpected error has happened with the HyperSecure SDK.|Notify HyperVerge|
    |603|INPUT_MISSING_USER_ID |Occurs when the request JSON Object is missing `userId`|Provide `userId` in the request JSON Object and retry|
    |604|INPUT_MISSING_USER_DETAILS |Occurs when the request JSON Object is missing `details`|Provide `details` in the request JSON Object and retry|
    |605|INPUT_MISSING_GROUPS |Occurs when the request JSON Object is missing `groups`|Provide `groups` in the request JSON Object and retry|
    |606|INPUT_MISSING_GROUP_ID |Occurs when the request JSON Object is missing `groupId`|Provide `groupId` in the request JSON Object and retry|
    |607|INPUT_MISSING_GROUP_NAME |Occurs when the request JSON Object is missing `groupName`|Provide `groupName` in the request JSON Object and retry|
    |608|INPUT_MISSING_GROUP_ROLE |Occurs when the request JSON Object is missing `groupRole`|Provide `groupRole` in the request JSON Object and retry|
    |609|INPUT_MISSING_GROUP_SIZE_LIMIT |Occurs when the request JSON Object is missing `sizeLimit`|Provide `sizeLimit` in the request JSON Object and retry|
    |610|INPUT_MISSING_IMAGE |Occurs when the request JSON Object is missing `image`|Provide `image` in the request JSON Object and retry|
    |611|INPUT_MISSING_ROLE |Occurs when the request JSON Object is missing `role`|Provide `role` in the request JSON Object and retry|
    |612|INPUT_MISSING_FACE |Occurs when the request JSON Object is missing `face`|Provide `face` in the request JSON Object and retry|
    |613|INPUT_MISSING_FACE_ID |Occurs when the request JSON Object is missing `faceId`|Provide `faceId` in the request JSON Object and retry|
    |614|INPUT_MISSING_FACE_IDS |Occurs when the request JSON Object is missing `faceIds`|Provide `faceIds` in the request JSON Object and retry|
    |615|INPUT_USER_NOT_FOUND |Occurs when there is no user associated with the `userId` provided|Provide correct `userId` and retry|
    |616|INPUT_USER_ALREADY_EXIST |Occurs when a user with `userId` provided already exists|Provide a new unique `userId` and retry|
    |617|INPUT_GROUP_NOT_FOUND |Occurs when no group is associated with the `groupId` provided|Provide correct `groupId` and retry|
    |618|INPUT_GROUP_ALREADY_EXIST |Occurs when a group already exists with the `groupId` provided|Provide a new unique `groupId` and retry|
    |621|INPUT_OTP_MISMATCH |Occurs when the OTP provided doesnot match the one that is sent to the user|Provide correct `otp` and retry|
    |622|ERROR_INPUT_INVALID_ENDPOINT |Occurs when the `endPoint` provided is not valid|Provide correct the `endPoint` and retry|
    |699|INPUT_OTHER |Occurs when some other issue is with the input|Read the log message for detailed explanation|

