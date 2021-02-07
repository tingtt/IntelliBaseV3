//
//  DocumentPopup.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI

struct DocumentPopup: View {
    @State var document: DocumentStruct
    
    @Binding var showingSheet: Bool
    @State var share: Bool = false
    var url: String
    @State var shareToggle: Bool = false
    var navTitle: String
    
    init(showing: Binding<Bool>,document: DocumentStruct) {
        self._showingSheet = showing
        self._document = State(initialValue: document)
        if (document.isNote){
            self.navTitle = document.note!.title
            self._noteShare = State(initialValue: document.note!.share)
        } else {
            self.navTitle = document.book.title
        }
        self.url = HomePageUrl(lastDirectoryUrl: "Search", fileName: "product_detail.php", getParams: ["id":String(document.book.id)]).getFullPath()
        self.share = ((document.note?.share) != nil)
    }
    
    @State var deleteNoteAlert = false
    @State var noteShare: Bool = false
    @State var shareOffAlert: Bool = false
    @State var sharedInformationAlert: Bool = false
    
    var body: some View {
        VStack{
//            Divider()
            if(self.document.isNote){
                // ノートの場合
                Text(self.document.note!.title)
                Divider()
                if noteShare {
                    HStack{
                        // 共有中
                        Button(action: {
                            // 保存済みの共有キーを取得してクリップボードにコピー
                            let writings: Note = CoreDataOperation().select(entity: .note, conditionStr: "id = \(document.note!.id)")[0]
                            UIPasteboard.general.setValue(writings.share_key! as String, forPasteboardType: "public.text")
                        }, label: {
                            Text("共有キーをコピー")
                        })
                        Button(action: {
                            // 共有の解除
                            
                        }, label: {
                            Text("共有をやめる")
                                .foregroundColor(.red)
                        })
                        .alert(isPresented: $shareOffAlert, content: {
                            Alert(
                                title: Text("共有をやめますか？"),
                                message: Text("共有をやめると同じ共有キーでの共有ができなくなり、すでに共有しているユーザも閲覧することができなくなります。"),
                                primaryButton: .cancel(Text("No")),
                                secondaryButton: .default(
                                    Text("Yes"),
                                    action: {
                                        // 共有の解除
                                        _ = Interface(
                                            apiFileName: "writings/delete_shared_writings",
                                            parameter: [
                                                "share_key":"\(String(describing: (CoreDataOperation().select(entity: .note, conditionStr: "id = \(document.note!.id)")[0] as Note).share_key))"
                                            ],
                                            sync: false
                                        )
                                        document.note!.share = false
                                        noteShare.toggle()
                                        _ = CoreDataOperation().update(entity: .note, conditionStr: "id = \(document.note!.id)", values: ["share_key":"", "share":false])
                                    }
                                )
                            )
                        })
                    }
                } else {
                    HStack{
                        Button(action: {
                            // 共有キーの生成
                            _ = UploadWritings(writingsId: document.note!.id)
                            
                            // 取得したキーをCoreDataに保存
                            
                        }, label: {
                            Text("共有する")
                        })
                    }
                }
                Divider()
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
