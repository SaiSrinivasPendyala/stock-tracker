//
//  SearchBar.swift
//  StockPriceLive
//
//  Created by P Sai Srinivas on 10/03/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search Stocks", text: $text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    SearchBar()
//}
