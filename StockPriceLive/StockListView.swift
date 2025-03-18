//
//  StockListView.swift
//  StockPriceLive
//
//  Created by P Sai Srinivas on 09/03/25.
//

import SwiftUI

struct StockListView: View {
    @StateObject private var viewModel = StockViewModel()
    @State private var showHistory = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    TextField("Search by Symbol...", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if viewModel.filteredStocks.isEmpty {
                        Text("No stocks found")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List(viewModel.filteredStocks) { stock in
                            Button(action: {
                                viewModel.fetchStockPrice(for: stock.symbol)
                            }) {
                                HStack {
                                    Text(stock.symbol)
                                        .font(.headline)
                                    Spacer()
                                    VStack {
                                        Text(stock.name)
                                        Text("Currency: \(stock.currency)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("Country: \(stock.country)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Stock Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {  // ✅ Button in NavBar
                        Button(action: {
                            showHistory = true
                        }) {
                            Image(systemName: "clock") // ⏳ History Icon
                                .foregroundColor(.blue)
                        }
                    }
                }
                .background(
                    NavigationLink(destination: StockHistoryView(), isActive: $showHistory) {
                        EmptyView()
                    }
                        .hidden()
                )
            }
            // Snackbar View
            if let message = viewModel.snackbarMessage {
                VStack {
                    Spacer()
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Text(message)
                            .foregroundColor(.white)
                            .padding(.leading, viewModel.isLoading ? 5 : 0)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom))
                }
            }
        }
    }
}

struct StockListView_Previews: PreviewProvider {
    static var previews: some View {
        StockListView()
    }
}
