import Vapor
import Fluent

struct AcronymsController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let acronymsRoutes = routes.grouped("api", "acronyms")
    
    // routes.get("api", "acronyms", use: getAllHandler)
    acronymsRoutes.get(use: getAllHandler)
    acronymsRoutes.post(use: createHandler)
    acronymsRoutes.get(":acronymID", use: getHandler)
    acronymsRoutes.put(":acronymID", use: updateHandler)
    acronymsRoutes.delete(":acronymID", use: deleteHandler)
    acronymsRoutes.get("search", use: searchHandler)
    acronymsRoutes.get("first", use: getFirstHandler)
    acronymsRoutes.get("sorted", use: sortedHandler)
    acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
    
  }
  
  func getAllHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
    Acronym.query(on: req.db).all()
  }
  
  // moved from routes.swift
  func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
//    let acronym = try req.content.decode(Acronym.self)
    let data = try req.content.decode(CreateAcronymData.self)
    let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
    return acronym.save(on: req.db).map { acronym }
    
  }
  
  func getHandler(_ req: Request) -> EventLoopFuture<Acronym> {
    Acronym.find(req.parameters.get("acronymID"), on: req.db)
      .unwrap(or: Abort(.notFound))
  }
  
  func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
//    let updatedAcronym = try req.content.decode(Acronym.self)
    let updateData = try req.content.decode(CreateAcronymData.self)
    
    return Acronym.find(req.parameters.get("acronymID"), on: req.db)
      .unwrap(or: Abort(.notFound))
      .flatMap { acronym in
        acronym.short = updateData.short
        acronym.long = updateData.long
        acronym.$user.id = updateData.userID
        
        return acronym.save(on: req.db).map {
          acronym
        }
      }
  }
  
  func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
    Acronym.find(req.parameters.get("acronymID"), on: req.db)
      .unwrap(or: Abort(.notFound))
      .flatMap { acronym in
        acronym.delete(on: req.db)
          .transform(to: .noContent)
      }
  }
  
  func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
    guard let searchTerm = req
            .query[String.self, at: "term"] else {
              throw Abort(.badRequest)
            }
    
    return Acronym.query(on: req.db).group(.or) {
      or in
      or.filter(\.$short == searchTerm)
      or.filter(\.$long == searchTerm)
    }.all()
  }
  
  func getFirstHandler(_ req: Request) -> EventLoopFuture<Acronym> {
    return Acronym.query(on: req.db)
      .first()
      .unwrap(or: Abort(.notFound))
  }
  
  func sortedHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
    return Acronym.query(on: req.db)
      .sort(\.$short, .ascending).all()
  }
  
  func getUserHandler(_ req: Request) -> EventLoopFuture<User> {
    Acronym.find(req.parameters.get("acronymID"), on: req.db)
      .unwrap(or: Abort(.notFound))
      .flatMap { acronym in
        acronym.$user.get(on: req.db)
      }
  }

}

struct CreateAcronymData: Content {
  let short: String
  let long: String
  let userID: UUID
}


