//
//  DocumentRootView.swift
//  IntelliBaseV3
//
//  Created by てぃん on 2021/01/26.
//

import SwiftUI

struct DocumentRootView: View {
    
    var document: DocumentStruct
        
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let dataPath: URL
    
    // show pdf
    var pdfKitView: PDFKitView
    
    init(documentId: Int = 1, isNote: Bool = false) {
        // PDFデータのパスを取得
        self.document = DocumentStruct(id: documentId, isNote: isNote)
        self.dataPath = documentDirectory.appendingPathComponent("book_\(document.book.id).pdf")
        
        self.pdfKitView = PDFKitView(url: dataPath)
    }
    
    // menu
    @State var showingMenu: Bool = false
    // sacling
    @State var nowScalingValue: CGFloat = 1.0
    @State var lastScaleValue: CGFloat = 1.0
    
    var body: some View {
        Group {
            
        }
        .navigationBarHidden(!showingMenu)
        .navigationBarItems(
            trailing:
                Group {
                }
        )
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
}

struct DocumentRootView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentRootView()
    }
}
