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
    
    private let projectContext: ProjectContext
    private(set) var propName: String
    
    var valueToShow: String { propValue?.id.uuidString ?? "nil" }
    
    @ObservedObject var owner: TEComponent2D
    private var propValue: TEComponent2D?
    
    private var ownerCopyForMirror: TEComponent2D //@ObservedObject is wrapper that don't allow you get TEComponent props directlry
    private var cancellable: AnyCancellable?
    
    init(projectContext: ProjectContext, owner: TEComponent2D, propName: String) {
        self.owner = owner
        self.ownerCopyForMirror = owner
        self.propName = propName
        self.projectContext = projectContext
        
        let allRef = owner.allTEComponentRefs()
        propValue = allRef[propName]!

        cancellable = self.owner.objectWillChange.sink(receiveValue: { self.objectWillChange.send() })
    }
    
    func handleDrop(nodeID: UUID) {
        guard let droppedNode = projectContext.editorScene.rootNode
            .findFirstInSubtree(where: { $0.id == nodeID }) else { return }
        
        // 1) Берем объявленный тип свойства и снимаем Optional
        guard let declaredAnyType = Mirror.getPropType(ownerCopyForMirror, propName: propName) else {
            return
        }
        let unwrappedAnyType = unwrapOptionalType(declaredAnyType)
        
        // 2) Получаем AnyClass (все компоненты наследуются от NSObject)
        guard let requiredClass = unwrappedAnyType as? AnyClass else {
            return
        }
        
        // 3) Проверяем подтипность через isKind(of:) или isSubclass(of:)
        for candidate in droppedNode.components {
            // Вариант через экземпляр:
            if (candidate as AnyObject).isKind(of: requiredClass) {
                SafeKVC.setValue(owner, forKey: propName, of: candidate)
                return
            }
        }
    }
}
