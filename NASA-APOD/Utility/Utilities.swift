//
//  Utilities.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
import UIKit
public enum APODMediaType: String {
    case video = "video"
    case image = "image"
    case unknown = "unknown"
}

public enum MediaConstants {
    static let youtubeRegex = #"://.*youtube\.com/embed/([^/?#]+)"#
}

public enum ErrorMessages {
    static let apodNotFoundTitle = "Error Loading Picture for this Day"
    static let apodNotFoundMessage = "No Picture found or Network Error"
    static let noAPODinApp = "NO Image to Display. Check Device Network Connection"
}

extension UITextField {
    func datePicker<T>(target: T,
                       doneAction: Selector,
                       cancelAction: Selector,
                       datePickerMode: UIDatePicker.Mode = .date) {
        let screenWidth = UIScreen.main.bounds.width
        
        func buttonItem(withSystemItemStyle style: UIBarButtonItem.SystemItem) -> UIBarButtonItem {
            let buttonTarget = style == .flexibleSpace ? nil : target
            let action: Selector? = {
                switch style {
                case .cancel:
                    return cancelAction
                case .done:
                    return doneAction
                default:
                    return nil
                }
            }()
            
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: style,
                                                target: buttonTarget,
                                                action: action)
            
            return barButtonItem
        }
        
        let datePicker = UIDatePicker(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: screenWidth,
                                                    height: UIScreen.main.bounds.height))
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = datePickerMode
        self.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0,
                                              y: 0,
                                              width: screenWidth,
                                              height: 44))
        toolBar.setItems([buttonItem(withSystemItemStyle: .cancel),
                          buttonItem(withSystemItemStyle: .flexibleSpace),
                          buttonItem(withSystemItemStyle: .done)],
                         animated: true)
        self.inputAccessoryView = toolBar
    }
}
