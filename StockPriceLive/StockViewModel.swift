//
//  StockViewModel.swift
//  StockPriceLive
//
//  Created by P Sai Srinivas on 09/03/25.
//

import Foundation
import Combine

class StockViewModel: ObservableObject {
    @Published var stockDetails: [StockDetail] = []
    @Published var searchText: String = ""
    @Published var filteredStocks: [StockDetail] = []
    @Published var isLoading: Bool = false
    @Published var snackbarMessage: String? = nil // Stores the message for snackbar
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchStockDetails()
        setupSearch()
    }
    
    
    // [weak self] is used to prevent retain cycles which might cause memory leaks.
    
    // In Combine, store(in:) is used to manage and automatically cancel subscriptions when they are no longer needed.
    
    // completion emits 2 values - .finished and .failure(Error)
    func fetchStockDetails() {
        StockAPI.shared.fetchStockDetails()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching stocks: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] details in
                DispatchQueue.main.async {
                    self?.stockDetails = details
                }
            })
            .store(in: &cancellables)
    }
    
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(3), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] text in
                guard let self = self else { return [] }
                return self.stockDetails.filter {
                    $0.symbol.lowercased().contains(text.lowercased())
                }
            }
            .assign(to: &$filteredStocks)
    }
    
    func fetchStockPrice(for symbol: String) {
        isLoading = true
        snackbarMessage = "Fetching price..."
        
        StockAPI.shared.fetchStockPrice(for: symbol)
            .sink(receiveCompletion: { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.snackbarMessage = "Error: \(error.localizedDescription)"
                    }
                }
            }, receiveValue: { [weak self] price in
                DispatchQueue.main.async {
                    self?.snackbarMessage = "Price of \(symbol): $\(price)"
                    
                    // Save to Core Data history
                    if let stock = self?.filteredStocks.first(where: { $0.symbol == symbol }) {
                        CoreDataManager.shared.saveStock(symbol: stock.symbol, name: stock.name)
                    }
                    
                    // Auto-dismiss snackbar after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self?.snackbarMessage = nil
                    }
                }
            })
            .store(in: &cancellables)
    }
}
