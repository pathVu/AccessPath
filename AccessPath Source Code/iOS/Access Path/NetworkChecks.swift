import Foundation
import Reachability

/**
 * Contains calls to different servers to check if they are online.
 */
class NetworkChecks: NSObject {
    
    var reachability: Reachability!
    
    // Create a singleton instance
    static let sharedInstance: NetworkChecks = { return NetworkChecks() }()
    
    override init() {
        super.init()
        
        // Initialise reachability
        reachability = Reachability()!
        
        // Register an observer for the network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        
        do {
            // Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        // Do something globally here!
    }
    
    static func stopNotifier() -> Void {
        do {
            // Stop the network status notifier
            try (NetworkChecks.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    // Network is reachable
    static func isReachable(completed: @escaping (NetworkChecks) -> Void) {
        if (NetworkChecks.sharedInstance.reachability).connection != .none {
            completed(NetworkChecks.sharedInstance)
        }
    }
    
    // Network is unreachable
    static func isUnreachable(completed: @escaping (NetworkChecks) -> Void) {
        if (NetworkChecks.sharedInstance.reachability).connection == .none {
            completed(NetworkChecks.sharedInstance)
        }
    }
    
    // Network is reachable via WWAN/Cellular
    static func isReachableViaWWAN(completed: @escaping (NetworkChecks) -> Void) {
        if (NetworkChecks.sharedInstance.reachability).connection == .cellular {
            completed(NetworkChecks.sharedInstance)
        }
    }
    
    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (NetworkChecks) -> Void) {
        if (NetworkChecks.sharedInstance.reachability).connection == .wifi {
            completed(NetworkChecks.sharedInstance)
        }
    }

    //Checks if all the ArcGIS servers are up
    func checkServerStatus() -> Bool {
        let url = URL(string: "https://services7.arcgis.com/lCps1TIE7mFpTJoN/arcgis/rest/services")!
        let req = NSMutableURLRequest(url: url)
        req.httpMethod = "HEAD"
        req.timeoutInterval = 10.0
        
        var response : URLResponse?
        
        do {
            try NSURLConnection.sendSynchronousRequest(req as URLRequest, returning: &response)
        } catch {
            print("ERROR BLOCK: " + error.localizedDescription)
        }
        
        return ((response as? HTTPURLResponse)?.statusCode ?? -1) == 200
    }
}
