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
    @State var pdfKitView: PDFKitView
    
    // edit view
    @ObservedObject var editViewManager = EditViewManager()
    
    // menu
    @State var showingMenu: Bool = false
    // sacling
    @State var nowScalingValue: CGFloat = 1.0
    @State var lastScaleValue: CGFloat = 1.0
    
    // note delete alert
    @State var deleteNoteAlert = false
    @State var deleteIndexSet: IndexSet = IndexSet(integer: 0)
    // new note sheet.
    @State private var documentName: String = ""
    @State var addShown: Bool = false
    @State var sheetNavigated: Bool = false
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State var alertShown = false
    @State var updateStatus: String = ""
    
    init(documentId: Int, isNote: Bool = false, openAsNewNote: Bool = false) {
        // PDFデータのパスを取得
        let document = DocumentStruct(id: documentId, isNote: isNote)
        self._document = State(initialValue: document)
        self._notes = State(initialValue: document.book.notes)
        self.dataPath = documentDirectory.appendingPathComponent("book_\(document.book.id).pdf")
        
        self._pdfKitView = State(initialValue: PDFKitView(url: dataPath))
        
        if isNote {
            // init note edit view.
            editViewManager.loadView(pdfKitView: $pdfKitView, noteId: document.note!.id)
        }
        
        if openAsNewNote {
            addShown = true
            if document.book.notes.count == 0 {
                sheetNavigated = true
            }
        }
    }
    
    @State var position: CGSize = CGSize(width: 400, height: 600)
    @State var lastPosition: CGSize = CGSize(width: 400, height: 600)
        
    var drag: some Gesture {
        DragGesture()
        .onChanged{ value in
            showingMenu = false
            self.position = CGSize(
                width: lastPosition.width
                    + value.translation.width,
                height: lastPosition.height
                    + value.translation.height
            )
        }
        .onEnded{ value in
            self.lastPosition = position
        }
    }
    
    var pinch: some Gesture {
        MagnificationGesture(minimumScaleDelta: 0.1)
            .onChanged { val in
                showingMenu = false
                if lastScaleValue * val > 0.5 {
                    if self.lastScaleValue * val < 3 {
                        self.nowScalingValue = self.lastScaleValue * val
                    } else {
                        self.nowScalingValue = 3
                    }
                }

            //... anything else e.g. clamping the newScale
            }.onEnded{ val in
                self.lastScaleValue = nowScalingValue
            }
    }
    
    var body: some View {
        ZStack {
            if document.isNote {
                editViewManager.view
                    .scaleEffect(self.nowScalingValue)
                    .position(x: position.width, y: position.height)
                    .gesture(SimultaneousGesture(pinch, drag))
                    .navigationBarItems(
                        leading:
                            Button(action: {
                                mode.wrappedValue.dismiss()
                            }){
                                CircleButton(icon: "chevron.backward.square")
                            },
                        trailing:
                            ZStack(alignment: .topLeading) {
                                if notes.count == 0 {
                                    Button(action: {
                                        sheetNavigated.toggle()
                                        addShown.toggle()
                                    }) {
                                        CircleButton(icon: "note.text.badge.plus")
                                    }
                                    
                                } else {
                                    Button(action: {
                                        addShown.toggle()
                                    }) {
                                        CircleButton(icon: "note.text.badge.plus")
                                    }
                                }
                            }
                    )
            } else {
                pdfKitView
                    .scaleEffect(self.nowScalingValue)
                    .position(x: position.width, y: position.height)
                    .gesture(SimultaneousGesture(pinch, drag))
                    .navigationBarItems(
                        leading:
                            Button(action: {
                                mode.wrappedValue.dismiss()
                            }){
                                CircleButton(icon: "chevron.backward.square")
                            },
                        trailing:
                            ZStack(alignment: .topLeading) {
                                if notes.count == 0 {
                                    Button(action: {
                                        sheetNavigated.toggle()
                                        addShown.toggle()
                                    }) {
                                        CircleButton(icon: "note.text.badge.plus")
                                    }
                                    
                                } else {
                                    Button(action: {
                                        addShown.toggle()
                                    }) {
                                        CircleButton(icon: "note.text.badge.plus")
                                    }
                                }
                            }
                    )
            }
            HStack {
                Button(action: {
                    goToPreviousPage()
                }) {
                    NextPrevButton(icon: "arrow.left")
                }
                Spacer()
                Button(action: {
                    goToNextPage()
                }) {
                    NextPrevButton(icon: "arrow.right")
                }
            }
        }
        .sheet(isPresented: $addShown, content: {
            NavigationView(content: {
                List {
                    ForEach(0..<notes.count) { index in
                        if index < notes.count {
                            Button(
                                action: {
                                    editViewManager.loadView(
                                        pdfKitView: $pdfKitView,
                                        noteId: notes[index].id,
                                        pageNum: (pdfKitView.pdfKitRepresentedView.pdfView.currentPage?.pageRef!.pageNumber)!
                                    )
                                    
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
//                                        message: Text("\(allNoteManager.notes[deleteIndexSet.map({$0})[0]].title)"),
                            primaryButton: .cancel(Text("No")),
                            secondaryButton: .default(Text("Yes"),action: {// TODO: show alert
                                let mapedIndexSet: [Int] = deleteIndexSet.map({$0})
                                mapedIndexSet.forEach({ index in
                                    // HomeListの表示を同期
                                    allNoteManager.deleteNote(id: notes[index].id)
                                    notes.remove(at: index)
                                })
                            })
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
        .onAppear(perform: {
            // 共有キーのアップデート、
            if document.isNote && document.note!.share && document.note!.account_id != document.note!.share_account_id {
                // 取得した書き込みデータの場合、共有情報がアップデートされていないか確認する。
                let interface = Interface(
                    apiFileName: "writings/check_key_update_or_delete",
                    parameter: [
                        "account_id":"\(document.note!.share_account_id)",
                        "book_id":"\(document.note!.book_id)",
                        "share_key":"\(document.note!.share_key)",
                        "local_writing_title":"\(document.note!.title)"
                    ],
                    sync: true
                )
                while interface.isDownloading {}
                if interface.error {
                    // ホーム画面へ戻る
                    mode.wrappedValue.dismiss()
                } else {
                    let status: String = interface.content[0]["status"] as! String
                    switch status {
                    case "noChange":break
                        
                    case "keyChanged":
                        updateStatus = "keyChanged"
                        alertShown.toggle()
                        break
                        
                    case "shareRejected":
                        updateStatus = "shareRejected"
                        alertShown.toggle()
                        break
                        
                    default: break
                    }
                }
            }
        })
        .alert(isPresented: $alertShown, content: {
            if updateStatus == "keyChanged" {
                return Alert(
                    title: Text("共有キーが変更されました。"),
                    message: Text("新しいキーを入力して取得し直してください。\n※取得済みの書き込みデータは削除されます。"),
                    dismissButton: .default(
                        Text("OK"),
                        action: {
                            allNoteManager.deleteNote(id: document.id)
                            // ホーム画面へ戻る
                            mode.wrappedValue.dismiss()
                        }
                    )
                )
            } else if updateStatus == "shareRejected" {
                return Alert(
                    title: Text("共有が解除されました。\n※取得済みの書き込みデータは削除されます。"),
                    dismissButton: .default(
                        Text("OK"),
                        action: {
                            allNoteManager.deleteNote(id: document.id)
                            // ホーム画面へ戻る
                            mode.wrappedValue.dismiss()
                        }
                    )
                )
            } else {
                return Alert(
                    title: Text("ノートを閉じますか？"),
                    primaryButton: .cancel(Text("No")),
                    secondaryButton: .default(
                        Text("Yes"),
                        action: {
                            document.note = nil
                            document.isNote = false
                        }
                    )
                )
            }
        })
        .background(Color("background1"))
        .navigationBarHidden(!showingMenu)
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea([.top, .bottom])
//        .statusBar(hidden: true)
        .gesture(TapGesture(count: 1).onEnded({showingMenu.toggle()}))
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
        
        let accountId = (coreData.select(entity: .account, conditionStr: "login = true")[0] as Account).id!
        _ = coreData.insert(
            entity: .note,
            values: [
                "id":noteId,
                "account_id": accountId,
                "book_id": document.book.id,
                "title": noteTitle,
                "share": false,
                "public_share": false,
                "update_date": Date(),
                "share_id": 0,
                "share_key":"",
                "share_account_id":accountId,
                "upload_date":Date(),
            ]
        )
        
        // 書き込み画像
        let pageCount: Int = self.pdfKitView.pdfKitRepresentedView.pdfView.document!.pageCount
        for pageNum in 1..<pageCount+1 {
            // coreDataに追加
            CoreDataManager.shared.addData(doc: DrawingDocument(id: UUID(), data: Data(), name: "\(noteTitle)_note\(String(describing: noteId))_page\(pageNum)"))
            //            print("Debug: drawing document added. Name: \(noteTitle)_note\(String(describing: noteId))_page\(pageNum)")
        }
        
        // Documentのフィールドを変更
        document.note = NoteStruct(id: noteId)
        self.notes.append(document.note!)
        
        // HomeListの表示を同期
        allNoteManager.addNote(note: document.note!)
        
        // canvasを変更
        addShown.toggle()
        sheetNavigated.toggle()
        
        // init note edit view.
        editViewManager.loadView(
            pdfKitView: $pdfKitView,
            noteId: noteId,
            pageNum: (pdfKitView.pdfKitRepresentedView.pdfView.currentPage?.pageRef!.pageNumber)!
        )
        
        document.isNote = true
    }
    
    func goToNextPage() {
        pdfKitView.pdfKitRepresentedView.pdfView.goToNextPage(nil)
        if document.isNote {
            editViewManager.view?.canvasManager.goToNextCanvas()
        }
    }
    
    func goToPreviousPage() {
        pdfKitView.pdfKitRepresentedView.pdfView.goToPreviousPage(nil)
        if document.isNote {
            editViewManager.view?.canvasManager.goToPreviousCanvas()
        }
    }
}
