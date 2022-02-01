import Fluent
import Vapor

func routes(_ app: Application) throws {
  // Default
//  app.get { req in
//    return "It works!"
//  }
//
//  app.get("hello") { req -> String in
//    return "Hello, world!"
//  }
  
  // Acronyms
  let acronymsController = AcronymsController()
  try app.register(collection: acronymsController)
  
  // Users
  let usersController = UsersController()
  try app.register(collection: usersController)
  
  // Categories Controller
  let categoriesController = CategoriesController()
  try app.register(collection: categoriesController)
  
  // Website Controller
  let websiteController = WebsiteController()
  try app.register(collection: websiteController)

}
