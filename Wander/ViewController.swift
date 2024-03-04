//
//  ViewController.swift
//  Wander
//
//  Created by Alex Cabrera on 2/26/24.
//

import UIKit

import CoreData



class ViewController: UIViewController {
    
    var users: [NSManagedObject] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
      //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }
      
        let managedContext = appDelegate.persistentContainer.viewContext
      
      //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StoredUser")
        fetchRequest.returnsObjectsAsFaults = false
      
      //3
        do {
            users = try managedContext.fetch(fetchRequest)
            save("William Bulko")
            print(users)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func save(_ name: String) {
      
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
      
      // 1
        let managedContext = appDelegate.persistentContainer.viewContext
      
      // 2
        let entity = NSEntityDescription.entity(forEntityName: "StoredUser", in: managedContext)!
      
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
      
      // 3
        person.setValue(UUID(), forKeyPath: "id")
        person.setValue(name, forKeyPath: "username")
      
      // 4
        do {
            try managedContext.save()
            users.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }


}

