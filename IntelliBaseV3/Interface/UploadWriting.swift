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
    
    var error = false
    
    init(writingsId: Int) {
        
        let writing: Note = CoreDataOperation().select(entity: .note, conditionStr: "id = \(writingsId)")[0]
        
        let shareInterface = Interface(
            apiFileName: "writings/generate_share_key",
            parameter: [
                "account_id":"\(String(describing: (CoreDataOperation().select(entity: .account, conditionStr: "login = true")[0] as Account).id!))",
                "local_writing_id":"\(String(describing: writing.id!))",
                "book_id":"\(String(describing: writing.book_id!))"
            ],
            sync: true
        )
        while shareInterface.isDownloading {}
        
//        print(shareInterface.content[0])
        
        let shareId: Int = Int((shareInterface.content[0]["id"] as! NSString).doubleValue)
        
        shareKey = shareInterface.content[0]["share_key"] as! String
        
        shareKayGenerating = false
        
        let noteDocs = CoreDataManager.shared.getNoteData(noteId: writingsId)
        for index in 0..<noteDocs.count {
//            let uploadInterface = InterfaceUL(shareId: shareId, shareKey: shareKey, data: noteDocs[index].data)
//            uploadInterface.upload()
            
//            let interface = Interface(
//                apiFileName: "writings/writingUploadPost",
//                parameter: [
//                    "share_id":"\(shareId)",
//                    "page_num":"\(index + 1)",
//                    "data":"\(noteDocs[index].data)"],
//                sync: true
//            )
//            while interface.isDownloading {}
            let fileName = "writing\(shareId)_page\(index + 1)"
            let boundary = "----WebKitFormBoundaryZLdHZy8HNaBmUX0d"
            
            var body: Data = "--\(boundary)\r\n".data(using: .utf8)!
            // サーバ側が想定しているinput(type=file)タグのname属性値とファイル名をContent-Dispositionヘッダで設定
            body += "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!
            body += "Content-Type: image/jpeg\r\n".data(using: .utf8)!
            body += "\r\n".data(using: .utf8)!
            body += noteDocs[index].data
            body += "\r\n".data(using: .utf8)!
            body += "--\(boundary)--\r\n".data(using: .utf8)!
            
            let url: URL = URL(string: HomePageUrl(lastDirectoryUrl: "api/writings", fileName: "writing_upload_post.php").getFullPath())!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            // マルチパートでファイルアップロード
            let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
            let urlConfig = URLSessionConfiguration.default
            urlConfig.httpAdditionalHeaders = headers
             
            let session = Foundation.URLSession(configuration: urlConfig)
            let task = session.uploadTask(with: request, from: body)
            task.resume()
            
            uploadingPageCount = index + 1
            print("Debug : Writing data upload start. page: \(index+1)")
            while task.state != .completed {}
            print("Debug : Upload ended.")
        }
        
        uploading = false
    }
}
