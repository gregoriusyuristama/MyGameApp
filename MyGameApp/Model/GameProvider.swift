//
//  GameProvider.swift
//  MyGameApp
//
//  Created by Gregorius Yuristama Nugraha on 1/31/23.
//

import CoreData
import UIKit

class GameProvider {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GameData 2")
        container.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Unresolved error \(error!)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.undoManager = nil
        return container
    }()
    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.undoManager = nil
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return taskContext
    }
    func getAllGames(completion: @escaping(_ games: [Game]) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameFav")
            do {
                let results = try taskContext.fetch(fetchRequest)
                var games: [Game] = []
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                for result in results {
                    let stringURL = result.value(forKey: "image") as? String
                    let game = Game(
                        title: (result.value(forKey: "title") as? String)!,
                        image: URL(string: stringURL!)!,
                        id: (result.value(forKey: "id") as? Int32)!,
                        rank: (result.value(forKey: "rank") as? Double)!,
                        release: (result.value(forKey: "releaseDate") as? Date)!,
                        description: (result.value(forKey: "gameDesc") as? String)!
                    )
                    games.append(game)
                }
                completion(games)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    func getGame(_ id: Int, completion: @escaping(_ members: Game) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameFav")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")
            do {
                if let result = try taskContext.fetch(fetchRequest).first {
                    let stringURL = result.value(forKey: "image") as? String
                    let game = Game(
                        title: (result.value(forKey: "title") as? String)!,
                        image: URL(string: stringURL!)!,
                        id: (result.value(forKey: "id") as? Int32)!,
                        rank: (result.value(forKey: "rank") as? Double)!,
                        release: (result.value(forKey: "releaseDate") as? Date)!,
                        description: (result.value(forKey: "gameDesc") as? String)!
                    )
                    completion(game)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    func saveGameToFavourite(_ id: Int32, _ title: String, _ rank: Double, _ releaseDate: Date, _ image: String,
                             _ gameDesc: String,
                             completion: @escaping() -> Void) {
        let taskContext = newTaskContext()
        taskContext.performAndWait {
            if let entity = NSEntityDescription.entity(forEntityName: "GameFav", in: taskContext) {
                let game = NSManagedObject(entity: entity, insertInto: taskContext)
                game.setValue(title, forKey: "title")
                game.setValue(image, forKey: "image")
                game.setValue(id, forKey: "id")
                game.setValue(rank, forKey: "rank")
                game.setValue(releaseDate, forKey: "releaseDate")
                game.setValue(gameDesc, forKey: "gameDesc")
                do {
                    try taskContext.save()
                    completion()
                } catch let error as NSError {
                    print("Couldn't save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    func deleteFavouriteGame(_ id: Int32, completion: @escaping() -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameFav")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            if let batchDeleteResult = try? taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult,
               batchDeleteResult.result != nil {
                completion()
            }
        }
    }
    func isGameFavorited(_ id: Int32, completion: @escaping(_ isFavorite: Bool) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameFav")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")
            do {
                if try taskContext.fetch(fetchRequest).first != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
