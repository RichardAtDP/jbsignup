//
//  Middleware.swift
//  jbsignup
//
//  Created by Richard on 2017-08-03.
//

import Foundation
import Vapor
import HTTP

final class knownMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)
        
        return response
    }
}
