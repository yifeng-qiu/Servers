//
//  ContentView.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-01-28.
//

import SwiftUI
import CoreData

enum HomeViewScenes{
    case Home
    case Download
    case Setting
}

struct FooterView: View{
    @Binding var homeViewScene : HomeViewScenes
    var body: some View{
            HStack(alignment:.center) {
                Button {
                    homeViewScene = .Home
                } label: {
                    Image(systemName: "house").frame(maxWidth: .infinity)
                }
                Button {
                    homeViewScene = .Download
                } label: {
                    Image(systemName: "tray.and.arrow.down").frame(maxWidth: .infinity)
                }
                Button {
                    homeViewScene = .Setting
                } label: {
                    Image(systemName: "gear").frame(maxWidth: .infinity)
                }
            }
            .font(.title)
        .foregroundColor(.black)
    
    }
}

struct HomeView: View {
    @State var homeViewScene = HomeViewScenes.Home
    
    var body: some View {
        VStack{
            NavigationView{
                switch homeViewScene {
                case .Home:
                    Text("This is Home")
                case .Download:
                    AllDownloadsView()
                case .Setting:
                    ShareExtensionServiceConfiguration()
                }
                
            }
            .navigationViewStyle(.stack)
            FooterView(homeViewScene: $homeViewScene)
        }
        
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
