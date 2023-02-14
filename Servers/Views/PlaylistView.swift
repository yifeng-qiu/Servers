//
//  PlaylistView.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-02-03.
//

import SwiftUI

struct PlaylistView: View {
    let progresses : [Progress]
    let playlist_title : String
    var body: some View {
        VStack{
            Text(playlist_title).font(.title)
            Divider()
            ScrollView(.vertical,showsIndicators: true){
                ForEach(progresses){progress in
                    DetailedDownloadView(progress: progress)
                    Divider()
                }
            }
            Spacer()
        }
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(progresses: [Progress()], playlist_title: "Playlist")
    }
}
