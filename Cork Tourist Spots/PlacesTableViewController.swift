//
//  PlacesTableViewController.swift
//  Cork Tourist Spots
//
//  Created by Reshma Surendran on 21/02/2019.
//  Copyright © 2019 UCC. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class PlacesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, PlaceTableViewCellDelegate {

    var placesDetails : TouristPlaces!
    
    // core data objects
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var placeManagedObject : Places! = nil
    var entity : NSEntityDescription! = nil
    var frc : NSFetchedResultsController<NSFetchRequestResult>! = nil
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPlaces : NSFetchedResultsController<NSFetchRequestResult>! = nil
    var filterCategory : String!
    var filterValue : String!
    
    var searchFooter = SearchFooter()
    
    func makeRequest(filter : Bool) -> NSFetchRequest<NSFetchRequestResult> {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        
        let sorter = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sorter]
        
        // predicate is used for applying filters
        if (filter == true && filterCategory != nil && filterValue != nil) {
                let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", filterCategory, filterValue)
                request.predicate = predicate
        }
        
        return request
        
    }
    
    func getDirectoryPath() -> NSURL {
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("CorkTouristSpotImages")
        let url = NSURL(string: path)
        return url!
    }
    
    func copyImageToDocument(imageName : String) {
        let fileManager = FileManager.default
        
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard documentsUrl.count != 0 else {
            print("Could not find documents URL")
            return
        }
        
        let finalImageURL = getDirectoryPath().appendingPathComponent(imageName)
        let bundleURL = Bundle.main.resourceURL?.appendingPathComponent(imageName)
        do {
            try fileManager.copyItem(atPath: (bundleURL?.path)!, toPath: finalImageURL!.path)
        } catch let error as NSError {
                print("Couldn't copy file to final location! Error:\(error.description)")
        }
    }
    
    func populateTableFromXML() {
        // Read place objects from xml
        let placeDetails = TouristPlaces(fromContentOfXML: "places.xml")
        for place in placeDetails.placesData {
            placeManagedObject = Places(context: context)
            
            //Fill it with the data from textfields
            placeManagedObject.name    = place.name
            placeManagedObject.address = place.address
            placeManagedObject.distance = place.distance
            placeManagedObject.background_image = place.background
            placeManagedObject.place_description = place.description
            placeManagedObject.images = place.images.joined(separator: ";")
            placeManagedObject.url = place.url
            
            // Copy images to documents folder
            copyImageToDocument(imageName: place.background)
            for image in place.images {
                copyImageToDocument(imageName: image)
            }
            
            // Save to Core Data
            do{
                try context.save()
            }
            catch{
                print(" Core Data NOT SAVED")
            }
        }
    }
    
    override func viewDidLoad() {
        print("In view did load tableview")
        super.viewDidLoad()

        self.title = "Places to Visit in Cork"
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "texture.jpeg")!)
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Places"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Setup the Scope bar
        searchController.searchBar.scopeButtonTitles = ["Name", "Address"]
        searchController.searchBar.delegate = self
        
        let request = makeRequest(filter: false)
        var count = 0
        do {
            count = try context.count(for: request)
        } catch {
            print("Core Data count could not be fetched")
        }
        if (count == 0) {
            populateTableFromXML()
        }
        
        // prepare for fetching
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        
        do{
            try frc.performFetch()
        } catch {
            print("Core data CANNOT FETCH")
        }
        
        self.tableView.tableFooterView = searchFooter
        
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func getImageFromDocumentDirectory(imageName: String) -> UIImage {
        let fileManager = FileManager.default
        
        let imagePath = (self.getDirectoryPath() as NSURL).appendingPathComponent(imageName)
        let urlString: String = imagePath!.absoluteString
        
        var image : UIImage!
        if fileManager.fileExists(atPath: urlString) {
            image = UIImage(contentsOfFile: urlString)!
        } else {
            print("Image \(imageName) not found in documents")
        }
        return image
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let totalCount = frc.sections![section].numberOfObjects
        if isFiltering() {
            let filteredCount = filteredPlaces.sections![section].numberOfObjects
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredCount, of: totalCount)
            return filteredCount
        }
        searchFooter.setNotFiltering()
        return totalCount
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlaceTableViewCell

        // get from frc the indexPath object
        if isFiltering() {
            placeManagedObject = filteredPlaces.object(at: indexPath) as? Places
        } else {
            placeManagedObject = frc.object(at: indexPath) as? Places
        }
        // Configure the cell...
        cell.placeLabelOutlet.text = placeManagedObject.name
        cell.addressLabelOutlet.text = placeManagedObject.address
        if !((placeManagedObject.images?.isEmpty)!) {
            let images : [String] = placeManagedObject.images!.components(separatedBy: ";")
            cell.placeImageOutlet.image = getImageFromDocumentDirectory(imageName: images[0])
        }
        cell.delegate = self

        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("In prepare")
        if (segue.identifier == "tableSegue") {
            print("In first if")
            // Get the new view controller using segue.destination.
            let destination = segue.destination as! PlaceImagesViewController
            
            // Pass the selected object to the new view controller.
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
            
            if isFiltering() {
                placeManagedObject = filteredPlaces.object(at: indexPath!) as? Places
            } else {
                placeManagedObject = frc.object(at: indexPath!) as? Places
            }
            
            let images : [String] = placeManagedObject.images!.components(separatedBy: ";")
            let place = Place(name: placeManagedObject.name!, address: placeManagedObject.address!, description: placeManagedObject.place_description!, distance: placeManagedObject.distance!, images: images, url: placeManagedObject.url!, background: placeManagedObject.background_image!)
            
            destination.placeData = place
        }
        if (segue.identifier == "editPlaceSegue") {
            print("In prepare segue for edit")
            let destination = segue.destination as! AddEditViewController
            
            destination.placeManagedObject = placeManagedObject
        }
        
    }
    
    func placeTableViewCellDidTapEdit(_ sender: PlaceTableViewCell) {
        
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        
        if isFiltering() {
            placeManagedObject = filteredPlaces.object(at: tappedIndexPath) as? Places
        } else {
            placeManagedObject = frc.object(at: tappedIndexPath) as? Places
        }
        
    }
    
    func placeTableViewCellDidTapDelete(_ sender: PlaceTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        
        let alert = UIAlertController(title: "Are you sure you want to delete this place?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            if self.isFiltering() {
                self.placeManagedObject = self.filteredPlaces.object(at: tappedIndexPath) as? Places
            } else {
                self.placeManagedObject = self.frc.object(at: tappedIndexPath) as? Places
            }
            
            var images : [String] = []
            if !((self.placeManagedObject.images?.isEmpty)!) {
                images = self.placeManagedObject.images!.components(separatedBy: ";")
            }
            let backgroundImage = self.placeManagedObject.background_image
            
            // delete it from context
            self.context.delete(self.placeManagedObject)
            
            // save context
            do{
                try self.context.save()
            } catch {
                print("Core Data DOES NOT SAVE")
                return
            }
            
            // delete image files
            let dirPath = self.getDirectoryPath()
            let fileManager = FileManager.default
            
            if (images.count > 0) {
                for image in images {
                    let fullPath = dirPath.appendingPathComponent(image)
                    do {
                        try fileManager.removeItem(atPath: (fullPath?.absoluteString)!)
                    } catch let error as NSError {
                        print("Could not delete file: \(error)")
                    }
                }
            }
            // delete background image file
            let imagePath = dirPath.appendingPathComponent(backgroundImage!)
            do {
                try fileManager.removeItem(atPath: (imagePath?.absoluteString)!)
            } catch let error as NSError {
                print("Could not delete background image file: \(error)")
            }
            
            // fetch and reload
            do{
                try self.frc.performFetch()
            } catch {
                print("Core Data DOES NOT FETCH")
            }
            
            self.tableView.reloadData()

        }))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "name") {

        filterCategory = scope.lowercased()
        filterValue = searchText
        let request = makeRequest(filter: true)
        
        // prepare for fetching
        filteredPlaces = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        filteredPlaces.delegate = self
        
        do{
            try filteredPlaces.performFetch()
        } catch {
            print("Core data CANNOT FETCH")
        }
        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension PlacesTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension PlacesTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
