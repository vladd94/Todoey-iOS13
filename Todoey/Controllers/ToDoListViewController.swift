//
//  ViewController.swift
//  Todoey
//
import CoreData
import UIKit

class ToDoListViewController: UITableViewController {
    var itemArray : [Item] = []
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), _predicate existingPredicate : NSPredicate? = nil){
        let predicate = NSPredicate( format: "parent.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = existingPredicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, additionalPredicate])
        }else{
            request.predicate = predicate
        }
        
        do {
            itemArray = try context.fetch(request)
        }catch {
            print("Error fetching, \(error)")
        }
        
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell",for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].text
        cell.accessoryType = itemArray[indexPath.row].complete ? .checkmark : .none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].complete = !itemArray[indexPath.row].complete
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert   )
        let action = UIAlertAction(title: "Add Item", style: .default) {(action) in
            let newItem = Item(context: self.context)
            newItem.text = textField.text!
            newItem.parent = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
        }
    
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    
    func saveItems(){
        do{
           try context.save()
        }catch {
            print("Error saving and viewing the context, \(error)")
        }
        
        tableView.reloadData()
    }
 
    
}

//MARK : SearchBar Delegate
extension ToDoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "text CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: true)]
       
        loadItems(with: request, _predicate: predicate)
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
