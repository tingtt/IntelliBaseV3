//
//  Home.swift
//  DesignCode
//
//  Created by Mithun x on 7/12/19.
//  Copyright © 2019 Mithun. All rights reserved.
//

import SwiftUI

let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
let screen = UIScreen.main.bounds

struct HomeTabView: View {
    
    @State var show = false
    @State var showProfile = false
    
    var body: some View {
        ZStack(alignment: .top) {
            HomeList(accountId: 1)
                .blur(radius: show ? 20 : 0)
                .scaleEffect(showProfile ? 0.95 : 1)
                .animation(.default)
            
            HStack {
                MenuButton(show: $show)
                    .offset(x: -40)
                Spacer()
                
                MenuRight(show: $showProfile)
                    .offset(x: -16)
            }
            
            .offset(y: showProfile ? statusBarHeight : 80)
            .animation(.spring())
            
            MenuView(show: $show)
        }
        .background(Color("background1"))
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
            .previewDevice("iPhone X")
    }
}
#endif

struct Menu: Identifiable {
    var id = UUID()
    var title: String
    var icon: String
}

let menuData = [
    Menu(title: "アカウント", icon: "person.crop.circle"),
    Menu(title: "設定", icon: "gear"),
    Menu(title: "お支払い情報", icon: "creditcard"),
    Menu(title: "サインアウト", icon: "arrow.uturn.down")
]
