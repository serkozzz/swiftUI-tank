//
//  PropViewModel.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 05.12.2025.
//

import SwiftUI
import TankEngine2D
import Combine



class PropRefViewModel: ObservableObject {
    
    private(set) var propName: String
    
    var codedValue: String { return "nil"
    }
    
    @ObservedObject var owner: TEComponent2D
    
    private var ownerCopyForMirror: TEComponent2D //@ObservedObject is wrapper that don't allow you get TEComponent props directlry
    private var cancellable: AnyCancellable?
    
    init(owner: TEComponent2D, propName: String) {
        self.owner = owner
        self.ownerCopyForMirror = owner
        self.propName = propName

        cancellable = self.owner.objectWillChange.sink(receiveValue: { self.objectWillChange.send() })
    }
    
    
    func propBinding() -> Binding<String> {
        Binding(
            get: { [unowned self] in
                "nil"
            },
            set: { [unowned self] newValue in
                //TODO get component by UUID
                //var component: TEComponent2D
                //SafeKVC.setValue(owner, forKey: propName, of: component)

                
//                let json = newValue.quotedJSON()
//                owner.setSerializableValue(for: propName, from: json)
            }
        )
    }
}
