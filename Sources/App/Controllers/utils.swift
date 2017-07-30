//
//  utils.swift
//  jbsignup
//
//  Created by Richard on 2017-07-29.
//

import Foundation
import Vapor

extension String {
  
    func toDate () -> Date {
    
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD"

            return dateFormatter.date(from: self)!
    }

}

extension Date {
    
    func ISODate () -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        
        return dateFormatter.string(from: self)
        
    }
    
    
}
