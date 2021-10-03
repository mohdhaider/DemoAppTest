//
//  InternetHandler.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import Reachability

class InternetHandler: NSObject {
    
    // MARK: - Variables -
    
    private lazy var connection = reachabilityManager?.connection
    
    private var isInternetConnectionAvailableTemp:Bool = false
    @objc var isInternetConnectionAvailable:Bool{
        set {
            isInternetConnectionAvailableTemp = newValue
        }
        get{
            if let connection = connection,
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
               let connection = connection,
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
               let connection = connection,
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
    }
    
    private var networkManager:Reachability?
    private var instantNetworkManager:Reachability?
    
    // MARK: - Initializers -
    
    static let shared = InternetHandler()
    
    // MARK: - Class Helper Methods -

    private func handleReachabilityStatus(_ connection:Reachability.Connection) {
        
        moveToMainThread{[weak self] in
            
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
            handleReachabilityStatus(reachability.connection)
        }
    }
}

// MARK:- Mock tests -

extension InternetHandler {
    
    func makeInternetNotAvailable() {
        
        connection = .unavailable
        isInternetConnectionAvailable = false
    }
    
    func makeInternetAvailable() {
        
        connection = .wifi
        isInternetConnectionAvailable = true
    }
    
    func checkInternetConnectionCases(_ completion:((Bool) -> Void)?) {
        
        let expectedCount = 4
        var successCount = 0
        
        connection = .unavailable
        isInternetConnectionAvailableTemp = true
        
        Logger.printLog("1 isInternetConnectionAvailable = \(isInternetConnectionAvailable)")
        
        if isInternetConnectionAvailable == false {
            successCount += 1
        }
        
        connection = .wifi
        isInternetConnectionAvailableTemp = false
        
        Logger.printLog("2 isInternetConnectionAvailable = \(isInternetConnectionAvailable)")
        
        if isInternetConnectionAvailable == true {
            successCount += 1
        }

        connection = .wifi
        isInternetAvailableViaWifiTemp = false
        
        Logger.printLog("isInternetAvailableViaWifi = \(isInternetAvailableViaWifi)")
        
        if isInternetAvailableViaWifi == true {
            successCount += 1
        }
        
        connection = .cellular
        isInternetAvailableViaMobileNetworkTemp = false
        
        Logger.printLog("isInternetAvailableViaMobileNetwork = \(isInternetAvailableViaMobileNetwork)")
        
        if isInternetAvailableViaMobileNetwork == true {
            successCount += 1
        }
        
        callCodeBlock(afterDelay: 5) {
            completion?(successCount == expectedCount)
        }
    }
    
    func checkReachabilityStatusIfWifiAvailable() -> Bool {
        
        if var connection = reachabilityManager?.connection {
            
            connection = .wifi
            
            handleReachabilityStatus(connection)
        }
        
        return isInternetAvailableViaWifi
    }
    
    func checkReachabilityStatusIfCellularAvailable() -> Bool {
        
        if var connection = reachabilityManager?.connection {
            
            connection = .cellular
            
            handleReachabilityStatus(connection)
        }
        
        return isInternetAvailableViaMobileNetwork
    }
    
    func checkNoInternetIfConnectionUnavailable() -> Bool {
        
        if var connection = reachabilityManager?.connection {
            
            connection = .unavailable
            
            handleReachabilityStatus(connection)
        }
        
        return isInternetConnectionAvailable
    }
}
