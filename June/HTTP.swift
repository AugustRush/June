//
//  HTTP.swift
//  June
//
//  Created by pingwei liu on 2019/7/26.
//  Copyright © 2019 pingwei liu. All rights reserved.
//

import SwiftUI
import Combine

class HTTP<T>: BindableObject {
    var expectValue: T
    
    typealias Transformer = (Data) -> T?
    internal var willChange = PassthroughSubject<Void,Never>()
    private var transformer: Transformer
    private var cancelable: Cancellable?
    
    required init(default value: T, transformer: @escaping Transformer) {
        self.expectValue = value
        self.transformer = transformer
    }
    
    func get(with path: String) {
        let url = URL(string: path)
        guard let real = url else { return }
        var request = URLRequest(url: real)
        request.httpMethod = "GET"
        get(with: request)
    }
    
    func get(with request: URLRequest) {
        let publisher = URLSession.shared.dataTaskPublisher(for: request)
        let subscriber = publisher.sink(receiveCompletion: { (error) in
            print(error)
        }) { (data,response) in
            if let result = self.transformer(data) {
                self.expectValue = result
                DispatchQueue.main.async {
                    self.willChange.send()
                }
            }
        }

        cancelable = subscriber
    }
    
    func cancel() {
        cancelable?.cancel()
    }
}

extension HTTP where T == UIImage {
    convenience init(default image: UIImage = UIImage()) {
        self.init(default: image, transformer: { UIImage(data: $0) })
    }
}
