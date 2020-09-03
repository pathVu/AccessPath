//
//  MotionObservable.swift
//  Access Path
//
//  Created by Chetu on 9/22/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import Foundation
import CoreMotion

let Fps60 = 0.016

class MotionObservable {
    
    let motionManager: CMMotionManager
    let updateInterval: Double = Fps60
    
    var gyroObservers = [(Double, Double, Double) -> Void]()
    var accelerometerObservers = [(Double, Double, Double) -> Void]()
    var magnetometerObservers = [(Double, Double, Double) -> Void]()
    // MARK: Public interface
    
    /* Changed by chetu
     * initaialize the motion manager
     */
    init() {
        motionManager = CMMotionManager()
        initMotionEvents()
    }
    
    /* Changed by chetu
     * Add observer for gyroscope
     */
    func addGyroObserver(observer: @escaping (Double, Double, Double) -> Void) {
        gyroObservers.append(observer)
    }
    
    
    /* Changed by chetu
     * Add observer for accelerometer
     */
    func addAccelerometerObserver(observer: @escaping (Double, Double, Double) -> Void) {
        accelerometerObservers.append(observer)
    }
    
    /* Changed by chetu
     Add observer for magnetometer
     */
    
    func addMagnetometerObserver(observer: @escaping (Double, Double, Double) -> Void) {
        magnetometerObservers.append(observer)
    }
    
    
    /* Changed by chetu
     clear observer for  stop accelerometer,gyroscope, magnetometer.
     */
    func clearObservers() {
        gyroObservers.removeAll()
        accelerometerObservers.removeAll()
        magnetometerObservers.removeAll()
    }
    
    
    // MARK: Internal methods
    /* Changed by chetu
     notify observer get gyroscope value
     */
    private func notifyGyroObservers(x: Double, y: Double, z: Double) {
        for observer in gyroObservers {
            observer(x, y, z)
        }
    }
    
    
    /* Changed by chetu
     notify observer get accelerometer value
     */
    private func notifyAccelerometerObservers(x: Double, y: Double, z: Double) {
        for observer in accelerometerObservers {
            observer(x, y, z)
        }
    }
    
    
    /* Changed by chetu
     notify observer get magnetometer value
     */
    private func notifymagnetometerObservers(x: Double, y: Double, z: Double) {
        for observer in magnetometerObservers {
            observer(x, y, z)
        }
    }
    
    
    /* Changed by chetu
       method for round the double values
     */
    private func roundDouble(value: Double) -> Double {
        return round(1000 * value)/100
    }
    
    
    /* Changed by chetu
     method for motion events occur from device
     */
    private func initMotionEvents() {
        if motionManager.isGyroAvailable || motionManager.isAccelerometerAvailable || motionManager.isMagnetometerAvailable {
            motionManager.deviceMotionUpdateInterval = updateInterval;
            motionManager.startDeviceMotionUpdates()
        }
        
        // Gyroscope is available and start update gyro scope values
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = updateInterval
            motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
                let rotation = gyroData!.rotationRate
                let x = self.roundDouble(value: rotation.x)
                let y = self.roundDouble(value: rotation.y)
                let z = self.roundDouble(value: rotation.z)
                self.notifyGyroObservers(x: x, y: y, z: z)
                
                if (NSError != nil){
                    print("\(String(describing: NSError))")
                }
            })
        } else {
            print("No gyro available")
        }
        
        // Accelerometer is available and start update Accelerometer  values
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = updateInterval
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
                
                if let acceleration = accelerometerData?.acceleration {
                    let x = self.roundDouble(value: acceleration.x)
                    let y = self.roundDouble(value: acceleration.y)
                    let z = self.roundDouble(value: acceleration.z)
                    self.notifyAccelerometerObservers(x: x, y: y, z: z)
                }
                if(NSError != nil) {
                    print("\(String(describing: NSError))")
                }
            }
        } else {
            print("No accelerometer available")
        }
       
        //Magnetometer is available and start update magnetometer values
    
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = updateInterval
            motionManager.startMagnetometerUpdates(to: OperationQueue.current!) { (magnetometerData: CMMagnetometerData?, NSError) -> Void in
 
                
                if let magnetfield = magnetometerData?.magneticField {
                    let x = self.roundDouble(value: magnetfield.x)
                    let y = self.roundDouble(value: magnetfield.y)
                    let z = self.roundDouble(value: magnetfield.z)
                    self.notifymagnetometerObservers(x: x, y: y, z: z)
                }
                if(NSError != nil) {
                    print("\(String(describing: NSError))")
                }
            }
        } else {
            print("No magnetometer available")
        }
        
        
    }
}
