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
    
    var courses = coursesData
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
            
            
            if noteManager.mappedIds.count > 0 {
                HStack {
                    Text("最近のノート")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Button(action: {
                        print(noteManager.mappedIds)
                    }, label: {Text("debug")})
                }
                // ノートがあったら
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6.0) {
                        SectionOfBookShelfView(ids: noteManager.mappedIds, partition: false)
                    }
                    .padding(.leading, 30)
                    .padding(.top, 30)
                    .padding(.bottom, 40)
                    Spacer()
                }
            } else {
                // ノートがない場合
                HStack {
                    Text("最近のノート")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Button(action: {
                        print(noteManager.mappedIds)
                    }, label: {Text("debug")})
                }
                VStack{
                    Text("ノートがありません")
                }
            }
            
            HStack {
                Text("最近購入した本")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
            if recentlyPurchasedBooks.count > 0 {
                // 購入した本が
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6.0) {
                        SectionOfBookShelfView(ids: self.recentlyPurchasedBooks, partition: false)
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
        
            //おすすめ
            ScrollView(.horizontal, showsIndicators: false) {
               HStack(spacing: 6.0) {
                  ForEach(courses) { item in
                     Button(action: { self.showContent.toggle() }) {
                        GeometryReader { geometry in
                           CourseView(image: item.image)
                              .rotation3DEffect(Angle(degrees:
                                 Double(geometry.frame(in: .global).minX - 30) / -40), axis: (x: 0, y: 10.0, z: 0))
                              .sheet(isPresented: self.$showContent) { ContentView() }
                        }
                        .frame(width: 250, height: 360)
                     }
                  }
               }
               .padding(.leading, 30)
               .padding(.top, 30)
               .padding(.bottom, 40)
               Spacer()
            }
            
            CertificateRow()
         }
         .padding(.top, 78)
         .padding(.bottom, 50)
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

struct CourseView: View {
    
    var image = "Book1"
    var item = Course(url: "https://www.isehangroup.jp/kissmeproject/kaosaiyo2020/",
                           image: "Recommend1")
    
    var body: some View {
        return VStack(alignment: .leading) {
            Button(action: {
                if let url = URL(string: item.url) {
                    UIApplication.shared.open(url)
                }
            }) {
                Image(image)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 246, height: 335, alignment: .leading)
                    .padding(.bottom, 30)
            }
        }
        .frame(width: 250, height: 360)
        .shadow(color: Color("backgroundShadow3"), radius: 20, x: 0, y: 20)
        
    }
}

struct Course: Identifiable {
    var id = UUID()
    var url: String
    var image: String
}

let coursesData = [
   Course(url: "https://www.isehangroup.jp/kissmeproject/kaosaiyo2020/",
          image: "Recommend1"),
   Course(url: "https://www.isehangroup.jp/kissmeproject/kaosaiyo2020/",
          image: "Recommend2"),
   Course(url: "https://www.isehangroup.jp/kissmeproject/kaosaiyo2020/",
          image: "Recommend3"),
   Course(url: "https://www.isehangroup.jp/kissmeproject/kaosaiyo2020/",
          image: "Recommend4"),
   Course(url: "https://www.isehangroup.jp/kissmeproject/kaosaiyo2020/",
          image: "Recommend5")
]
