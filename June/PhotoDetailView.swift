//
//  PhotoDetailView.swift
//  June
//
//  Created by pingwei liu on 2019/7/26.
//  Copyright © 2019 pingwei liu. All rights reserved.
//

import SwiftUI

struct PhotoDetailView: View {
    @ObjectBinding var webImage = WebImage()
    var url: String
            
    var body: some View {
        VStack {
            Image(uiImage: webImage.expectValue).frame(width: 400, height: 400, alignment: .center).scaledToFill().clipped()
                .onAppear {
                    self.webImage.get(with: self.url)
                }
                .onDisappear {
                    self.webImage.cancel()
                }
            Text("name")
        }
    }
}

#if DEBUG
struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailView(url: "https://picsum.photos/id/233/200/200")
    }
}
#endif
