//
//  BaseRouteVC.swift
//  Access Path
//
//  Created by chetu on 17/05/19.
//  Copyright © 2019 pathVu. All rights reserved.
//

import UIKit
import ArcGIS
import AudioToolbox

class BaseRouteVC: UIViewController {

    //Route Solving
    var route:AGSRoute?
    var routeOverlay:AGSGraphicsOverlay?
    var routeParameters:AGSRouteParameters?
    var routeResult:AGSRouteResult?
    var routeTask:AGSRouteTask?
    var routeTaskInfo:AGSRouteTaskInfo?
    var routeTaskUrl:String?
    var travelModes:[AGSTravelMode]?
    var travelMode: AGSTravelMode?
    var enteredStop:AGSStop?
    var fromStop:AGSStop?
    var sourceLocationStop:AGSStop?
    var toStop:AGSStop?
    var userStartStop:AGSStop?
    
    var featureModelArray = [hazardFeaturesModel]()
    var manueverArray = [manueverListModel]()
    var routeGeometryArray = [routeGeometryModel]()
    
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    //PHP calls class instance
    let pathVuPHP = PHPCalls()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Route Url
        routeTask = AGSRouteTask(url: RoutingUrls.routeTaskURL!)
        // Do any additional setup after loading the view.
    }
    
    /*
     Changed by Chetu
     Route method call and created travel mode attributed parameter
     */
    func routeMe() {
        var thComfortValue:Float?
        var rsComfortKeyValue:Float?
        var csComfortKeyValue:Float?
        var roComfortKeyValue:Float?
        self.routeTask?.load { (error) -> Void in
            
            // by chetu add error check for load rote task
            if let error = error{
                debugPrint(error)
            }
            else{
                self.routeTaskInfo = self.routeTask?.routeTaskInfo()
                self.travelModes = self.routeTaskInfo?.travelModes
                
                //get one travel mode from travels mode
                self.travelMode = self.travelModes?.first
                
                //travelModesData
                self.routeTask?.defaultRouteParameters { [weak self] (params: AGSRouteParameters?, error: Error?) -> Void in
                    if let error = error {
                        debugPrint(error)
                    }
                    else {
                        debugPrint("Received route parameters \(String(describing: params))")
                        self?.routeParameters = params
                        
                        for  model in (self?.routeParameters?.travelMode?.attributeParameterValues)! {
                            if model.parameterName == thwString {
                                if let thvalue =  self?.preferences.value(forKey:PrefKeys.thComfortKeyValue) as? Int {
                                    thComfortValue = Float(thvalue)
                                }
                                else{
                                    thComfortValue = 1.0
                                }
                                model.parameterValue = thComfortValue
                            }
                                //added attribute set  RSw
                            else if model.parameterName == rswString {
                                if let thvalue =  self?.preferences.value(forKey:PrefKeys.rsComfortKeyValue) as? Int {
                                    rsComfortKeyValue = Float(thvalue)
                                }
                                else{
                                    rsComfortKeyValue = 1.0
                                }
                                model.parameterValue = rsComfortKeyValue
                            }
                                
                                //added attribute set CSw
                            else if model.parameterName == cswString {
                                if let thvalue =  self?.preferences.value(forKey:PrefKeys.csComfortKeyValue) as? Int {
                                    csComfortKeyValue = Float(thvalue)
                                }
                                else{
                                    csComfortKeyValue = 1.0
                                }
                                model.parameterValue = csComfortKeyValue
                                
                            }
                                //added attribute set ROw
                            else if model.parameterName == rowString {
                                //ro
                                if let thvalue =  self?.preferences.value(forKey:PrefKeys.rComfortKeyValue) as? Int {
                                    roComfortKeyValue = Float(thvalue)
                                }
                                else{
                                    roComfortKeyValue = 1.0
                                }
                                model.parameterValue = roComfortKeyValue
                            }
                        }
                        
                        //show route
                        //self?.showRoute()
                    }
                }
            }
        }
    }
    
    
    
    
    /**
     * This function is responsible for getting a route based on certain route parameters
     * and displaying it on the map.
     */
    func showRoute(routeParameters:AGSRouteParameters?, completionHandler:@escaping (AGSRoute)->Void) {
        
        //Solve the route with the given parameters
        if(routeParameters != nil) {
            routeTask?.solveRoute(with: self.routeParameters!) { (routeResult: AGSRouteResult?, error: Error?) -> Void in
                if let error = error {
                    debugPrint(error)
                    //Show an alert if a route cannot be found
                    let alert = UIAlertController(title: AlertConstant.notRouteAvailable, message: AlertConstant.notRouteDisplay, preferredStyle: UIAlertControllerStyle.alert)
                    self.present(alert, animated: true, completion: nil)
                    alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                        switch action.style{
                        default:
                            //Go back to search screen
                            debugPrint("nothing")
                            self.dismiss(animated: true, completion: nil)
                        }
                    }))
                } else {
                    if(routeResult != nil) {
                        //Get best route
                        guard let routes = routeResult?.routes else {
                            return
                        }
                        self.route = routes.first
                        completionHandler(self.route!)
                        
                        //TODO: Change the hazard layer
                        if (self.preferences.bool(forKey: crowdSourceString)) {
                            //self.getHazardsInRoute()
                        }

                    } else {
                        debugPrint("No route")
                    }
                }
                ////
            }
        }
        //
        else {
            debugPrint("Did not load route parameters")
        }
    }
    
    
    
}
