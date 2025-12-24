//
//  PropView.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 04.12.2025.
//

import SwiftUI
import TankEngine2D

//factory of particular type representation views
struct PropViewFactory: View {
    @ObservedObject var viewModel: PropViewModel
    var body: some View {
        Text(viewModel.propName).propCell(alignment: .leading)
        
        switch (viewModel.propType) {
        case .bool:
            BoolRepresentation(value: viewModel.propBinding()).propCell(alignment: .trailing)
        case .integer:
            IntegerRepresentaton(value: viewModel.propBinding()).propCell(alignment: .trailing)
        case .float:
            FloatRepresentaton(value: viewModel.propBinding()).propCell(alignment: .trailing)
        case .string:
            StringRepresentaton(value: viewModel.stringPropBinding()).propCell(alignment: .trailing)
        case .vector2:
            Vector2Representaton(value: viewModel.propBinding()).propCell(alignment: .trailing)
        case .vector3:
            Vector3Representaton(value: viewModel.propBinding()).propCell(alignment: .trailing)
        case .other:
            StringRepresentaton(value: viewModel.stringPropBinding()).propCell(alignment: .trailing)

        }
    }
}


#Preview {
    @Previewable @State var vm =  PropsInspectorViewModel(projectContext: ProjectContext.sampleContext, selectedNode: nil)
    vm.selectedNode = vm.projectContext.editorScene.rootNode.children[1]
    
    return HStack {
        PropViewFactory(viewModel: PropViewModel(component: vm.selectedNode!.components[0], propName: "myBool"))
    }
}
