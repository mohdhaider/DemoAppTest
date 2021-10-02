//
//  DateAdditions.swift
//  SearchApp
//
//  Created by Haider on 25/09/21.
//

import UIKit

extension Date {
    
    static func convertDate(_ dateObj:Any?, sourceFormat sFormat:String?, targetFormat tFormat:String?) -> String? {
        
        var convertedDate:String?
        var dateSource:Date?
        
        if let obj = dateObj as? String {
            
            let formatter = DateFormatter()
            formatter.dateFormat = sFormat
            dateSource = formatter.date(from: obj)
        }
        else if let obj = dateObj as? Date {
            dateSource = obj
        }
        
        if let dateSource = dateSource,
           let tFormat = tFormat {
            
            let formatter = DateFormatter()
            formatter.dateFormat = tFormat
            
            convertedDate = formatter.string(from: dateSource)
        }
        
        return convertedDate
    }
    
    static func utcToLocal(dateStr: String?, dateFormat format:String?, targetFormat tFormat:String?) -> String? {
        
        guard let dateVal = dateStr else { return nil }
        
        let defaultFormat = "H:mm:ss"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format ?? defaultFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateVal) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = tFormat ?? defaultFormat
        
            return dateFormatter.string(from: date)
        }
        return nil
    }
}
