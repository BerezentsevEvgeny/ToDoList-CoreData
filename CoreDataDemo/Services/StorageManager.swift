//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Евгений Березенцев on 17.08.2021.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
 
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    // MARK: - Fetch data from base
    
    func fetchData(completion: ([Task])-> Void) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            let taskList = try persistentContainer.viewContext.fetch(fetchRequest)
            completion(taskList)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Saving data 
    
    func saveData(_ taskName: String, completion: (Task)->Void) {
        guard let entiyDescription = NSEntityDescription.entity(forEntityName: "Task", in: persistentContainer.viewContext) else {
            return
        }
        guard let task = NSManagedObject(entity: entiyDescription, insertInto: persistentContainer.viewContext) as? Task else { return }
        task.name = taskName
        completion(task)

    }
    
    
    
}
