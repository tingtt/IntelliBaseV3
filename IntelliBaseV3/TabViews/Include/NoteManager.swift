//
//  ObservedNotes.swift
//  IntelliBaseV3
//
//  Created by てぃん on 2021/01/27.
//

import SwiftUI

class NoteManager: ObservableObject {
    
    @Published var notes: [NoteStruct] = []
//    @Published var noteIds: [Int] = []
    @Published var mappedIds: [[Any]] = []
    
    init() {
        fetch()
    }
    
    func addNote(note: NoteStruct) {
        // 先頭に追加したい
//        notes.append(note)
        notes.insert(note, at: 0)
    }
    
    func deleteNote(id: Int) {
        for index: Int in 0..<notes.count {
            if notes[index].id == id {
                notes.remove(at: index)
            }
            if mappedIds[index][0] as! Int == id {
                mappedIds.remove(at: index)
            }
        }
        // delete from coreData
        notes[id].delete()
        // delete from published array.
        notes.remove(at: id)
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
        print("Debug : \(mappedIds)")
    }
}
