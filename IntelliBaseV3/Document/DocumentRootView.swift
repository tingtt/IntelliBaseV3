//
//  DocumentRootView.swift
//  IntelliBaseV3
//
//  Created by てぃん on 2021/01/26.
//

import SwiftUI

struct DocumentRootView: View {
    
    @State var document: DocumentStruct
        
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let dataPath: URL
    
    // pdf viewer
    var pdfKitView: PDFKitView
    // note editor
//    var editor: DocumentEditView
    
    init(documentId: Int, isNote: Bool = false) {
        // PDFデータのパスを取得
        let document = DocumentStruct(id: documentId, isNote: isNote)
        self._document = State(initialValue: document)
        self.dataPath = documentDirectory.appendingPathComponent("book_\(document.book.id).pdf")
        
        self.pdfKitView = PDFKitView(url: dataPath)
    }
    
    // menu
    @State var showingMenu: Bool = false
    // sacling
    @State var nowScalingValue: CGFloat = 1.0
    @State var lastScaleValue: CGFloat = 1.0
    
    // note editor alert
    @State var closeNoteAlertShown: Bool = false
    // new note sheet.
    @State private var documentName: String = ""
    @State var addShown: Bool = false
    
    var body: some View {
        Group {
            if document.isNote {
                DocumentEditView(
                    bookId: document.book.id,
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
                        message: Text("※一度閉じるとundo/redoできなくなります。"),
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
                                Button("Open note") {
                                    
                                }
                                Button("New note") {
                                    addShown.toggle()
                                }
                            }
                    )
                    .sheet(isPresented: $addShown, content: {
                        VStack {
                            Text("Enter note title:")
                            
                            TextField("Enter note title here...", text: $documentName, onCommit: {
                                save(fileName: documentName)
                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Create") {
                                save(fileName: documentName)
                            }
                        }.padding()
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
//        .gesture(MagnificationGesture(minimumScaleDelta: 0.1)
//            .onChanged { val in
//                self.nowScalingValue = self.lastScaleValue * val
//
//            //... anything else e.g. clamping the newScale
//            }.onEnded{ val in
//                self.lastScaleValue *= val
//            }
//        )
    }
    
    private func save(fileName: String) {
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
                "title": fileName,
                "share": false,
                "public_share": false,
                "update_date": Date()
            ]
        )
        
        // 書き込み画像
        let pageCount: Int = self.pdfKitView.pdfKitRepresentedView.pdfView.document!.pageCount
        for pageNum in 1..<pageCount+1 {
            // coreDataに追加
            CoreDataManager.shared.addData(doc: DrawingDocument(id: UUID(), data: Data(), name: "\(fileName)_note\(String(describing: noteId))_page\(pageNum)"))
            print("Debug: drawing document added. Name: \(fileName)_note\(String(describing: noteId))_page\(pageNum)")
        }
        
        // Documentのフィールドを変更
        document.note = NoteStruct(id: noteId)
        document.isNote = true
        
        // canvasを変更
        addShown.toggle()
    }
}

struct DocumentRootView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentRootView(documentId: 1, isNote: false)
    }
}
