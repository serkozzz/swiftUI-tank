//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct AssetsBrowserView: View {
    @StateObject var viewModel: AssetsBrowserViewModel
    
    init(viewModel: AssetsBrowserViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        let columns: [GridItem] = [
            GridItem(.adaptive(minimum: 50, maximum: 50), spacing: nil, alignment: nil),
        ]
        
        LazyVGrid(columns: columns) {
            ForEach(viewModel.visibleAssets) { asset in
                Text(asset.name)
            }
        }

    }
}

#Preview {
    AssetsBrowserView(viewModel: AssetsBrowserViewModel(projectRoot: "/Users/sergeykozlov/Documents/TankEngineProjects/Sandbox"))
}
