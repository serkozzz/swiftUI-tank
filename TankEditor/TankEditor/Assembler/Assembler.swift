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
    
    func buildUserCode() async throws {
        guard let buildRoot = createAndFillPackageFolderIfNeeded() else {
            throw NSError(domain: "BuildError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare build folder"])
        }
        try await compiler.build(at: buildRoot).value
        //TODO разобраться с тем откуда плагин должен подцепить либу.
        //PluginLoader.shared.load()
    }
    
    
    private func createAndFillPackageFolderIfNeeded() -> URL? {
        let buildRoot = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/TankEditor/\(projectContext.projectName)/UserBuild")
        
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
        
        // cоздаём папку-симлинк на скрипты юзера
        do {
            let linkPath = sourcesDir.appendingPathComponent("UserCodeDylib").path
            try fm.createSymbolicLink(atPath: linkPath, withDestinationPath: projectContext.projectPath)
        } catch(let error) {
            TELogger2D.error("Build error. Could not create symling for UserCodeDylib: \(error)")
            return nil
        }
        
        // Копируем TankEngine2D.framework
        guard copyEngineFramework(buildRoot: buildRoot) else { return nil }
        
        return buildRoot
    }
    
   ///Копирует (создаёт симлинк на) TankEngine2D.framework из контейнера приложения в buildRoot/Frameworks
    private func copyEngineFramework(buildRoot: URL) -> Bool {
        do {
            // Папка назначения для фреймворков
            let frameworksDestDir = buildRoot.appendingPathComponent("Frameworks")
            if !fm.fileExists(atPath: frameworksDestDir.path) {
                try fm.createDirectory(at: frameworksDestDir, withIntermediateDirectories: true)
            }
        
            // Для macOS app bundle фреймворки лежат в Contents/Frameworks.
            // privateFrameworksURL в большинстве случаев указывает на ту папку.
            let frameworkName = "TankEngine2D.framework"
            
            // Попробуем несколько вариантов поиска:
            var possibleFrameworkURLs: [URL] = []
            if let privateFW = Bundle.main.privateFrameworksURL {
                possibleFrameworkURLs.append(privateFW.appendingPathComponent(frameworkName))
            }
            let bundleURL = Bundle.main.bundleURL
            possibleFrameworkURLs.append(bundleURL.appendingPathComponent("Contents/Frameworks/\(frameworkName)"))
        
            guard let engineFrameworkURL = possibleFrameworkURLs.first(where: { fm.fileExists(atPath: $0.path) }) else {
                TELogger2D.error("Build error. TankEngine2D.framework not found in app bundle Frameworks")
                return false
            }
            
            let destFrameworkURL = frameworksDestDir.appendingPathComponent(frameworkName)
            
            // Если уже есть (ссылка или папка) — удалим
            if fm.fileExists(atPath: destFrameworkURL.path) {
                try fm.removeItem(at: destFrameworkURL)
            }
            
            // Создаём символическую ссылку вместо копирования
            try fm.createSymbolicLink(atPath: destFrameworkURL.path, withDestinationPath: engineFrameworkURL.path)
        } catch(let error) {
            TELogger2D.error("Build error. Could not create symlink for TankEngine2D.framework: \(error)")
            return false
        }
        return true
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

