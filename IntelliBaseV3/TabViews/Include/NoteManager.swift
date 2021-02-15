//
//  ObservedNotes.swift
//  IntelliBaseV3
//
//  Created by てぃん on 2021/01/27.
//

import SwiftUI

class NoteManager: ObservableObject {
    static let shared = NoteManager()
    
    @Published var notes: [NoteStruct]
//    @Published var noteIds: [Int] = []
    @Published var mappedIds: [[Any]]
    
    init() {
        notes = []
        mappedIds = []
//        fetch()
        for note:Note in CoreDataOperation().select(entity: .note, conditionStr: "account_id == \((CoreDataOperation().select(entity: .account, conditionStr: "login == true")[0] as! Account).id as! Int)", sort: ["update_date":false]) {
            notes.append(NoteStruct(id: note.id as! Int))
            mappedIds.append([note.id as! Int, true])
        }
    }
    
    func addNote(note: NoteStruct) {
        // 先頭に追加したい
        notes.insert(note, at: 0)
        mappedIds.insert([note.id, true], at: 0)
    }
    
    // シェアキーから書き込みの共有情報を取得して追加
    func addSharedNote(shareKey: String) -> Bool {
        let interface = Interface(apiFileName: "get_writings", parameter: ["share_key":shareKey], sync: true)
        while interface.isDownloading {}
        
        if interface.error {
            return false
        }
        // ログインしているアカウントが本を所持していない場合にfalseを返す
        if CoreDataOperation().select(entity: .book, conditionStr: "id = \(String(describing: interface.content[0]["book_id"] as! Int)) AND account_id = \((CoreDataOperation().select(entity: .account, conditionStr: "login == true")[0] as! Account).id as! Int)").count != 1 {
            print("Debug : Book ID that the user does not have has been entered.")
            return false
        }
        
        addNote(note: NoteStruct(shareKey: shareKey, sharedWritingInfo: interface.content[0]))
        
        return true
    }
    
    func moveToFirst(noteId: Int) {
        var movedOne: Bool = false
        for index in 0..<notes.count {
            if notes[index].id == noteId {
                if index == 0 {
                    break
                }
                notes.move(fromOffsets: IndexSet([index]), toOffset: 0)
                if movedOne {
                    break
                } else {
                    movedOne = true
                }
            }
            if mappedIds[index][0] as! Int == noteId {
                if index == 0 {
                    break
                }
                mappedIds.move(fromOffsets: IndexSet([index]), toOffset: 0)
                if movedOne {
                    break
                } else {
                    movedOne = true
                }
            }
        }
        
    }
    
    func deleteNote(id: Int) {
        let oldCount = notes.count
        for index: Int in 0..<notes.count {
            if (notes[index]).id == id {
                // delete from coreData
                notes[index].delete()
                // delete from published array
                notes.remove(at: index)
                if mappedIds.count != oldCount {
                    break
                }
            }
            if mappedIds[index][0] as! Int == id {
                // delete from published array
                mappedIds.remove(at: index)
                if notes.count != oldCount {
                    break
                }
            }
        }
    }
    
    func fetch() {
        notes = []
//        noteIds = []
        mappedIds = []
        // ログイン中のアカウントの最近開いた本を取得
        for note:Note in CoreDataOperation().select(entity: .note, conditionStr: "account_id == \((CoreDataOperation().select(entity: .account, conditionStr: "login == true")[0] as! Account).id as! Int)", sort: ["update_date":false]) {
            notes.append(NoteStruct(id: note.id as! Int))
//            noteIds.append(note.id as! Int)
            mappedIds.append([note.id as! Int, true])
        }
        
        
        // Debug print
        for note in notes {
            print([
                "id":note.id,
                "title":note.title
            ])
        }
        print("Debug : \(mappedIds)")
    }
}
