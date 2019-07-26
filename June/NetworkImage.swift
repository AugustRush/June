//
//  NetworkImage.swift
//  Apple
//
//  Created by pingwei liu on 2019/6/17.
//  Copyright © 2019 pingwei liu. All rights reserved.
//

import SwiftUI
import Combine
import Cache

private final class ImageLoader {
    
    enum LoadError: Error {
        case requestLoadError
    }
    
    weak var subscriber : AnyCancellable?
    lazy var cache: Storage<UIImage> = {
        let diskConfig = DiskConfig(name: "Floppy", expiry: .seconds(60 * 60 * 24 * 3))
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        return try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forImage())
    }()
    
    func download(url: String, completion: @escaping (Result<UIImage>) -> (Void)) {
        cache.async.object(forKey: url) { (result) in
            switch result {
            case .value(let img):
                    completion(.value(img))
            case .error(_):
                guard let Url = URL(string: url)  else {
                    return
                }
                var request = URLRequest(url: Url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
                request.httpMethod = "GET"
                let publisher = URLSession.shared.dataTaskPublisher(for: request)
                self.subscriber = publisher.sink(receiveCompletion: { (error) in
                                    completion(.error(LoadError.requestLoadError))
                                
                }) { (data, response) in
                    if let image = UIImage(data: data) {
                        completion(.value(image))
                        try! self.cache.setObject(image, forKey: url)
                    } else {
                        completion(.error(LoadError.requestLoadError))
                    }
                }
            }
        }
    }
    
    func cancel()  {
        subscriber?.cancel()
        subscriber = nil
    }
}

struct NetworkImage : View {
    
    private var loader = ImageLoader()
    var url: String
    @State var image = UIImage()
    
    
    init(_ url: String) {
        self.url = url
    }
    
    var body: some View {
        Image(uiImage: image).resizable(resizingMode:.stretch).aspectRatio(contentMode: .fill)
            .onAppear {
                self.loader.download(url: self.url) { (result) -> (Void) in
                    var image = UIImage()
                    switch result {
                    case .value(let img):
                        image = img
                    case .error(let error):
                        print(error)
                    }
                    
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
            .onDisappear {
                self.loader.cancel()
            }
    }
}
