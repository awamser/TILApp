import Fluent
import Vapor

func routes(_ app: Application) throws {
  
  // Acronyms
  let acronymsController = AcronymsController()
  try app.register(collection: acronymsController)
  
  // Users
  let usersController = UsersController()
  try app.register(collection: usersController)
  
}
