//
//  PhotosView.swift
//  June
//
//  Created by pingwei liu on 2019/7/23.
//  Copyright © 2019 pingwei liu. All rights reserved.
//

import SwiftUI

struct ThumbnailsView : View {
    
    let title: String
    let urls: [String]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                NavigationLink(destination: PicsumView()) {
                    HStack {
                        Text(title).font(.headline).foregroundColor(.black).padding(4)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.gray).padding(4)
                    }
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                }
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(urls, id: \.self) { item in
                            URLImage(URL(string: item)!).resizable()
                                .frame(width: 120, height: 120, alignment: .center)
                                .background(Color.white)
                        }
                    }.padding(4)
                }
                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            }
        }
    }
}

#if DEBUG
struct ThumbnailsView_Previews : PreviewProvider {
    static var previews: some View {
        ThumbnailsView(title: "Picsum", urls: (210..<230).map{ "https://picsum.photos/id/\($0)/200/200" })
    }
}
#endif
