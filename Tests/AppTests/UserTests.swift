//
//  UserTests.swift
//  
//
//  Created by Alan on 1/11/22.
//

@testable import App
import XCTVapor

final class UserTests: XCTestCase {
  
  func testUsersCanBeRetrievedFromAPI() throws {
    let expectedName = "Alice"
    let expectedUsername = "alice"
    
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    
    try app.autoRevert().wait()
    try app.autoMigrate().wait()

    
    let user = User(
      name: expectedName,
      username: expectedUsername)
    try user.save(on: app.db).wait()
    
    try User(name: "Luke", username: "lukes")
      .save(on: app.db)
      .wait()
    
    try app.test(.GET, "/api/users", afterResponse: { response in
      XCTAssertEqual(response.status, .ok)
      
      let users = try response.content.decode([User].self)
      
      XCTAssertEqual(users.count, 2)
      XCTAssertEqual(users[0].name, expectedName)
      XCTAssertEqual(users[0].username, expectedUsername)
      XCTAssertEqual(users[0].id, user.id)
      
    })
  }
}
