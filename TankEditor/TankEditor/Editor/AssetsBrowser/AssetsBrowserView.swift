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
    private var CELL_SIZE = CGSize(width: 75, height: 75)
    
    init(viewModel: AssetsBrowserViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color.gray
            VStack {
                assetsGrid
                    .background {
                        Color.green
                    }
                    .padding()
                
                Text("path:/" + viewModel.displayPath)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
    }
    
    @ViewBuilder
    var assetsGrid: some View {
        let columns: [GridItem] = [
            GridItem(.adaptive(minimum: CELL_SIZE.width, maximum: CELL_SIZE.width), spacing: nil, alignment: nil),
        ]
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.visibleAssets) { asset in
                    if (asset.type == .goUpFolder) {
                        assetView(asset)
                    } else {
                        assetView(asset).draggable(asset)
                    }
                }
            }
        }
    }
    
    
    func assetView(_ asset: Asset) -> some View {
        VStack {
            Image( asset.type == .file ? "swift": "folder1")
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
            Text(asset.displayName).font(.caption).lineLimit(1)
        }
        .frame(height: CELL_SIZE.height)
        .onTapGesture {
            viewModel.open(asset: asset)
        }
        .background {
            RoundedRectangle(cornerRadius: 3).stroke(.black)
        }
    }
}

#Preview {
    AssetsBrowserView(viewModel: AssetsBrowserViewModel(projectRoot: "/Users/sergeykozlov/Documents/TankEngineProjects/Sandbox"))
}
