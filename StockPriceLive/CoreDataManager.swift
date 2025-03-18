//
//  CoreDataManager.swift
//  StockPriceLive
//
//  Created by P Sai Srinivas on 12/03/25.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "StockHistory")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func saveStock(symbol: String, name: String) {
        let context = context
        let newStock = StockEntity(context: context)
        newStock.symbol = symbol
        newStock.name = name
        newStock.date = Date()
        
        do {
            let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let stocks = try context.fetch(fetchRequest)
            
            // Keep only the last 10 entries
            if stocks.count >= 10 {
                context.delete(stocks.last!)
            }
            
            try context.save()
        } catch {
            print("Failed to save stock: \(error.localizedDescription)")
        }
    }
    
    // Fetch last 10 searched stocks
    func fetchHistory() -> [StockEntity] {
        let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 10
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch history: \(error.localizedDescription)")
            return []
        }
    }
    
}
