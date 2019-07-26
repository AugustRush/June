//
//  PhotosView.swift
//  June
//
//  Created by pingwei liu on 2019/7/23.
//  Copyright © 2019 pingwei liu. All rights reserved.
//

import SwiftUI

struct URLImage : View {
    let url : String
    @ObjectBinding var imageLoader = HTTP<UIImage>()
    
    init(url: String) {
        self.url = url
    }
    
    var body: some View {
        Image(uiImage: self.imageLoader.expectValue).resizable()
            .onAppear {
                self.imageLoader.get(with: self.url)
        }
            .onDisappear {
                self.imageLoader.cancel()
        }
    }
}

struct ThumbnailsView : View {
    
    let title: String
    let urls: [String]
    @ObjectBinding var imageLoader = HTTP<UIImage>()
    
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
                            URLImage(url: item)
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
