//
//  validation.swift
//  jbsignup
//
//  Created by Richard on 2017-07-30.
//

import Foundation
import Vapor
import HTTP


class validate {
    
    var errorCapture = [String: [String:Any]]()
    
    var fieldConfig = [String:[String:Any]]()
    
    init(){
        self.fieldConfig["password"] = ["type":"String","min":8,"max":25,"Required":"Y"]
        self.fieldConfig["email"] = ["type":"email","min":5,"max":100,"Required":"Y"]
        self.fieldConfig["name"] = ["type":"String","min":2,"max":255,"Required":"Y"]
        self.fieldConfig["FirstName"] = ["type":"String","min":2,"max":255,"Required":"Y"]
        self.fieldConfig["LastName"] = ["type":"String","min":2,"max":255,"Required":"Y"]
        self.fieldConfig["DateOfBirth"] = ["type":"Date","min":10,"max":10,"Required":"Y"]
        self.fieldConfig["street"] = ["type":"String","min":5,"max":255,"Required":"Y"]
        self.fieldConfig["apt"] = ["type":"String","min":1,"max":255,"Required":"N"]
        self.fieldConfig["city"] = ["type":"String","min":5,"max":255,"Required":"Y"]
        self.fieldConfig["postcode"] = ["type":"String","min":6,"max":7,"Required":"Y"]
        self.fieldConfig["homephone"] = ["type":"String","min":10,"max":255,"Required":"N"]
        self.fieldConfig["cellphone"] = ["type":"String","min":10,"max":255,"Required":"N"]
        self.fieldConfig["emergencyContact"] = ["type":"String","min":10,"max":255,"Required":"Y"]
        self.fieldConfig["gender"] = ["type":"String","min":2,"max":10,"Required":"Y"]
        
    }
    
    let content = ["register": ["name","password","email"],
                   "leader": ["name"],
                   "location": ["name"],
                   "dancer": ["FirstName","LastName","DateOfBirth","gender"],
                   "inscription": ["email","street","appartment","city","postcode","homephone","cellphone","emergencyContact"]
                   ]
    
    
    func verifyField(field:String, data:String?) -> JSON {
        
        print("Field: \(field)")
        print("Data: \(String(describing: data))")
        
        if fieldConfig[field] == nil {return JSON(["status":"NOK"])}
        let config = fieldConfig[field]!
        print(config)
        
        if let data = data {
            
            if data.characters.count < config["min"] as! Int {addError(field: field, message: "TOO_SHORT", limit: (config["min"] as! Int))}
            if data.characters.count > config["max"] as! Int {addError(field: field, message: "TOO_LONG", limit: (config["max"] as! Int))}
            if config["type"] as! String == "email" && (data.range(of:"@")==nil || data.range(of:".")==nil) {addError(field: field, message: "INVALID_EMAIL")}
            if config["type"] as! String == "Integer" && data.isNumber == false {addError(field: field, message: "MUST_BE_NUMERIC")}
            if config["type"] as! String == "Date" && data.isDate() == false {addError(field: field, message: "MUST_BE_ISO_DATE")}
            
        } else {
            
            if config["Required"] as! String == "Y" {addError(field: field, message: "MISSING_REQUIRED_FIELD") ; return JSON(["status":"NOK"]) }
            
        }
        
        print("Validation Finished")
        if errorCapture.isEmpty {
            print("Error Capture empty")
            return JSON(["status":"OK"])
        } else {
            print("Error Capture content")
            print(errorCapture)
            return try! JSON(node: errorCapture)        }
        
    }
    
    
    func verify(data:Content, contentType: String) -> JSON {
        print("data: \(data)")
        print("contenttype: \(contentType)")
        
        let fields = content[contentType]
        
        for field in fields! {
            
            _ = verifyField(field: field, data: data[field]?.string)
            
        }
        
        if errorCapture.isEmpty {
            
            return JSON(["status":"ok"])
        } else {
            return try! JSON(node: errorCapture)        }
    }
    
    
    
    func addError(field:String, message:String, limit:Int?=nil) {
    
        var errorMessage = [String:Any]()
        
        errorMessage["error"] = message
        if limit != nil {errorMessage["limit"] = limit!}
        
        errorCapture[field] = errorMessage

    }
    
    
}



extension String  {
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
}
