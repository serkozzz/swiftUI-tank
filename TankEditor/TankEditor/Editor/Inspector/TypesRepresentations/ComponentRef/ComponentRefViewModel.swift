//
//  PropViewModel.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 05.12.2025.
//

import SwiftUI
import TankEngine2D
import Combine
import UniformTypeIdentifiers





@MainActor
class ComponentRefViewModel: ObservableObject {
    
    private let projectContext: ProjectContext
    private(set) var propName: String
    @Published private(set) var isUnderAcceptableDrag = false
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
    
    func canAcceptDrop(node: TESceneNode2D) -> Bool {
        getFirstSuitableComponent(node) != nil
    }
    
    func handleDrop(node: TESceneNode2D) {
        guard let component = getFirstSuitableComponent(node) else { return }
        SafeKVC.setValue(owner, forKey: propName, of: component)
        return
    }
    
    private func getFirstSuitableComponent(_ droppedNode: TESceneNode2D) -> TEComponent2D? {
        
        guard let declaredAnyType = Mirror.getPropType(ownerCopyForMirror, propName: propName)
        else { return nil }
        
        let unwrappedAnyType = unwrapOptionalType(declaredAnyType)
        
        // Получаем AnyClass (все компоненты наследуются от NSObject)
        guard let requiredClass = unwrappedAnyType as? AnyClass else { return nil }
        
        // Проверяем подтипность через isKind(of:)
        for candidate in droppedNode.components {
            if (candidate as AnyObject).isKind(of: requiredClass) {
                return candidate
            }
        }
        return nil
    }
}

@MainActor
extension ComponentRefViewModel: DropDelegate {
    
    func validateDrop(info: DropInfo) -> Bool {
        guard let node = SceneNodeDragManager.shared.draggingNode  else { return false }
        let canAccept = canAcceptDrop(node: node)
        return canAccept
    }
    
    func dropEntered(info: DropInfo) {
        isUnderAcceptableDrag = true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        // Можно вернуть .copy/.move/.forbidden в зависимости от вашей логики;
        // мы оставили .copy чтобы появлялся "+" рядом с курсором.
        return DropProposal(operation: .copy)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let node = SceneNodeDragManager.shared.draggingNode else { return false }
        handleDrop(node: node)
        isUnderAcceptableDrag = false
        SceneNodeDragManager.shared.finishDrag()
        return true
    }
    
    func dropExited(info: DropInfo) {
        isUnderAcceptableDrag = false
    }
}
