//
//  SectionOfBookShelfView.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI

struct SectionOfBookShelfView: View {
    var ids: Array<Array<Any>>
    var partition: Bool
    
    init(
        ids: Array<Array<Any>> = [[1,false],[1],[1,false],[1,false]],
        partition: Bool = false
    ) {
        self.ids = ids
        self.partition = partition
        
        return
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<self.ids.count) {i in
                    if ids[i].count == 2 {
                        DocumentThumbnailView(id: ids[i][0] as! Int, isNote: ids[i][1] as! Bool)
                    } else {
                        DocumentThumbnailView(id: ids[i][0] as! Int)
                    }
                    //Divider()
                }
            }
        }
    }
}

struct SectionOfBookShelfView_Previews: PreviewProvider {
    static var previews: some View {
        SectionOfBookShelfView()
    }
}
