//
//  ViewController.swift
//  Core Data
//
//  Created by Сергей Веретенников on 25/04/2022.
//

import UIKit
import CoreData


class TaskListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    
    var fetchController: NSFetchedResultsController<Task>!
    
    private let context = StorageMenager.shared.persistentContainer.viewContext
    
    private let cellID = "task"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "task")
        setupNavigationBar()
        
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let sortDesc = NSSortDescriptor(key: "createdDate", ascending: true)
        
        request.sortDescriptors = [sortDesc]
        
        fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchController.delegate = self
        
        reloadData()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 0.8)
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    
    
    @objc private func addNewTask() {
        showAlert(with: "Add new task", and: "Any plans?")
    }
    
    private func fetchData() {
        do {
            try fetchController.performFetch()
        } catch {
            print(2)
        }
    }
}

extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let sourceCell = fetchController.object(at: sourceIndexPath)
        let destinationCell = fetchController.object(at: destinationIndexPath)
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchController.sections?[section]
        
        return section?.numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = fetchController.object(at: indexPath)
        cell.textLabel?.text = task.titleOfTask
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let taskToEdit = fetchController.object(at: indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        guard let title = taskToEdit.titleOfTask else { return }
        
        request.predicate = NSPredicate(format: "titleOfTask = %@", title)
        
        do {
            let obj = try context.fetch(request).last
            saveEdit(object: obj)
        } catch {
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let taskToDelete = fetchController.object(at: indexPath)
            context.delete(taskToDelete)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }

        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath, to: newIndexPath!)
            StorageMenager.shared.saveContext()
        default: break
        }
    }
}

extension TaskListViewController {
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
    
    private func showAlert(with: String, and message: String) {
        
        let alert = UIAlertController(title: with, message: message, preferredStyle: .alert)
        let saveAct = UIAlertAction(title: "Save", style: .default) { _ in
            
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        let cancelAct = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(saveAct)
        alert.addAction(cancelAct)
        alert.addTextField { textField in
            textField.placeholder = "New task"
        }
        present(alert, animated: true)
    }
    
    
    private func save(_ taskName: String) {
        
        let task = Task(context: context)
        task.titleOfTask = taskName
        task.createdDate = Date()
        
        print(task.createdDate as Any)
        
        let section = fetchController.sections?[0]
        
        let index = IndexPath(row: section?.numberOfObjects ?? 0, section: 0)
        
        fetchData()
        
        tableView.insertRows(at: [index], with: .automatic)
        
        StorageMenager.shared.saveContext()
    }
    
    
    private func saveEdit(object: NSManagedObject?) {
        guard let object = object as? Task else { return }
        
        let alert = UIAlertController(title: "edit", message: "", preferredStyle: .alert)
        
        let alOk = UIAlertAction(title: "Save", style: .default) { _ in
            object.titleOfTask = alert.textFields?.first?.text
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField { tf in
            tf.text = object.titleOfTask
        }
        
        alert.addAction(alOk)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}
