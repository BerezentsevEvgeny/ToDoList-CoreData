//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by brubru on 16.08.2021.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let context = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "cell"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchTasks()
    }
    
    // MARK: - Deleting task
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            context.delete(task)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Editing task
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let alert = UIAlertController(title: "Editing task", message: "Enter new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            let currentTask = self.taskList[indexPath.row]
            currentTask.name = taskName
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = self.taskList[indexPath.row].name
        }
        present(alert, animated: true)
    }
    
    // Fetching tasks from storage
    private func fetchTasks() {
        StorageManager.shared.fetchData { tasks in
            taskList = tasks
        }
    }
    
    // Saving new data to storage
    private func saveNewData(_ taskName: String) {
        StorageManager.shared.saveData(taskName) { task in
            taskList.append(task)
            let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
            tableView.insertRows(at: [cellIndex], with: .automatic)

            if context.hasChanges {
                do {
                    try context.save()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearence = UINavigationBarAppearance()
        
        navBarAppearence.configureWithOpaqueBackground()
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
        
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.saveNewData(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
    
}

//MARK: - DataSource

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
}







// Изначальные методы

//    private func save(_ taskName: String) {
//        guard let entiyDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
//            return
//        }
//        guard let task = NSManagedObject(entity: entiyDescription, insertInto: context) as? Task else { return }
//        task.name = taskName
//        taskList.append(task)
//
//        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
//        tableView.insertRows(at: [cellIndex], with: .automatic)
//
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch let error {
//                print(error.localizedDescription)
//            }
//        }
//    }


//    private func fetchData() {
//        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
//
//        do {
//            taskList = try context.fetch(fetchRequest)
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
