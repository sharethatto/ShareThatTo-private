//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import UIKit
import Foundation

protocol ShareOutletDelegate {
    func success()
    func failure(error: String)
    func cancelled()
}

protocol ShareOutlet {
    var delegate: ShareOutletDelegate? { get set }
    var imageName: String { get }
    var outlateName: String { get }
    func share(content: Content, viewController: UIViewController);
}
