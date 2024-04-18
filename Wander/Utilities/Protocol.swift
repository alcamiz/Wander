//
//  Protocols.swift
//  Wander
//
//  Created by Alex Cabrera on 4/11/24.
//

import Foundation

protocol ImageableFirebase {
    var id: String? { get }
    var image: Data? { get set }
}
