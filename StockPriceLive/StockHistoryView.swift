//
//  StockHistoryView.swift
//  StockPriceLive
//
//  Created by P Sai Srinivas on 12/03/25.
//

import SwiftUI

struct StockHistoryView: View {
    @State private var history: [StockEntity] = []

    var body: some View {
        List(history, id: \.self) { stock in
            VStack(alignment: .leading) {
                Text(stock.symbol ?? "Unknown")
                    .font(.headline)
                Text(stock.name ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Search History")
        .onAppear {
            history = CoreDataManager.shared.fetchHistory()
        }
    }
}

#Preview {
    StockHistoryView()
}
