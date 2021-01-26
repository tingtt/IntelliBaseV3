//
//  ContentView.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI

struct ContentView: View {
    
    @State var navigation: Bool = false
    @State var id: Int = 0
    @State var email: String = ""
    @State var loginSkip: Bool = false
    
    init() {
        // init coreData (debug)
        let coreData = CoreDataOperation()
        for account: Account in coreData.select(entity: .account) {
            print("AccoID: \(String(describing: account.id as! Int))")
        }
        for purchase: Purchase in coreData.select(entity: .purchase) {
            print("PurcID: \(String(describing: purchase.id as! Int)), AccID: \(String(describing: purchase.account_id as! Int))")
        }
        for book: Book in coreData.select(entity: .book) {
            print("BookID: \(String(describing: book.id as! Int))")
        }
//        _ = coreData.delete(entity: .book)
//        _ = coreData.delete(entity: .purchase)
//        _ = coreData.delete(entity: .account)
        _ = coreData.save()
        
        // get genres from api.
        let entity: CoreDataEnumManager.EntityName = .genre
        let savedData:Array<Genre> = coreData.select(entity: entity, sort: ["id":false])
        var alreadyGetId = "0"
        if savedData.count != 0 {
            alreadyGetId = "\((savedData[0]).id as! Int)"
        }
        print("Debug : Saved Genre -> ~\(alreadyGetId)")
        let dataGetter = GetNewData(entity: entity)
        while dataGetter.interface!.isDownloading {}
    }
    
    var body: some View {
        NavigationView {
            NavigationLink(
                destination:
                    LoginView(email: email, id: id, skipLogin: loginSkip)
                    .navigationBarHidden(true),
                isActive:
                    $navigation
            ){
                Text("Login")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: {
            let coreData = CoreDataOperation()
            let entity: CoreDataEnumManager.EntityName = .account
            
            // Used acocunt exist ?
            if coreData.select(entity: entity).count > 0 {
                // Loginned ?
                // Get loginned account.
                let loginnedAccountAry: Array<Account> = coreData.select(entity: entity, conditionStr: "login == true")
                if loginnedAccountAry.count == 1 {
                    // loginned account
                    let loginnedAccount: Account = loginnedAccountAry[0]
                    
                    // account id
                    self.id = loginnedAccount.id as! Int
                    
                    // loginned date
                    let date: Date = loginnedAccount.login_date!
                    
                    // formatted loginned date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMddHHmmss"
                    dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
                    let dateInt: Int = Int(dateFormatter.string(from: date))!
                    
                    // Check password update.
                    let interface = Interface(apiFileName: "get_modify_date", parameter: ["id":"\(id)", "type":"password"], sync: true)
                    while interface.isDownloading {}
                    
                    let modifiedDateInt: Int = Int(interface.content[0]["datetime"] as! String)!
                    
                    if dateInt < modifiedDateInt {
                        // Loginned account's password modified.
                        
                        // Account: login <- false
                        if coreData.update(entity: entity, conditionStr: "id == \(id)", values: ["login":false]) {}
                        
                        // Navigation login view.
                        print("Debug : Loginned account's password modified. id : \(id)")
                        self.navigation = true
                    } else {
                        // Navigation menu with skip login view.
//                        print("Debug : Skip login. id : \(id)")
                        self.loginSkip = true
                        self.navigation = true
                    }
                } else {
                    // Get most recently used account.
                    let account: Account = coreData.select(entity: entity, conditionStr: "", sort: ["login_date":false])[0]
                    self.email = account.email!
                    
                    // No logining accout.
                    print("Debug : Navigation login view with email client has ever loginned.")
                    self.navigation = true
                }
            } else {
                // Client has never loginned.
                print("Debug : First try to login.")
                self.navigation = true
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
