//
//  ServiceListView.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-01-30.
//

import SwiftUI

struct ServiceView: View {
    let service : Services
//    @StateObject var httpManager : HTTPManager
    @Environment(\.managedObjectContext) private var viewContext
    @State var showDeleteServiceConfirmation : Bool = false
    
    init(service: Services) {
        self.service = service
//        self._httpManager = StateObject(wrappedValue: HTTPManager(service.serviceURI))
    }
    
    var body: some View {
        Button {
            
        } label: {
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: "circle.fill")
//                        .foregroundColor(self.httpManager.serverOnline ? .green : .red)
                    Text(service.serviceName!).font(.headline)
                    Spacer()
                    Button {
                        showDeleteServiceConfirmation = true
                    } label: {
                        Image(systemName: "xmark.circle")
                        
                    }
                    .confirmationDialog(
                        "Confirmation",
                        isPresented: $showDeleteServiceConfirmation
                    ) {
                        Button("Remove this service", role: .destructive) {
                            service.removeService(from: viewContext)
                        }
                        Button("Cancel", role: .cancel) {
                            showDeleteServiceConfirmation = false
                        }
                    } message: {
                        Text("You cannot undo this action!")
                    }
                    
                }
                Text(service.serviceURI!.absoluteString)
                Text(service.serviceDescription!)
                //                Text("\(service.objectID)")
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width - 32, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color("ServiceListViewBG"))
                    .shadow(color: .black, radius: 5, x:3, y: 3)
            )
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }
    

}

//struct ServiceView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceView(service: Services())
//    }
//}
