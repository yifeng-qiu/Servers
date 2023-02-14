//
//  NewServiceView.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-01-30.
//

import SwiftUI

struct NewServiceView: View {
    @Binding var serviceName: String
    @Binding var serviceURI: String
    @Binding var serviceDescription: String
    @Binding var requireVPN : Bool
    @Binding var testOutput : String

    var body: some View {
        VStack(alignment: .leading){
            
            Form{
                Section {
                    TextField("Service Name", text: $serviceName)
                    TextField("Service URL", text: $serviceURI)
                    Toggle(isOn: $requireVPN){
                        Text("VPN Required?")
                    }
                    Text("Description")
                    TextEditor(text: $serviceDescription)
                } header: {
                    Text("CONNECTION").font(.headline)
                }
            }
            .autocorrectionDisabled()
            
            VStack(alignment:.leading){
                Text("Output")
                Divider()
                Text(testOutput).multilineTextAlignment(.leading)
            }.padding()
            Spacer()
        }
        
    }
}

struct NewServiceView_Previews: PreviewProvider {
    static var previews: some View {
        NewServiceView(serviceName: .constant(""), serviceURI: .constant(""), serviceDescription: .constant(""), requireVPN: .constant(false), testOutput: .constant(""))
    }
}
