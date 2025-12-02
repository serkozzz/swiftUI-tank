//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct PropsInspectorView: View {
    @ObservedObject var viewModel: PropsInspectorViewModel
    
    let subheaderFont: Font = .title2.bold()
    let subheader2Font: Font = .default.bold()
    
    
    var body: some View {
        if viewModel.selectedNode == nil {
            Color.clear
        } else {
            let node = viewModel.selectedNode!
            VStack {
                Text("NodeName: \(node.displayName)")
                    .font(subheaderFont)
                VStack(alignment: .leading) {
                    Text("Views:")
                        .font(subheaderFont)
                    viewsGrid(node.views)
                }
                Divider()
                VStack(alignment: .leading) {
                    Text("Components:")
                        .font(subheaderFont)
                        .padding(.leading, 8)
                    componentsGrid(node.components)
                }
                .background(
                    Rectangle()
                        .stroke(Color.black))
            }
            
            .padding()
            
        }
    }
    
    @ViewBuilder
    func viewsGrid(_ views: [any TEView2D]) -> some View {
        VStack(alignment: .leading) {
            ForEach(0..<views.count, id: \.self) { i in
                Text(String(describing: type(of: views[i])))
                HStack(spacing: 0) {
                    gridCell("viewModel", alignment: .leading)
                    gridCell("nil", alignment: .trailing)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
        
    
    @ViewBuilder
    func componentsGrid(_ components: [TEComponent2D]) -> some View {
        let columns: [GridItem] = [
            GridItem(.flexible(), spacing: 0, alignment: nil),
            GridItem(.flexible(), spacing: 0, alignment: nil)
        ]
        VStack(alignment: .leading, spacing: 0) {
            ForEach(components) { component in
                HStack {
                    Text(String(describing: type(of: component)))
                        .font(subheader2Font)
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "arrowshape.up")
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "arrowshape.down")
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .padding(8)
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
                    let refs = component.allTEComponentRefs()
                    ForEach(refs.keys.sorted(), id: \.self) { key in
                        gridCell(key, alignment: .leading)
                        gridCell("nil", alignment: .trailing)
                    }
                    
                    let props = component.encodeSerializableProperties()
                    ForEach(props.keys.sorted(), id: \.self) { key in
                        gridCell(key, alignment: .leading)
                        gridCell(props[key]!, alignment: .trailing)
                    }
                    
                }
            }
        }
    }
    
    
    func gridCell(_ str: String, alignment: Alignment) -> some View {
        Text(str)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: alignment)
            .background(
                Rectangle()
                    .stroke(Color.black)
            )
    }
}

#Preview {
    @Previewable @State var vm =  PropsInspectorViewModel(projectContext: ProjectContext.sampleContext)
    vm.selectedNode = vm.projectContext.editorScene.rootNode.children[1]
    return PropsInspectorView(viewModel: vm).frame(width: 300, height: 600)
}
