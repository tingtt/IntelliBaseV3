//
//  DocumentPopup.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI

struct DocumentPopup: View {
    var document: DocumentStruct
    @State var share: Bool = false
    var url: String
    @State var shareToggle: Bool = false
    var navTitle: String
    
    init(document: DocumentStruct) {
        self.document = document
        if (document.isNote){
            self.navTitle = document.note!.title
        } else {
            self.navTitle = document.book.title
        }
        self.url = HomePageUrl(lastDirectoryUrl: "Search", fileName: "product_detail.php", getParams: ["id":String(document.book.id)]).getFullPath()
        self.share = ((document.note?.share) != nil)

    }
    
    var body: some View {
        VStack{
            if(self.document.isNote){
                // ノートの場合
                Text(self.document.note!.title)
                Divider()
                Toggle(isOn: $shareToggle) {
                    Text("共有")
                }
                Divider()
                Button(action: {}){
                    Text("ノートの削除")
                        .foregroundColor(Color.red)
                }
                Divider()
                Button(action: {}) {
                    Text("別のノートを見る")
                }
            } else {
                // 本の場合
                Button(action:{}){
                    Text("ノート作成")
                }
                Divider()
                Button(action:{}){
                    Text("ノート一覧")
                }
                
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

struct DocumentPopup_Previews: PreviewProvider {
    static var previews: some View {
        DocumentPopup(document: DocumentStruct(id: 0, isNote: true))
    }
}
