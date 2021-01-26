//
//  DocumentThumbnailView.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI
import UIKit

struct DocumentThumbnailView: View {
    var id: Int
    @State var navSelection: Int? = nil
    @State var showingPopover: Bool = false
    @State var showingSheet: Bool = false
    var document: DocumentStruct
    
    var thumbnailDataPath: URL
    var uiImage: UIImage? = nil
    
    @State private var popoverWidth = CGFloat(500)
    
    init(id: Int, isNote: Bool = false) {
        self.id = id
        self.document = DocumentStruct(id: id, isNote: isNote)
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.thumbnailDataPath = documentDirectory.appendingPathComponent("thumbnail_\(document.book.id).png")
        
        do {
            let thumbnailData = try Data(contentsOf: thumbnailDataPath)
            self.uiImage = UIImage(data: thumbnailData)
        } catch let error {
            print(error)
        }
    }
    
    var body: some View {
//        NavigationLink(destination: <#T##_#>, isActive: <#T##Binding<Bool>#>, label: <#T##() -> _#>)
        NavigationLink(destination: DocumentView(document: self.document), tag: 0, selection: $navSelection) {
            Group {
                // Thumbnail
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210, height: 297, alignment: .center)
                } else {
                    Text("\(document.book.id)")
                        .frame(width: 210, height: 297, alignment: .center)
//                        Image("thumbnailPlaceholder")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 210, height: 297, alignment: .center)
                }
            }
            .onTapGesture(count: 2) {
                let interfaceDl = InterfaceDL(id: document.book.id, documentType: "book")
                while interfaceDl.download.task!.state != .completed {}
                self.navSelection = 0
            }
            .onLongPressGesture {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    // iPhone
                    self.showingSheet.toggle()
                }
                else if UIDevice.current.userInterfaceIdiom == .pad {
                    // iPad
//                    self.showingPopover.toggle()
                    // temp for debug
                    self.showingSheet.toggle()
                }
            }
            .onTapGesture(count: 1) {
                let interfaceDl = InterfaceDL(id: document.book.id, documentType: "book")
//                while interfaceDl.download.task!.state != .completed {}
                while interfaceDl.download.isDownloading {}
                self.navSelection = 0
            }
            // 長押しの判定とタップの判定を同時に行う
            // Reference
            // https://stackoverflow.com/a/60138475
        }
        .popover(isPresented: $showingPopover) {
            NavigationView {
                DocumentPopup(document: self.document)
            }
        }
        .sheet(isPresented: $showingSheet) {
            NavigationView {
                DocumentPopup(document: self.document)
            }
        }
        .onAppear(perform: {
            print("Debug : thumbnail view loaded. id : \(self.document.id)")
        })
    }
}

struct DocumentThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentThumbnailView(id: 1)
    }
}
