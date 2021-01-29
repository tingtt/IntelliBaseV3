//
//  DocumentRootView.swift
//  IntelliBaseV3
//
//  Created by てぃん on 2021/01/26.
//

import SwiftUI

struct DocumentRootView: View {
    
    @State var document: DocumentStruct
    @State var notes: [NoteStruct]
    
    // use in HomeList()
    var allNoteManager: NoteManager = NoteManager.shared
    
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let dataPath: URL
    
    // pdf viewer
    var pdfKitView: PDFKitView
    
    init(documentId: Int, isNote: Bool = false) {
        // PDFデータのパスを取得
        let document = DocumentStruct(id: documentId, isNote: isNote)
        self._document = State(initialValue: document)
        self._notes = State(initialValue: document.book.notes)
        self.dataPath = documentDirectory.appendingPathComponent("book_\(document.book.id).pdf")
        
        self.pdfKitView = PDFKitView(url: dataPath)
    }
    
    // menu
    @State var showingMenu: Bool = false
    // sacling
    @State var nowScalingValue: CGFloat = 1.0
    @State var lastScaleValue: CGFloat = 1.0
    
    // note delete alert
    @State var deleteNoteAlert = false
    @State var deleteIndexSet: IndexSet = IndexSet(integer: 0)
    // note editor alert
    @State var closeNoteAlertShown: Bool = false
    // new note sheet.
    @State private var documentName: String = ""
    @State var addShown: Bool = false
    @State var sheetNavigated: Bool = false
    
    var body: some View {
        Group {
            if document.isNote {
                DocumentEditView(
                    pdfKitView: pdfKitView,
                    noteId: document.note!.id,
                    pageNum: pdfKitView.pdfKitRepresentedView.pdfView.currentPage?.pageRef!.pageNumber
                )
                .scaleEffect(self.nowScalingValue)
                .navigationBarItems(
                    trailing:
                        Button("Close note") {
                            closeNoteAlertShown.toggle()
                        }
                )
                .alert(isPresented: $closeNoteAlertShown, content: {
                    Alert(
                        title: Text("ノートを閉じますか？"),
                        message: Text("※一度閉じるとundoできなくなります。"),
                        primaryButton: .cancel(Text("No")),
                        secondaryButton: .default(
                            Text("Yes"),
                            action: {
                                document.note = nil
                                document.isNote = false
                            }
                        )
                    )
                })
            } else {
                pdfKitView
                    .scaleEffect(self.nowScalingValue)
                    .navigationBarItems(
                        trailing:
                            HStack {
                                if notes.count == 0 {
                                    Button("New note") {
                                        sheetNavigated.toggle()
                                        addShown.toggle()
                                    }
                                } else {
                                    Button("Open note") {
                                        addShown.toggle()
                                    }
                                }
                            }
                    )
                    .sheet(isPresented: $addShown, content: {
                        NavigationView(content: {
                            List {
                                ForEach(0..<notes.count) { index in
                                    if index < notes.count {
                                        Button(
                                            action: {
                                                document.note = NoteStruct(id: notes[index].id)
                                                document.isNote = true
                                            },
                                            label: {
                                                Text(notes[index].title)
                                            }
                                        )
                                    }
                                }
                                .onDelete(perform: { indexSet in
                                    deleteIndexSet = indexSet
                                    deleteNoteAlert.toggle()
                                })
                                .alert(isPresented: $deleteNoteAlert) {
                                    Alert(
                                        title: Text("ノートを削除しますか？"),
                                        message: Text("\(allNoteManager.notes[deleteIndexSet.first!].title)"),
                                        primaryButton: .cancel(Text("No")),
                                        secondaryButton: .default(Text("Yes"),
                                            action: {// TODO: show alert
                                                let mapedIndexSet: [Int] = deleteIndexSet.map({$0})
                                                mapedIndexSet.forEach({ index in
                                                    // HomeListの表示を同期
                                                    allNoteManager.deleteNote(id: notes[index].id)
                                                    notes.remove(at: index)
                                                })
                                            }
                                        )
                                    )
                                }
                                NavigationLink(
                                    destination:
                                        VStack {
                                            Text("Enter note title:")
                                            
                                            TextField("Enter note title here...", text: $documentName, onCommit: {
                                                save(noteTitle: documentName)
                                            })
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            
                                            Button("Create") {
                                                save(noteTitle: documentName)
                                            }
                                        }.padding(),
                                    isActive: $sheetNavigated,
                                    label: {
                                        Text("新規ノート")
                                    }
                                )
                            }
                        })
                    })
            }
        }
        .navigationBarHidden(!showingMenu)
        .edgesIgnoringSafeArea([.top, .bottom])
        .statusBar(hidden: !showingMenu)
        .navigationBarBackButtonHidden(!showingMenu)
        .onTapGesture(perform: {
            self.showingMenu.toggle()
        })
        // zoom in/out
        .gesture(MagnificationGesture(minimumScaleDelta: 0.1)
            .onChanged { val in
                self.nowScalingValue = self.lastScaleValue * val

            //... anything else e.g. clamping the newScale
            }.onEnded{ val in
                self.lastScaleValue *= val
            }
        )
    }
    
    private func save(noteTitle: String) {
        // Noteの登録
        // 使用済みのノートIDの最大値＋1
        let coreData = CoreDataOperation()
        let notes: Array<Note> = coreData.select(entity: .note, conditionStr: "", sort: ["id":false])
        let noteId: Int
        if notes.count == 0 {
            noteId = 1
        } else {
            noteId = notes[0].id as! Int + 1
        }
        
        _ = coreData.insert(
            entity: .note,
            values: [
                "id":noteId,
                "account_id": (coreData.select(entity: .account, conditionStr: "login = true")[0] as Account).id!,
                "book_id": document.book.id,
                "title": noteTitle,
                "share": false,
                "public_share": false,
                "update_date": Date()
            ]
        )
        
        // 書き込み画像
        let pageCount: Int = self.pdfKitView.pdfKitRepresentedView.pdfView.document!.pageCount
        for pageNum in 1..<pageCount+1 {
            // coreDataに追加
            CoreDataManager.shared.addData(doc: DrawingDocument(id: UUID(), data: Data(), name: "\(noteTitle)_note\(String(describing: noteId))_page\(pageNum)"))
            print("Debug: drawing document added. Name: \(noteTitle)_note\(String(describing: noteId))_page\(pageNum)")
        }
        
        // Documentのフィールドを変更
        document.note = NoteStruct(id: noteId)
        self.notes.append(document.note!)
        
        // HomeListの表示を同期
        allNoteManager.addNote(note: document.note!)
        
        // canvasを変更
        addShown.toggle()
        sheetNavigated.toggle()
        
        document.isNote = true
    }
}

struct DocumentRootView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentRootView(documentId: 1, isNote: false)
    }
}
