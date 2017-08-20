//
//  family.swift
//  jbsignup
//
//  Created by Richard on 2017-07-29.
//

import Foundation
import Vapor
import FluentProvider
import SMTP

final class family: Model {
    
    var email: String
    var CASL: String?
    var printKey: String
    var street: String
    var appartment: String?
    var city: String
    var postcode: String
    var homephone: String?
    var cellphone: String?
    var emergencyContact: String?
    var how_hear: String?
    var photos: String?
    var lang:String?
    
    let storage = Storage()
    
    init(email:String, CASL:String?, street:String, appartment:String?, city:String, postcode:String, homephone:String?, cellphone:String?, emergencyContact:String?, how_hear:String?, photos:String?, lang:String?) throws {
        
        self.email = email
        self.CASL = CASL
        self.printKey = randomString(length: 24)
        self.street = street
        self.appartment = appartment
        self.city = city
        self.postcode = postcode
        self.homephone = homephone
        self.cellphone = cellphone
        self.emergencyContact = emergencyContact
        self.how_hear = how_hear
        self.photos = photos
        self.lang = lang

    }
    
    
    init(row: Row) throws {
        email = try row.get("email")
        CASL = try row.get("CASL")
        printKey = try row.get("printKey")
        street = try row.get("street")
        appartment = try row.get("appartment")
        city = try row.get("city")
        postcode = try row.get("postcode")
        homephone = try row.get("homephone")
        cellphone = try row.get("cellphone")
        emergencyContact = try row.get("emergencyContact")
        how_hear = try row.get("how_hear")
        photos = try row.get("photos")
        lang = try row.get("lang")
        
    }
    
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("email", email)
        try row.set("CASL", CASL)
        try row.set("printKey", printKey)
        try row.set("street", street)
        try row.set("appartment", appartment)
        try row.set("city", city)
        try row.set("postcode", postcode)
        try row.set("homephone", homephone)
        try row.set("cellphone", cellphone)
        try row.set("emergencyContact", emergencyContact)
        try row.set("how_hear", how_hear)
        try row.set("photos", photos)
        try row.set("lang", lang)
        
        return row
        
    }
    
}


extension family: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { family in
            family.id()
            family.string("email")
            family.string("CASL",optional:true)
            family.string("printKey")
            family.string("street")
            family.string("appartment",optional:true)
            family.string("city")
            family.string("postcode")
            family.string("homephone",optional:true)
            family.string("cellphone",optional:true)
            family.string("emergencyContact",optional:true)
            family.string("how_hear",optional:true)
            family.string("photos",optional:true)
            family.string("lang",optional:true)
   
        }
        
        
        
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension family: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            email: json.get("email"),
            CASL: json.get("CASL"),
            street:  json.get("street"),
            appartment:  json.get("appartment"),
            city:  json.get("city"),
            postcode:  json.get("postcode"),
            homephone:  json.get("homephone"),
            cellphone:  json.get("cellphone"),
            emergencyContact:  json.get("emergencyContact"),
            how_hear: json.get("how_hear"),
            photos: json.get("photos"),
            lang: json.get("lang")

        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("email", email)
        try json.set("CASL", CASL?.toCheck())
        try json.set("printKey", printKey)
        try json.set("street", street)
        try json.set("appartment", appartment)
        try json.set("city", city)
        try json.set("postcode", postcode)
        try json.set("homephone", homephone)
        try json.set("cellphone", cellphone)
        try json.set("emergencyContact", emergencyContact)
        try json.set("how_hear", how_hear)
        try json.set("photos", photos?.toCheck())
        try json.set("lang",lang)
        try json.set("updatedAt",updatedAt?.dateAndTime())
        try json.set("createdAt",createdAt?.dateAndTime())
        
        return json
    }
}

extension family: Timestampable { }

extension family: ResponseRepresentable { }

