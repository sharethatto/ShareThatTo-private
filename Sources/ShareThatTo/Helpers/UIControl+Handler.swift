//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/27/21.
//
import UIKit
import Foundation

extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping()->())
    {
        @objc class ClosureSleeve: NSObject {
            let closure:()->()
            init(_ closure: @escaping()->()) { self.closure = closure }
            @objc func invoke() { closure() }
        }
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, "\(UUID())", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
