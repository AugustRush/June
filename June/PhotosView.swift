//
//  PhotosView.swift
//  June
//
//  Created by pingwei liu on 2019/7/23.
//  Copyright © 2019 pingwei liu. All rights reserved.
//

import SwiftUI

struct PhotosView : View {
    
    let title: String
    let urls: [String]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                NavigationLink(destination: PicsumView()) {
                    HStack {
                        Text(title).font(.headline).foregroundColor(.black).padding(4)
                        Spacer()
                        Image(systemName: "chevron.right").renderingMode(.none).padding(4)
                    }
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                }
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(urls, id: \.self) { item in
                            NetworkImage(item)
                                .frame(width: 120, height: 120, alignment: .center)
                                .background(Color.white)
                        }
                    }.padding(4)
                }
            }
        }
    }
}
