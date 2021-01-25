//
//  MenuView.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI

struct MenuView: View {
    
    var menu = menuData
    @Binding var show: Bool
    @State var showSettings = false
    
    var body: some View {
        return HStack {
            VStack(alignment: .leading) {
                ForEach(menu) { item in
                    if item.title == "アカウント" {
                        Button(action: { self.showSettings.toggle() }) {
                            MenuRow(image: item.icon, text: item.title)
                                .sheet(isPresented: self.$showSettings) { Settings() }
                        }
                    } else {
                        MenuRow(image: item.icon, text: item.title)
                    }
                }
                Spacer()
            }
            .padding(.top, 20)
            .padding(30)
            .frame(minWidth: 0, maxWidth: 360)
            .background(Color("button"))
            .cornerRadius(30)
            .padding(.trailing, 60)
            .shadow(radius: 20)
            .rotation3DEffect(Angle(degrees: show ? 0 : 60), axis: (x: 0, y: 10.0, z: 0))
            .animation(.default)
            .offset(x: show ? 0 : -UIScreen.main.bounds.width)
            .onTapGesture {
                self.show.toggle()
            }
            Spacer()
        }
        .padding(.top, statusBarHeight)
    }
}
