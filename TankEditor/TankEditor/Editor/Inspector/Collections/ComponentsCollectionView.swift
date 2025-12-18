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
    @ObservedObject var viewModel: PropsInspectorViewModel
    var components: [TEComponent2D]
    
    @State private var dragState: ReorderingDragState = .init()
    
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
                    .reordering( dragState: $dragState,
                                 items: components,
                                 item: component,
                                 index: index,
                                 uiTypeIdentifier: UTType.componentDrag.identifier ) { src, dest in
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
            componentButtons(component: component)
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
            ForEach(refs, id: \.uuidString) { dto in
                Text(dto.propertyName).propCell(alignment: .leading)
                ComponentRefRepresentation(
                    viewModel: ComponentRefViewModel(
                        projectContext: viewModel.projectContext,
                        owner: component,
                        propName: dto.propertyName,
                        propID: dto.uuidString
                    )
                )
                .propCell(alignment: .trailing)
            }
            let props = component.encodeSerializableProperties()//.filter({ $0.key == "myVector2"})
            ForEach(props.keys.sorted(), id: \.self) { key in
                PropViewFactory(viewModel: PropViewModel(component: component, propName: key))
            }
        }
    }
    
    @ViewBuilder
    func componentButtons(component: TEComponent2D) -> some View {
        Button {
            guard let sourceInx = viewModel.indexOf(component: component), sourceInx > 0  else { return }
            viewModel.moveComponent(sourceIndex: sourceInx, destIndex: sourceInx - 1)
        } label: {
            Image(systemName: "arrowshape.up")
        }
        Button {
            guard let sourceInx = viewModel.indexOf(component: component), sourceInx < components.count - 1  else { return }
            viewModel.moveComponent(sourceIndex: sourceInx, destIndex: sourceInx + 1)
        } label: {
            Image(systemName: "arrowshape.down")
        }
        Button {
            component.owner!.detachComponent(component.id)
        } label: {
            Image(systemName: "xmark")
        }
    }
    
}
