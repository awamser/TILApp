//
//  File.swift
//
//
//  Created by Alan on 1/3/22.
//

import Vapor

struct UsersController: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    let usersRoute = routes.grouped("api", "users")
    usersRoute.post(use: createHandler)
    usersRoute.get(use: getAllHandler)
    usersRoute.get(":userID", use: getHandler)
    usersRoute.get(":userID", "acronyms", use: getAcronymsHandler)

    let basicAuthMiddleware = User.authenticator()
    let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
    basicAuthGroup.post("login", use: loginHandler)

  }

  func createHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
    let user = try req.content.decode(User.self)
    user.password = try Bcrypt.hash(user.password)

    // return user.save(on: req.db).map { user }
    return user.save(on: req.db).map { user.convertToPublic() }

  }

  func getAllHandler(_ req: Request) -> EventLoopFuture<[User.Public]> {
    // User.query(on: req.db).all()

    // uses the extension for EventLoopFuture<[User]>
    User.query(on: req.db).all().convertToPublic()
  }

  func getHandler(_ req: Request) -> EventLoopFuture<User.Public> {
    // User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
    User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
      .convertToPublic()

  }

  func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
    User.find(req.parameters.get("userID"), on: req.db)
      .unwrap(or: Abort(.notFound))
      .flatMap { user in
        user.$acronyms.get(on: req.db)
      }
  }

  func loginHandler(_ req: Request) throws -> EventLoopFuture<Token> {
    let user = try req.auth.require(User.self)
    let token = try Token.generate(for: user)

    return token.save(on: req.db).map { token }
  }

}
