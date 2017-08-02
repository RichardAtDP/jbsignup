//
//  dancers.swift
//  Bits
//
//  Created by Richard on 2017-07-29.
//

import Foundation
import Vapor
import FluentProvider

final class dancer: Model {

    var FirstName: String
    var LastName: String
    var Family: String
    var DateOfBirth: Date
    var Gender: String
    
    let storage = Storage()
    
    init(FirstName:String, LastName:String, Family:String, DateOfBirth:Date, Gender:String) throws {
        
        self.FirstName = FirstName
        self.LastName = LastName
        self.Family = Family
        self.DateOfBirth = DateOfBirth
        self.Gender = Gender
    }

    
     init(row: Row) throws {
         FirstName = try row.get("FirstName")
         LastName = try row.get("LastName")
         Family = try row.get("Family")
         DateOfBirth = try row.get("DateOfBirth")
         Gender = try row.get("Gender")
        
    }

    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("Family", Family)
        try row.set("FirstName", FirstName)
        try row.set("LastName", LastName)
        try row.set("DateOfBirth", DateOfBirth)
        try row.set("Gender", Gender)
        
        return row

    }

}


extension dancer: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { dancer in
            dancer.id()
            dancer.string("FirstName")
            dancer.string("LastName")
            dancer.string("Family")
            dancer.date("DateOfBirth")
            dancer.string("Gender")

            
            
            
        }
        
        
        
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension dancer: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            FirstName: json.get("FirstName"),
            LastName: json.get("LastName"),
            Family: json.get("Family"),
            DateOfBirth: json.get("DateOfBirth"),
            Gender: json.get("Gender")

            
        )
}

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("FirstName", FirstName)
        try json.set("LastName", LastName)
        try json.set("Family", Family)
        try json.set("DateOfBirth", DateOfBirth)
        try json.set("Gender", Gender)

        return json
    }
}

extension dancer: Timestampable { }

extension dancer: ResponseRepresentable { }


func formatLessonList(familyid: Int ,info:Droplet) throws -> Array<JSON> {
    var selectedLessons = JSON()
    var dancers = [JSON]()
    let lessons = info.config["lessons","lessons"]!.array
    
    for dancer in try dancer.makeQuery().filter("Family", .equals, familyid).all() {
        
        
        let chosenLessons = try lesson.makeQuery().filter("dancerId",.equals,dancer.id).all()
        
        // Create form
        var form = ""
        
        for chosenLesson in chosenLessons {
            
            var lessonDetails = ""
            for lessonKey in lessons! {
                var checked = ""
                if lessonKey.string! == chosenLesson.lessonId {checked = "selected"}
                
                lessonDetails += "<option value='\(lessonKey.string!)' \(checked)>\(String(describing: info.config["lessons",lessonKey.string!,"en"]!.string!))</option>"
                
            }
            
            
            form += "<div uk-grid class='uk-grid-divider'><div class='uk-width-expand@m'><select class='uk-select' name='lesson'>\(lessonDetails)</select></div><div class='uk-width-1-3@m'><input class='uk-input' type='text' placeholder='Sessions per week' name='sessions' value='\(chosenLesson.frequency)'></div><div class='uk-width-1-6@m'><a href='/family/\(familyid)/lesson/\(chosenLesson.id!.int!)/delete' uk-icon='icon: trash'></a></div><input type='hidden' name='dancer' value='\(dancer.id!.string!)'></div>"
            
        }
        
        // Add form to dancer
        try selectedLessons.set(dancer.id!.string!,form)
        var dancerDetails = try dancer.makeJSON()
        try dancerDetails.set("lessons",form)
        dancers.append(dancerDetails)
    }
    
    return dancers
}

