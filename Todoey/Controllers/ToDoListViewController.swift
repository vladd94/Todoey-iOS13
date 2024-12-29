//
//  ViewController.swift
//  Todoey
//
import RealmSwift
import UIKit

class ToDoListViewController: UITableViewController {
    var itemArray : Results<Item>?
    let realm = try! Realm()
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadItems()
    }
    
    func loadItems(){
        itemArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell",for: indexPath)
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.text
            cell.accessoryType = item.complete ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items here"
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    item.complete = !item.complete
                    //realm.delete(item) -> to delete stuff from realm
                }
            } catch {print("Error saving and viewing the realm stuff, \(error)")}
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert   )
        let action = UIAlertAction(title: "Add Item", style: .default) {(action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.text = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                        self.tableView.reloadData()
                        //self.saveItems(add: newItem)
                    }
                } catch {print("Error saving and viewing the realm stuff, \(error)")}
                
            }
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    
    func saveItems(add item : Item){
        do{
            try realm.write{realm.add(item)}
        }catch {
            print("Error saving and viewing the realm stuff, \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK : SearchBar Delegate
extension ToDoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemArray = itemArray?.filter("text CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated",ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
