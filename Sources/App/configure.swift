import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.migrations.add(CreateTodo())

    // register routes
    try routes(app)
    
    //image upload maxSize
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.workingDirectory))
    app.routes.defaultMaxBodySize = "150mb"
    
    //Session configuration
    app.middleware.use(app.sessions.middleware)
    
}
//Add comments so i guess i can commit it to github
