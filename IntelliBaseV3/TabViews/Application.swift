//
//  Home.swift
//  DesignCode
//
//  Created by Mithun x on 7/12/19.
//  Copyright © 2019 Mithun. All rights reserved.
//

import SwiftUI

//let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
//let screen = UIScreen.main.bounds

struct Application: View {
    
    @State var show = false
    @State var showProfile = false
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    var accountId: Int = 0
    
    init(id: Int) {
        let coreData = CoreDataOperation()
        let accounts: Array<Account> = coreData.select(entity: .account, conditionStr: "login = true")
        if accounts.count == 0 {
            // Back to login view.
            self.mode.wrappedValue.dismiss()
        } else {
            self.accountId = accounts[0].id as! Int
        }
        
        print("Debug : Menu loaded. id = \(accountId).")
        
        // get purchased books
        let dataGetter = GetNewData(entity: .book, id: self.accountId)
        while dataGetter.interface!.isDownloading {}
    }
    
    var body: some View {
        TabView{
            HomeTabView()
                .animation(Animation.linear)
                .tabItem {
                    HStack {
                        Image(systemName: "house.fill")
                    }
                }.tag(1)
            LibraryTabView()
                .animation(Animation.linear)
                .tabItem {
                    VStack {
                        Image(systemName: "book.fill")
                    }
                }.tag(2)
        }
    }
}
