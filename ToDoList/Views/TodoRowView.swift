//
//  TodoRowView.swift
//  ToDoList
//
//  Created by Medina Huseynova on 31.01.26.
//

import SwiftUI

struct TodoRowView: View {
    
    let todo: ToDoEntity
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            
            Image(systemName: todo.isCompleted ? "checkmark.circle" : "circle")
                .foregroundStyle(todo.isCompleted ? Color("Yellow") : Color("Gray"))
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(todo.title ?? "")
                    .font(.medium16)
                    .foregroundStyle(
                        todo.isCompleted
                        ? Color("TextHint")
                        : Color("MainText")
                    )
                    .strikethrough(
                        todo.isCompleted,
                        color: Color("TextHint")
                    )
                    .lineLimit(2)
                
                if let details = todo.details,
                   !details.isEmpty {
                    Text(details)
                        .font(.regular12)
                        .foregroundStyle(
                            todo.isCompleted
                            ? Color("TextHint")
                            : Color("MainText")
                        )
                        .lineLimit(2)
                }
                
                if let date = todo.createdAt {
                    Text(date.formattedForTodo())
                        .font(.regular12)
                        .foregroundStyle(Color("TextHint"))
                }
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .contextMenu {
            Button {
                onEdit?()
            } label: {
                Label("Редактировать", systemImage: "square.and.pencil")
            }
            
            Button {
                
            } label: {
                Label("Поделиться", systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive) {
                onDelete?()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}
