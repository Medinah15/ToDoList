//
//  NetworkService.swift
//  ToDoList
//
//  Created by Medina Huseynova on 02.02.26.
//

import Foundation

final class NetworkService {
    
    static let shared = NetworkService()
    private init() {}
    
    func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {
        
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let response = try JSONDecoder().decode(TodoResponseDTO.self, from: data)
                completion(.success(response.todos))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
