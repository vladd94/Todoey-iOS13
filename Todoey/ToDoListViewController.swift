//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    private var items: [Item] = []
    let defaults = UserDefaults.standard
    private let openAIService = OpenAIService()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    // MARK: - Data Management
    private func loadItems() {
        if let savedItems = defaults.array(forKey: "TodoListArray") as? [String] {
            items = savedItems.map { Item(title: $0) }
        } else {
            items = [
                Item(title: "Buy Eggos"),
                Item(title: "Destroy Demogorgon"),
                Item(title: "Find Mike")
            ]
        }
    }
    
    private func saveItems() {
        defaults.set(items.map { $0.title }, forKey: "TodoListArray")
    }
    
    // MARK: - UI Actions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", 
                                    message: "", 
                                    preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self] _ in
            guard let self = self,
                  let newItemTitle = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newItemTitle.isEmpty else { return }
            
            // Show loading indicator
            let loadingAlert = UIAlertController(title: nil, message: "Generating inspiring options...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .medium
            loadingIndicator.startAnimating()
            loadingAlert.view.addSubview(loadingIndicator)
            self.present(loadingAlert, animated: true)
            
            // Generate options using OpenAI
            Task {
                do {
                    let options = try await self.openAIService.generateInspiringOptions(text: newItemTitle)
                    
                    DispatchQueue.main.async {
                        loadingAlert.dismiss(animated: true) {
                            // Show options alert
                            let optionsAlert = UIAlertController(title: "Choose Your Inspiration", 
                                                               message: "Select the version you prefer:", 
                                                               preferredStyle: .alert)
                            
                            // Add an action for each option
                            for option in options {
                                let optionAction = UIAlertAction(title: option, style: .default) { [weak self] _ in
                                    guard let self = self else { return }
                                    let newItem = Item(title: option)
                                    self.items.append(newItem)
                                    self.saveItems()
                                    self.tableView.reloadData()
                                }
                                optionsAlert.addAction(optionAction)
                            }
                            
                            // Add cancel option that uses original text
                            let cancelAction = UIAlertAction(title: "Use Original", style: .cancel) { [weak self] _ in
                                guard let self = self else { return }
                                let newItem = Item(title: newItemTitle)
                                self.items.append(newItem)
                                self.saveItems()
                                self.tableView.reloadData()
                            }
                            optionsAlert.addAction(cancelAction)
                            
                            self.present(optionsAlert, animated: true)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        loadingAlert.dismiss(animated: true)
                        // Fall back to original text if API call fails
                        let newItem = Item(title: newItemTitle)
                        self.items.append(newItem)
                        self.saveItems()
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = items[indexPath.row]
        
        // Configure cell
        cell.textLabel?.text = item.title
        // Set checkmark based on completion status
        cell.accessoryType = item.isCompleted ? .checkmark : .none
        
        return cell
    }
    
    //Mark - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle completion status
        items[indexPath.row].isCompleted.toggle()
        
        // Save changes
        saveItems()
        
        // Update cell appearance
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        // Animate deselection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - TableView Data Source & Delegate Methods
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item
            items.remove(at: indexPath.row)
            // Save the updated items array
            saveItems()
            // Delete the row with animation
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Add support for swipe actions with more customization
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Create the delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            // Remove the item
            self.items.remove(at: indexPath.row)
            // Save the updated items
            self.saveItems()
            // Delete the row with animation
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            completionHandler(true)
        }
        
        // Customize the delete action
        deleteAction.backgroundColor = .systemRed
        
        // Create the swipe configuration
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        // Prevent full swipe to trigger the action automatically
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
}

