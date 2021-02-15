//
//  NoteStruc.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import Foundation
import SwiftUI

struct NoteStruct {
    var id: Int
    var book_id: Int
    var share: Bool = false
    var share_account_id = 0
    var share_key: String = ""
    var share_id: Int = 0
    var public_share: Bool = false
    var title: String
    var account_id: Int
    
    init(id: Int) {
        let entity: CoreDataEnumManager.EntityName = .note
        let coreData = CoreDataOperation()
        
        // init
        var book: Int = 0
        var titleStr: String = ""
        var shareBool: Bool = false
        var account: Int = 0
        var shareAccountId = 0
        var shareKey: String = ""
        var shareId: Int = 0
        
        // fetch
//        let fetchResults: Array<Note> = coreData.select(entityName: "Note", conditionStr: "id == \(id)")
        let fetchResults: Array<Note> = coreData.select(entity: entity, conditionStr: "id == \(id)")


        // have book info?
        if fetchResults.count == 1 {
            // yes
            titleStr = fetchResults[0].title!
            account = fetchResults[0].account_id as! Int
            shareBool = fetchResults[0].share
            book = fetchResults[0].book_id as! Int
            shareKey = fetchResults[0].share_key!
            shareAccountId = fetchResults[0].share_account_id as! Int
            shareId = Int(truncating: fetchResults[0].share_id!)
        } else {
            // no
            
            // init insert vslurs array
            var insertValues: Dictionary<String,String> = [:]
            
            // get info from api
            let interface = Interface(apiFileName: "get_note", parameter: ["id": "\(id)"], sync: true)
            while interface.isDownloading {}
            // download complete to continue ↓
            
            // success ?
            if !interface.error {
                let result = interface.content
                if result.count == 0 {
                    // Error
                    print("Error : Api returned empty data. [ \(interface.apiPath) ]")
                } else {
                    // loop in record
                    for (key, value) in result[0] {
                        insertValues[key] = value as? String
                    }
                }
            }
            // insert book info to core data
            if coreData.insert(entity: entity, values: insertValues) {
                // success
                
                // fetch inserted data
                let fetchResults2: Array<Book> = coreData.select(entity: entity, conditionStr: "id == \(id)", sort: ["id":false])
                titleStr = fetchResults2[0].title!
//                account = fetchResults2[0].account_id as! Int
//                shareBool = fetchResults2[0].share as! Bool
//                book = fetchResults2[0].book_id as! Int
            }
        }
        self.id = id
        self.title = titleStr
        self.book_id = book
        self.account_id = account
        self.share_account_id = shareAccountId
        self.share_id = shareId
        self.share_key = shareKey
        self.share = shareBool
        
        return
    }
    
    init(shareKey: String, sharedWritingInfo: Dictionary<String,Any>) {
        // 未使用のIDを取得して設定
        let notes: Array<Note> = CoreDataOperation().select(entity: .note, conditionStr: "", sort: ["id":false])
        let noteId: Int
        if notes.count == 0 {
            noteId = 1
        } else {
            noteId = notes[0].id as! Int + 1
        }
        id = noteId
        
        book_id = Int((sharedWritingInfo["book_id"] as! NSString).doubleValue)
        share = true
        share_key = shareKey
        share_account_id = Int((sharedWritingInfo["account_id"] as! NSString).doubleValue)
        share_id = Int((sharedWritingInfo["writing_id"] as! NSString).doubleValue)
        public_share = false
        title = sharedWritingInfo["local_writing_title"] as! String
        account_id = (CoreDataOperation().select(entity: .account, conditionStr: "login == true")[0] as! Account).id as! Int
        
        _ = CoreDataOperation().insert(
            entity: .note,
            values: [
                "id":noteId,
                "account_id": account_id,
                "book_id": book_id,
                "title": title,
                "share": true,
                "public_share": false,
                "update_date": Date(),
                "share_account_id": share_account_id,
                "share_id": share_id,
                "share_key":shareKey,
                "upload_date": Date(),
            ]
        )
        
        self.downloadWriting(noteId: noteId)
    }
    
