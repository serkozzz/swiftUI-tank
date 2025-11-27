//
//  SettingsView.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @Binding var path: NavigationPath
    var body: some View {
        VStack{
            Button("Back to menu") {
                path.removeLast()
            }
            Text("Settings")
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    SettingsView(path: $path)
}
