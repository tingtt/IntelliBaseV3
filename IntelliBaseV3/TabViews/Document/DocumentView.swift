//
//  DocumentView.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI
import PDFKit

struct DocumentView: View {
    var document: DocumentStruct
        
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let dataPath: URL
    
    init(document: DocumentStruct) {
        
        self.dataPath = documentDirectory.appendingPathComponent("book_\(document.book.id).pdf")
        self.document = document
        
        return
    }
    
    @ObservedObject var pdfInfo: PDFInfo = PDFInfo()
        
    var body: some View {
        VStack {
            ShowPDFView(pdfInfo: pdfInfo, url: dataPath)
            PdfInfoView(pdfInfo: pdfInfo)
            .padding()
        }.onAppear(){
            pdfInfo.addObserver()
        }
        
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(document: DocumentStruct(id: 1))
    }
}
