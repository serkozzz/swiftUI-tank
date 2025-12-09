//
//  ViewsCollecitonView.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 09.12.2025.
//

import SwiftUI
import TankEngine2D

struct ViewsCollecitonView : View {
    
    var views: [any TEView2D]
    @State private var dragState: DragState = .init()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Views:").font(Globals.INSPECTOR_SUBHEADER_FONT).padding(.leading, 8)
            
            
            ForEach(0..<views.count, id: \.self) { i in
                VStack(alignment: .leading) {
                    Text(String(describing: type(of: views[i]))).padding(8)
                    HStack(spacing: 0) {
                        Text("viewModel").propCell(alignment: .leading)
                        Text("nil").propCell(alignment: .trailing)
                    }
                }
                .background{
                    RoundedRectangle(cornerRadius: 10).fill(
                        Color("InspectorView"))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
