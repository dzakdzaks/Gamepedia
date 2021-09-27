//
//  GameProvider.swift
//  Gamepedia
//
//  Created by Dzaky on 27/09/21.
//

import CoreData
import UIKit


class GameProvider {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoriteGame")
        
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
    
    func getAllGames(completion: @escaping(_ games: [LocalGameModel]) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocalGame")
            do {
                let results = try taskContext.fetch(fetchRequest)
                var games: [LocalGameModel] = []
                
                for result in results {
                    let game = LocalGameModel(
                        id: result.value(forKey: "id") as? Int32,
                        gameId: result.value(forKey: "gameId") as? Int32,
                        name: result.value(forKey: "name") as? String,
                        releaseDate: result.value(forKey: "releaseDate") as? String,
                        backgroundImage: result.value(forKey: "backgroundImage") as? String,
                        rating: result.value(forKey: "rating") as? Double,
                        ratingTop: result.value(forKey: "ratingTop") as? Double,
                        parentPlatforms: result.value(forKey: "parentPlatforms") as? String,
                        genres: result.value(forKey: "genres") as? String,
                        esrbRating: result.value(forKey: "esrbRating") as? String,
                        descriptionRaw: result.value(forKey: "descriptionRaw") as? String,
                        developers: result.value(forKey: "developers") as? String,
                        publishers: result.value(forKey: "publishers") as? String
                    )
                    games.append(game)
                }
                completion(games)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func addToFavorite(
        _ paramGame: LocalGameModel,
        completion: @escaping() -> Void
    ) {
        let taskContext = newTaskContext()
        taskContext.performAndWait {
            if let entity = NSEntityDescription.entity(forEntityName: "LocalGame", in: taskContext) {
                let game = NSManagedObject(entity: entity, insertInto: taskContext)
                self.getMaxId { id in
                    game.setValue(id+1, forKeyPath: "id")
                    game.setValue(paramGame.gameId, forKey: "gameId")
                    game.setValue(paramGame.name, forKeyPath: "name")
                    game.setValue(paramGame.releaseDate, forKeyPath: "releaseDate")
                    game.setValue(paramGame.backgroundImage, forKeyPath: "backgroundImage")
                    game.setValue(paramGame.rating, forKeyPath: "rating")
                    game.setValue(paramGame.ratingTop, forKeyPath: "ratingTop")
                    game.setValue(paramGame.parentPlatforms, forKeyPath: "parentPlatforms")
                    game.setValue(paramGame.genres, forKeyPath: "genres")
                    game.setValue(paramGame.esrbRating, forKeyPath: "esrbRating")
                    game.setValue(paramGame.descriptionRaw, forKeyPath: "descriptionRaw")
                    game.setValue(paramGame.developers, forKeyPath: "developers")
                    game.setValue(paramGame.publishers, forKeyPath: "publishers")
                    
                    do {
                        try taskContext.save()
                        completion()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
        }
    }
    
    
    func getMaxId(completion: @escaping(_ maxId: Int) -> Void) {
        let taskContext = newTaskContext()
        taskContext.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocalGame")
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchLimit = 1
            do {
                let lastGame = try taskContext.fetch(fetchRequest)
                if let member = lastGame.first, let position = member.value(forKeyPath: "id") as? Int{
                    completion(position)
                } else {
                    completion(0)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func isGameAlreadyFavorited(gameId: Int, completion: @escaping(_ isAlreadyFavorited: Bool) -> Void) {
        let taskContext = newTaskContext()
        taskContext.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocalGame")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "gameId == \(gameId)")
            do {
                let lastGame = try taskContext.fetch(fetchRequest)
                completion(lastGame.first != nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteFromFavorite(_ id: Int, completion: @escaping() -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalGame")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "gameId == \(id)")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            if let batchDeleteResult = try? taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
                if batchDeleteResult.result != nil {
                    completion()
                }
            }
        }
    }
    
    func deleteAllGame(completion: @escaping() -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalGame")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            if let batchDeleteResult = try? taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
                if batchDeleteResult.result != nil {
                    completion()
                }
            }
        }
    }
    
}
