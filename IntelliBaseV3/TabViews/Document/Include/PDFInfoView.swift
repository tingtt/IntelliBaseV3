//
//  PDFInfoView.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI
import PDFKit

struct PdfInfoView: View {
    @ObservedObject var pdfInfo: PDFInfo
    @State var enableTopButton: Bool = true
    
    var body: some View {
        HStack{
            Text(String(pdfInfo.pageNo))
            // Group / HStack / VStack / ZStack　でwrapされているとそこで条件式が使える
//            if (!pdfInfo.pdfView.canGoToFirstPage) {
//                Button(action: {
//                    pdfInfo.pdfView.goToFirstPage(self)
//                }, label: {
//                    Text("TOP")
//                })
//                .hidden()
//            } else {
//                Button(action: {
//                    pdfInfo.pdfView.goToFirstPage(self)
//                }, label: {
//                    Text("TOP")
//                })
//            }
            
            // ボタンの状態を変えてクリック無効にする場合はこちら
            Button(action: {
                pdfInfo.pdfView.goToFirstPage(self)
            }, label: {
                Text("TOP")
            })
            .disabled(!pdfInfo.stateTopButton)
        }
    }
}

//struct PdfInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PdfInfoView(pdfInfo: <#PDFInfo#>)
//    }
//}

