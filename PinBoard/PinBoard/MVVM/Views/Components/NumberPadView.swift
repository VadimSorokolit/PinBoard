//
//  NumberPadView.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 08.07.2025.
//
    
import SwiftUI

struct NumberPadView: View {
    let onAdd: (_ value: Int) -> Void
    let onRemoveLast: () -> Void
    let onDissmis: () -> Void
    private let columns: [GridItem] = Array(repeating: .init(), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns){
            ForEach(1 ... 9, id: \.self) { index in
                Button(action: {
                    
                    onAdd(index)
                }) {
                    Text("\(index)")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16.0)
                        .contentShape(.rect)
                }
            }
            
            Button(action: {
                
                onRemoveLast()
            }) {
                Image(systemName: "delete.backward")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16.0)
                    .contentShape(.rect)
            }
            
            Button(action: {
                
                onAdd(0)
            }) {
                Text("0")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16.0)
                    .contentShape(.rect)
            }
            
            Button(action: {
                
                onDissmis()
            }) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16.0)
                    .contentShape(.rect)
            }
        }
        .foregroundStyle(.primary)
    }
    
}
