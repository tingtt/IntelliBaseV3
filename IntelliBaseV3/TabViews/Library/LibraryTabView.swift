//
//  LibraryTabView.swift
//  DesignCode
//
//  Created by 二宮良太 on 2020/12/07.
//  Copyright © 2020 Mithun. All rights reserved.
//

import SwiftUI

struct LibraryTabView: View {
    @State var show = false
    @State var showProfile = false
    
    var body: some View {
        ZStack(alignment: .top) {
            LibraryList()
                .blur(radius: show ? 20 : 0)
                .scaleEffect(showProfile ? 0.95 : 1)
                .animation(.default)
                
            ContentView()
                .frame(minWidth: 0, maxWidth: 712)
                .cornerRadius(30)
                .shadow(radius: 20)
                .animation(.spring())
                .offset(y: showProfile ? statusBarHeight + 40 : UIScreen.main.bounds.height)
            
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

struct TextCardView: View {
    //var card: TwentyFourGame<String>.Card
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 9).stroke()
                //Text(card.content)
                    //.font(Font.system(size: min(geo.size.width, geo.size.height) * 0.7))
            }
        }
    }
}

#if DEBUG
struct LibraryTabView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryTabView()
    }
}
#endif


