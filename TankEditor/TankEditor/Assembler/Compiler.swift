//
//  Compiler.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 26.11.2025.
//

import Foundation
import TankEngine2D

class Compiler {
    
    private var buildTask: Task<Void, Never>? = nil
    private var activeProcess: Process? = nil
    
    func build(at buildRoot: URL) {
        // Если уже выполняется — отменяем
        
        buildTask?.cancel()
        
        buildTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            
            do {
                try await self.buildProcess(at: buildRoot)
                await MainActor.run {
                    TELogger2D.info("Build finished!")
                }
            } catch is CancellationError {
                await MainActor.run {
                    TELogger2D.info("Build cancelled")
                }
            } catch {
                await MainActor.run {
                    TELogger2D.error("Build failed: \(error)")
                }
            }
        }
    }
    
    
    func buildProcess(at buildRoot: URL) async throws {
        try Task.checkCancellation()
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", "build", "-c", "debug", "--package-path", buildRoot.path]
        
        // Запоминаем, чтобы можно было отменить извне
        self.activeProcess = process
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        
        // Читаем вывод асинхронно
        for try await line in pipe.fileHandleForReading.bytes.lines {
            try Task.checkCancellation()
            print("[swift build]", line)
        }
        
        // Ждём, пока закончится
        process.waitUntilExit()
        
        //если компиляция завершилась с ошибками, процесс вернет не 0 (это не значит что
        //процесс упал, например если процесс завершился корректно с ошибками компиляции - это 1.
        if process.terminationStatus != 0 {
            throw NSError(domain: "BuildError", code: Int(process.terminationStatus))
        }
    }
    
    func cancelBuild() {
        buildTask?.cancel()
        buildTask = nil
        
        activeProcess?.interrupt()
        activeProcess?.terminate()
        activeProcess = nil
    }

    deinit {
        cancelBuild()
    }
}

