	import Vapor

extension Droplet {
    func setupRoutes() throws {
        
        
        get("inscription") { req in
            
            return try self.view.make("inscription")
        
        }
        
        post("inscription") { req in
            
            let emailProvided = req.data["email"]?.string
            
            if (emailProvided?.range(of:"@")==nil || emailProvided?.range(of:".")==nil) {
                
                    return Response(redirect: "/inscription?error=INVALID_EMAIL")}
            else {
                
                let Family = try family(email:emailProvided!)
                try Family.save()
                
                return Response(redirect: "/family/\(String(describing: Family.id!.int!))/dancer")
            }
            
        }
        
        
        get("description") { req in return req.description }
        
        
        get("family", ":id", "dancer") {req in
            
            guard let familyid = req.parameters["id"]?.int else {
                throw Abort.badRequest
            }
            
            
            
         return try self.view.make("dancer")
            
        }
        
        post("family", ":id", "dancer") { req in
         
            guard let familyid = req.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            
            let status = validate().verify(data: req.data, contentType: "dancer")
            
            if status["status"] == "ok" {
            
                let Dancer = try dancer(
                    FirstName:(req.data["FirstName"]?.string!)!
                    , LastName:(req.data["LastName"]?.string!)!
                        , Family:familyid
                    , DateOfBirth:(req.data["DateOfBirth"]?.string?.toDate())!
                    , Gender:(req.data["gender"]?.string!)!)
                
                try Dancer.save()
                
                return Response(redirect: "/family/\(String(describing: familyid))")
                
            } else {

                return try self.view.make("dancer", ["errors":status])
            }
        }
        
        
        get("family", ":id", "dancer", ":dancerId") {req in
            
            guard let familyid = req.parameters["id"]?.int else {
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
            
            return try self.view.make("dancer", ["Dancer": Dancer])
            
        }
        
 
        post("family", ":id", "dancer", ":dancerId") {req in
            
            guard let familyid = req.parameters["id"]?.int else {
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
                return try self.view.make("dancer", ["errors":status])
            }
        }
        
        
        get("family",":id","dancer", ":dancerId", "delete") { req in
           
            guard let familyid = req.parameters["id"]?.int else {
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
            
            var familyMembers = [JSON]()
            
            for member in try dancer.makeQuery().filter("Family", .equals ,familyid).all() {
                
                var dancer = try member.makeJSON()
                let FormattedDate: Date = try dancer.get("DateOfBirth")
                try dancer.set("FormattedDoB", FormattedDate.ISODate())
                
                familyMembers.append(dancer)
            }
            
            return try self.view.make("family", ["family":familyMembers, "familyid":familyid])
        }
        
        get("family",":id","lessons") { req in
            
            guard let familyid = req.parameters["id"]?.int else {
                throw Abort.badRequest
            }

            var dancers = [JSON]()
            for dancer in try dancer.makeQuery().filter("Family", .equals, familyid).all() {
                dancers.append(try dancer.makeJSON())
            }
            
            let lessons = self.config["lessons","lessons"]!.array
            
            var selectLesson = [JSON]()
            for lesson in lessons! {
                print(lesson.string!)
                print(self.config["lessons",lesson.string!,"en"]!.string!)
                var json = JSON()
                try json.set("key",lesson.string!)
                try json.set("readable",self.config["lessons",lesson.string!,"en"]!.string!)
                try json.set("status","")
                selectLesson.append(json)
                
            }
            
            return try self.view.make("lessons", ["familyid":familyid,"selectLesson":selectLesson,"dancers":dancers])
        }
        
        try resource("posts", PostController.self)
    }
}
