//
//  ContentView.swift
//  June
//
//  Created by pingwei liu on 2019/7/23.
//  Copyright © 2019 pingwei liu. All rights reserved.
//

import SwiftUI

struct HomeView : View {
    @State var showingProfile = false
    
     var profileButton: some View {
         Button(action: { self.showingProfile.toggle() }) {
             Image(systemName: "person.crop.circle")
                 .imageScale(.large)
                 .accessibility(label: Text("User Profile"))
                 .padding()
         }
     }
    var body: some View {
        NavigationView {
            ThumbnailsView(title: "Picsum", urls: (200..<220).map{ "https://picsum.photos/id/\($0)/200/200" })
            .navigationBarTitle("Channels")
            .navigationBarItems(trailing: profileButton)
            .sheet(isPresented: $showingProfile) {
                 PhotoDetailView(url: "https://picsum.photos/id/233/500/500")
            }
        }
    }
}

#if DEBUG
struct HomeView_Previews : PreviewProvider {
    static var previews: some View {
        HomeView()
//            .environment(\.colorScheme, .dark)
    }
}
#endif
