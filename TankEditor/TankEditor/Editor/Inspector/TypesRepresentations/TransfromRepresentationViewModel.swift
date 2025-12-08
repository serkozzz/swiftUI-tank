//
//  TransfromRepresentationViewModel.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 07.12.2025.
//

import SwiftUI
import Combine
import TankEngine2D

class TransfromRepresentationViewModel: ObservableObject {
    @Published var node: TESceneNode2D
    
    init(node: TESceneNode2D) {
        self.node = node
    }
    
    lazy var positionBinding = { Binding(
        get: { [unowned self] in
            node.transform.position
        },
        set: { [unowned self] newValue in
            node.transform.setPosition(newValue)
        }
    ) }()
    
    lazy var rotationBinding = { Binding(
        get: { [unowned self] in
            node.transform.rotation
        },
        set: { [unowned self] newValue in
            node.transform.setRotation(clockwiseAngle: newValue)
        }
    )}()
    
    lazy var scaleBinding = { Binding(
        get: { [unowned self] in
            node.transform.scale
        },
        set: { [unowned self] newValue in
            node.transform.setScale(newValue)
        }
    ) }()
                                                  
                                                  

}