func sendEmail(familyId:String, Template:String, drop:Droplet, lang:String, host:String) throws {
    
    var subject = ""
    var body = ""
    
    let Family = try family.find(familyId)
    
    if Template == "PRINT" {
        
        if lang == "en" {
            body = "<html><p>Thank you entering your inscription information.</p> <p>The next step is to visit the school on Tuesday 22nd, Saturday 26th or Sunday 27th August to complete your inscription.</p><p><b>Please print out your contracts and bring them with you.</b></p> <p>You can retrieve your contracts by clicking <a href='https://\(host)/summary/\(Family!.printKey)'>here</a>.</p>Thank you for your confidence in Junior Ballet!</p></html>"
            
            subject = "Your Inscription with Junior Ballet"
        }
        
        if lang == "fr" {
            
            body = "<html><p>Merci d'avoir complété les informations nécessaires pour l'inscription automne-hiver 2017.</p> <p>La prochaine étape est de se rendre à l'école soit le mardi 22, soit le samedi 26 soit le dimanche 27 aout pour terminer votre inscription.</p><p><b>Veuillez imprimer vos contrats et les ramener à l'école lors de votre passage.</b></p> <p>Vous pouvez acceder à vos contrats <a href='https://\(host)/summary/\(Family!.printKey)'>ici</a>.</p>Merci pour votre confiance en le Junior Ballet</p></html>"
            
            subject = "Votre inscription avec le Junior Ballet"
            
        }

    }
    

    if Template == "EMAIL_EXISTS" {
        if lang == "en" {
            body = "<html>You can continue or modify your Junior Ballet inscription by clicking on this link:<p> https://\(host)/restart/\(Family!.printKey)</p></html>"
            
            subject = "Your Inscription to Junior Ballet's Fall-Winter 2017 Season"
        }
        
        if lang == "fr" {
            body = "<html>Vous pouvez continuer ou modifier votre inscription Junior Ballet en accedant ce lien:<p> https://\(host)/restart/\(Family!.printKey)</p></html>"
        
            subject = "Votre inscription au session automne-hiver 2017 du Junior Ballet"
        }
    }
    
    if Template == "REMINDER" {
        if lang == "en" {
            body = "<html></p>Hi,</p><p>Thank you for having begun your inscription to the Junior Ballet!</p><p>We cannot wait to welcome you to our Fall-Winter season.</p><p></p><p><br />In order to accelerate your inscription, don't forget to print <a href='https://\(host)/summary/\(Family!.printKey)'>your contract</a> and bring it to the inscription session.</p> <p></p><p><br />The inscription sessions will take place:</p><p> </p><p>Tuesday 22nd August from 16:00 à 20:00</p><p>Saturday and Sunday 26th and 27th August from 13:00 to 17:00</p><p></p><p><br />Thank you!</p></html>"
            
            subject = "Your Inscription to Junior Ballet's Fall-Winter 2017 Season"
        }
        
        if lang == "fr" {
            body = "<html></p>Bonjour,</p><p>Merci d’avoir démarré votre inscription au Junior Ballet.</p><p>Nous avons hâte de vous accueillir pour notre nouvelle session.</p><p></p><p><br />Pour accélérer votre inscription, n'oubliez pas d'imprimer <a href='https://\(host)/summary/\(Family!.printKey)'>votre contrat</a> et apportez le lors des l’inscriptions.</p> <p></p><p><br />Les inscriptions auront lieu au Junior Ballet :</p><p> </p><p>Mardi 22 août de 16h00 à 20h00</p><p>Samedi et dimanche 26 et 27 août de 13h00 à 17h00</p><p></p><p><br />Merci de l’intérêt que vous portez au Junior Ballet !</p></html>"
            
            subject = "Votre inscription au session automne-hiver 2017 du Junior Ballet"
        }
    }
    
    if Template == "ADDDANCERS" {
        if lang == "en" {
            body = "<html></p>Hi,</p><p>Thank you for having begun your inscription to the Junior Ballet!</p><p>We cannot wait to welcome you to our Fall-Winter season.</p><p></p><p><br />In order to continue your inscription, please enter your dancer(s) name  : https://\(host)/restart/\(Family!.printKey) <p></p><p></p><p><br />The inscription sessions will take place:</p><p> </p><p>Tuesday 22nd August from 16:00 à 20:00</p><p>Saturday and Sunday 26th and 27th August from 13:00 to 17:00</p><p></p><p><br />Thank you!</p></html>"
            
            subject = "Your Inscription to Junior Ballet's Fall-Winter 2017 Season"
        }
        
        if lang == "fr" {
            body = "<html></p>Bonjour,</p><p>Merci d’avoir démarré votre inscription au Junior Ballet.</p><p>Nous avons hâte de vous accueillir pour notre nouvelle session.</p><p></p><p><br />Afin de continuer votre inscription, pourriez-vous remplir le nom de l’élève  en cliquant sur le lien suivant : https://\(host)/restart/\(Family!.printKey) <p></p><p>Pour accélérer votre inscription, imprimez votre contrat et apportez le lors des l’inscriptions.</p> <p></p><p><br />Les inscriptions auront lieu au Junior Ballet :</p><p> </p><p>Mardi 22 août de 16h00 à 20h00</p><p>Samedi et dimanche 26 et 27 août de 13h00 à 17h00</p><p></p><p><br />Merci de l’intérêt que vous portez au Junior Ballet !</p></html>"
            
            subject = "Votre inscription au session automne-hiver 2017 du Junior Ballet"
        }
    }
    
    let emailContent = EmailBody(type: .html, content: body)
    let email = Email(from:"info@junior-ballet.com", to: Family!.email, subject: subject, body: emailContent)
    try drop.mail.send(email)
}
