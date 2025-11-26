//
//  Assembler.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 26.11.2025.
//

import Foundation
import TankEngine2D

class Assembler {
    
    private let fm = FileManager.default
    private let projectContext: ProjectContext
    
    private let PACKAGE_TEMPLATE_FILE_NAME = "PackageTemplate"
    private let compiler = Compiler()

    
    init(projectContext: ProjectContext) {
        self.projectContext = projectContext
    }
    
    func buildUserCode() {
        guard let buildRoot = createAndFillPackageFolderIfNeeded() else { return }
        compiler.build(at: buildRoot)
    }
    
   

    
    private func createAndFillPackageFolderIfNeeded() -> URL? {
        let buildRoot = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/\(projectContext.projectName)/UserBuild")
        let sourcesDir = buildRoot.appendingPathComponent("Sources")
        
        do {
            try? fm.removeItem(at: buildRoot) // можно и не удалять
            try fm.createDirectory(at: buildRoot, withIntermediateDirectories: true)
            try fm.createDirectory(at: sourcesDir, withIntermediateDirectories: true)
        } catch(let error) {
            TELogger2D.error("Build error. Could not create folder: \(error)")
            return nil
        }
        
        //package
        do {
            let packageFileContent = readResourcesFile(fileName: PACKAGE_TEMPLATE_FILE_NAME,
                                                       fileExtension: "txt")
            let packageURL = buildRoot.appendingPathComponent("Package.swift")
            try packageFileContent.write(to: packageURL, atomically: true, encoding: .utf8)
            
        } catch(let error) {
            TELogger2D.error("Build error. Could not write package file into a build folder: \(error)")
            return nil
        }
        
        // cоздаём симлинк на UserCodeDylib
        do {
            let linkPath = sourcesDir.appendingPathComponent("UserCodeDylib").path
            try fm.createSymbolicLink(atPath: linkPath, withDestinationPath: projectContext.projectPath)
        } catch(let error) {
            TELogger2D.error("Build error. Could not create symling for UserCodeDylib: \(error)")
            return nil
        }
        return buildRoot
    }
    
    
    private func readResourcesFile(fileName: String, fileExtension: String) -> String {
        let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension)!
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            fatalError("Ошибка при чтении файла: \(error.localizedDescription)")
        }
    }
}
