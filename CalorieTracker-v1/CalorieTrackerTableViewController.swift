//
//  CalorieTrackerTableViewController.swift
//  CalorieTracker-v1
//
//  Created by Austin Potts on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData
import SwiftChart

class CalorieTrackerTableViewController: UITableViewController {
    
    //MARK: Chart View Outlet Property
   
     
    @IBOutlet weak var chartView: Chart!
    

    
      override func viewDidLoad() {
           super.viewDidLoad()

           NotificationCenter.default.addObserver(self, selector: #selector(updateCalorieChart), name: .calorieIntakeAdded, object: nil)
           updateCalorieChart()
        }

    //MARK: Computed Property for Date usage
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "LLL dd yyyy 'at' h:mm:ss a"
            formatter.timeZone = TimeZone.autoupdatingCurrent
            return formatter
        }
    
    
    //MARK: - Fetch Results Controller for Core Data
    
        lazy var fetchedResultsController: NSFetchedResultsController<Intake> = {

            let fetchRequest: NSFetchRequest<Intake> = Intake.fetchRequest()

            fetchRequest.sortDescriptors = [NSSortDescriptor(key: PropertyKeys.date, ascending: true)]

            let moc = CoreDataStack.shared.mainContext
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: PropertyKeys.date, cacheName: nil)

            frc.delegate = self

            do {
                try frc.performFetch()
            } catch {
                fatalError("Error performing fetch for frc: \(error)")
            }

            return frc
        }()

    
    //MARK: Table View Set Up

        override func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return fetchedResultsController.sections?.count ?? 0
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.cell, for: indexPath)

            let calorieIntake = fetchedResultsController.object(at: indexPath)

            cell.textLabel?.text = "Calories: \(calorieIntake.calories)"

            if let date = calorieIntake.date {
                cell.detailTextLabel?.text = dateFormatter.string(from: date)
            } else {
                cell.detailTextLabel?.text = "No date has been provided."
            }

            return cell
        }

        // MARK: - Actions for the Calorie Intake

        @IBAction func addIntake(_ sender: Any) {
            let alert = UIAlertController(title: "Add Calories", message: "Input the amount of calories you consumed during meals today.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
                self.add(calorieCount: alert.textFields?[0].text ?? "")
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addTextField(configurationHandler: { textfield in textfield.placeholder = "Calories" })

            self.present(alert, animated: true, completion: nil)
        }

        

        private func add(calorieCount: String) {
            guard let calories = Int(calorieCount) else { return }
            Intake(calories: calories)
            save()
        }

        private func save() {
            do {
                try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
                NotificationCenter.default.post(name: .calorieIntakeAdded, object: nil)
            } catch {
                print("Error saving to CoreData:\(error)")
            }
        }

    // MARK: - Updating the charts values
        @objc private func updateCalorieChart() {
            var caloriesArray: [Double] = []
            let calorieIntakes = fetchedResultsController.fetchedObjects

            calorieIntakes?.forEach { caloriesArray.append(Double($0.calories)) }

            let series = ChartSeries(caloriesArray)
            series.color = ChartColors.greenColor()
            series.area = true
            chartView.add(series)
            
            chartView.gridColor = ChartColors.yellowColor()
            chartView.labelColor = ChartColors.yellowColor()
            chartView.backgroundColor = ChartColors.purpleColor()
        }
    }


   //MARK: FRC Delegation

extension CalorieTrackerTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else{return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .delete:
            guard let indexPath = indexPath else{return}
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else{return}
            tableView.moveRow(at: indexPath, to: newIndexPath)
            
        case .update:
            guard let indexPath = indexPath else{return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        @unknown default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let sectionSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(sectionSet, with: .automatic)
            
        case .delete:
            tableView.deleteSections(sectionSet, with: .automatic)
            
        default: return
        }
        
    }
    
}


extension Notification.Name {
    static let calorieIntakeAdded = Notification.Name(PropertyKeys.caloriesAdded)
}

extension NotificationCenter {
    func postOnMainThread(name: NSNotification.Name, object: Any?) {
        DispatchQueue.main.async {
            NotificationCenter.self.default.post(name: name, object: nil)
        }
    }
}
