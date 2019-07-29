//
//  HTTP.swift
//  June
//
//  Created by pingwei liu on 2019/7/26.
//  Copyright © 2019 pingwei liu. All rights reserved.
//

import SwiftUI
import Combine
import Cache

class HTTP<T>: BindableObject {
    
    var expectValue: T {
        didSet {
            self.willChange.send()
        }
    }
    
    
    typealias Transformer = (Data) -> T?
    internal let willChange = PassthroughSubject<Void,Never>()
    private var transformer: Transformer
    private var cancelable: Cancellable?
    
    required init(default value: T, transformer: @escaping Transformer) {
        self.expectValue = value
        self.transformer = transformer
    }
    
    func get(with path: String, session: URLSession = URLSession.shared, queue: DispatchQueue = .main) {
        let url = URL(string: path)
        guard let real = url else { return }
        var request = URLRequest(url: real)
        request.httpMethod = "GET"
        get(with: request)
    }
    
    func get(with request: URLRequest, session: URLSession = URLSession.shared, queue: DispatchQueue = .main) {
        let publisher = URLSession.shared.dataTaskPublisher(for: request).map {  self.transformer($0.data) }.drop(while: { $0 == nil }).receive(on: queue)
        cancelable = publisher.sink(receiveCompletion: { (error) in
            print(error)
        }) {
            self.expectValue = $0!
        }
    }
    
    func cancel() {
        cancelable?.cancel()
    }
    
    internal func finished(with path: String, value: T) {
        //do nothing
    }
}

class WebImage: HTTP<UIImage> {
    
     lazy var storage: Storage<UIImage> = {
           let diskConfig = DiskConfig(name: "Floppy", expiry: .seconds(60 * 60 * 24 * 3))
           let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
           return try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forImage())
    }()
    
    
    convenience init(default image: UIImage = UIImage()) {
        self.init(default: image, transformer: { UIImage(data: $0) })
    }
    
    override func get(with path: String, session: URLSession = URLSession.shared, queue: DispatchQueue = .main) {
        storage.async.object(forKey: path) { (result) in
            switch result {
            case .value(let image):
                queue.async {
                  self.expectValue = image
                }
            case .error(_):
                super.get(with: path, session: session, queue: queue)
            }
        }
    }
    
    override func finished(with path: String, value: UIImage) {
        try? storage.setObject(value, forKey: path)
    }
}

//extension HTTP where T : Decodable {
//    convenience init(default value: T) {
//        self.init(default: value, transformer: {
//            try? JSONDecoder().decode(T.self, from: $0)
//        })
//    }
//}
