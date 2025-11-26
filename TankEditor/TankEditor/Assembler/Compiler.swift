//
//  Compiler.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 26.11.2025.
//

import Foundation
import TankEngine2D

class Compiler {
    
    private var buildTask: Task<Void, Error>? = nil
    private var activeProcess: Process? = nil
    
    func build(at buildRoot: URL) -> Task<Void, Error> {
        // Если уже выполняется — отменяем
        cancelBuild()
        
        let task = Task.detached(priority: .userInitiated) { [weak self] in
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
                throw CancellationError()
            } catch {
                await MainActor.run {
                    TELogger2D.error("Build failed: \(error)")
                }
                throw error
            }
        }
        self.buildTask = task
        return task
    }
    
    func buildProcess(at buildRoot: URL) async throws {
        try Task.checkCancellation()
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", "build", "-c", "debug", "--package-path", buildRoot.path]
        
        self.activeProcess = process
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        
        for try await line in pipe.fileHandleForReading.bytes.lines {
            try Task.checkCancellation()
            print("[swift build]", line)
        }
        
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            throw NSError(domain: "BuildError", code: Int(process.terminationStatus))
        }
    }
    
    func cancelBuild() {
        // Отменяем task (если есть) — это бросит CancellationError внутри buildProcess
        buildTask?.cancel()
        buildTask = nil
        
        // Пытаемся остановить внешний процесс
        activeProcess?.interrupt()
        activeProcess?.terminate()
        activeProcess = nil
    }

    deinit {
        cancelBuild()
    }
}

