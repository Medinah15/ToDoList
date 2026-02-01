//
//  TodoRowView.swift
//  ToDoList
//
//  Created by Medina Huseynova on 31.01.26.
//

import SwiftUI

struct TodoRowView: View {
    
    let todo: ToDoEntity
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            
            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(todo.isCompleted ? Color("Yellow") : Color("Gray"))
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(todo.title ?? "")
                    .font(.medium16)
                    .foregroundStyle(Color("MainText"))
                    .lineLimit(2)
                
                if let details = todo.details,
                   !details.isEmpty {
                    Text(details)
                        .font(.regular12)
                        .foregroundStyle(Color("MainText"))
                        .lineLimit(2)
                }
                
                if let date = todo.createdAt {
                    Text(date.formatted(date: .numeric, time: .omitted))
                        .font(.regular12)
                        .foregroundStyle(Color("TextHint"))
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 24)
    }
}
