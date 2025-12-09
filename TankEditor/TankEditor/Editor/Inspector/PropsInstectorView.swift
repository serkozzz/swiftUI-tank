//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import AppKit
import TankEngine2D
import UniformTypeIdentifiers

struct PropsInspectorView: View {
    @ObservedObject var viewModel: PropsInspectorViewModel
    
    let subheaderFont: Font = .title2.bold()
    let subheader2Font: Font = .default.bold()
    
    @State private var draggedComponentID: UUID?
    
    var body: some View {
        ZStack {
            Color(nsColor: .controlBackgroundColor)
            if let node = viewModel.selectedNode {
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
            
            VStack {
                ForEach(Array(components.enumerated()), id: \.element.id) { index, component in
                    VStack {
                        componentHeader(component)
                            .padding(8)
                        componentPropsGrid(component)
                    }

                    .padding(8)
                    .background{
                        RoundedRectangle(cornerRadius: 10).fill(
                        Color(nsColor: .underPageBackgroundColor))
                    }
                    .contentShape(Rectangle())
                    .opacity(draggedComponentID == component.id ? 0.2 : 1.0)
                    .onDrag( {
                        self.draggedComponentID = component.id
                        return NSItemProvider(object: component.id.uuidString as NSString)
                        
                    })
                    .onDrop(of: [.text],
                            delegate: {
                        print(".onDrop")
                        return DragRelocateDelegate(item: component,
                                             currentIndex: index,
                                             components: components,
                                             moveAction: moveComponent,
                                             draggedComponentID: $draggedComponentID)
                    }())
                }
            }
        }

    }
    
    func moveComponent(sourceID: UUID, destIndex: Int) {
        guard let sourceIndex = viewModel.selectedNode?.components.firstIndex(where: { $0.id == sourceID }) else { return }
        if sourceIndex != destIndex {
            viewModel.moveComponent(sourceIndex: sourceIndex, destIndex: destIndex)
        }
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

struct DragRelocateDelegate: DropDelegate {
    let item: TEComponent2D
    let currentIndex: Int
    let components: [TEComponent2D]
    let moveAction: (UUID, Int) -> Void
    @Binding var draggedComponentID: UUID?
    
    func dropEntered(info: DropInfo) {
        guard let draggedID = draggedComponentID,
              let fromIndex = components.firstIndex(where: { $0.id == draggedID }),
              fromIndex != currentIndex else { return }
        moveAction(draggedID, currentIndex)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedComponentID = nil
        return true
    }
    
    func dropExited(info: DropInfo) {
        draggedComponentID = nil
    }
}


#Preview {
    @Previewable @State var vm =  PropsInspectorViewModel(projectContext: ProjectContext.sampleContext)
    vm.selectedNode = vm.projectContext.editorScene.rootNode.children[1]
    return PropsInspectorView(viewModel: vm).frame(width: 300, height: 600)
}
