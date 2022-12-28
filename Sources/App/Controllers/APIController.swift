//
//  File.swift
//  
//
//  Created by Beket Muratbek on 22.12.2022.
//

import Foundation
import Fluent
import FileProvider
import Vapor
import os

private var logger = Logger()

struct APIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let controller = routes.grouped("controller")
        controller.post(use: saveFileOnMac)
    }
    func saveFileOnMac(req: Request) async throws -> Response {
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
    
}
