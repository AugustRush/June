//
//  PhotosChannelView.swift
//  Apple
//
//  Created by pingwei liu on 2019/6/17.
//  Copyright © 2019 pingwei liu. All rights reserved.
//

import SwiftUI
import Combine

struct Photo : Codable, Identifiable {
    let id : String
    let author : String
    let width : CGFloat
    let height : CGFloat
    let url : String
    let download_url : String
}

class PicsumViewModel: BindableObject {
    
    let willChange = PassthroughSubject<PicsumViewModel,Never>()
    var photos = [Photo]()
    var pageIndex = 0
    var limit = 5
    
    func fetchMorePhotos() {
        self.pageIndex += 1
        let qurl = URL(string: "https://picsum.photos/v2/list?page=\(pageIndex)&limit=\(limit)")
        guard let url = qurl else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                let photos = try JSONDecoder().decode([Photo].self, from: data!)
                if(photos.count > 0) {
                    self.photos.append(contentsOf: photos)
                    DispatchQueue.main.async {
                        self.willChange.send(self)
                    }
                }
            } catch let err {
                print(err)
            }
        }.resume()
    }
}

struct PicsumView : View {
    
    @ObjectBinding var viewModel = PicsumViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            List {
                Section {
                        ForEach(self.viewModel.photos) { photo in
                            URLImage(URL(string: "https://picsum.photos/id/\(photo.id)/\(Int(geometry.size.width * 3))/\(Int((photo.height / photo.width) * geometry.size.width * 3))")!)
                                .resizable()
                                .frame(width: geometry.size.width, height: (photo.height / photo.width) * geometry.size.width, alignment: .trailing)
                                .overlay(HStack {
                                    Text("\(photo.author)").font(.caption).foregroundColor(.white).padding(4)
                                }, alignment: .bottomLeading).background(Color.gray)
                    }
                }.listRowInsets(EdgeInsets())
            
                Section {
                    Text("refreshing")
                }
                .onAppear {
                    self.viewModel.fetchMorePhotos()
                }
            }
        }
        .navigationBarTitle(Text("Photos"))
    }
}

#if DEBUG
struct PhotosChannelView_Previews : PreviewProvider {
    static var previews: some View {
        PicsumView()
    }
}
#endif
