//
//  KeyPressHandler.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 26.08.2025.
//
import SwiftUI

struct KeyPressHandler: UIViewControllerRepresentable {
    var onKeyPress: (ArrowKey) -> Void
    
    func makeUIViewController(context: Context) -> KeyboardController {
        let controller = KeyboardController()
        controller.onKeyPress = onKeyPress
        return controller
    }
    
    func updateUIViewController(_ uiViewController: KeyboardController, context: Context) {}
}



class KeyboardController: UIViewController {
    var onKeyPress: ((ArrowKey) -> Void)?
    
    override var keyCommands: [UIKeyCommand]? {
        [
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(up)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(down)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(left)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(right))
        ]
    }
    
    @objc func up() { onKeyPress?(.up) }
    @objc func down() { onKeyPress?(.down) }
    @objc func left() { onKeyPress?(.left) }
    @objc func right() { onKeyPress?(.right) }
    
    override var canBecomeFirstResponder: Bool { true }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder() // важно!
    }
}

enum ArrowKey {
    case up, down, left, right
}
