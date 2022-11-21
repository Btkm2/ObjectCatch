import Fluent
import Vapor
import Foundation

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
//        "Hello, world!"
//        guard let request = req.client! else{
//            return ""
//        }
//        return ("Hello it's \(req.client.self) of device")
        return ("Description: \(req.description) \n Session: \(req.session)")
    }
    app.post("upload") { req -> EventLoopFuture<Response> in
        struct FileContent: Content {
            var files: [File]
        }
        let directory = DirectoryConfiguration.detect()
        let workPath = directory.workingDirectory
        let name = UUID().uuidString + ".jpg"
        let imageFolder = "/Users/bkt/UploadedImages/"
        let test_url = req.application.directory.publicDirectory + "uploads/"
        //add folder creation method so every upload will be saved into it's own new folder/directory
        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)

        let input = try req.content.decode(FileContent.self)
        return input.files.map { payload in
            return req.fileio.writeFile(payload.data, at: imageFolder + name).map{}
        /*return req.application.fileio.openFile(path: saveURL.path,mode: .write,flags: .allowFileCreation(posixMode: 0x744),eventLoop: req.eventLoop)
                .flatMap { handle in
                    req.application.fileio.write(fileHandle: handle,buffer: payload.data,eventLoop: req.eventLoop)
                        .flatMapThrowing { _ in
                            try handle.close()
//                            return UploadedFile(url: fileName, isImage: isImage)
                        }
                }*/
//                do {
//            try payload.data.write(to: saveURL)
//                    try payload.data.write(to: saveURL)
//                    print("payload: \(payload)")
//                   return 0
            
//                } catch {
//                    print("error: \(error)")
//                    throw Abort(.internalServerError, reason: "Unable to write multipart form data to file. Underlying error \(error)")
//                }
        }.flatten(on: req.eventLoop).transform(to: Response(status: .accepted))
//        if #available(macOS 12.0, *) {
//            HelloPhotogrammetry.main(["/Users/bkt/UploadedImages"
//                                      ,"/Users/bkt/ProcessedModels",
//                                      "-d","medium",
//                                      "-o","unordered",
//                                      "-f","high"])
//        } else {
//            fatalError("Requires minimum macOS 12.0!")
//        }
    }
    
    try app.register(collection: TodoController())
}
