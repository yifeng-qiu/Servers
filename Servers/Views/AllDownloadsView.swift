//
//  AllDownloadsView.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-02-03.
//

import SwiftUI

struct AllDownloadsView: View {
    @StateObject var allDownloadsModel = AllDownloadsModel()
    @State var showErrorAlert : Bool = false
    var body: some View {
        VStack(alignment:.leading){
            HStack {
                Text("All Downloads").font(.title)
                    .onReceive(allDownloadsModel.$error) { error in
                        if error != nil{
                            showErrorAlert.toggle()
                        }
                    }
                    .alert(allDownloadsModel.error?.localizedDescription ?? "Something went wrong", isPresented: $showErrorAlert) {
                        Button("OK"){
                        }
                    }
                Spacer()
                Button {
                    allDownloadsModel.manualRefresh()
                } label: {
                    Image(systemName: "arrow.clockwise.icloud")
                }
                Text(allDownloadsModel.serverOnline ? "Online" : "Offline").font(.headline)
                    .foregroundColor(allDownloadsModel.serverOnline ? .green : .red)
            }.padding(.horizontal)
            NavigationView {
                ScrollView{
                    VStack{
                        ForEach(allDownloadsModel.Sessions){session in
                            NavigationLink {
                                PlaylistView(progresses: session.progress, playlist_title: session.playlistTitle)
                                    .onAppear {
                                        allDownloadsModel.scheduleFetchRefresh()
                                    }
                                    .onDisappear{
                                        allDownloadsModel.cancelFetchRefresh()
                                    }
                            } label: {
                                DownloadSessionView(session: session)
                                
                            }
                            Divider()
                        }
                    }
                }
                .refreshable {
                    allDownloadsModel.fetchData()
                }
            }
        }
    }
}

struct AllDownloadsView_Previews: PreviewProvider {
    static var previews: some View {
        AllDownloadsView()
    }
}
