//
//  UGCConfig.swift
//  UCGCreator
//
//  Created by Justin Hilliard on 2/25/21.
//

import Foundation

struct UGCQueueManager {
    
    static var activeWorkItems: [DispatchWorkItem] = []
    static var createdUGCs: [UGC] = []
    static let setAttributesDispatchQueue = DispatchQueue.init(label: "com.Sharethat.to.setAttributesDispatchQueue",
                                                               qos: .userInteractive,
                                                               attributes: [],
                                                               autoreleaseFrequency: .workItem,
                                                               target: nil)
    
    static var status: AppStatus = .appInForeground
    
    static func appendSceneCreationComponentToQueue(workerItem: DispatchWorkItem) -> Bool {
        UGCQueueManager.setAttributesDispatchQueue.sync(execute: workerItem)
        UGCQueueManager.activeWorkItems.append(workerItem)
        return true
    }
    
    static func appDidMoveToBackground(){
        for ugc in createdUGCs {
            for scene in ugc.scenes{
                if scene.status == .exporting {
                    scene.cancelExport(seconds: 0)
                }
            }
        }
    }
    
    static func appDidMoveToForeground(){
        if(createdUGCs.count > 0 ) {
            for ugc in createdUGCs {
                for scene in ugc.scenes{
                    if scene.status == .canceled {
                        scene.remakeScene()
                        for workerItem in UGCQueueManager.activeWorkItems {
                            scene.sceneDispatchGroup.enter()
                            UGCQueueManager.setAttributesDispatchQueue.sync(execute: workerItem)
                        }
                        scene.startExport()
                    }
                }
            }
        }
    }
    
    enum AppStatus {
        case appInForeground
        case appDidEnterBackground
    }
    
    
//    static func pauseRender(){
//        for ugc in queuedUGCs {
//            for scene in ugc.scenes {
//                switch scene.status {
//                case .exporting:
//                    scene.cancelExport(seconds: 0)
//                    scene.setStatus(status: .canceled)
//                case .
//                default:
//                }
//            }
//        }
//    }
    
//    static func resumeRender(scene: UGCSecne){
//        queuedScenes.append(scene)
//    }
    
}
