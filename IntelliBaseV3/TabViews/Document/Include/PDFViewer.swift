//
//  PDFViewer.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI
import PDFKit

struct PDFViewer: UIViewRepresentable {
    @ObservedObject var pdfInfo: PDFInfo
    
    let url: URL
    
    func makeUIView(context: UIViewRepresentableContext<PDFViewer>) -> PDFViewer.UIViewType {
        // 画面サイズに合わす
        pdfInfo.pdfView.autoScales = true
        // 単一ページのみ表示（これを入れるとページめくりができない）
//        pdfView.displayMode = .singlePage
        //pageViewControllerを利用して表示(displayModeは無視される)
        pdfInfo.pdfView.usePageViewController(true)
        //スクロール方向を水平方向へ
        pdfInfo.pdfView.displayDirection = .horizontal
        //スクロール方向を垂直方向へ
//        pdfInfo.pdfView.displayDirection = .vertical
        //余白を入れる
//        pdfInfo.pdfView.displaysPageBreaks = true
        
        pdfInfo.pdfView.document = PDFDocument(url: url)

        return pdfInfo.pdfView
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PDFViewer>) {
    }
    
}