    func downloadWriting(noteId: Int) {
        let writings: Note = CoreDataOperation().select(entity: .note, conditionStr: "id = \(noteId)")[0]
        // シェアIDから書き込みのページ数を取得
        let interface = Interface(apiFileName: "writings/get_page_count", parameter: ["share_id": "\(String(describing: writings.share_id!))"], sync: true)
        while interface.isDownloading {}
        let pageCount: Int = Int((interface.content[0]["page_count"] as! NSString).doubleValue)
        
        for pageNum in 1..<pageCount+1 {
            let url: URL = URL(string: HomePageUrl(lastDirectoryUrl: "uploadedData/writing", fileName: "writing\(String(describing: writings.share_id))_page\(String(describing: pageNum))").getFullPath())!
            let downloadTask = URLSession.shared.downloadTask(with: url) { location, response, error in
                // ダウンロードデータの一時保存URL
    //            print("Debug : Saved as temp to \(location!)")

                if let tempFileUrl = location {
                    do {
                        // Insert into coreData.
                        let data = try Data(contentsOf: tempFileUrl)
                        CoreDataManager.shared.addData(doc: DrawingDocument(id: UUID(), data: data, name: "\(writings.title!)_note\(String(describing: noteId))_page\(pageNum)"))
    //                    print("Debug : Seved to coreData \(writeFilePath.absoluteString)")
                    } catch {
                        print("Error : Caught error at download file.")
                    }
                }
            }
            downloadTask.resume()
            while downloadTask.state != .completed {}
        }
    }
    
    func delete() {
        if share {
            deleteSharedWritings()
        }
        _ = CoreDataOperation().delete(entity: .note, conditionStr: "id = \(id)")
    }
    
    mutating func shareOff() {
        share = false
        deleteSharedWritings()
        _ = CoreDataOperation().update(entity: .note, conditionStr: "id = \(id)", values: ["share_key":"", "share_id":0, "share":false])
    }
    
    private func deleteSharedWritings() {
        _ = Interface(apiFileName: "writings/delete_shared_writings", parameter: ["share_key":share_key], sync: false)
    }
    
    mutating func shareOn() {
        uploadWritings()
    }
    
    mutating func updateSharedData() {
        uploadWritings()
    }
    
    mutating func uploadWritings() {
        if !share {
            // 共有されていなければ共有キーを取得する
            let shareInterface = Interface(
                apiFileName: "writings/generate_share_key",
                parameter: [
                    "account_id":"\(String(describing: (CoreDataOperation().select(entity: .account, conditionStr: "login = true")[0] as Account).id!))",
                    "local_writing_id":"\(id)",
                    "local_writing_title":"\(title)",
                    "book_id":"\(book_id)"
                ],
                sync: true
            )
            while shareInterface.isDownloading {}
            
            print(shareInterface.content[0])
            
            share_id = Int((shareInterface.content[0]["id"] as! NSString).doubleValue)
            share_key = shareInterface.content[0]["share_key"] as! String
            
            _ = CoreDataOperation().update(entity: .note, conditionStr: "id = \(id)", values: ["share_key":shareInterface.content[0]["share_key"] as! String, "share_id":Int((shareInterface.content[0]["id"] as! NSString).doubleValue), "share":true])
            share = true
        }
        
        // upload
        let noteDocs = CoreDataManager.shared.getNoteData(noteId: id)
        for index in 0..<noteDocs.count {
            let fileName = "writing\(share_id)_page\(index + 1)"
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
            
            print("Debug : Writing data upload start. page: \(index+1)")
            while task.state != .completed {}
            print("Debug : Upload ended.")
        }
    }
    
    mutating func regenerateShareKey() {
        let shareInterface = Interface(
            apiFileName: "writings/generate_share_key",
            parameter: [
                "account_id":"\(String(describing: (CoreDataOperation().select(entity: .account, conditionStr: "login = true")[0] as Account).id!))",
                "local_writing_id":"\(id)",
                "local_writing_title":"\(title)",
                "book_id":"\(book_id)"
            ],
            sync: true
        )
        while shareInterface.isDownloading {}
        
        print(shareInterface.content[0])
        
        share_id = Int((shareInterface.content[0]["id"] as! NSString).doubleValue)
        share_key = shareInterface.content[0]["share_key"] as! String
        
        _ = CoreDataOperation().update(entity: .note, conditionStr: "id = \(id)", values: ["share_key":share_key, "share_id":share_id, "share":true])
    }
}
