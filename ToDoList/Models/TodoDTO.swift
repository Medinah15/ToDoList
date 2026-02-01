//
//  TodoDTO.swift
//  ToDoList
//
//  Created by Medina Huseynova on 02.02.26.
//

import Foundation

struct TodoDTO: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
