//
//  LibraryList.swift
//  IntelliBaseV3
//
//  Created by 二宮良太 on 2021/01/25.
//

import SwiftUI

struct LibraryList: View {

   var courses = coursesData2
   @State var showContent = false

   var body: some View {
      ScrollView {
         VStack {
            HStack {
               VStack(alignment: .leading) {
                  Text("本棚")
                     .font(.largeTitle)
                     .fontWeight(.heavy)

                  Text("20冊の本")
                     .foregroundColor(.gray)
               }
               Spacer()
            }
            .padding(.leading, 60.0)
            
            ScrollView(.horizontal, showsIndicators: false) {
               HStack(spacing: 20.0) {
                  ForEach(courses) { item in
                     Button(action: { self.showContent.toggle() }) {
                        GeometryReader { geometry in
                           CourseView2(//title: item.title,
                                      image: item.image,
                                      //color: item.color,
                                      shadowColor: item.shadowColor)
//                              .rotation3DEffect(Angle(degrees:
//                                 Double(geometry.frame(in: .global).minX - 30) / -40), axis: (x: 0, y: 10.0, z: 0))
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

            //CertificateRow()
         }
         .padding(.top, 78)
      }
   }
}


#if DEBUG
struct LibraryList_Previews: PreviewProvider {
   static var previews: some View {
        HomeList()
   }
}
#endif

struct CourseView2: View {

   //var title = "Build an app with SwiftUI"
   var image = "Book1"
   //var color = Color("background3")
   var shadowColor = Color("backgroundShadow3")

   var body: some View {
    return HStack(alignment: .center) {
//         Text(title)
//            .font(.title)
//            .fontWeight(.bold)
//            .foregroundColor(.white)
//            .padding(30)
//            .lineLimit(4)
//
//         Spacer()
         Image(image)
            .resizable()
            .renderingMode(.original)
            //.aspectRatio(contentMode: .fit)
            .frame(width: 240, height: 310, alignment: .center)
            //.cornerRadius(30)
            .padding(.bottom, 30)


      }
      //.background(color)
      //.cornerRadius(30)
//      .frame(width: 250, height: 360)
      .shadow(color: shadowColor, radius: 20, x: 0, y: 20)

   }
}

struct Course2: Identifiable {
   var id = UUID()
   var image: String
   var shadowColor: Color
}

let coursesData2 = [
   Course(//title: "Build an app with SwiftUI",
          image: "Book1",
          //color: Color("background3"),
          shadowColor: Color("backgroundShadow3")),
   Course(//title: "Design and animate your UI",
          image: "Book2",
          //color: Color("background4"),
          shadowColor: Color("backgroundShadow3")),
   Course(//title: "Swift UI Advanced",
          image: "Book3",
          //color: Color("background7"),
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
   Course(//title: "Framer Playground",
          image: "Book4",
          //color: Color("background8"),
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
   Course(//title: "Flutter for Designers",
          image: "Book5",
          //color: Color("background9"),
          shadowColor: Color(hue: 0.677, saturation: 0.701, brightness: 0.788, opacity: 0.5)),
]

