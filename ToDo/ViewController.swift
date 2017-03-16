//
//  ViewController.swift
//  ToDo
//
//  Created by Sigit Prayoga on 3/7/17.
//  Copyright © 2017 Sigit Prayoga. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private var todoItems: [ToDo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Bucket List"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.didTapAddItemButton(_:)))
        getTodos()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < todoItems.count
        {
            //get the item at that row
            let item = todoItems[indexPath.row]
            //update todo
            updateTodo(item: item, indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_todo", for: indexPath)
        
        if indexPath.row < todoItems.count
        {
            let item = todoItems[indexPath.row]
            cell.textLabel?.text = item.title
            let accessory: UITableViewCellAccessoryType = item.done ? .checkmark : .none
            cell.accessoryType = accessory
        }
        
        return cell
    }
    
    func didTapAddItemButton(_ sender: UIBarButtonItem)
    {
        // Create an alert
        let alert = UIAlertController(
            title: "New to-do item",
            message: "Insert the title of the new to-do item:",
            preferredStyle: .alert)
        
        // Add a text field to the alert for the new item's title
        alert.addTextField(configurationHandler: nil)
        
        // Add a "cancel" button to the alert. This one doesn't need a handler
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Add a "OK" button to the alert. The handler calls addNewToDoItem()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let title = alert.textFields?[0].text
            {
                DispatchQueue.main.async {
                    self.addTodo(title: title)
                }
            }
        }))
        
        // Present the alert to the user
        self.present(alert, animated: true, completion: nil)
    }
    
    func getTodos() {
        // create request
        var req = URLRequest(url: URL(string: "http://127.0.0.1:8383/todos")!)
        req.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: req){ data, response, err in
            guard let data = data, err == nil else {
                print("error=\(err)")
                return
            }
            
            do {
                // make sure it is fresh
                self.todoItems = []
                
                // serialize the response data, expected to be array
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as! [[String:AnyObject]]
                
                for item in jsonArray {
                    // Init new todo
                    let todo = ToDo(json: item as AnyObject)
                    
                    // Add to array
                    self.todoItems.append(todo)
                }
                
                //back to main thread
                DispatchQueue.main.async {
                    // refresh the whole thing
                    self.tableView.reloadData()
                }
            }catch{
                print("JSON serialization failed")
            }
        }
        task.resume()
    }
    
    func addTodo(title: String) {
        // get the request construction
        let req = getAddTodoRequest(title: title);
        
        // do request
        let task = URLSession.shared.dataTask(with: req){ data, response, err in
            guard let data = data, err == nil else {
                print("error=\(err)")
                return
            }
            
            do {
                // serialize the response data.
                let newTodo = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                
                // Init new todo
                let todo = ToDo(json: newTodo as AnyObject)
                
                // Add it to array
                self.todoItems.append(todo)
                
                // back to main thread
                DispatchQueue.main.async {
                    // Refresh the table view
                    self.tableView.reloadData()
                }
            }catch{
                print("JSON serialization failed")
            }
        }
        task.resume()
    }
    
    // IndexPath is needed to reload the row.
    func updateTodo(item: ToDo, indexPath: IndexPath){
        // get the request construction
        let req = getUpdateTodoRequest(todo: item)
        
        // do request
        let task = URLSession.shared.dataTask(with: req){ data, response, err in
            guard let data = data, err == nil else {
                print("error=\(err)")
                return
            }
            
            do {
                let updatedTodo = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                
                let done = updatedTodo["done"] as! Bool
                
                // here we update the status, check if it's done, otherwise uncheck
                item.done = done
                
                // back to main thread.
                DispatchQueue.main.async {
                    // reload that row only
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }catch{
                print("JSON serialization failed")
            }
        }
        task.resume()
    }
    
    func getUpdateTodoRequest(todo: ToDo) -> URLRequest {
        var req = URLRequest(url: URL(string: "http://127.0.0.1:8383/todos/update")!)
        req.httpMethod = "POST"
        
        // prepare request body
        let json: [String: Any] = ["id": todo.id, "done": !todo.done, "todo": todo.title]
        req.httpBody = try? JSONSerialization.data(withJSONObject: json)
        return req
    }
    
    func getAddTodoRequest(title: String) -> URLRequest {
        var req = URLRequest(url: URL(string: "http://127.0.0.1:8383/todos/add")!)
        req.httpMethod = "POST"
        
        // prepare request body
        let json: [String: Any] = ["todo": title]
        req.httpBody = try? JSONSerialization.data(withJSONObject: json)
        return req
    }
}

