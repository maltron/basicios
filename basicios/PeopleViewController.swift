//
//  ViewController.swift
//  basicios
//
//  Created by Mauricio Leal on 2/15/18.
//  Copyright © 2018 Mauricio Leal. All rights reserved.
//
import UIKit
import CoreData

protocol PeopleCoreDataDelegate {
    func created(_ firstName: String, _ lastName: String)
    func updated(_ person: Person)
}

class PeopleViewController: UITableViewController, PeopleCoreDataDelegate, NSFetchedResultsControllerDelegate {
    
    lazy var persitentContainer: NSPersistentContainer = {
        /**
         The persitent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail
        */
        let container = NSPersistentContainer(name: "PersonModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although
            // it may be useful during development.
            
            /**
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created,
                or disallows writing.
             * The persistent store is not accessible, due to permissions or data
               protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
               Check the error message to determine what the actual problem was.
            */
                fatalError("### UNABLE TO LOAD CORE DATA: Unresolved error \(error) \(error.userInfo)")
            }
        })
        return container
    }()
    
    var fetchedResultsController: NSFetchedResultsController<Person>!
    
    let CELL_ID: String = "PeopleCellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "People"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_ID)
        
        // Fetching a NSFetchedResultsController
        let context: NSManagedObjectContext = persitentContainer.viewContext
        let fetchRequest: NSFetchRequest<Person> = NSFetchRequest<Person>(entityName: "Person")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch let fetchErr {
            print("### viewDidLoad() UNABLE TO FETCH DATA:", fetchErr)
        }
    }
    
    @objc private func handleAdd() {
        let personViewController: PersonViewController = PersonViewController()
        personViewController.delegate = self
        navigationController?.pushViewController(personViewController, animated: true)
    }
    
    // TableView DATA SOURCE DATA SOURCE DATA SOURCE DATA SOURCE DATA SOURCE
    //   DATA SOURCE DATA SOURCE DATA SOURCE DATA SOURCE DATA SOURCE DATA SOURCE
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections: [NSFetchedResultsSectionInfo] = fetchedResultsController.sections else { return 0 }
        
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath)
        let person: Person = fetchedResultsController.object(at: indexPath)
        
        if let firstName = person.firstName, let lastName = person.lastName {
            cell.textLabel?.text = "\(firstName) \(lastName)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction: UITableViewRowAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            let person: Person = self.fetchedResultsController.object(at: indexPath)
            let context = self.persitentContainer.viewContext
            context.delete(person)
            do {
                try context.save()
            } catch let deleteErr {
                print("### delete() UNABLE TO DELETE:", deleteErr)
            }
        }
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let personViewController: PersonViewController = PersonViewController()
        personViewController.person = fetchedResultsController.object(at: indexPath)
        personViewController.delegate = self

        navigationController?.pushViewController(personViewController, animated: true)
    }
    
    // PEOPLE DELEGATE PEOPLE DELEGATE PEOPLE DELEGATE PEOPLE DELEGATE PEOPLE DELEGATE
    //   PEOPLE DELEGATE PEOPLE DELEGATE PEOPLE DELEGATE PEOPLE DELEGATE PEOPLE DELEGATE
    func created(_ firstName: String, _ lastName: String) {
        let context: NSManagedObjectContext = persitentContainer.viewContext
//        let newPerson: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: "Person", into: context)
//        newPerson.setValue(firstName, forKey: "firstName")
//        newPerson.setValue(lastName, forKey: "lastName")
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Person", in: context)!
        let newPerson: Person = Person(entity: entity, insertInto: context)
        newPerson.firstName = firstName
        newPerson.lastName = lastName
        
        do {
            try context.save()
        } catch let saveErr {
            print("### create() UNABLE TO SAVE DATA:", saveErr)
        }
    }
    
    func updated(_ person: Person) {
        print(">>> PeopleViewController.updated()")
        let context: NSManagedObjectContext = persitentContainer.viewContext
        
        do {
            try context.save()
        } catch let updateErr {
            print("### update() UNABLE TO UPDATE DATA:", updateErr)
        }
    }
    
    // NS FETCHED RESULTS NS FETCHED RESULTS NS FETCHED RESULTS
    //  NS FETCHED RESULTS NS FETCHED RESULTS NS FETCHED RESULTS
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(">>> controllerWillChangeContent()")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print(">>> controller(didChange)")
        
        switch type {
        // INSERT/CREATE
        case NSFetchedResultsChangeType.insert:
            if let insertIndexPath = newIndexPath {
                tableView.insertRows(at: [insertIndexPath], with: .automatic)
            }
        // DELETE
        case NSFetchedResultsChangeType.delete:
            if let deleteIndexPath = indexPath {
                tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
            }
            
        // UPDATE
        case NSFetchedResultsChangeType.update:
            if let updateIndexPath = indexPath {
                let cell = tableView.cellForRow(at: updateIndexPath)
                let person: Person = fetchedResultsController.object(at: updateIndexPath)
                
                if let firstName = person.firstName, let lastName = person.lastName {
                    cell?.textLabel?.text = "\(firstName) \(lastName)"
                }
            }
            
        // MOVE = DELETE + INSERT
        case NSFetchedResultsChangeType.move:
            if let deleteIndexPath = indexPath {
                tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
            }
            
            if let insertIndexPath = newIndexPath {
                tableView.insertRows(at: [insertIndexPath], with: .automatic)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print(">>> controller(didChange:sectionInfo")
        
        switch type {
        // INSERT
        case .insert:
            let sectionIndexSet = IndexSet(integer: sectionIndex)
            tableView.insertSections(sectionIndexSet, with: .automatic)
        // DELETE
        case .delete:
            let sectionIndexSet = IndexSet(integer: sectionIndex)
            tableView.deleteSections(sectionIndexSet, with: .automatic)
        default:
            break
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(">>> controllerDidChangeContent")
        tableView.endUpdates()
    }

    
    // CORE DATA CORE DATA CORE DATA CORE DATA CORE DATA CORE DATA
    //   CORE DATA CORE DATA CORE DATA CORE DATA CORE DATA CORE DATA
    
//    func saveContext() {
//        let context: NSManagedObjectContext = persitentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately
//                // fatalError() causes the application to generate a crash log
//                // and terminate. You should not use this function in a shipping application,
//                // although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("### saveContext() Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }

}

