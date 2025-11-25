//
//  MulticastDelegate.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 25.11.2025.
//

import SwiftUI

class MulticastDelegate<T> {
    private var delegates: [WeakWrapper] = []

    func addDelegate(_ delegate: T) {
        delegates.append(WeakWrapper(value: delegate as AnyObject))
    }

    func removeDelegate(_ delegate: T) {
        delegates.removeAll { $0.value === delegate as AnyObject }
    }

    func invoke(_ closure: (T) -> Void) {
        for delegate in delegates {
            if let d = delegate.value as? T {
                closure(d)
            }
        }
        // очищаем умершие weak-ссылки
        delegates.removeAll { $0.value == nil }
    }

    private class WeakWrapper {
        weak var value: AnyObject?
        init(value: AnyObject?) { self.value = value }
    }
}
