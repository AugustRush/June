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
    
    var expectValue: T {
        didSet {
            self.willChange.send()
        }
    }
    
    
    typealias Transformer = (Data) -> T?
    internal var willChange = PassthroughSubject<Void,Never>()
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
}

extension HTTP where T == UIImage {
    convenience init(default image: UIImage = UIImage()) {
        self.init(default: image, transformer: { UIImage(data: $0) })
    }
}

extension HTTP where T : Decodable {
    convenience init(default value: T) {
        self.init(default: value, transformer: {
            try? JSONDecoder().decode(T.self, from: $0)
        })
    }
}
