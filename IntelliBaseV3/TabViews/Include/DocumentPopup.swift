//
//  DocumentPopup.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI

struct DocumentPopup: View {
    var document: DocumentStruct
    
    @Binding var showingSheet: Bool
    @State var share: Bool = false
    var url: String
    @State var shareToggle: Bool = false
    var navTitle: String
    
    init(showing: Binding<Bool>,document: DocumentStruct) {
        self._showingSheet = showing
        self.document = document
        if (document.isNote){
            self.navTitle = document.note!.title
        } else {
            self.navTitle = document.book.title
        }
        self.url = HomePageUrl(lastDirectoryUrl: "Search", fileName: "product_detail.php", getParams: ["id":String(document.book.id)]).getFullPath()
        self.share = ((document.note?.share) != nil)
    }
    
    @State var deleteNoteAlert = false
    
    var body: some View {
        VStack{
            if(self.document.isNote){
                // ノートの場合
                Divider()
                Text(self.document.note!.title)
                Divider()
//                Toggle(isOn: $shareToggle) {
//                    Text("共有")
//                }
//                Divider()
                Button(action: {
                    deleteNoteAlert.toggle()
                }, label: {
                    Text("ノートの削除")
                    .foregroundColor(.red)
                })
                .alert(isPresented: $deleteNoteAlert, content: {
                    Alert(
                        title: Text("ノートを削除しますか？"),
                        primaryButton: .cancel(Text("No")),
                        secondaryButton: .default(
                            Text("Yes"),
                            action: {
                                NoteManager.shared.deleteNote(id: document.note!.id)
                                showingSheet.toggle()
                            }
                        )
                    )
                })
                Divider()
            } else {
                // 本の場合
//                Button(action:{}){
//                    Text("ノート作成")
//                }
//                Divider()
//                Button(action:{}){
//                    Text("ノート一覧")
//                }
                
            }
            Divider()
            Button(action: {}) {
                Text("本の情報")
            }
        }
        .padding(.all)
        .navigationBarTitle(Text(self.navTitle), displayMode: .inline)
    }
}
