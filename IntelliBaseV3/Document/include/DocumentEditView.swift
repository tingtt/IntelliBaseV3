//
//  DocumentEditView.swift
//  IntelliBaseV3
//
//  Created by てぃん on 2021/01/27.
//

import SwiftUI

struct DocumentEditView: View {
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    @Binding var pdfKitView: PDFKitView
    
    var noteId: Int = 0
    
    @ObservedObject var drawingManager: DrawingManager
    @ObservedObject var canvasManager: CanvasManager
    
    init(pdfKitView: Binding<PDFKitView>, noteId: Int, pageNum: Int = 1) {
        self._pdfKitView = pdfKitView
        
        self.noteId = noteId
        let drawingManager = DrawingManager(noteId: noteId)
//        self._drawingManager = State(initialValue: drawingManager)
        self.drawingManager = drawingManager
        var readOnly = false
        let note:Note = CoreDataOperation().select(entity: .note, conditionStr: "id = \(noteId)")[0]
        if note.account_id != note.share_account_id {
            readOnly = true
//            print("Debug : Read only true.")
        }
        self.canvasManager = CanvasManager(drawingManager: drawingManager, pageNum: pageNum, readOnly: readOnly)
    }
    
    var body: some View {
        ZStack {
            pdfKitView
            ForEach(canvasManager.currentPageIndex, id: \.self){ index in
                if index < canvasManager.canvases.count {
                    canvasManager.canvases[index]
                }
            }
        }
    }
}

//struct DocumentEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        DocumentEditView(pdfKitView: PDFKitView, noteId: 1)
//    }
//}
