//
//  DocumentEditView.swift
//  IntelliBaseV3
//
//  Created by てぃん on 2021/01/27.
//

import SwiftUI

struct DocumentEditView: View {
    let bookId: Int
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var pdfKitView: PDFKitView
    
    var noteId: Int = 0
    
    @State var drawingManager: DrawingManager
    @State var canvas: DrawingWrapper
    
    init(bookId: Int, noteId: Int, pageNum: Int? = 1) {
        self.bookId = bookId
        let dataPath = documentDirectory.appendingPathComponent("book_\(bookId).pdf")
        self.pdfKitView = PDFKitView(url: dataPath)
        
        self.noteId = noteId
        let drawingManager = DrawingManager(noteId: noteId)
        self._drawingManager = State(initialValue: drawingManager)
        self._canvas = State(initialValue: DrawingWrapper(manager: drawingManager, id: drawingManager.docs[pageNum!-1].id))
    }
    
    var body: some View {
        ZStack {
            pdfKitView
            canvas
        }
    }
}

struct DocumentEditView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentEditView(bookId: 1, noteId: 1)
    }
}
