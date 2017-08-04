import Vapor
import Sessions

var lang = "en"

extension Droplet {

    
    func setupRoutes() throws {
        
        
        get("inscription") { req in
            
            setLang(req.data["lang"])
            
            var error:String?
            
            if req.data["error"] != nil {
                error = self.config["labels",lang,req.data["error"]!.string!]!.string
            }
            
            
            return try self.view.make("inscription",["label":self.config["labels",lang] as Any, "errors":error as Any])
        
        }
        
        post("inscription") { req in
            
            let emailProvided = req.data["email"]?.string
            
            if (emailProvided?.range(of:"@")==nil || emailProvided?.range(of:".")==nil) {
                
                    return Response(redirect: "/inscription?error=INVALID_EMAIL")}
           
            let Fam = try family.makeQuery().filter("email", .equals, emailProvided)
            if try Fam.count() > 0 {
                
                try sendEmail(familyId: (try Fam.first()!.id?.string!)!, Template: "EMAIL_EXISTS", drop: self)
                    return Response(redirect: "/inscription?error=EMAIL_EXISTS")
            }
                
                
                let Family = try family(email:emailProvided!)
                try Family.save()
                
                let session = try req.assertSession()
                try session.data.set("email", emailProvided)
                
                return Response(redirect: "/family/\(String(describing: Family.id!.int!))/dancer")
        
            
        }
        

        
        
        get("family", ":id", "dancer") {req in
            
            guard let familyid = req.parameters["id"]?.int else {
                throw Abort.badRequest
            }
            
            let session = try req.assertSession()
            if try family.makeQuery().filter("email",.equals,session.data["email"]!.string!).first()!.id!.int! != familyid  {
                throw Abort.badRequest
            }
            
         return try self.view.make("dancer",["label":self.config["labels",lang]])
            
        }
        
        post("family", ":id", "dancer") { req in
         
            guard let familyid = req.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            
            let session = try req.assertSession()
            if try family.makeQuery().filter("email",.equals,session.data["email"]!.string!).first()!.id!.string! != familyid  {
                throw Abort.badRequest
            }
            
            
            let status = validate().verify(data: req.data, contentType: "dancer")
            
            if status["status"] == "ok" {
            
                let Dancer = try dancer(
                    FirstName:(req.data["FirstName"]?.string!)!
                    , LastName:(req.data["LastName"]?.string!)!
                        , Family:familyid
                    , DateOfBirth:(req.data["DateOfBirth"]?.string?.toDate())!
                    , Gender:(req.data["gender"]?.string!)!
                    , Allergies:(req.data["Allergies"]?.string!)!
                )
                
                try Dancer.save()
                
                return Response(redirect: "/family/\(String(describing: familyid))")
                
            } else {

                return try self.view.make("dancer", ["errors":status,"label":self.config["labels",lang]])
            }
        }
        
        
        get("family", ":id", "dancer", ":dancerId") {req in
            
            guard let familyid = req.parameters["id"]?.int else {
                throw Abort.badRequest
            }
            
            let session = try req.assertSession()
            if try family.makeQuery().filter("email",.equals,session.data["email"]!.string!).first()!.id!.int! != familyid  {
                throw Abort.badRequest
            }
            
            guard let dancerid = req.parameters["dancerId"]?.int! else {
                throw Abort.badRequest
            }
           
            guard var Dancer = try dancer.find(dancerid)?.makeJSON() else {
                throw Abort.notFound
            }
            
            if try Dancer.get("Gender") == "male" {
                try Dancer.set("male", true)
            } else {
                try Dancer.set("female", true)
            }
            
            return try self.view.make("dancer", ["Dancer": Dancer,"label":self.config["labels",lang]])
            
        }
        
 
        post("family", ":id", "dancer", ":dancerId") {req in
            
            guard let familyid = req.parameters["id"]?.int else {
                throw Abort.badRequest
            }
            
            let session = try req.assertSession()
            if try family.makeQuery().filter("email",.equals,session.data["email"]!.string!).first()!.id!.int! != familyid  {
                throw Abort.badRequest
            }
            
            guard let dancerid = req.parameters["dancerId"]?.int! else {
                throw Abort.badRequest
            }
            
            let status = validate().verify(data: req.data, contentType: "dancer")
            
            if status["status"] == "ok" {
            
                guard let Dancer = try dancer.find(dancerid) else {
                    throw Abort.notFound
                }
                
                Dancer.FirstName = (req.data["FirstName"]?.string!)!
                Dancer.LastName = (req.data["LastName"]?.string!)!
                Dancer.Gender = (req.data["gender"]?.string!)!
                Dancer.DateOfBirth = (req.data["DateOfBirth"]?.string?.toDate())!
                
                try Dancer.save()
                
                return Response(redirect: "/family/\(String(describing: familyid))")
                
            } else {
                return try self.view.make("dancer", ["errors":status,"label":self.config["labels",lang]])
            }
        }
        
        
        get("family",":id","dancer", ":dancerId", "delete") { req in
           
            guard let familyid = req.parameters["id"]?.int else {
                throw Abort.badRequest
            }
            
            let session = try req.assertSession()
            if try family.makeQuery().filter("email",.equals,session.data["email"]!.string!).first()!.id!.int! != familyid  {
                throw Abort.badRequest
            }
            
            guard let dancerid = req.parameters["dancerId"]?.int! else {
                throw Abort.badRequest
            }
            
            guard let Dancer = try dancer.find(dancerid) else {
                throw Abort.notFound
            }
            
            try Dancer.delete()
            
            return Response(redirect: "/family/\(String(describing: familyid))")
        }
        
        get("family", ":id") { req in
            
            guard let familyid = req.parameters["id"]?.int else {
                throw Abort.badRequest
            }
            
            let session = try req.assertSession()
            if (try family.makeQuery().filter("email",.equals,session.data["email"]?.string).first()?.id?.int ?? 0)! != familyid  {
                throw Abort.badRequest
            }
            
            let familyMembers =  try dancer.makeQuery().filter("Family", .equals ,familyid).all().makeJSON()
                
            return try self.view.make("family", ["family":familyMembers, "familyid":familyid, "label":self.config["labels",lang]])
        }
        
        get("family",":id","lessons") { req in
            
            guard let familyid = req.parameters["id"]?.int else {
                throw Abort.badRequest
            }
            
            let session = try req.assertSession()
            if (try family.makeQuery().filter("email",.equals,session.data["email"]?.string).first()?.id?.int ?? 0)! != familyid  {
                throw Abort.badRequest
            }
            
            let dancers = try formatLessonList(familyid:familyid, info:self)

            return try self.view.make("lessons", ["familyid":familyid,"dancers":dancers,"selectLesson":lessonList(self), "label":self.config["labels",lang]])
        }
        
        post("family",":id","lessons") { req in
        
            guard let familyid = req.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            
            let session = try req.assertSession()
            if (try family.makeQuery().filter("email",.equals,session.data["email"]?.string).first()?.id?.string ?? "0")! != familyid  {
                throw Abort.badRequest
            }
            
            try saveLesson(proData:req.data, familyid:familyid)
           
            try sendEmail(familyId: familyid, Template: "PRINT", drop: self)
            
            return try self.view.make("confirm", ["familyid":familyid,"label":self.config["labels",lang]])
        }
        
        get("family",":id", "lesson",":lessonId","delete") { req in
            
            guard let familyid = req.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            
            let session = try req.assertSession()
            if (try family.makeQuery().filter("email",.equals,session.data["email"]?.string).first()?.id?.string ?? "0")! != familyid  {
                throw Abort.badRequest
            }
            
            guard let lessonid = req.parameters["lessonId"]?.int else {
                throw Abort.badRequest
            }
            
            try lesson.find(lessonid)?.delete()
            
            return Response(redirect: "/family/\(String(describing: familyid))/lessons")
        }
        
        get("print",":printKey") { req in
            
            guard let printKey = req.parameters["printKey"]?.string else {
                throw Abort.badRequest
            }
            
            guard let Family = try family.makeQuery().filter("printKey",.equals,printKey).first() else {
                throw Abort.badRequest
            }
            
            
            let dancers = try dancer.makeQuery().filter("Family",.equals,Family.id!.string!).all()
            
            let lessons = try addLessonName(drop: self, familyId: Family.id!.string!, lang:lang)


            
            return try self.view.make("print",["family":Family.makeJSON(), "dancers":dancers.makeJSON(), "lessons":lessons, "config":self.config["lessons"]!.makeNode(in:nil), "label":self.config["labels",lang]])
        }
        
        get("restart",":printKey") { req in
            
            guard let printKey = req.parameters["printKey"]?.string else {
                throw Abort.badRequest
            }
            
            guard let Family = try family.makeQuery().filter("printKey",.equals,printKey).first() else {
                throw Abort.badRequest
            }
            
            let session = try req.assertSession()
            try session.data.set("email", Family.email)
            
            return Response(redirect: "/family/\(String(describing: Family.id!.string!))")
        }
        
        try resource("posts", PostController.self)
    }
    
    

    
}

func setLang(_ content:Node?) {
    
    if content?.string != nil {
        
        if ["en","fr"].contains(content!.string!)  {
            lang = (content!.string!)
            print(lang)
        }
    }
}
