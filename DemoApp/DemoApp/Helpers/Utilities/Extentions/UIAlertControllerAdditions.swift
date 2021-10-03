//
//  UIAlertControllerAdditions.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import UIKit

extension UIAlertController {
    
    class func showNoInternetAlert() {
        
        NSObject.moveToMainThread {
            
            UIAlertController.showAlertController(withTitle: AppMessages.noConnectionTitle.rawValue,
                                                  alertMessage: AppMessages.noConnectionMessage.rawValue,
                                                  alertStyle: .alert,
                                                  withCancelTitle: AppMessages.noConnectionCancelButtonTitle.rawValue,
                                                  alertActions: nil,
                                                  fromController: nil,
                                                  sourceView: nil,
                                                  popupDirection: PopupArrowDirection.any())
        }
    }
    
    class func showAlertController(withTitle title: String?,
                             alertMessage message: String?,
                             alertStyle style: UIAlertController.Style,
                             withCancelTitle cancelTitle: String?,
                             alertActions actions:[UIAlertAction]?,
                             fromController controller:UIViewController?,
                             sourceView view: Any?,
                             popupDirection direction: Int) {
        
        NSObject.moveToMainThread {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
            
            if let actions = actions {
                for action in actions {
                    alertController.addAction(action)
                }
            }
            
            let actionCancel:UIAlertAction = UIAlertAction(title: cancelTitle ?? "Cancel", style: UIAlertAction.Style.cancel) { (action) in
                
            }
            alertController.addAction(actionCancel)
            
            if let controller = controller {
                alertController.showAlertController(fromController: controller, sourceView: view, popupDirection: direction)
            } else {
                let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                if let controller = keyWindow?.rootViewController {
                    alertController.showAlertController(fromController: controller, sourceView: view, popupDirection: direction)
                }
            }
        }
    }
    
    class func displayAlertController(withTitle title: String?,
                             alertMessage message: String?,
                             alertStyle style: UIAlertController.Style,
                             alertActions actions:[AlertAction]?,
                             fromController controller:UIViewController?,
                             sourceView view: Any?,
                             popupDirection direction: Int) {
        
        NSObject.moveToMainThread {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
            
            if let actions = actions {
                for actionObj:AlertAction in actions {
                    
                    let action = UIAlertAction(title: actionObj.title,
                                               style: actionObj.style) { (alertAction) in
                                                actionObj.completion?(alertAction)
                    }
                    alertController.addAction(action)
                }
            }
            
            if let controller = controller {
                alertController.showAlertController(fromController: controller, sourceView: view, popupDirection: direction)
            }
            else {
                let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                if let controller = keyWindow?.rootViewController {
                    alertController.showAlertController(fromController: controller, sourceView: view, popupDirection: direction)
                }
            }
        }
    }
    
    // Please use "PopupArrowDirection" for popupDirection argument.
    func showAlertController(fromController controller:UIViewController, sourceView view: Any?, popupDirection arrowDirection: Int) {
        
        NSObject.moveToMainThread{
            
            var direction: UIPopoverArrowDirection = .any
            
            switch arrowDirection {
            case PopupArrowDirectionType.up.rawValue:
                direction = .up
            case PopupArrowDirectionType.down.rawValue:
                direction = .down
            case PopupArrowDirectionType.left.rawValue:
                direction = .left
            case PopupArrowDirectionType.right.rawValue:
                direction = .right
            case PopupArrowDirectionType.any.rawValue:
                direction = .any
            case PopupArrowDirectionType.unknown.rawValue:
                direction = .unknown
            default:
                break
            }
            
            var sourceView: UIView = controller.view
            var barButtonItem: UIBarButtonItem? = nil
            if let view = view as? UIView {
                sourceView = view
            }
            else if let barButton = view as? UIBarButtonItem {
                barButtonItem = barButton
            }
            
            let presentator: UIPopoverPresentationController? = self.popoverPresentationController ?? controller.popoverPresentationController
            
            if let presenter = presentator {
                if let item = barButtonItem {
                    presenter.barButtonItem = item
                    presenter.sourceRect = CGRect(x: item.width / 2.0, y: item.width / 2.0, width: 0, height: 0)
                    presenter.permittedArrowDirections = direction
                }
                else {
                    presenter.sourceView = sourceView
                    presenter.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
                    presenter.permittedArrowDirections = direction
                }
            }
            controller.present(self, animated: true, completion: nil)
        }
    }
}

class AlertAction: NSObject {
    
    var title:String? = ""
    var style: UIAlertAction.Style = .default
    var completion: ((UIAlertAction) -> Void)?
}

enum PopupArrowDirectionType: Int {
        case up

        case down

        case left

        case right

        case any

        case unknown
}

class PopupArrowDirection: NSObject {
    
    class func up() -> Int {
        return PopupArrowDirectionType.up.rawValue
    }
    
    class func down() -> Int {
        return PopupArrowDirectionType.down.rawValue
    }
    
    class func left() -> Int {
        return PopupArrowDirectionType.left.rawValue
    }
    
    class func right() -> Int {
        return PopupArrowDirectionType.right.rawValue
    }
    
    class func any() -> Int {
        return PopupArrowDirectionType.any.rawValue
    }
    
    class func unknown() -> Int {
        return PopupArrowDirectionType.unknown.rawValue
    }
}
