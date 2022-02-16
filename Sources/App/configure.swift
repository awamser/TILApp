import Fluent
import FluentPostgresDriver
import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
  // uncomment to serve files from /Public folder
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  // added for unit testing
  let databaseName: String
  let databasePort: Int
  
  if (app.environment == .testing) {
    databaseName = "vapor-test"
    databasePort = 5433
//    if let testPort = Environment.get("DATABASE_PORT") {
//      databasePort = Int(testPort) ?? 5433
//    } else {
//      databasePort = 5433
//    }
  } else {
    databaseName = "vapor_database"
    databasePort = 5432
  }

  app.databases.use(.postgres(
    hostname: Environment.get("DATABASE_HOST") ?? "localhost",
    port: databasePort,
    username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
    password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
    database: Environment.get("DATABASE_NAME") ?? databaseName
  ), as: .psql)

  /**
   app.databases.use(.postgres(
   hostname: Environment.get("DATABASE_HOST") ?? "localhost",
   port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
   username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
   password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
   database: Environment.get("DATABASE_NAME") ?? "vapor_database"
   ), as: .psql)
   **/
  
  // app.migrations.add(CreateTodo())
  
  app.migrations.add(CreateUser())
  app.migrations.add(CreateAcronym())
  app.migrations.add(CreateCategory())
  app.migrations.add(CreateAcronymCategoryPivot())
    
  
  app.logger.logLevel = .debug
  try app.autoMigrate().wait()

  // Leaf
  app.views.use(.leaf)

  
  // register routes
  try routes(app)
}
