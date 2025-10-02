//
//  DamagableObject.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 01.10.2025.
//

protocol DamagableObject: AnyObject {
    var health: Int { get set }
    func takeDamage()
}
