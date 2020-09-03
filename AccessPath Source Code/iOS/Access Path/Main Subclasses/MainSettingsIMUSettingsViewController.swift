//
//  MainSettingsIMUSettingsViewController.swift
//  Access Path
//
//  Created by Chetu on 9/26/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

//

import UIKit
import  Alamofire
import SwiftyJSON
import Reachability
import CoreLocation

/**
 * This class is a dynamic class for changing alert IMU settings.
 * The type of alert depends on the value passed to this class.
 * This class simply saves the alert value to shared preferences.
 */
class MainSettingsIMUSettingsViewController: UIViewController, CLLocationManagerDelegate {
    var gameTimer: Timer?
    var preferences = UserDefaults.standard
    // for core motion get accelerator value
    internal let motion = MotionObservable()
    var isActive: Bool = false
    //UI Outlets
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var alertOnButton: UIButton!
    @IBOutlet weak var alertOffButton: UIButton!
    @IBOutlet weak var alertOnCheckmark: UIImageView!
    @IBOutlet weak var alertOffCheckmark: UIImageView!
    
    /// IMU info api send Data
    var acctid = String()
    var usession = 0
    var lat = 0.0
    var  lon = 0.0
    var accxaxis = 0.0
    var accyaxis = 0.0
    var acczaxis = 0.0
    var gyoxaxis = 0.0
    var gyoyaxis = 0.0
    var gyozaxis = 0.0
    var magxaxis = 0.0
    var magyaxis = 0.0
    var magzaxis = 0.0
    var locManager = CLLocationManager()
    
    var alertSetting = -1
    //Hazard type will be passed to this class
    var type = -1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let uacctId = preferences.string(forKey: PrefKeys.aidKey)else {
            return
        }
        acctid = uacctId
        guard  let usessionValue =  preferences.value(forKey:PrefKeys.sessionImuVaue) as? Int else {
            alertOffCheckmark.isHidden = true
            alertOnCheckmark.isHidden = true
            return
        }
        
        usession = usessionValue
        self.updateLocationCorrdinateMethod()
        //Get the type of hazard and load it
        type = preferences.integer(forKey: PrefKeys.IMUSettingsType)
        
