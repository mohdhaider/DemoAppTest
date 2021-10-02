//
//  InternetHandler.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import Reachability

class InternetHandler: NSObject {
    
    // MARK: - Variables -
    
    private var isInternetConnectionAvailableTemp:Bool = false
    @objc var isInternetConnectionAvailable:Bool{
        set {
            isInternetConnectionAvailableTemp = newValue
        }
        get{
            if let connection = reachabilityManager?.connection,
               connection != .unavailable {

                if !isInternetConnectionAvailableTemp {
                    isInternetConnectionAvailableTemp = true
                    if isInternetConnectionAvailableTemp {
                        callCodeBlock(afterDelay: 1.0) {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: NetworkingKeys.internetStatusChanged.rawValue), object: nil)
                        }
                    }
                }
            } else {
                if isInternetConnectionAvailableTemp {
                    isInternetConnectionAvailableTemp = false
                    if !isInternetConnectionAvailableTemp {
                        callCodeBlock(afterDelay: 1.0) {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: NetworkingKeys.internetStatusChanged.rawValue), object: nil)
                        }
                    }
                }
            }
            
            return isInternetConnectionAvailableTemp
        }
    }
    
    private var isInternetAvailableViaMobileNetworkTemp:Bool = false
    var isInternetAvailableViaMobileNetwork:Bool{
        set {
            isInternetAvailableViaMobileNetworkTemp = newValue
        }
        get{
            if !isInternetAvailableViaMobileNetworkTemp,
               let connection = reachabilityManager?.connection,
               connection == .cellular {
                
                isInternetAvailableViaMobileNetworkTemp = true
            }
            return isInternetAvailableViaMobileNetworkTemp
        }
    }
    
    private var isInternetAvailableViaWifiTemp:Bool = false
    var isInternetAvailableViaWifi:Bool{
        set {
            isInternetAvailableViaWifiTemp = newValue
        }
        get{
            if !isInternetAvailableViaWifiTemp,
               let connection = reachabilityManager?.connection,
               connection == .wifi {
                
                isInternetAvailableViaWifiTemp = true
            }
            return isInternetAvailableViaWifiTemp
        }
    }
    
    private var reachabilityManagerTemp:Reachability? = nil
    private var reachabilityManager:Reachability? {
        get{
            guard let _ = reachabilityManagerTemp else {
                reachabilityManagerTemp = try? Reachability()
                return reachabilityManagerTemp
            }
            return reachabilityManagerTemp
        }
        set {
            reachabilityManagerTemp = newValue
        }
    }
    
    private var networkManager:Reachability?
    private var instantNetworkManager:Reachability?
    
    // MARK: - Initializers -
    
    static let shared = InternetHandler()
    
    // MARK: - Class Helper Methods -

    private func handleReachabilityStatus(_ reachability:Reachability) {
        
        moveToMainThread{[weak self] in
            
            let connection = reachability.connection
            
            switch connection {
            case .wifi:
                
                self?.isInternetConnectionAvailable = true;
                self?.isInternetAvailableViaMobileNetwork = false;
                self?.isInternetAvailableViaWifi = true;
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: NetworkingKeys.internetStatusChanged.rawValue), object: nil)
                
            case .cellular:
                
                self?.isInternetConnectionAvailable = true;
                self?.isInternetAvailableViaMobileNetwork = true;
                self?.isInternetAvailableViaWifi = false;
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: NetworkingKeys.internetStatusChanged.rawValue), object: nil)
                
            case .unavailable:
                
                self?.isInternetConnectionAvailable = false;
                self?.isInternetAvailableViaMobileNetwork = false;
                self?.isInternetAvailableViaWifi = false;
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: NetworkingKeys.internetStatusChanged.rawValue), object: nil)
            default:
                NotificationCenter.default.post(name: Notification.Name(rawValue: NetworkingKeys.internetStatusChanged.rawValue), object: nil)
            }
        }
    }
    
    func startNetworkReachabilityObserver() -> Void {
        
        if let manager = reachabilityManager {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(reachabilityChanged(note:)),
                                                   name: .reachabilityChanged,
                                                   object: manager)
        }
        
        try? reachabilityManager?.startNotifier()
    }
    
    @objc private func reachabilityChanged(note: Notification) {
        
        if let reachability = note.object as? Reachability {
            handleReachabilityStatus(reachability)
        }
    }
    
    func checkNetworkAvailability(_ completion:@escaping ((Bool) -> Void)) {
        
        if self == InternetHandler.shared {
            moveToMainThread{[weak self] in
                completion(self?.isInternetConnectionAvailable ?? false)
            }
        } else {
            callCodeBlock(afterDelay: 0.2) {[weak self] in
                
                if self?.isInternetConnectionAvailable ?? false {
                    self?.moveToMainThread{
                        completion(true)
                    }
                }
                else {
                    self?.startNetworkReachabilityObserver()
                    
                    self?.networkManager = try? Reachability()
                    
                    func handleReachabilityStatus(_ reachability:Reachability) {
                        
                        self?.moveToMainThread{
                            
                            self?.networkManager = nil
                            
                            let status = reachability.connection
                            
                            switch status {
                                case .wifi:
                                    
                                    completion(true)
                                    
                                case .cellular:
                                    
                                    completion(true)
                                    
                                case .unavailable:
                                    
                                    completion(false)
                                default:
                                    completion(false)
                            }
                        }
                    }
                    
                    self?.networkManager?.whenReachable = { (status) in
                        
                        if let networkManager = self?.networkManager {
                            handleReachabilityStatus(networkManager)
                        }
                    }
                    
                    self?.networkManager?.whenUnreachable = { (status) in
                        
                        if let networkManager = self?.networkManager {
                            handleReachabilityStatus(networkManager)
                        }
                    }
                    
                    try? self?.networkManager?.startNotifier()
                }
            }
        }
    }
}
