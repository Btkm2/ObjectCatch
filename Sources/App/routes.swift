import Fluent
import Vapor
import Foundation
import ZipArchive
import os

private var logger = Logger()

var filename: String = ""

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
        let name = UUID().uuidString + ".zip"
        let imageFolder = "/Users/bkt/UploadedImages/"
        let test_url = req.application.directory.publicDirectory + "uploads/"
        //add folder creation method so every upload will be saved into it's own new folder/directory
        let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
        let input = try req.content.decode(FileContent.self)
//        do {
//            return input.files.map { payload in
//                filename = payload.filename
//    //            runConversion(filename: payload.filename)
//                getFileName(filename: payload.filename)
//                return req.fileio.writeFile(payload.data, at: imageFolder + payload.filename).map{}
//            }.flatten(on: req.eventLoop).transform(to: Response(status: .accepted))
//            print("Done")
//        } catch {
//            print("Enable to save file")
//        }
//        print("Something")
        return input.files.map { payload in
            filename = payload.filename
//            getFileName(filename: payload.filename)
            do {
                try req.fileio.writeFile(payload.data, at: imageFolder + payload.filename).map{}
                print("new Success!")
                getFileName(filename: payload.filename)
                return Response(status: .accepted).encodeResponse(for: req)
                logger.log("Successfully saved file!")
                print("Success!")
            } catch {
                print(error)
            }
//            return req.fileio.writeFile(payload.data, at: imageFolder + payload.filename).map{}
//            runConversion(filename: payload.filename)
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
//        print("something")
    }
//    completion(true)
    //Doesn't run code
//    getFileName(filename: filename)
    
    app.get("downloadFile") { req -> EventLoopFuture<Response> in
        let path = "/Users/bkt/ProcessedModels/"
//        let promise = req.eventLoop.makePromise(of: Response.self)
        let response = req.fileio.streamFile(at: "/Users/bkt/ProcessedModels/Rock36Images.usdz")
        return req.eventLoop.makeSucceededFuture(response)
    }
    
//    /Users/bkt/ProcessedModels/Rock36Images.usdz
    try app.register(collection: TodoController())
}
//Add comments so i guess i can commit it to github

func getFileName(filename: String) -> String{
    let fileManager = FileManager.default
//    print(unZipFile(filename: filename))
//    print(fileManager.displayName(atPath: "/Users/bkt/ProcessedModels/\(filename)"))
    var fileNameWithoutExtension = URL(string: filename)
//    print("relative path: \(String(describing: fileNameWithoutExtension?.deletingPathExtension().relativePath))")
//    print("absolute URL: \(String(describing: fileNameWithoutExtension?.deletingPathExtension().absoluteURL))")
//    print("absolute String: \(String(describing: fileNameWithoutExtension?.deletingPathExtension().absoluteString))")
//    print("base URL: \(String(describing: fileNameWithoutExtension?.deletingPathExtension().baseURL))")
//    print("DeletingPathExtension: \(String(describing: fileNameWithoutExtension?.deletingPathExtension()))")
    guard let newFileName = fileNameWithoutExtension?.deletingPathExtension().absoluteString else {
        return ""
    }
    print(newFileName)
    if unZipFile(filename: filename) {
        logger.log("Successfully unzipped file!")
        do {
            try fileManager.removeItem(atPath: "/Users/bkt/UploadedImages/\(filename)")
            logger.log("Deleted zip file")
        } catch {
            print(error)
        }
    }
    if !fileManager.fileExists(atPath: "/Users/bkt/UploadedImages/\(filename)") {
        DispatchQueue.global(qos: .userInitiated).async {
            //runConversion(filename: newFileName)
        }
        print("Success!")
        print("FileName: \(filename)")
    }else {
        print("Error file exist!")
    }
    return filename
}

func runConversion(filename: String) {
    if #available(macOS 12.0, *) {
        HelloPhotogrammetry.main(["/Users/bkt/UploadedImages/\(filename)"
                                  ,"/Users/bkt/ProcessedModels/\(filename).usdz",
                                  "-d","medium",
                                  "-o","unordered",
                                  "-f","high"])
    }
}

func unZipFile(filename: String) -> Bool{
    logger.log("Starting unzipping")
    let path = "/Users/bkt/ProcessedModels/"
    return SSZipArchive.unzipFile(atPath: "/Users/bkt/UploadedImages/\(filename)", toDestination: "/Users/bkt/UploadedImages")
}
///Users/bkt/UploadedImages/Rock36Images.zip
