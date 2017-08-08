//
//  utils.swift
//  jbsignup
//
//  Created by Richard on 2017-07-29.
//

import Foundation
import Vapor
import FluentProvider
import Random
import SMTP


extension String {
  
    func toDate () -> Date {
    
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            print(dateFormatter.date(from: self)!)
        
            return dateFormatter.date(from: self)!
    }
    
    func toCheck () -> String {
        
        if self == "on" {
            return "✓"
        } else {
            return ""
        }
    }
    
    func isDate() -> Bool {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        if dateFormatterGet.date(from: self) != nil {
            return true
        } else {
            // invalid format
            return false
        }
        
        
    }
}

extension Date {
    
    func ISODate () -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: self)
        
    }
    
    func dateAndTime () -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormatter.string(from: self)
        
    }
    
    
    func age () -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: .year, in: .era, for: self) else { return 0 }
        guard let end = currentCalendar.ordinality(of: .year, in: .era, for: Date()) else { return 0 }
        
        return end - start
        
    }
    
}

extension String
{
    var isNumeric: Bool
    {
        let range = self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted)
        return (range == nil)
    }
}


func lessonList(_ info:Droplet) throws -> Array<JSON> {
    
    let lessons = info.config["lessons","lessons"]!.array
    var selectLesson = [JSON]()
    for lesson in lessons! {
        var json = JSON()
        try json.set("key",lesson.string!)
        try json.set("readable",info.config["lessons",lesson.string!,"en"]!.string!)
        try json.set("status","")
        selectLesson.append(json)
    }
    return selectLesson
}

func randomString(length: Int) -> String {

    let letters : String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    var randomString = ""
    
    
    for _ in 0 ..< length {
        let rand = makeRandom(min: 0, max: 61)
        let index = letters.characters.index(letters.startIndex, offsetBy: rand)
        let nextChar = letters[index]
        randomString += String(describing: nextChar)
    }

    return randomString
}


func addLessonName(drop:Droplet, familyId:String, lang:String) throws -> JSON {
    
     let lessons = try lesson.makeQuery().filter("familyId", .equals, familyId).all()
     let dancers = try dancer.makeQuery().filter("Family", .equals, familyId).all()
    
     var lessonList = [JSON]()
     var dancerList = [String]()
    
    // Return all dancers so the lines can be generated if no lessons selected
    for dancer in dancers {
        dancerList.append((dancer.id?.string!)!)
    }
    
     var i = 0
     for lesson in lessons {
        var lessonItem = JSON()
        try lessonItem = lesson.makeJSON()
        try lessonItem.set("Lesson",drop.config["lessons",lesson.lessonId,lang])
        lessonList.append(lessonItem)
        i += 1
        dancerList.append(lesson.dancerId)
    }
    
    // Add blank lines for the print if there are less than 4 items.
    for dancer in Set(dancerList) {

        if countItem(List: dancerList, item: dancer) < 4 {
            for _ in countItem(List: dancerList, item: dancer)...4 {
                var blankLine = JSON()
                try blankLine.set("dancerId", dancer)
                
                lessonList.append(blankLine)
            }
        }
    }

    return try lessonList.makeJSON()
}



    
func countItem(List:Array<String>, item:String) -> Int {
        
        var counting = 0
        
        for elementItem in List {
            
            if elementItem == item {counting += 1}
        }
        
        return counting
}

func sendAdminEmail(Template:String, drop:Droplet, lang:String, host:String, email:String) throws {
    
    var subject = ""
    var body = ""
    
    
    if Template == "ADMINLINK" {
        
        if lang == "en" {
            body = "<html><p>To access the Administration Module, please click on this link</p><p>https://\(host)/administration/\(try drop.hash.make(email).makeString())</><p>Please do not share this link in order to maintain security.</p></html>"
            
            subject = "Access the Administration Centre"
        }
        
        if lang == "fr" {
            
            body = "<html><p>Pour acceder au module d'administration, veuillez cliquer sur cette lien</p><p>https://\(host)/administration/\(try drop.hash.make(email).makeString())</><p>Ce lien est personalizé uniquement pour vous. Ne pas partager s'il vous plaît.</p></html>"
            
            subject = "Votre accès au système d'administration"
            
        }
        
    }
    
    
    let emailContent = EmailBody(type: .html, content: body)
    let email = Email(from:"info@junior-ballet.com", to: email, subject: subject, body: emailContent)
    try drop.mail.send(email)
}
