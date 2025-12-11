//
//  ViewsCollecitonView.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 09.12.2025.
//

import SwiftUI
import TankEngine2D
import UniformTypeIdentifiers

private struct AnyIdentifiableView2D: Identifiable {
    var id: UUID { base.id }
    let base: any TEView2D

    init(_ base: any TEView2D) {
        self.base = base
    }
}

struct ViewsCollecitonView : View {

    var views: [any TEView2D]
    @State private var dragState: ReorderingDragState = .init()
    @ObservedObject var viewModel: PropsInspectorViewModel

    var body: some View {
        VStack(alignment: .leading) {

            Text("Views:").font(Globals.INSPECTOR_SUBHEADER_FONT).padding(.leading, 8)

            // Преобразуем к "type-erased" массиву
            let typedViews = views.map { AnyIdentifiableView2D($0) }
            ForEach(Array(typedViews.enumerated()), id: \.element.id) { i, wrapped in
                VStack(alignment: .leading) {
                    Text(String(describing: type(of: wrapped.base))).padding(8)
                    HStack(spacing: 0) {
                        Text("viewModel").propCell(alignment: .leading)
                        Text("nil").propCell(alignment: .trailing)
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 10).fill(
                        Color("InspectorView"))
                }
                .reordering(dragState: $dragState,
                            items: typedViews,
                            item: wrapped,
                            index: i,
                            uiTypeIdentifier: UTType.viewDrag.identifier ) { src, dst in
                            viewModel.moveView(sourceIndex: src, destIndex: dst)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
