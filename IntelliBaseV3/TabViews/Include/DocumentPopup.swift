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
//            Divider()
            if(self.document.isNote){
                // ノートの場合
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
            } else {
                // 本の場合
//                Button(action: {
//
//                }, label: {
//                    Text("ノートで開く")
//                })
//                Divider()
                Button(action: {
                    // 本のストアページを開く
                    if let url = URL(string: HomePageUrl(lastDirectoryUrl: "Search", fileName: "product_detail.php", getParams: ["book_id":"\(document.book.id)"]).getFullPath()) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("ストアページ : \(document.book.title)")
                }
                Divider()
                Button(action: {
                    // 著者のページを開く
                    if let url = URL(string: HomePageUrl(lastDirectoryUrl: "Search", fileName: "search.php", getParams: ["keyword":"\(document.book.auther.name)"]).getFullPath()) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("著者 : \(document.book.auther.name)")
                }
            }
//            Divider()
        }
        .padding(.all)
        .navigationBarTitle(Text(self.navTitle), displayMode: .inline)
    }
}