        //Loads the user's IMU setting, if set
        loadData()
        loadType()
    }
    
    
    /** Created by chetu
     *  method for  view diddisappear
     */
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // self.stopTimerTest()
    }
    
    
    /** Created by chetu
     *  method for update get user  location
     */
    func updateLocationCorrdinateMethod(){
        locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.distanceFilter = 30.0
        locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation()
        
        if(locManager.location != nil) {
            lat = (locManager.location?.coordinate.latitude)!
            lon = (locManager.location?.coordinate.longitude)!
        }
        
    }
    
    
    /**
     * Alert On Button Handler
     */
    @IBAction func alertOnButtonPressed(_ sender: Any) {
        alertSetting = 1
        setSelected(selectedButton: alertOnButton!)
        saveData()
        alertOnCheckmark.isHidden = false
    }
    
    /**
     * Alert Off Button Handler
     */
    @IBAction func alertOffButtonPressed(_ sender: Any) {
        alertSetting = 2
        setSelected(selectedButton: alertOffButton!)
        saveData()
        alertOffCheckmark.isHidden = false
    }
    
    /**
     * Saves the setting into shared preferences
     */
    @IBAction func saveButtonPressed(_ sender: Any) {
        saveData()
    }
    
    /**
     * Sets a button to the default white color
     */
    func setDefaultButtonStyles(btn: UIButton) {
        btn.layer.backgroundColor = UIColor.white.cgColor
        btn.layer.cornerRadius = 5
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = AppColors.defaultBorder.cgColor
    }
    
    /**
     * Sets a checkmark to be hidden
     */
    func setDefaultCheckmarkStyles(checkmark: UIImageView) {
        checkmark.isHidden = true
    }
    
    /**
     * Sets the style of the currently selected button
     * Clears the styles of the unselected buttons
     */
    func setSelected(selectedButton: UIButton) {
        
        //Button array
        let buttons = [alertOnButton, alertOffButton]
        
        //Checkmark array
        let checkmarks = [alertOnCheckmark, alertOffCheckmark]
        
        //Set all buttons to their default style
        for btn in buttons {
            setDefaultButtonStyles(btn: btn!)
        }
        
        //Set all checkmarks to their default style
        for checkmark in checkmarks {
            setDefaultCheckmarkStyles(checkmark: checkmark!)
        }
        
        //Set the border and background colors of selected button
        selectedButton.layer.borderColor = AppColors.selectedBorder.cgColor
        selectedButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
    }
    
    
    
    /**
     * Saves the user's selected alert setting
     * This happens after every button press
     */
    func saveData() {
        preferences.setValue(alertSetting, forKey: PrefKeys.IMUSettingsType)
        
        let saveStatus = preferences.synchronize()
        loadData()
        if(!saveStatus){
            print("Error saving settings")
        }
    }
    
    
    /**
     * Loads the user's alert setting if it has previously been set.
     * If it has been set, the correct button is highlighted to reflect their alert setting.
     * If it has not been set, nothing happens and the all buttons are their default style.
     */
    func loadData() {
        if(preferences.object(forKey:  PrefKeys.IMUSettingsType) != nil) {
            alertSetting = preferences.integer(forKey:  PrefKeys.IMUSettingsType)
        }
        else{
            alertOffCheckmark.isHidden = true
            alertOnCheckmark.isHidden = true
            alertSetting = 0
        }
        switch alertSetting {
        case 2:
            setSelected(selectedButton: alertOffButton)
            //call method for  remove acceleromter and Gyroscope value from device
            self.stopTimerTest()
            self.motion.clearObservers()
            
            alertOffCheckmark.isHidden = false
            break
            
        case 1:
            setSelected(selectedButton: alertOnButton)
            self.callIMUmethod()
            usession =  usession + 1
            preferences.set(usession, forKey: PrefKeys.sessionImuVaue)
            preferences.synchronize()
            alertOnCheckmark.isHidden = false
            break
        case 0:
            alertOffCheckmark.isHidden = true
            alertOnCheckmark.isHidden = true
            break
        default:
            alertOffCheckmark.isHidden = true
            alertOnCheckmark.isHidden = true
            break
        }
    }
    
    
    
    
    
    
    /**
     * Sets the button text depending on the hazard type
     */
    func setButtonText(hazardType: String) {
        alertOnButton.setTitle("\(turnOn) " + hazardType, for: .normal)
        alertOffButton.setTitle("\(turnOff) " + hazardType, for: .normal)
    }
    
    
    /**
     * Load which obstruction type the user is changing the setting for
     * based on what they chose on the obstruction list.
     */
    func loadType() {
        titleText.text = PrefKeys.iMUAlert
        descriptionText.text = PrefKeys.receiveAlertsIMU
        setButtonText(hazardType: PrefKeys.IMU)
    }
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.stopTimerTest()
        self.dismiss(animated: true, completion: nil)
    }
    
    //Return to obstruction list
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.stopTimerTest()
        performSegue(withIdentifier: StoryboardIdentifier.unwindToObstructionList, sender: self)
    }
    
    /*
     Changed by chetu
     getting value of Accelerometer,Gyroscope and Magnetometer
     */
    
    // for get accelroratoe values
    
    func callIMUmethod(){
        //call method for acceleromter and Gyroscope value from device
        self.initAccelerometer()
        
        // add timer with call  Api method for every 30 sec
        gameTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(callIMUApiMethod), userInfo: nil, repeats: true)
    }
    
    func stopTimerTest() {
        if gameTimer != nil {
            gameTimer?.invalidate()
            gameTimer = nil
        }
    }
    
    /** Created by chetu
     * func call api method for get IMU data
     */
    @objc func callIMUApiMethod(){
        debugPrint("123")
        // call api for Imu infroamtion
        self.checkForConnection()
        //self.imuInfoDictionaryMthod()
    }
    
    /** Created by chetu
     * func get accellerometer values
     */
    func initAccelGyro() {
        motion.addGyroObserver(observer: {(x: Double, y: Double, z: Double) -> Void in
            let summary = Int(abs(x) + abs(y) + abs(z))
            print("Gyro: \(summary) X:\(x) y:\(y) Z: \(z)")
            self.gyoxaxis = x
            self.gyoyaxis = y
            self.gyozaxis = z
            self.initMagnetometer()
            
        })
        //...
    }
    
    /** Created by chetu
     * func get accellerometer values
     */
    func initAccelerometer(){
        motion.addAccelerometerObserver(observer: {(x: Double, y: Double, z: Double) -> Void in
            let summary = Int(abs(x) + abs(y) + abs(z))
            self.magxaxis = x
            self.magyaxis = y
            self.magzaxis = z
            self.initAccelGyro()
            
        })
    }
    
    
    /** Created by chetu
     *  func get Magnetometer values
     */
    
    func initMagnetometer(){
        motion.addMagnetometerObserver(observer: {(x: Double, y: Double, z: Double) -> Void in
            let summary = Int(abs(x) + abs(y) + abs(z))
            self.accxaxis = x
            self.accyaxis = y
            self.acczaxis = z
            //           // call api for Imu infroamtion
            //         self.imuInfoDictionaryMthod()
        })
        //...
    }
    
    /** Created by chetu
     * This function  POST parameters to the server
     */
    func imuInfoDictionaryMthod(){
        //POST parameters
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = ValidEmailFormattor.yearDateFormattor
        let timeResult = formatter.string(from: date)
        
        let parameters = [
            AxisKeys.uAcctid: acctid,
            AxisKeys.uSession: usession,
            AxisKeys.uTime: timeResult,
            AxisKeys.latKey: lat,
            AxisKeys.lonKey: lon,
            AxisKeys.accXaxis:accxaxis,
            AxisKeys.accYaxis:accyaxis,
            AxisKeys.accZaxis: acczaxis,
            AxisKeys.gyoXaxis:gyoxaxis,
            AxisKeys.gyoYaxis:gyoyaxis,
            AxisKeys.gyoZaxis:gyozaxis,
            AxisKeys.magXaxis:magxaxis,
            AxisKeys.magYaxis:magyaxis,
            AxisKeys.magZaxis:magzaxis
            ] as [String : Any]
        
        self.imuInformationApi(parameter:parameters)
    }
    
    
    /** Created by chetu
     * This function Imu information  POST parameters to the server
     */
    func imuInformationApi(parameter:[String:Any]) {
        //Server PHP URL
        let url = APIURL.newimudataUrl
        let headers:HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        let post :HTTPMethod = .post
        //POST parameters
        let parameters = parameter
        Alamofire.request(url,method:post,parameters: parameters, encoding: JSONEncoding.default,headers: headers).responseJSON{ (response)-> Void in
            
            switch response.result
            {
            case .success(let data):
                debugPrint(data)
            case .failure(let error):
                debugPrint(error)
                break
                
            }
            
        }
    }
    
    /** Changed by Chetu
     * Performs initial network and server checks and adds listeners in case
     * the network/server is unreachable after loading this view controller.
     */
    func checkForConnection() -> Bool {
        var connectionStatus:Bool = false
        NetworkChecks.isReachable { _ in
            print("Network Connected")
            connectionStatus = true
            //      self.imuInfoDictionaryMthod()
        }
        NetworkChecks.isUnreachable { _ in
            print("Network is Unavailable")
            connectionStatus = false
        }
        return connectionStatus
    }
    
    
    /** Created by Chetu
     * TODO: Change tolocation changed handler
     * Users location changed handler
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lat = (manager.location?.coordinate.latitude)!
        self.lon = (manager.location?.coordinate.longitude)!
    }
}
