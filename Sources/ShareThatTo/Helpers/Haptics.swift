//
//  Haptics.swift
//  
//
//  Created by Justin Hilliard on 3/2/21.
//

import UIKit

public enum HapticType : Int {
    case selection
    case light
    case medium
    case heavy
    case success
    case warning
    case error
}

class Haptics: NSObject
{
    public static let shared = Haptics()
    
    private let feedbackGeneratorLight = UIImpactFeedbackGenerator(style: .light)
    private let feedbackGeneratorMedium = UIImpactFeedbackGenerator(style: .medium)
    private let feedbackGeneratorHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let feedbackGeneratorSelection = UISelectionFeedbackGenerator()
    private let feedbackGeneratorNotification = UINotificationFeedbackGenerator()
    
    public func play(_ feedback: HapticType) {
        feedbackGeneratorSelection.prepare()
    
        switch feedback {
        case .selection:
            feedbackGeneratorSelection.selectionChanged()
        case .light:
            feedbackGeneratorLight.impactOccurred()
        case .medium:
            feedbackGeneratorMedium.impactOccurred()
        case .heavy:
            feedbackGeneratorHeavy.impactOccurred()
        case .success:
            feedbackGeneratorNotification.notificationOccurred(.success)
        case .warning:
            feedbackGeneratorNotification.notificationOccurred(.warning)
        case .error:
            feedbackGeneratorNotification.notificationOccurred(.error)
        }
    }
}

