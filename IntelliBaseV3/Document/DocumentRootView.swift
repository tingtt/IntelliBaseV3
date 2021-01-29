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
    
    // edit view
    @State var documentEditView: DocumentEditView? = nil
    @ObservedObject var editViewManager = EditViewManager()
    
    init(documentId: Int, isNote: Bool = false) {
        // PDFデータのパスを取得
        let document = DocumentStruct(id: documentId, isNote: isNote)
        self._document = State(initialValue: document)
        self._notes = State(initialValue: document.book.notes)
        self.dataPath = documentDirectory.appendingPathComponent("book_\(document.book.id).pdf")
        
        self.pdfKitView = PDFKitView(url: dataPath)
        
        if isNote {
            // init note edit view.
            editViewManager.loadView(pdfKitView: pdfKitView, noteId: document.note!.id)
        }
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
        ZStack {
            if document.isNote {
                editViewManager.view
                .scaleEffect(self.nowScalingValue)
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            closeNoteAlertShown.toggle()
                        }) {
                            CircleButton(icon: "text.badge.xmark")
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
                    .sheet(isPresented: $addShown, content: {
                        NavigationView(content: {
                            List {
                                ForEach(0..<notes.count) { index in
                                    if index < notes.count {
                                        Button(
                                            action: {
                                                editViewManager.loadView(
                                                    pdfKitView: pdfKitView,
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
            HStack {
                if document.isNote {
                    Button(action: {
                        print("Debug : ")
                        print(editViewManager.view!.canvasManager.canvases[(editViewManager.view!.canvasManager.currentPageIndex[0])])
                    }){
                        Text("Debug")
                    }
                }
            }
        }
        .background(Color("background1"))
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
        
        // init note edit view.
        editViewManager.loadView(
            pdfKitView: pdfKitView,
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

struct DocumentRootView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentRootView(documentId: 1, isNote: false)
    }
}
