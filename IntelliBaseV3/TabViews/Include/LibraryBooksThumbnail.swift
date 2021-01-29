//
//  LibraryBooksThumbnail.swift
//  IntelliBaseV3
//
//  Created by 二宮良太 on 2021/01/28.
//

import SwiftUI
import UIKit

struct LibraryBooksThumbnail: View {
    var noteManager: NoteManager = NoteManager.shared
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
        NavigationLink(destination: DocumentRootView(documentId: self.document.id, isNote: self.document.isNote), tag: 0, selection: $navSelection) {
            Group {
                // Thumbnail
                if let image = uiImage {
                    VStack(alignment: .leading) {
                        GeometryReader { geometry in
                            Image(uiImage: image)
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 240, height: 330)
                                .padding(.bottom, 30)
                        }
                        .frame(width: 246, height: 360)
                    }
                    .frame(width: 250, height: 360)
                    .shadow(color: Color("backgroundShadow3"), radius: 20, x: 0, y: 20)
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
                let _ = InterfaceDL(id: document.book.id, documentType: "book")
                self.navSelection = 0
            }
            // 長押しの判定とタップの判定を同時に行う
            // Reference
            // https://stackoverflow.com/a/60138475
        }
        .popover(isPresented: $showingPopover) {
            NavigationView {
                DocumentPopup(showing: $showingSheet,document: self.document)
            }
        }
        .sheet(isPresented: $showingSheet) {
            NavigationView {
                DocumentPopup(showing: $showingSheet,document: self.document)
            }
        }
        .onAppear(perform: {
            print("Debug : thumbnail view loaded. id : \(self.document.id)")
        })
    }
}

struct LibraryBooksThumbnail_Previews: PreviewProvider {
    static var previews: some View {
        LibraryBooksThumbnail(id: 1)
    }
}
