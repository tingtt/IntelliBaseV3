//
//  HomeList.swift
//  IntelliBaseV3
//
//  Created by 二宮良太 on 2021/01/25.
//

import SwiftUI

struct HomeList: View {
    
    var recentlyNotes: Array<Array<Any>> = []
    var recentlyPurchasedBooks: Array<Array<Any>> = []
    var recommandBooks: Array<Array<Any>> = []
    var courses = coursesData
    @State var showContent = false
    
    init(accountId: Int) {
        let coreData = CoreDataOperation()
        
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
                Text("最近読んだ本")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20.0) {
                    SectionOfBookShelfView(ids: self.recentlyPurchasedBooks, partition: false)
                }
                .padding(.leading, 30)
                .padding(.top, 30)
                .padding(.bottom, 40)
                Spacer()
            }
        
            
            HStack {
                Text("最近購入した本")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
            ScrollView(.horizontal, showsIndicators: false) {
               HStack(spacing: 20.0) {
                  ForEach(courses) { item in
                     Button(action: { self.showContent.toggle() }) {
                        GeometryReader { geometry in
                           CourseView(//title: item.title,
                                      image: item.image,
                                      shadowColor: item.shadowColor)
                              .rotation3DEffect(Angle(degrees:
                                 Double(geometry.frame(in: .global).minX - 30) / -40), axis: (x: 0, y: 10.0, z: 0))
                              .sheet(isPresented: self.$showContent) { ContentView() }
                        }
                        .frame(width: 246, height: 360)
                     }
                  }
               }
               .padding(.leading, 30)
               .padding(.top, 30)
               .padding(.bottom, 40)
               Spacer()
            }
            
            HStack {
                Text("おすすめ")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
               HStack(spacing: 20.0) {
                  ForEach(courses) { item in
                     Button(action: { self.showContent.toggle() }) {
                        GeometryReader { geometry in
                           CourseView(//title: item.title,
                                      image: item.image,
                                      shadowColor: item.shadowColor)
                              .rotation3DEffect(Angle(degrees:
                                 Double(geometry.frame(in: .global).minX - 30) / -40), axis: (x: 0, y: 10.0, z: 0))
                              .sheet(isPresented: self.$showContent) { ContentView() }
                        }
                        .frame(width: 246, height: 360)
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
      }
   }
}

#if DEBUG
struct HomeList_Previews: PreviewProvider {
   static var previews: some View {
    HomeList(accountId: 1)
   }
}
#endif

struct CourseView: View {

   var image = "Book1"
   var shadowColor = Color("backgroundShadow3")

   var body: some View {
      return VStack(alignment: .leading) {
         Image(image)
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .frame(width: 440, height: 340)
            .padding(.bottom, 30)
      }
      .frame(width: 250, height: 360)
      .shadow(color: shadowColor, radius: 20, x: 0, y: 20)

   }
}

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
