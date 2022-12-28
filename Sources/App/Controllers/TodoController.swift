import Fluent
import Vapor
import Foundation
import FileProvider
import os

private var logger = Logger()

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
            todo.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [Todo] {
        try await Todo.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Todo {
        let todo = try req.content.decode(Todo.self)
        try await todo.save(on: req.db)
        return todo
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await todo.delete(on: req.db)
        return .noContent
    }
    
    func saveFile(req: Request) async throws -> Response {
        struct FileContent: Content {
            var files: [File]
        }
        let saveFolderPath = "/Users/bkt/UploadImages/"
        let input = try req.content.decode(FileContent.self)
        try await input.files.map { file in
            do {
                try req.fileio.writeFile(file.data, at: saveFolderPath + file.filename).map{}
                print("Succes from async/await!")
                getFileName(filename: file.filename)
                logger.log("Successfully saved file from async/await!")
                return Response(status: .accepted)
            } catch {
                print(error)
                return Response(status: .badRequest)
            }
        }
        return Response(status: .accepted)
    }
    
    func downloadFile(_ req: Request) throws -> Response {
        guard let url = try URL(string: "/Users/bkt/ProcessedModels/Rock36Images.usdz") else {
            return Response(status: .noContent)
        }
        return req.fileio.streamFile(at: url.path)
    }
    
    /*struct FileContent: Content {
        var file: [File]
    }
    //MARK: Solve problem with working directory
    func uploadUser(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
            print("uploadUserImage")
        let directory = DirectoryConfiguration.detect()
        let workPath = directory.workingDirectory
        let name = UUID().uuidString + ".jpg"
        let imageFolder = "profile/images"
        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)

        let input = try req.content.decode(FileContent.self)
        return input.file.map { payload in
//                do {
            try payload.data.write(to: saveURL)
                    try payload.data.write(to: saveURL)
                    print("payload: \(payload)")
                   return 0
//                } catch {
//                    print("error: \(error)")
//                    throw Abort(.internalServerError, reason: "Unable to write multipart form data to file. Underlying error \(error)")
//                }
        }.flatten(on: req as! EventLoop).transform(to: .ok)
        }*/
}
//Add comments so i guess i can commit it to github
