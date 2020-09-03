//
//  PHPCalls.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/23/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleMaps

class PHPCalls {
    
    //Data saved on the device
    let preferences = UserDefaults.standard
    
    /**
     * PHP call for signing up with an email address
     */
    func emailSignUp(firstName:String, lastName:String, email:String, password:String) -> Int {
        
        var signUpStatus = 0
        
        let postString = "ufirstname=" + firstName + "&ulastname=" + lastName + "&uemail=" + email + "&upassword=" + password
        
        let group = DispatchGroup()
        let url = URL(string: "https://pathvudata.com/api1/api/users/add/* removed for security purposes */")!
        var request = URLRequest(url: url)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<newuser.php>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<newuser.php>: Failure:" + (response?.description)!)
                print("<newuser.php>: Error Code: \(httpStatus.statusCode)")
            }
            let responseString = String(data: data, encoding: .utf8) ?? ""
            let aid = "\(responseString.replacingOccurrences(of: "\"", with: ""))"
            if Int(aid) != nil {
                self.preferences.set(aid, forKey: PrefKeys.aidKey)
                self.preferences.set(aid, forKey: PrefKeys.uidKey)
                print("<newuser.php>: Sign up Successful")
                print("<newuser.php>: Account ID: " + aid)
                signUpStatus = 1
            }
            else if responseString.contains("ua006") {
                print("<newuser.php>: \(responseString)")
                signUpStatus = 2
            }
            else {
                print("<newuser.php>: " + responseString)
                signUpStatus = 5
            }
            group.leave()
        }
    
        group.enter()
        task.resume()
        group.wait()
        
        return signUpStatus
    }
    
    /**
     * PHP call for creating a new user account with Google
     */
    func signUpWithGoogle(gtoken:String) -> Int {
        
        var status = 0
        
        let postString = "gtoken=" + gtoken + "&uisgoogle=1"
        
        let group = DispatchGroup()
        let url = URL(string: "https://pathvudata.com/api1/api/users/add/* removed for security purposes */")!
        var request = URLRequest(url: url)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            
            guard let data = data, error == nil else {
                print("<signUpWithGoogle>: Error: " + (error?.localizedDescription)!)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<signUpWithGoogle>: Failure:" + (response?.description)!)
                print("<signUpWithGoogle>: Error Code: \(httpStatus.statusCode)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            let json = JSON(data)
            let typeValue = Int(json.arrayValue.first?["typeset"].string ?? "-1")
            let settingsValue = Int(json.arrayValue.first?["settingsset"].string ?? "-1")
            if json["new"] != nil || typeValue == 0 || settingsValue == 0 {
                if json["new"] != nil {
                    if let aid = Int(json["new"].stringValue) {
                        print("<signUpWithGoogle: Success: \(json)")
                        self.preferences.set(aid, forKey: PrefKeys.aidKey)
                        self.preferences.set(aid, forKey: PrefKeys.uidKey)
                        print("<signUpWithGoogle>: Sign up Successful")
                        print("<signUpWithGoogle>: Account ID: " + String(aid))
                        status = 1
                    }
                }
                else if json.arrayValue.first?["login"] != nil {
                    if let aid = Int((json.arrayValue.first?["login"].stringValue)!) {
                        print("<signUpWithGoogle>: user already exists but has not completed onboarding: \(json)")
                        self.preferences.set(aid, forKey: PrefKeys.aidKey)
                        self.preferences.set(aid, forKey: PrefKeys.uidKey)
                        print("<signUpWithGoogle>: Account ID: " + String(aid))
                        status = 1
                    }
                    else {
                        print("<signUpWithGoogle>: Error signing up: \(responseString)")
                    }
                }
            }
            else if json.arrayValue.first?["login"] != nil {
                if let aid = Int((json.arrayValue.first?["login"].stringValue)!) {
                    self.preferences.set(aid, forKey: PrefKeys.aidKey)
                    self.preferences.set(aid, forKey: PrefKeys.uidKey)
                    print("<signUpWithGoogle>: User account already exists")
                    status = 2
                }
            }
            else {
                print(json)
                print("<signUpWithGoogle>: " + (responseString ?? "Error" ))
            }
            group.leave()
        }
        
        group.enter()
        task.resume()
        group.wait()
        
        return status
    }
    
    
    /**
     * PHP call for creating a new user account with Facebook
     */
    func signUpWithFacebook(ftoken: String) -> Int {
        var status = -1
        let postString = "ftoken=" + ftoken + "&uisfacebook=1"
        
        let group = DispatchGroup()
        let url = URL(string: "https://pathvudata.com/api1/api/users/add/* removed for security purposes */")!
        var request = URLRequest(url: url)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<newfbuser.php>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<newfbuser.php>: Failure:" + (response?.description)!)
                print("<newfbuser.php>: Error Code: \(httpStatus.statusCode)")
            }
            
            else {
                let responseString = String(data: data, encoding: .utf8)
                let json = JSON(data)[0]
                let typeValue = Int(json["typeset"].string ?? "-1")
                let settingsValue = Int(json["settingsset"].string ?? "-1")
                if json["new"] != nil || typeValue == 0 || settingsValue == 0 {
                    let aid = Int((json["new"].stringValue)) ?? Int((json["login"].stringValue))
                    if aid != nil {
                        self.preferences.set(aid, forKey: PrefKeys.aidKey)
                        self.preferences.set(aid, forKey: PrefKeys.uidKey)
                        print("<newguestuser>: Sign up Successful")
                        status = 1
                    }
                    else {
                        print("<newguestuser>: Error signing up")
                    }
                }
                else if json["login"] != nil {
                    if let aid = Int((json["login"].stringValue)) {
                        self.preferences.set(aid, forKey: PrefKeys.aidKey)
                        self.preferences.set(aid, forKey: PrefKeys.uidKey)
                        print("<newguestuser>: User account already exists")
                        status = 2
                    }
                }
                else {
                    print("<newguestuser>: " + (responseString ?? "Error" ))
                }
            }
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()
        
        return status
    }
    
    /**
     * PHP call for creating a new guest user account
     */
    func signUpAsGuest(uacctid: String) -> Int {

        var signUpStatus = -1
        var json:JSON = nil
        var postString = ""
        if uacctid != "" {
            postString = "uacctid=" + uacctid
        }
        
        
        let group = DispatchGroup()
        let url = URL(string: "https://pathvudata.com/api1/api/users/addguestuser/* removed for security purposes */")!
        var request = URLRequest(url: url)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<newguestuser.php>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<newguestuser.php>: Failure:" + (response?.description)!)
                print("<newguestuser.php>: Error Code: \(httpStatus.statusCode)")
            }
            else {
                let responseString = String(data: data, encoding: .utf8)
                json = JSON(data)
                let typeValue = Int(json["typeset"].string ?? "-1")
                let settingsValue = Int(json["settingsset"].string ?? "-1")
                if json["new"] != nil || typeValue == 0 || settingsValue == 0 {
                    let aid = json["new"].int ?? Int(json["login"].stringValue)
                    if aid != nil {
                        self.preferences.set(aid, forKey: PrefKeys.aidKey)
                        self.preferences.set(aid, forKey: PrefKeys.uidKey)
                        print("<newguestuser>: Sign up Successful")
                        signUpStatus = 1
                    }
                    else {
                        signUpStatus = 1
                        print("<newguestuser>: Error signing up")
                    }
                }
                else if json["login"] != nil {
                    if let aid = Int((json["login"].stringValue)) {
                        self.preferences.set(aid, forKey: PrefKeys.aidKey)
                        self.preferences.set(aid, forKey: PrefKeys.uidKey)
                        print("<newguestuser>: User account already exists")
                        signUpStatus = 2
                    }
                }
                else {
                    print("<newguestuser>: " + (responseString ?? "Error" ))
                    self.preferences.set("", forKey: PrefKeys.aidKey)
                    self.preferences.set("", forKey: PrefKeys.uidKey)
                }
            }
            group.leave()
        }
        
        group.enter()
        task.resume()
        group.wait()
        
        
        return signUpStatus
    }
    
    func getGuestUsername(acctid: String) -> Bool {
        var status = false
        let group = DispatchGroup()
        let url = URL(string: "https://pathvudata.com/api1/api/users/guestusername/* removed for security purposes */")!
        var request = URLRequest(url: url)
        
        let postString = "uacctid=" + acctid
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<guestusername>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<guestusername>: Failure:" + (response?.description)!)
                print("<guestusername>: Error Code: \(httpStatus.statusCode)")
            }
            let responseString = String(data: data, encoding: .utf8)
            let json = JSON(data)
            if(json["username"] != nil) {
                self.preferences.set(json["username"].stringValue, forKey: PrefKeys.usernameKey)
                print("<guestusername>: Received Username: \(responseString!.replacingOccurrences(of: "\"", with: ""))")
                status = true
            } else {
                print("<guestusername>: Invalid response")
            }
            group.leave()
        }
        
        group.enter()
        task.resume()
        group.wait()
        
        return status
    }
    /**
     * PHP call for getting an account's username
     */
    func getUsername(uid: String) -> Bool {

        var status = false
        let group = DispatchGroup()
        
        let params = "uacctid=" + uid
        
        let url = URL(string: "https://pathvudata.com/api1/api/users/* removed for security purposes */" + params)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<getUsername>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<getusername>: Failure:" + (response?.description)!)
                print("<getusername>: Error Code: \(httpStatus.statusCode)")
            }
            let responseString = String(data: data, encoding: .utf8)
            let dict = responseString?.toJSON() as? [String: AnyObject]
            if(dict != nil && dict!["uusername"] != nil) {
                self.preferences.set(dict!["uusername"]!, forKey: PrefKeys.usernameKey)
                print("<getusername>: Received Username: \(responseString!.replacingOccurrences(of: "\"", with: ""))")
                status = true
            } else {
                print("<getusername>: Invalid response")
            }
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()
        
        return status
    }
    
    /**
     * PHP call for getting a user's unique ID, used when inserting comfort/alert settings
     */
    func getUID(acctid:String) -> Bool {
        var getUIDSuccess:Bool = false
        let group = DispatchGroup()
        let url = URL(string: "https://pathvudata.com/accesspathweb/onboardid.php")!
        var request = URLRequest(url: url)
        
        let postString = "acctid=" + acctid
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<onboardid.php>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<onboardid.php>: Failure:" + (response?.description)!)
                print("<onboardid.php>: Error Code: \(httpStatus.statusCode)")
            }
            let responseString = String(data: data, encoding: .utf8)
            let dict = responseString?.toJSON() as? [String: AnyObject]
            if(dict == nil) {
                let uid = "\(responseString!.replacingOccurrences(of: "\"", with: ""))"
                self.preferences.set(uid, forKey: PrefKeys.uidKey)
                self.preferences.synchronize()
                print("<onboardid.php>: Retrieved Unique ID")
                print("<onboardid.php>: Unique ID: " + uid)
                getUIDSuccess = true
            } else {
                let fullError = String("\(dict!["error"]!)")
                print("<onboardid.php>: " + fullError)
            }
            group.leave()
        }
        
        group.enter()
        task.resume()
        group.wait()
        
        return getUIDSuccess
    }
  
    /**
     * Wrapper function for inserting comfort/alert settings
     */
    func insertSettings() -> Bool {
        let thComfortInt = preferences.string(forKey: PrefKeys.thComfortKeyValue) ?? "1"
        let rComfortInt =  preferences.string(forKey: PrefKeys.rComfortKeyValue) ?? "1"
        let rsComfortInt = preferences.string(forKey: PrefKeys.rsComfortKeyValue) ?? "1"
        let csComfortInt = preferences.string(forKey: PrefKeys.csComfortKeyValue) ?? "1"
        
        
        let thAlertInt = preferences.string(forKey: PrefKeys.thAlertKeyValue) ?? "1"
        let rAlertInt =  preferences.string(forKey: PrefKeys.rAlertKeyValue) ?? "1"
        let rsAlertInt = preferences.string(forKey: PrefKeys.rsAlertKeyValue) ?? "1"
        let csAlertInt = preferences.string(forKey: PrefKeys.csAlertKeyValue) ?? "1"
        
        let uid = preferences.string(forKey: PrefKeys.uidKey)
        
        let thPost = "thw=" + thComfortInt  + "&thalert=" + thAlertInt
        let rPost = "&row=" + rComfortInt + "&roalert=" + rAlertInt
        let rsPost = "&rsw=" + rsComfortInt + "&rsalert=" + rsAlertInt
        let csPost = "&csw=" + csComfortInt + "&csalert=" + csAlertInt
        let uidPost = "&uacctid=" + uid!
        let postString = thPost + rPost + rsPost + csPost + uidPost
        
        debugPrint("this is post setting parameter \(postString)")
        
        //comment limit restriction parameter
        //+ thlimitPost + rolimitPost + rslimitPost + cslimitPost
        
        return insertSettings(postString: postString)
    }
    
    /** CREATED by Chetu
     * add New Alert And Comfort key value pass as parameter
     * Wrapper function for inserting comfort/alert settings
     */
    func insertNewSettings() -> Bool {
        let thComfortInt = preferences.string(forKey: PrefKeys.thComfortKeyValue) ?? "1"
        let rComfortInt =  preferences.string(forKey: PrefKeys.rComfortKeyValue) ?? "1"
        let rsComfortInt = preferences.string(forKey: PrefKeys.rsComfortKeyValue) ?? "1"
        let csComfortInt = preferences.string(forKey: PrefKeys.csComfortKeyValue) ?? "1"
        
        
        let thAlertInt = preferences.string(forKey: PrefKeys.thAlertKeyValue) ?? "1"
        let rAlertInt =  preferences.string(forKey: PrefKeys.rAlertKeyValue) ?? "1"
        let rsAlertInt = preferences.string(forKey: PrefKeys.rsAlertKeyValue) ?? "1"
        let csAlertInt = preferences.string(forKey: PrefKeys.csAlertKeyValue) ?? "1"
        
        let uid = preferences.string(forKey: PrefKeys.uidKey)
        
        let thPost = "thw=" + thComfortInt  + "&thalert=" + thAlertInt
        let rPost = "&row=" + rComfortInt + "&roalert=" + rAlertInt
        let rsPost = "&rsw=" + rsComfortInt + "&rsalert=" + rsAlertInt
        let csPost = "&csw=" + csComfortInt + "&csalert=" + csAlertInt
        let uidPost = "&uacctid=" + uid!
        let postString = thPost + rPost + rsPost + csPost + uidPost
        
        debugPrint("this is post setting parameter \(postString)")
        
        return insertSettings(postString: postString)
    }
    
    func getSettings(uacctid:String) -> [JSON]? {
        var res:[JSON]? = nil
        let group = DispatchGroup()
        let params = "uacctid=" + uacctid
        let url = URL(string: "https://pathvudata.com/api1/api/users/getsettings/* removed for security purposes */" + params)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("<insertsettings.php>: Error: \(String(describing: error))")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("Error getting user settings")
            }
            let responseString = String(data: data, encoding: .utf8)
            let json = JSON(data)
            let settings = json["settings"].array
            if let settings = settings {
                if !(responseString?.contains("ugs00"))! {
                    res = settings
                }
            }
            else {
                print("Settings Response: \(responseString)")
            }
            group.leave()
        }
        
        group.enter()
        task.resume()
        group.wait()
            
        return res
    }
    /**
     * PHP call for inserting the user's comfort/alert settings
     */
    private func insertSettings(postString:String) -> Bool {
        var insertSuccess:Bool = false
        let group = DispatchGroup()
        let url = URL(string: "https://pathvudata.com/api1/api/users/setsettings/* removed for security purposes */")!
        var request = URLRequest(url: url)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        print("body = \(request.httpBody)")
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                print("<insertsettings.php>: Error: \(String(describing: error))")
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<insertsettings.php>: Failure: \(String(describing: response))")
                print("<insertsettings.php>: Error Code: \(httpStatus.statusCode)")
            }
            guard let responseString = String(data: data, encoding: .utf8) else {
                print("<insertsettings.php>: Error inserting settings")
                return
            }
            let json = JSON(data)
            if json["settingsset"] == 1 {
                print("<insertsettings.php>: Successfully inserted settings")
                insertSuccess = true
            } else {
                print(responseString)
            }
            group.leave()
        }
        
        group.enter()
        task.resume()
        group.wait()
        
        return insertSuccess
    }
    
    /**
     * PHP call for changing an accoun's username
     */
    func changeUsername(uusername:String, uid:String) -> Bool {
        var status = false
        let group = DispatchGroup()
        let parameters = [
            [
                "key": "uacctid",
                "value": uid,
                "type": "text"
            ],
            [
                "key": "uusername",
                "value": uusername,
                "type": "text"
            ]] as [[String : Any]]

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for param in parameters {
            if param["disabled"] == nil {
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                let paramType = param["type"] as! String
                if paramType == "text" {
                    let paramValue = param["value"] as! String
                    body += "\r\n\r\n\(paramValue)\r\n"
                }
                else {
                    let paramSrc = param["src"] as! String
                    do {
                        let fileData = try NSData(contentsOfFile:paramSrc, options:[]) as Data
                        let fileContent = String(data: fileData, encoding: .utf8)!
                        body += "; filename=\"\(paramSrc)\"\r\n" + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                        body += "--\(boundary)--\r\n"
                    }
                    catch {
                        print("error sending 'change user' data")
                    }
                }
            }
        }
        let postData = body.data(using: .utf8)

        var request = URLRequest(url: URL(string: APIURL.changeUsernameURL)!)
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("<updateusername.php>: Error: " + (error?.localizedDescription)!)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<updateusername.php>: Failure:" + (response?.description)!)
                print("<updateusername.php>: Error Code: \(httpStatus.statusCode)")
            }
            guard let responseString = String(data: data!, encoding: .utf8) else {
                print ("<updateusername.php>: error changing username")
                return
            }
            print("change user response: \(responseString)")
            if (responseString.contains("updated")) {
                print("<updateusername.php>: Username set")
                status = true
            }
            else {
                print("<updateusername.php>: " + responseString)
            }
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()
    
        return status
    }
    
    
    
    /**
     * PHP call for logging in with email and password
     */
    func signInWithEmail(email: String, password: String) -> Int {
        var status = 0
        
        let postString = "uemail=" + email + "&upassword=" + password
        
        let group = DispatchGroup()
        
        let url = URL(string: "https://pathvudata.com/api1/api/users/login/* removed for security purposes */")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<login.php>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<login.php>: Failure:" + (response?.description)!)
                print("<login.php>: Error Code: \(httpStatus.statusCode)")
            }
            
            guard let responseString = String(data: data, encoding: .utf8) else {
                print("Error getting user sign in response")
                return
            }
            let json = JSON(data)
            if json["login"] != nil {
                let aid = Int((json["login"].stringValue))
                print("<login.php>: " + responseString)
                self.preferences.set(aid, forKey: PrefKeys.aidKey)
                self.preferences.set(aid, forKey: PrefKeys.uidKey)
                status = 1
            }
            else if responseString.contains("ul003") {
                status = 2
            }
            else if responseString.contains("ul004") {
                status = 3
            }
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()
        
        return status
    }
    
    /**
     * PHP call for sending an email to a person for the purposes
     * of resetting their password.
     */
    func forgotPassword(email: String) -> Any! {
        var returnString:Any!
        
        let postString = "uemail=" + email
        
        let group = DispatchGroup()
        
        let url = URL(string: "https://pathvudata.com/accesspathweb/forgotpassword.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<forgotpassword.php>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<forgotpassword.php>: Failure:" + (response?.description)!)
                print("<forgotpassword.php>: Error Code: \(httpStatus.statusCode)")
            }
            let responseString = String(data: data, encoding: .utf8)
            print("<forgotpassword.php>: " + responseString!)
            let dict = responseString?.toJSON() as? [String: AnyObject]
            if(dict == nil) {
                returnString = responseString
            } else {
                let fullError = String("\(dict!["error"]!)")
                returnString = fullError
            }
            group.leave()
        }
        
        group.enter()
        task.resume()
        group.wait()
        
        return returnString
    }
    
    /**
     * PHP call for checking if an account is activated
     */
    func checkActivation(aid: String) -> Any! {
        var returnString:Any!
        
        let postString = "uacctid=" + aid
        
        let group = DispatchGroup()
        
        let url = URL(string: "https://pathvudata.com/accesspathweb/checkactivation.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<checkactivation.php>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<checkactivation.php>: Failure:" + (response?.description)!)
                print("<checkactivation.php>: Error Code: \(httpStatus.statusCode)")
            }
            let responseString = String(data: data, encoding: .utf8)
            print("<checkactivation.php>: " + responseString!)
            let dict = responseString?.toJSON() as? [String: AnyObject]
            if(dict == nil) {
                returnString = responseString
            } else {
                let fullError = String("\(dict!["activation"]!)")
                returnString = fullError
            }
            group.leave()
        }
        
        group.enter()
        task.resume()
        group.wait()
        return returnString
    }
    
    /**
     * PHP call for adding a new recent place
     */
    func newFavorite(acctid:String, faddress:String, fname:String, flat:Double, flon:Double) -> Bool {
        let group = DispatchGroup()
        let parameters = [
            [
                "key": "uacctid",
                "value": acctid,
                "type": "text"
            ],
            [
                "key": "fname",
                "value": fname,
                "type": "text"
            ],
            [
                "key": "faddress",
                "value": faddress,
                "type": "text"
            ],
            [
                "key": "flat",
                "value": String(flat),
                "type": "text"
            ],
            [
                "key": "flon",
                "value": String(flon),
                "type": "text"
            ]] as [[String : Any]]

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for param in parameters {
            if param["disabled"] == nil {
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                let paramType = param["type"] as! String
                if paramType == "text" {
                    let paramValue = param["value"] as! String
                    body += "\r\n\r\n\(paramValue)\r\n"
                } else {
                    let paramSrc = param["src"] as! String
                    var fileData = Data()
                    do {
                        fileData = try NSData(contentsOfFile:paramSrc, options:[]) as Data
                    }
                    catch {
                        print("Error posting favorites")
                    }
                    let fileContent = String(data: fileData, encoding: .utf8)!
                    body += "; filename=\"\(paramSrc)\"\r\n"
                      + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                }
            }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)

        
        var request = URLRequest(url: URL(string: addFavoriteURLString)!)
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        var success = false;
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print(error)
            }
            else {
                success = true
            }
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()
        
        return success
    }

    /**
     * PHP call for getting recent places
     */
    func getFavorites(acctid: String) -> Data? {
        var responseData:Data?
        
        let postString = "?uacctid=" + acctid
        
        let group = DispatchGroup()
        
//        let url = URL(string: "https://pathvudata.com/accesspathweb/getfavorites_v2.php")!
        guard let url = URL(string: "\(getFavoritesURLString)\(postString)") else { return nil }
        
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            guard let data = data, error == nil else {
                print("<getfavorites.php>: Error: " + (error?.localizedDescription)!)
                return
            }
            // check if response is a valid json object
            let responseString = String(data: data, encoding: .utf8)
            if let responseDictionary = responseString?.toJSON() as? [String: AnyObject] {
                responseData = data
            }
            group.leave()
        }

        group.enter()
        task.resume()
        group.wait()

        return responseData
    }
        
    /**
     * PHP call for getting recent places
     */
    func getRecents(acctid: String) -> Data? {
        var responseData:Data?
        
        let postString = "?uacctid=" + acctid
        
        let group = DispatchGroup()
        
        guard let url = URL(string: "\(getRecentsURLString)\(postString)") else { return nil }
        
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            guard let data = data, error == nil else {
                print("<getrecents.php>: Error: " + (error?.localizedDescription)!)
                return
            }
            // check if response is a valid json object
            let responseString = String(data: data, encoding: .utf8)
            if let responseDictionary = responseString?.toJSON() as? [String: AnyObject] {
                responseData = data
            }
            group.leave()
        }

        group.enter()
        task.resume()
        group.wait()

        return responseData
    }
    
    /**
     * PHP call for adding a recent place
     */
    func newRecent(acctid: String, address: String, lat:Double, lng:Double) -> Bool! {
        let group = DispatchGroup()
        let parameters = [
           [
               "key": "uacctid",
               "value": acctid,
               "type": "text"
           ],
           [
               "key": "raddress",
               "value": address,
               "type": "text"
           ],
           [
               "key": "rlat",
               "value": String(lat),
               "type": "text"
           ],
           [
               "key": "rlon",
               "value": String(lng),
               "type": "text"
           ]] as [[String : Any]]

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for param in parameters {
           if param["disabled"] == nil {
               let paramName = param["key"]!
               body += "--\(boundary)\r\n"
               body += "Content-Disposition:form-data; name=\"\(paramName)\""
               let paramType = param["type"] as! String
               if paramType == "text" {
                   let paramValue = param["value"] as! String
                   body += "\r\n\r\n\(paramValue)\r\n"
               } else {
                   let paramSrc = param["src"] as! String
                   var fileData = Data()
                   do {
                       fileData = try NSData(contentsOfFile:paramSrc, options:[]) as Data
                   }
                   catch {
                       print("Error posting recent")
                   }
                   let fileContent = String(data: fileData, encoding: .utf8)!
                   body += "; filename=\"\(paramSrc)\"\r\n"
                     + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
               }
           }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)


        var request = URLRequest(url: URL(string: addRecentURLString)!)
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        var success = false;
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print(error)
            }
            else {
                print("String type repsonse\n \(String(data: data!, encoding: .utf8))")
                print("data type repsonse\n \(data)")
                print("JSON of new Route response\n \(JSON(data))")
                success = true
            }
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()

        return success
    }
    
    /**
     * PHP call for getting current weather conditions
     * This returns a tuple containing the temperature, conditions, and icon code
     */
    func getCurrentTemp(lat:Double, lon:Double) -> (Int, String, String) {
        var temperature:Int = 0
        var conditions:String = "null"
        var iconCode:String = "null"
        
        let weatherURL = "https://api.openweathermap.org/data/2.5/weather?"
        let postLat = "lat=" + String(lat)
        let postLon = "lon=" + String(lon)
        let appID = "&APPID=86297b6d659bc424d98c8805fbc540fd"
        
        let postString = postLat + "&" + postLon + appID
        let fullString = weatherURL + postString
        
        guard let url = URL(string: fullString) else { return (0, "null", "null") }
        
        let group = DispatchGroup()
        group.enter()
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                
                let json = JSON(data)
                
                temperature = json["main"]["temp"].intValue
                conditions = json["weather"][0]["main"].stringValue
                iconCode = json["weather"][0]["icon"].stringValue
                
                print("Temperature: " + String(temperature) + " Kelvin")
                print("Conditions: " + conditions)
                print("Icon Code: " + iconCode)
                
            }
            group.leave()
            }.resume()
        
        group.wait()
        return (temperature, conditions, iconCode)
    }
    
    /**
     * PHP call for removing a favorite place
     */
    func removeFavorite(acctid:String, fname:String) -> Bool! {
        var returnValue = true
        
        let group = DispatchGroup()
        
        let url = URL(string: "https://pathvudata.com/accesspathweb/removefavorite.php")!
        var request = URLRequest(url: url)
        
        let postString = "acctid=" + acctid + "&fname=" + fname
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<removefavorite.php>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<removefavorite.php>: Failure:" + (response?.description)!)
                print("<removefavorite.php>: Error Code: \(httpStatus.statusCode)")
                returnValue = false
            }
            let responseString = String(data: data, encoding: .utf8)
            print("<removefavorite.php>: " + responseString!)
            
            if(!(responseString?.isEmpty)!) {
                returnValue = false
            }
            
            group.leave()
        }
        
        group.enter()
        task.resume()
        group.wait()
        
        return returnValue
    }
    
    /**
     * PHP call for renaming a favorite place
     */
    func updateFavorite(acctid:String, fname:String, fnewname:String) -> Bool! {
        var returnValue = true
        
        let group = DispatchGroup()
        
        let url = URL(string: "https://pathvudata.com/accesspathweb/updatefavorite.php")!
        var request = URLRequest(url: url)
        
        let postString = "acctid=" + acctid + "&fname=" + fname + "&fnewname=" + fnewname
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<updatefavorite.php>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<updatefavorite.php>: Failure:" + (response?.description)!)
                print("<updatefavorite.php>: Error Code: \(httpStatus.statusCode)")
                returnValue = false
            }
            let responseString = String(data: data, encoding: .utf8)
            print("<updatefavorite.php>: " + responseString!)
            
            if(!(responseString?.isEmpty)!) {
                returnValue = false
            }
        
            group.leave()
        }
        
        group.enter()
        task.resume()
        group.wait()
        
        return returnValue
    }
    
    
    /**
     * Changed by Chetu
     * PHP call for thumbs up and thumbs down vote
     */
    func thumbsUpVoteApi(cid:Int,acctid:Int, thumbsUp:Int) -> String? {
        var returnString = ""
        let acctidPost = "uacctid=" + "\(acctid)"
        let cidPost = "&cid=" + "\(cid)"
        let votePost = "&vote=" + "\(thumbsUp)"
       
        let postString = acctidPost + cidPost + votePost
        
        let group = DispatchGroup()
        
        let url = URL(string: "\(String(describing: ThumbsUpVoteApi.thumbsUpURL!))")
        print("URL: --- \(String(describing: url))")
        
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<newfavorite.php>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<newfavorite.php>: Failure:" + (response?.description)!)
                print("<newfavorite.php>: Error Code: \(httpStatus.statusCode)")
            }
            let responseString = String(data: data, encoding: .utf8)
            print("<newfavorite.php>: " + responseString!)
            let dict = responseString?.toJSON() as? [String: AnyObject]
            if(dict == nil) {
                print(returnString)
                //returnString = true
                returnString = responseString!
            } else {
                let fullError = String("\(dict!["error"]!)")
                print(fullError)
                //returnString = false
                returnString = responseString!
            }
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()
        return returnString
    }
    
    
    /**
     * Changed by Chetu
     * PHP call for Total vote Api
     */
    func totalVoteCountApi(cid:Int) -> String? {
        var returnString = ""
        //let acctidPost = "acctid=" + "\(acctid)"
        let cidPost = "&cid=" + "\(cid)"
        //let votePost = "&vote=" + "\(thumbsUp)"
        
        let postString = cidPost //+ votePost
        
        let group = DispatchGroup()
        
        let url = URL(string: "\(String(describing: ThumbsUpVoteApi.thumbsTotalVoteURL!))")
        print("URL: --- \(String(describing: url))")
        
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("<newfavorite.php>: Error: " + (error?.localizedDescription)!)
            return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<newfavorite.php>: Failure:" + (response?.description)!)
                print("<newfavorite.php>: Error Code: \(httpStatus.statusCode)")
            }
            let responseString = String(data: data, encoding: .utf8)
            print("<newfavorite.php>: " + responseString!)
            let dict = responseString?.toJSON() as? [String: AnyObject]
            if(dict == nil) {
                print(returnString)
                //returnString = true
                returnString = responseString!
            } else {
                let fullError = String("\(dict!["error"]!)")
                print(fullError)
                //returnString = false
                returnString = responseString!
            }
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()
        return returnString
    }
    
    // Return routing and navigation information
    func getRoute(with params: RouteParameters) throws -> Data? {
        let group = DispatchGroup()
        let parameters = [
            [
                "key": "fromlat",
                "value": String(Double(round(1000*params.from.latitude))/1000),
                "type": "text"
            ],
            [
                "key": "fromlon",
                "value": String(Double(round(1000*params.from.longitude))/1000),
                "type": "text"
            ],
            [
                "key": "tolat",
                "value": String(Double(round(1000*params.to.latitude))/1000),
                "type": "text"
            ],
            [
                "key": "tolon",
                "value": String(Double(round(1000*params.to.longitude))/1000),
                "type": "text"
            ],
            [
                "key": "uacctid",
                "value": String(params.uacctid),
                "type": "text"
            ],
            [
                "key": "tid",
                "value": String(params.tid),
                "type": "text"
            ],
            [
                "key": "thw",
                "value": String(params.thw),
                "type": "text"
            ],
            [
                "key": "rsw",
                "value": String(params.rsw),
                "type": "text"
            ],
            [
                "key": "csw",
                "value": String(params.csw),
                "type": "text"
            ],
            [
                "key": "row",
                "value": String(params.row),
                "type": "text"
            ]] as [[String : Any]]

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for param in parameters {
            if param["disabled"] == nil {
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                let paramType = param["type"] as! String
                if paramType == "text" {
                    let paramValue = param["value"] as! String
                    body += "\r\n\r\n\(paramValue)\r\n"
                } else {
                    let paramSrc = param["src"] as! String
                    let fileData = try NSData(contentsOfFile:paramSrc, options:[]) as Data
                    let fileContent = String(data: fileData, encoding: .utf8)!
                    body += "; filename=\"\(paramSrc)\"\r\n"
                      + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                }
            }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)

        var request = URLRequest(url: RoutingUrls.routeURL!)
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        var res:Data?
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            res = data
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()
        return res
    }
    
    // return a list of places near user location within specified radius
    func getNearbyPlaces(near location:CLLocationCoordinate2D, radius:Int) -> [GooglePlace]? {
        var result:[GooglePlace]? = nil
        let group = DispatchGroup()
        let params = "?key=\(GoogleAPILicenseKey)&location=\(location.latitude),\(location.longitude)&radius=\(radius)"
        let url = URL(string: GoogleURLs.nearBySearchURLString + params)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                debugPrint(error)
                return
            }
            guard let data = data else { return }
            
            result = [GooglePlace]()
            let json = JSON(data)
            for place in json["results"].arrayValue {
                result?.append(GooglePlace(with: place, userLocation: location))
            }
            result?.sort(by: { $0.distance < $1.distance } )
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()
        return result
    }
    
    
    
    func setType(uacctid:String, type:String) -> Bool {
        var success = false
        //let acctidPost = "acctid=" + "\(acctid)"
        let params = "uacctid=" + uacctid + "&tid=" + type
        //let votePost = "&vote=" + "\(thumbsUp)"
        
        let group = DispatchGroup()
        
        let url = URL(string: APIURL.setTypeURL)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = params.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("<setType>: Error: " + (error?.localizedDescription)!)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("<setType>: Failure:" + (response?.description)!)
                print("<setType>: Error Code: \(httpStatus.statusCode)")
            }
            let responseString = String(data: data, encoding: .utf8)
            let json = JSON(data)
            print("<setType>: " + responseString!)
            if json["typeset"] != nil && json["typeset"].intValue == 1 {
                success = true
            }
            else {
                print(responseString!)
            }
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()
        
        return success
    }
}


/////////////


/**
 * Extension for converting strings to json for allowing subscript
 */
extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

