//
//  NoteStruc.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import Foundation

struct NoteStruct {
    var id: Int
    var book_id: Int
    var share: Bool
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
        self.share = shareBool
        self.account_id = account
        
        return
    }
    
    func delete() {
        _ = CoreDataOperation().delete(entity: .note, conditionStr: "id = \(id)")
    }
}
