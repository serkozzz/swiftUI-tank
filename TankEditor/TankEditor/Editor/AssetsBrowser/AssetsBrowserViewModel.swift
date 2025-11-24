//
//  AssetsBrowserViewModel.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 24.11.2025.
//

import SwiftUI
import Combine

class AssetsBrowserViewModel: ObservableObject {
    @Published var visibleAssets: [Asset] = []
    
    var projectRoot: String
    
    private var path = [String]() {
        didSet { updateVisibleAssets() }
    }
    
    private var fullPath: String {
        projectRoot + path.reduce("/", { $0 + $1 + "/" })
    }
    
    init(projectRoot: String) {
        self.projectRoot = projectRoot
        updateVisibleAssets()
    }
    
    func updateVisibleAssets() {
        let fm = FileManager.default
        let dirURL = URL(fileURLWithPath: fullPath)
        
        do {
            let items = try fm.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants])
            
            var assets: [Asset] = []
            assets.reserveCapacity(items.count)
            
            for url in items {
                let name = url.lastPathComponent
                // пропускаем скрытые
                if name.hasPrefix(".") { continue }
                
                // определяем папка/файл
                let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey])
                let isDirectory = resourceValues?.isDirectory ?? false
                
                if isDirectory {
                    assets.append(Asset(name: name, type: .folder))
                } else if url.pathExtension.lowercased() == "swift" {
                    assets.append(Asset(name: name, type: .file))
                } else {
                    // игнорируем другие файлы
                    continue
                }
            }
            
            // сортировка: папки сверху, затем файлы; обе группы по имени (case-insensitive)
            assets.sort { lhs, rhs in
                switch (lhs.type, rhs.type) {
                case (.folder, .file):
                    return true
                case (.file, .folder):
                    return false
                default:
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.visibleAssets = assets
            }
        } catch {
            // В случае ошибки — очищаем список
            DispatchQueue.main.async { [weak self] in
                self?.visibleAssets = []
            }
        }
    }
    
    func open(asset: Asset) {
        switch asset.type {
        case .file:
            break
        case .folder:
            path.append(asset.name)
        }
    }
    
    func goUp() {
        path = Array(path.dropLast())
    }
}

