//
//  EditViewManager.swift
//  IntelliBaseV3
//
//  Created by てぃん on 2021/01/29.
//

import SwiftUI

class EditViewManager: ObservableObject {
    @Published var view: DocumentEditView?
    
    init() {}
    
    func loadView(pdfKitView: Binding<PDFKitView>, noteId: Int, pageNum: Int = 1) {
        view = DocumentEditView(pdfKitView: pdfKitView, noteId: noteId, pageNum: pageNum)
    }
}
