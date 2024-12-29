//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Vlad Stoicoviciu on 12/26/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
      //  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let realm = try! Realm()
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath )
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added"
        return cell
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert   )
        let action = UIAlertAction(title: "Add Category", style: .default) {(action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            self.saveItems(add:newCategory)
        }
    
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    
    
    func saveItems(add category : Category) {
        do{
            try realm.write{realm.add(category)}
        }catch {
            print("Error saving and viewing the realm stuff, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
}
