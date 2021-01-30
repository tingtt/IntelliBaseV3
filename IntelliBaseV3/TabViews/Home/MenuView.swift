//
//  MenuView.swift
//  IntelliBaseV2
//
//  Created by てぃん on 2020/12/15.
//

import SwiftUI

struct MenuView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var menu = menuData
    @Binding var show: Bool
    @State var showSettings = false
    @State var showLogoutAlert = false
    
    var body: some View {
        ZStack{
            //
//            Image("")
//                .opacity(0)
//                .frame(minWidth: 1668, maxWidth: 2388)
//                .onTapGesture {
//                    show.toggle()
//                }
            //
            HStack {
                VStack(alignment: .leading) {
                    ForEach(menu) { item in
                        switch item.title {
                        case "アカウント":
                            Button(action: { self.showSettings.toggle() }) {
                                MenuRow(image: item.icon, text: item.title)
                                    .sheet(isPresented: self.$showSettings) {
                                        Settings()
                                    }
                            }
                        case "サインアウト":
                            Button(action: {
                                showLogoutAlert.toggle()
                            }, label: {
                                MenuRow(image: item.icon, text: item.title)
                            })
                            .alert(isPresented: $showLogoutAlert, content: {
                                Alert(
                                    title: Text("本当にログアウトしますか？"),
                                    primaryButton: .cancel(Text("No")),
                                    secondaryButton: .default(
                                        Text("Yes"),
                                        action: {
                                            // Logout
                                            _ = CoreDataOperation().update(entity: .account, conditionStr: "login = true", values: ["login":false])
                                            // Back to login view.
                                            mode.wrappedValue.dismiss()
                                        }
                                    )
                                )
                            })
                        default :
                            Button(action: {
                                
                            }, label: {
                                MenuRow(image: item.icon, text: item.title)
                            })
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
}

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
