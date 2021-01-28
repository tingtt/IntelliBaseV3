//
//  HomeList.swift
//  IntelliBaseV3
//
//  Created by 二宮良太 on 2021/01/25.
//

import SwiftUI

struct HomeList: View {
    let accountId: Int
    @ObservedObject var noteManager:NoteManager = NoteManager.shared
    var recentlyNotes: [[Any]] = []
    var recentlyPurchasedBooks: [[Any]] = []
    var recommandBooks: [[Any]] = []
    //var courses = coursesData
    @State var showContent = false
    
    init() {
        let coreData = CoreDataOperation()
        
        // ログイン中のアカウントを取得
        let accounts: Array<Account> = coreData.select(entity: .account, conditionStr: "login = true")
        accountId = accounts[0].id as! Int
        
        // 最近購入された本を取得
//        print("Debug : Load recently purchased books.")
        for purchase:Purchase in coreData.select(entity: .purchase, conditionStr: "account_id = \(accountId)", sort: ["id":false]) {
            recentlyPurchasedBooks.append([purchase.book_id as! Int])
        }
    }

//   var courses = coursesData
//   @State var showContent = false

   var body: some View {
      ScrollView {
         VStack {
            HStack {
               VStack(alignment: .leading) {
                  Text("ホーム")
                     .font(.largeTitle)
                     .fontWeight(.heavy)
               }
               Spacer()
            }
            .padding(.leading, 60.0)
            
            HStack {
                Text("最近のノート")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Button(action: {
                    print(noteManager.mappedIds)
                }, label: {Text("debug")})
            }
            if noteManager.mappedIds.count > 0 {
                // ノートがあったら
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 18.0) {
                        SectionOfBookShelfView(noteManager: noteManager, ids: noteManager.mappedIds, partition: false)
                    }
                    .padding(.leading, 30)
                    .padding(.top, 30)
                    .padding(.bottom, 40)
                    Spacer()
                }
            } else {
                // ノートがない場合
            }
            
            HStack {
                Text("最近購入した本")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
            if recentlyPurchasedBooks.count > 0 {
                // 購入した本が
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20.0) {
                        SectionOfBookShelfView(noteManager: noteManager, ids: self.recentlyPurchasedBooks, partition: false)
                    }
                    .padding(.leading, 30)
                    .padding(.top, 30)
                    .padding(.bottom, 40)
                    Spacer()
                }
            } else {
                // 本がない場合、
            }
            
            HStack {
                Text("おすすめ")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18.0) {
                    SectionOfBookShelfView(noteManager: noteManager, ids: self.recommandBooks, partition: false)
                }
                .padding(.leading, 30)
                .padding(.top, 30)
                .padding(.bottom, 40)
                Spacer()
            }
            
            CertificateRow()
         }
         .padding(.top, 78)
      }
   }
}

#if DEBUG
struct HomeList_Previews: PreviewProvider {
   static var previews: some View {
        HomeList()
   }
}
#endif


struct Course: Identifiable {
   var id = UUID()
   var image: String
   var shadowColor: Color
}

let coursesData = [
   Course(//title: "Build an app with SwiftUI",
          image: "Book1",
          shadowColor: Color("backgroundShadow3")),
   Course(//title: "Design and animate your UI",
          image: "Book2",
          shadowColor: Color("backgroundShadow3")),
   Course(//title: "Swift UI Advanced",
          image: "Book3",
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
   Course(//title: "Framer Playground",
          image: "Book4",
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
   Course(//title: "Flutter for Designers",
          image: "Book5",
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
]
