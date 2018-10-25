//
//  PreviewManager.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 10/10/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import Foundation
import SwiftLinkPreview

class PreviewManager {
    let slp: SwiftLinkPreview
    
    init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 07.0
        sessionConfig.timeoutIntervalForResource = 07.0
        let session = URLSession(configuration: sessionConfig)
        slp = SwiftLinkPreview(session: session,
                               workQueue: SwiftLinkPreview.defaultWorkQueue,
                               responseQueue: DispatchQueue.main,
                               cache: DisabledCache.instance)
    }
    
    func getPreview(of url: String, completion: @escaping((title: String, portal: String)?, Error?) -> Void) {
        slp.preview(url, onSuccess: { result in
            if let title = result[SwiftLinkResponseKey.title] as? String,
                let portal = result[SwiftLinkResponseKey.canonicalUrl] as? String {
                completion((title, portal), nil)
            } else {
                completion(nil, nil)
            }
        }) { error in
            completion(nil, error)
        }
    }
}
