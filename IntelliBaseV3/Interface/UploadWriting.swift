//
//  UploadWriting.swift
//  IntelliBaseV3
//
//  Created by てぃん on 2021/02/07.
//

import Foundation

class UploadWritings: ObservableObject {
    
    var shareKayGenerating = true
    var uploading = true
    var uploadingPageCount = 0
    var shareKey: String
    
    init(writingsId: Int) {
        
        let shareInterface = Interface(apiFileName: "writings/generate_share_key.php")
        while shareInterface.isDownloading {}
        
        let shareId = shareInterface.content[0]["id"]
        shareKey = shareInterface.content[0]["share_key"] as! String
        
        shareKayGenerating = false
        
        let noteDocs = CoreDataManager.shared.getNoteData(noteId: writingsId)
        for index in 0..<noteDocs.count {
            let uploadURL = URL(string: HomePageUrl(lastDirectoryUrl: "uploadedData/writings", fileName: "writing\(String(describing: shareId))_page\(index + 1)").getFullPath())!
            let uploadInterface = InterfaceUL(url: uploadURL, data: noteDocs[index].data)
            uploadingPageCount = index + 1
            while uploadInterface.taskState != .completed {}
        }
        
        uploading = false
    }
}
