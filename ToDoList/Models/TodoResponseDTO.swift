//
//  TodoResponseDTO.swift
//  ToDoList
//
//  Created by Medina Huseynova on 02.02.26.
//

import Foundation

struct TodoResponseDTO: Decodable {
    let todos: [TodoDTO]
}
