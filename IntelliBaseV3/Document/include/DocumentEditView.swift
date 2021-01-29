//
//  DocumentEditView.swift
//  IntelliBaseV3
//
//  Created by てぃん on 2021/01/27.
//

import SwiftUI

struct DocumentEditView: View {
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var pdfKitView: PDFKitView
    
    var noteId: Int = 0
    
    @State var drawingManager: DrawingManager
    @State var canvas: DrawingWrapper
    
    init(pdfKitView: PDFKitView, noteId: Int, pageNum: Int? = 1) {
        self.pdfKitView = pdfKitView
        
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

//struct DocumentEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        DocumentEditView(pdfKitView: PDFKitView, noteId: 1)
//    }
//}
