//
//  DetailedDownloadView.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-02-03.
//

import SwiftUI

struct DetailedDownloadView: View {
    let progress : Progress
    var body: some View {
        VStack{
            HStack(alignment: .center){
                Text("\(progress.id):")
                ScrollView(.horizontal){
                    Text("\(progress.title)")
                }
            }.font(.system(size: 16, weight: .bold))
            HStack{
                VStack{
                    Text("Status:")
                    Text("\(progress.status)")
                }.frame(maxWidth: .infinity)
                VStack{
                    Text("Speed")
                    if let lastTrack = progress.tracks.last{
                        if lastTrack.progress == 1.0{
                            Text("-")
                        }else{
                            Text("\(lastTrack.speed)")
                        }
                    }else{
                        Text("-")
                    }  
                }.frame(maxWidth: .infinity)
                VStack{
                    Text("Remaining")
                    if progress.status.lowercased() == "completed"{
                        Text("-")
                    }else{
                        if let lastTrack = progress.tracks.last{
                            Text(lastTrack.eta)
                        }else{
                            Text("-")
                        }
                    }
                }.frame(maxWidth: .infinity)
            }
            VStack{
                ForEach(progress.tracks) { newTrack in
                    HStack{
                        Text("\(newTrack.id):").frame(width:20, alignment: .leading).padding(0)
                        Text("\(newTrack.size)").frame(width:100, alignment: .center).padding(5)
                        ProgressView(value: newTrack.progress)
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(Color(.white))
    }
}

struct DetailedDownloadView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedDownloadView(progress: Progress())
    }
}
