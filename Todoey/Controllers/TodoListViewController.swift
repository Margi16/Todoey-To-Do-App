//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
class TodoListViewController: SwipeTableViewController {
    var todoItems: Results<Item>?
//    var todoItems = [Item]()
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.separatorStyle = .none
        
        
        //        loadItems()
        //        if let items = defaults.array(forKey: "ToDoListArray") as? [Item]{
        //            todoItems = items
        //        }
        //
    }
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour{
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation Controller does not exist.")
            }
            if let navBarColour = UIColor(hexString: colourHex) {
                navBar.backgroundColor = navBarColour
                    navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
                    searchBar.barTintColor = navBarColour
            }
        
        }
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todoItems?.count ?? 1
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        print("cellForRowAt indexpath called")
        //        let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage:CGFloat(indexPath.row)/CGFloat(todoItems!.count))
            {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
//            print("version 1: \(CGFloat(indexPath.row/todoItems!.count))")
//            print("version 2: \(CGFloat(indexPath.row)/CGFloat(todoItems!.count))")
//
//
            //cellForRowAt tableview method loads up when first view loads up, so only initial checkmarks and none can be seen in below written if else
            
            
            //Ternary operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            
            cell.accessoryType = item.done ? .checkmark : .none
            
            
            //        or
            //        cell.accessoryType = item.done == true ? .checkmark : .none
            //      or
            //        if item.done == true {
            //            cell.accessoryType = .checkmark
            //        }
            //        else{
            //            cell.accessoryType = .none
            //        }
            
        }
        else {
            cell.textLabel?.text = "No Items added"
        }
        return cell
        
    }
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
//                    realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
            
        }
        tableView.reloadData()
        
        //        print(todoItems[indexPath.row])
        
        //        context.delete(todoItems[indexPath.row])
        //        todoItems.remove(at: indexPath.row)
        
        //        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        //        saveItems()
        
        //or
        //        if todoItems[indexPath.row].done == false {
        //            todoItems[indexPath.row].done = true
        //        }
        //        else{
        //            todoItems[indexPath.row].done = false
        //        }
        
        
        //        tableView.reloadData()//since cellForRowAt tableview method loads up when first view loads up, so only initial checkmarks and none can be seen in above to above written if else, we write this code to make tablview refresh and reload data again and again
        //commented now cz this code is inside saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //what will happen when user clicks in Add Item button on our UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
                
            }
            self.tableView.reloadData()
            
//            self.saveItems()
            
        }
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create New Item"
            
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manipulation Methods
    func saveItems() {
        
//        do{
////            try context.save()
//        }
//        catch{
//            print("Error saving context \(error)")
//        }
        
        self.tableView.reloadData()
        
    }
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil){
        //        let request: NSFetchRequest<Item> = Item.fetchRequest()

//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

//        if let additionalPredicate = predicate {
//
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate] )
//
//        }
//        else
//        {
//            request.predicate = categoryPredicate
//
//        }


        //      below 2 lines of code are written above using optional binding so that no nil value is unwrapped
        //        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,predicate])
        //
        //        request.predicate = compoundPredicate

//        do{
//            todoItems = try context.fetch(request)
//        }
//        catch{
//            print("Error fetching data from context \(error)")
//        }
        self.tableView.reloadData()
    }
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            do{
           try realm.write {
                realm.delete(item)
            }
        }
            catch{
                print("Error deleting item, \(error)")
            }
        }
        
    }
}
//MARK: - Search Bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        todoItems = todoItems?.filter("title CONTAINS[cd] %@",searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        //        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        //        request.predicate = predicate
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        //        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        //        request.sortDescriptors = [sortDescriptor]
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request,predicate: predicate)

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {

            loadItems()

            DispatchQueue.main.async {

                searchBar.resignFirstResponder()

            }

        }
    }
}
