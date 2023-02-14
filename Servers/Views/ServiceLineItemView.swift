//
//  ServiceLineItemView.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-01-30.
//

import SwiftUI

struct ServiceLineItemView: View {
    @State var serviceName : String = "Host"
    var body: some View {
        HStack(alignment: .center){
            Image(systemName: "globe")
            VStack{
                HStack{
                    Text("Name".capitalized)
                        .frame(width:100, alignment: .leading)
                    TextField("serviceName", text: $serviceName).foregroundColor(.gray)
                }
                Divider()
            }
        }
            
    }
}

struct ServiceLineItemView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceLineItemView()
    }
}
