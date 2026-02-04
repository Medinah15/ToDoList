//
//  Date+Extensions.swift
//  ToDoList
//
//  Created by Medina Huseynova on 02.02.26.
//

import Foundation

extension Date {
    func formattedForTodo() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: self)
    }
}
