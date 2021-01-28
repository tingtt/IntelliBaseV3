//
//  PDFInfo.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import Foundation
import PDFKit

class PDFInfo: ObservableObject {
    @Published var pageNo: Int = 1
    @Published var pdfView: PDFView = PDFView()
    @Published var stateTopButton: Bool = false
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.pageChanged(_:)), name: Notification.Name.PDFViewPageChanged, object: nil)
    }
    
    @objc func pageChanged(_ notification: Notification) {
        pageNo = pdfView.currentPage!.pageRef!.pageNumber
        stateTopButton = pdfView.canGoToFirstPage
        print(self.pageNo)
        print("page is changed")
    }
}
