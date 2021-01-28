//
//  ShowPDFView.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI
import PDFKit

struct ShowPDFView: View {
    @ObservedObject var pdfInfo: PDFInfo
    let url:URL
    
    var body: some View {
        PDFViewer(pdfInfo: pdfInfo, url: url)
    }
}

//struct ShowPDFView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShowPDFView(pdfInfo: PDFInfo())
//    }
//}
