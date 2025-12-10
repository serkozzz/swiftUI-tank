//
//  ComponentsCollectionView.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 09.12.2025.
//

import SwiftUI
import TankEngine2D
import UniformTypeIdentifiers

struct ComponentsCollectionView: View {
    var viewModel: PropsInspectorViewModel
    var components: [TEComponent2D]
    
    @State private var dragState: DragState = .init()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Components:").font(Globals.INSPECTOR_SUBHEADER_FONT).padding(.leading, 8)
            
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
                            Color("InspectorComponent"))
                    }
                    .contentShape(Rectangle())
                    .opacity(dragState.draggedItemID == component.id && dragState.isDragOverCollection ? 0.2 : 1.0)
                    .reordering( dragState: $dragState,
                                 items: components,
                                 item: component,
                                 index: index) { src, dest in
                        viewModel.moveComponent(sourceIndex: src, destIndex: dest)
                    }
                }
            }
        }

    }
    



    @ViewBuilder
    func componentHeader(_ component: TEComponent2D) -> some View {
        HStack {
            Text(String(describing: type(of: component)))
                .font(Globals.INSPECTOR_SUBHEADER2_FONT)
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
