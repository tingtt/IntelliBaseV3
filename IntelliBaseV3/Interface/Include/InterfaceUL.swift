//
//  InterfaceUL.swift
//  IntelliBaseV3
//
//  Created by てぃん on 2021/02/07.
//

import Foundation

public class InterfaceUL {
    private var uploadTask: URLSessionUploadTask
    var taskState: URLSessionTask.State = .canceling
    
    init(url: URL, data: Data) {
        uploadTask = URLSession.shared.uploadTask(with: URLRequest(url: url), from: data)
    }
    
    func upload() {
        uploadTask.resume()
        taskState = uploadTask.state
    }
}
