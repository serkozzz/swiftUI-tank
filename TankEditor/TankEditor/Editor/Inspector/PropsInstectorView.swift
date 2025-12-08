//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import AppKit
import TankEngine2D

struct PropsInspectorView: View {
    @ObservedObject var viewModel: PropsInspectorViewModel
    
    let subheaderFont: Font = .title2.bold()
    let subheader2Font: Font = .default.bold()
    
    
    var body: some View {
        ZStack {
            Color(nsColor: .underPageBackgroundColor)
            if viewModel.selectedNode != nil {
                let node = viewModel.selectedNode!
                ScrollView {
                    VStack {
                        Text("NodeName: \(node.displayName)").font(subheaderFont)
                        
                        transformSection()
                        viewsSection(node.views)
                        
                        Divider()
                        componentsSection(node.components)
                        
                    }
                    
                    .padding()
                }
            }
        }
    }
    
    @ViewBuilder func transformSection() -> some View {
        VStack(alignment: .leading) {
            Text("Transform:").font(subheaderFont).padding(.leading, 8)
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    TransformRepresentation(viewModel: .init(node: viewModel.selectedNode!))
                }
            }
            .background(
                Rectangle()
                    .stroke(Color.black))
        }
    }
    
    @ViewBuilder
    func viewsSection(_ views: [any TEView2D]) -> some View {
        VStack(alignment: .leading) {
            
            Text("Views:").font(subheaderFont).padding(.leading, 8)
            
            
            ForEach(0..<views.count, id: \.self) { i in
                VStack(alignment: .leading) {
                    Text(String(describing: type(of: views[i]))).padding(8)
                    HStack(spacing: 0) {
                        Text("viewModel").propCell(alignment: .leading)
                        Text("nil").propCell(alignment: .trailing)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .stroke(Color.black))
        }
    }
    
    
    @ViewBuilder
    func componentsSection(_ components: [TEComponent2D]) -> some View {
        VStack(alignment: .leading) {
            
            Text("Components:").font(subheaderFont).padding(.leading, 8)
            
            List {
                ForEach(components) { component in
                    VStack {
                        componentHeader(component)
                            .padding(8)
                        componentPropsGrid(component)
                    }
                    
                    .background(
                        Rectangle()
                            .stroke(Color.black))
                    .padding(8)
                    
                }
                .onMove(perform: moveComponent)
            }
                .frame(height: 500)

        }
    }
    
    func moveComponent(from source: IndexSet, to destination: Int) {
        viewModel.moveComponent(sourceIndex: source.first!, destIndex: destination)
    }
    
    
    @ViewBuilder
    func componentHeader(_ component: TEComponent2D) -> some View {
        HStack {
            Text(String(describing: type(of: component)))
                .font(subheader2Font)
            Spacer()
            componentButtons
        }
    }
    
    @ViewBuilder
    func componentPropsGrid(_ component: TEComponent2D) -> some View {
        let columns: [GridItem] = [
            GridItem(.flexible(), spacing: 0, alignment: nil),
            GridItem(.flexible(), spacing: 0, alignment: nil)
        ]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
            let refs = component.allTEComponentRefs()
            ForEach(refs.keys.sorted(), id: \.self) { key in
                Text(key).propCell(alignment: .leading)
                Text("nil").propCell(alignment: .trailing)
            }
            let props = component.encodeSerializableProperties()//.filter({ $0.key == "myVector2"})
            ForEach(props.keys.sorted(), id: \.self) { key in
                PropViewFactory(viewModel: PropViewModel(component: component, propName: key))
            }
        }
    }
    
    @ViewBuilder
    var componentButtons: some View {
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
    


}



#Preview {
    @Previewable @State var vm =  PropsInspectorViewModel(projectContext: ProjectContext.sampleContext)
    vm.selectedNode = vm.projectContext.editorScene.rootNode.children[1]
    return PropsInspectorView(viewModel: vm).frame(width: 300, height: 600)
}
