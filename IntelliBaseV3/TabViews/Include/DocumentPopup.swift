//
//  DocumentPopup.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI

struct DocumentPopup: View {
    @Binding var document: DocumentStruct
    
    @Binding var showingSheet: Bool
    @State var share: Bool = false
    var url: String = ""
    @State var shareToggle: Bool = false
    var navTitle: String = ""
    
    @Binding var navigateAsNewNote: Bool
    @Binding var navigateWithNoteId: Int?
    
    init(showing: Binding<Bool>,bindedDocument: Binding<DocumentStruct>, bindedNavigateFlag: Binding<Bool>, navigateWithNoteId: Binding<Int?>) {
        self._showingSheet = showing
        self._document = bindedDocument
        self._navigateAsNewNote = bindedNavigateFlag
        self._navigateWithNoteId = navigateWithNoteId
        if (document.isNote){
            self.navTitle = document.note!.title
        } else {
            self.navTitle = document.book.title
        }
        self.url = HomePageUrl(lastDirectoryUrl: "Search", fileName: "product_detail.php", getParams: ["id":String(document.book.id)]).getFullPath()
        self.share = ((document.note?.share) != nil)
    }
    
    @State var deleteNoteAlert = false
    @State var shareOffAlert: Bool = false
    @State var keyRegenerateAlert: Bool = false
    @State var sharedInformationAlert: Bool = false
    @State var openAsNote: Bool = false
    @State var newNoteTiele: String = ""
    
    var body: some View {
        VStack{
//            Divider()
            if(self.document.isNote){
                // ノートの場合
                Text(self.document.note!.title)
                Divider()
                if document.note!.share_account_id == (CoreDataOperation().select(entity: .account, conditionStr: "login == true")[0] as! Account).id as! Int {
                    // own
                    if document.note!.share {
                        // shared
                        Button("共有キーをコピー", action: {
                            // 保存済みの共有キーを取得してクリップボードにコピー
                            let writings: Note = CoreDataOperation().select(entity: .note, conditionStr: "id = \(document.note!.id)")[0]
                            UIPasteboard.general.string = writings.share_key! as String
                        })
                        Divider()
                        Button("共有した書き込みのアップデート", action: {
                            // 共有データのアップデート
                            document.note!.updateSharedData()
                        })
                        Divider()
                        Button(action: {
                            keyRegenerateAlert.toggle()
                        }, label: {
                            Text("共有キーを再生成")
                                .alert(isPresented: $keyRegenerateAlert, content: {
                                    Alert(
                                        title: Text("共有キーを再生成しますか？"),
                                        message: Text("共有キーを再生成すると、すでに共有しているユーザ側で新しいキーを入力するまで見られなくなります。"),
                                        primaryButton: .cancel(Text("No")),
                                        secondaryButton: .default(
                                            Text("Yes"),
                                            action: {
                                                // 共有キーの再取得
                                                document.note!.regenerateShareKey()
                                            }
                                        )
                                    )
                                })
                        })
                        Divider()
                        Button(action: {
                            // 共有の解除
                            shareOffAlert.toggle()
                        }, label: {
                            Text("共有をやめる")
                                .foregroundColor(.red)
                                .alert(isPresented: $shareOffAlert, content: {
                                    Alert(
                                        title: Text("共有をやめますか？"),
                                        message: Text("共有をやめると同じ共有キーでの共有ができなくなり、すでに共有しているユーザが閲覧することができなくなります。"),
                                        primaryButton: .cancel(Text("No")),
                                        secondaryButton: .default(
                                            Text("Yes"),
                                            action: {
                                                // 共有の解除
                                                document.note!.shareOff()
                                            }
                                        )
                                    )
                                })
                        })
                    } else {
                        // not shared
                        Button("共有する", action: {
                            // 共有キーの取得と書き込みのアップロード
                            document.note!.shareOn()
                        })
                    }
                    Divider()
                    Button(action: {
                        deleteNoteAlert.toggle()
                    }, label: {
                        Text("ノートの削除")
                            .foregroundColor(.red)
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
                    })
                } else {
                    // 取得した共有書き込みの場合
                    Button("アップデート", action: {
                        document.note!.downloadWriting()
                    })
                    Divider()
                    Button(action: {
                        deleteNoteAlert.toggle()
                    }, label: {
                        Text("端末から削除")
                            .foregroundColor(.red)
                            .alert(isPresented: $deleteNoteAlert, content: {
                                Alert(
                                    title: Text("取得したデータを削除しますか？"),
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
                    })
                }
            } else {
                // 本の場合
                Button(action: {
                    openAsNote.toggle()
                }, label: {
                    Text("ノートで開く")
                        .sheet(isPresented: $openAsNote, content: {
                            NavigationView(content: {
                                List {
                                    ForEach(0..<document.book.notes.count) { index in
                                        if index < document.book.notes.count {
                                            Button(document.book.notes[index].title){
                                                openAsNote.toggle()
                                                showingSheet.toggle()
                                                print("Debug : Open note with ID -> \(document.book.notes[index].id)")
                                                navigateWithNoteId = document.book.notes[index].id
                                            }
                                        }
                                    }
                                    Button("新規ノート"){
                                        openAsNote.toggle()
                                        showingSheet.toggle()
                                        navigateAsNewNote.toggle()
                                    }
                                }
                            })
                        })
//                    NavigationLink(destination: DocumentRootView(documentId: document.id, isNote: document.isNote, openAsNewNote: true), isActive: $navigateAsNewNote){}
                })
                Divider()
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
