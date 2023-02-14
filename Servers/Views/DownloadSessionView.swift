//
//  DownloadSessionView.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-02-03.
//

import SwiftUI

struct DownloadSessionView: View {
    let session : DownloadSession
    @State var showDeleteConfirmation : Bool = false
    @State var showPauseConfirmation : Bool = false
    
    let alertTitle = "Confirmation"
    private let client = HTTPClient()
    @StateObject private var viewModel : DownloadSessionModel
    
    init(session: DownloadSession){
        self.session = session
        self._viewModel = StateObject(wrappedValue: DownloadSessionModel(URL(string: session.urlraw)))
    }
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing:5){
                HStack(){
                    if viewModel.siteIcon != nil{
                        Image(uiImage: viewModel.siteIcon!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height:40)
                    }else{
                        Image("LogoYoutube")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height:40)
                    }
                    Spacer()
                    
                    Text("\(session.status.capitalized)").bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                    HStack(spacing: 5){
                        
                        // Only show these two buttons if the download has not been completed
                        if session.status.lowercased() != "completed" && session.status.lowercased() != "error"{
                            Button {
                                showPauseConfirmation = true
                            } label: {
                                if session.status.lowercased() == "downloading"{
                                    Image(systemName: "pause.circle")
                                }else{
                                    Image(systemName: "play.circle")
                                }
                            }
                            .confirmationDialog(
                                alertTitle,
                                isPresented: $showPauseConfirmation
                            ) {
                                Button(session.status.lowercased() == "downloading" ? "Pause this download" : "Resume this download", role: .destructive) {
                                    client.pauseResumeDownload(session.id)
                                }
                                Button("Go back", role: .cancel) {
                                    showDeleteConfirmation = false
                                }
                            } message: {
                                Text(session.status.lowercased() == "downloading" ? "You can resume this download later" : "You can pause this download later")
                            }
                        }
                        
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "xmark.circle").foregroundColor(.red)
                        }
                        .confirmationDialog(
                            alertTitle,
                            isPresented: $showDeleteConfirmation
                        ) {
                            Button(session.status.lowercased() == "completed" ? "Remove this download" : "Cancel this download", role: .destructive) {
                                client.cancelDownload(session.id)
                            }
                            Button("Go back", role: .cancel) {
                                showDeleteConfirmation = false
                            }
                        } message: {
                            Text("You cannot undo this action.")
                        }
                        
                    }
                    .font(.title)
                    .frame(maxWidth: 60, alignment: .trailing)
                }
                HStack(alignment:.top){
                    VStack{
                        if session.isPlaylist{
                            HStack{
                                Text("Playlist:").bold()
                                ScrollView(.horizontal){
                                    Text("\(session.playlistTitle)")
                                }
                            }
                        }
                        ScrollView(.horizontal){
                            Text("(\(session.playlistIndex)/\(session.playlistCount))\(session.progress.last?.title ?? "Title missing")")
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(Color(.white))
        
    }
}

struct DownloadSessionView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadSessionView(session: DownloadSession())
    }
}
