//
//  UGCConfig.swift
//  UCGCreator
//
//  Created by Justin Hilliard on 2/25/21.
//

import Foundation

struct UGCLifecycleManager {
    
    static var activeWorkItems: [DispatchWorkItem] = []
    
    static var status: AppStatus = .appInForeground
    
//    static func appendSceneCreationComponentToQueue(workerItem: DispatchWorkItem) -> Bool {
//        UGCQueueManager.setAttributesDispatchQueue.sync(execute: workerItem)
//        UGCQueueManager.activeWorkItems.append(workerItem)
//        return true
//    }
//
    static func appDidMoveToBackground(){
        for ugc in UGC.createdUGCs {
            for scene in ugc.scenes{
                if scene.status == .exporting {
                    scene.cancelExport(seconds: 0)
                }
            }
            if ugc.status == .exporting {
                ugc.cancelExport(seconds: 0)
            }
        }
    }
//
    static func appDidMoveToForeground(){
        if(UGC.createdUGCs.count > 0 ) {
            for ugc in UGC.createdUGCs {
                for scene in ugc.scenes{
                    print(scene.status)
                    if scene.status == .canceled {
                        scene.startExport()
                    }
                }
                if ugc.status == .canceled {
                    ugc.startExport()
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
