//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/13/21.
//

import UIKit
import Foundation

public protocol Presentable
{
    func present(on viewController: UIViewController, view: UIView) -> Swift.Error?
}
