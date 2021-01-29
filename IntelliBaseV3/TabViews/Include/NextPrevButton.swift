//
//  NextPrevButton.swift
//  IntelliBaseV3
//
//  Created by 二宮良太 on 2021/01/30.
//

import SwiftUI

struct NextPrevButton: View {
    
    var icon = "person.crop.circle"
    
    var body: some View {
        return HStack {
            Image(systemName: icon)
                .foregroundColor(.primary)
        }
        .frame(width: 77, height: 77)
        .background(Color("button"))
        .cornerRadius(30)
        .shadow(color: Color("buttonShadow"), radius: 20, x: 0, y: 20)
    }
}
