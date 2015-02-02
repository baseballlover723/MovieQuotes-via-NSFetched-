//
//  MovieQuotesTableViewController.swift
//  MovieQuotes
//
//  Created by Philip Ross on 1/22/15.
//  Copyright (c) 2015 Philip Ross. All rights reserved.
//

import UIKit
import CoreData


class MovieQuotesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var movieQuoteCount : Int {
        return fetchedResultsController.sections![0].numberOfObjects
    }
    
    func getMovieQuoteAtIndexPath (indexPath: NSIndexPath) -> MovieQuote {
        return fetchedResultsController.objectAtIndexPath(indexPath) as MovieQuote
    }
    
    let movieQuoteCellIdentifier = "MovieQuoteCell"
    let noMovieQuotesCellIdentifier = "NoMovieQuoteCell"
    let showDetailSegueIdentifier = "ShowDetailSegue"
    let movieQuoteEntityName = "MovieQuote"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "showAddQuoteDialog")
        
//        movieQuotes.append(MovieQuote(quote: "I'll be back", movie: "The Terminator"))
//        movieQuotes.append(MovieQuote(quote: "Earmuffs", movie: "Old School"))
    }
  
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    
    func saveManagedObjectContext() {
        var error: NSError? = nil
        managedObjectContext!.save(&error)
        if error != nil {
            println("Unresolved Core Data error \(error?.userInfo)")
            abort()
        }
    }

    func showAddQuoteDialog() {
        //        println("you just pressed add quote")
        let alertController = UIAlertController(title: "Create a new movie quote", message: "", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Quote"
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Movie Title"
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            println("you pressed cancel")
        }
        let createQuoteAction = UIAlertAction(title: "create quote", style:UIAlertActionStyle.Default) { (action) -> Void in
            println("You pressed Create Quote")
            
            let quoteTextField = alertController.textFields![0] as UITextField
            let movieTextField = alertController.textFields![1] as UITextField
            let newMovieQuote = NSEntityDescription.insertNewObjectForEntityForName(self.movieQuoteEntityName, inManagedObjectContext: self.managedObjectContext!) as MovieQuote
            newMovieQuote.quote = quoteTextField.text
            newMovieQuote.movie = movieTextField.text
            newMovieQuote.lastTouchDate = NSDate()
            self.saveManagedObjectContext()
            
//            if (self.movieQuoteCount == 1) {
//                    self.tableView.reloadData()
//            } else {
//            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//            }
        }
        //        quoteTextField.text, movie: movieTextField.txt)
        
        alertController.addAction(cancelAction)
        alertController.addAction(createQuoteAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(movieQuoteCount, 1)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell;
        if movieQuoteCount == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(noMovieQuotesCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(movieQuoteCellIdentifier, forIndexPath: indexPath) as UITableViewCell
            let movieQuote = getMovieQuoteAtIndexPath(indexPath)
            cell.textLabel?.text = movieQuote.quote
            cell.detailTextLabel?.text = movieQuote.movie
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (movieQuoteCount != 0) {
        println("you just pressed on \(getMovieQuoteAtIndexPath(indexPath))")
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return movieQuoteCount > 0
    }

    override func setEditing(editing: Bool, animated: Bool) {
        if self.movieQuoteCount == 0 {
            super.setEditing(false, animated: animated)
        } else {
            super.setEditing(editing, animated: animated)
        }
    }
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
//        movieQuotes.removeAtIndex(indexPath.row)
        let movieQuoteToDelete = getMovieQuoteAtIndexPath(indexPath)
        managedObjectContext?.deleteObject(movieQuoteToDelete)
        
        saveManagedObjectContext()
//        
//        if movieQuoteCount == 0 {
//            tableView.reloadData()
//            setEditing(false, animated: true)
//        } else {
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        }
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("segue = \(segue.identifier)")
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
        if segue.identifier == showDetailSegueIdentifier{
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let movieQuote = getMovieQuoteAtIndexPath(indexPath)
                println("movie quote = \(movieQuote)")
                (segue.destinationViewController as MovieQuoteDetailViewController).movieQuote = movieQuote
                (segue.destinationViewController as MovieQuoteDetailViewController).managedObjectContext = managedObjectContext
            }
        }
    }

    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest(entityName: movieQuoteEntityName)
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "lastTouchDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if (self.movieQuoteCount == 1) {
                tableView.reloadData()
            } else {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
        case .Delete:
            if movieQuoteCount == 0 {
                tableView.reloadData()
                setEditing(false, animated: true)
            } else {
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    
}
