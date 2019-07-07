//
//  AddEditViewController.swift
//  Cork Tourist Spots
//
//  Created by Reshma on 05/04/2019.
//  Copyright © 2019 UCC. All rights reserved.
//

import UIKit
import CoreData

class AddEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var pickedView : UIImageView!
    
    @IBAction func firstImageAction(_ sender: Any) {
        print("First image clicked")
        pickedView = firstImageView
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            // setup the picker
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .savedPhotosAlbum
            
            //present the picker
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func secondImageAction(_ sender: Any) {
        print("second image clicked")
        pickedView = secondImageView
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            // setup the picker
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .savedPhotosAlbum
            
            //present the picker
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func thirdImageAction(_ sender: Any) {
        print("Third image clicked")
        pickedView = thirdImageView
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            // setup the picker
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .savedPhotosAlbum
            
            //present the picker
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func backgroundImageAction(_ sender: Any) {
        print("Background image clicked")
        pickedView = backgroundImageView
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            // setup the picker
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .savedPhotosAlbum
            
            //present the picker
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if(placeManagedObject != nil){
            update()
        }
        else{
            add()
        }
        // Force navigation back to the TVC
        navigationController?.popViewController(animated: true)
    }
    
    //Core data objects context entity and managedobjects
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var entity : NSEntityDescription! = nil
    var placeManagedObject : Places! = nil
    
    // deal with image picking
    var imagePicker = UIImagePickerController()
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // get the image from info
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        //place into imageview
        pickedView.image = image
        
        // dismiss
        dismiss(animated: true, completion: nil)
        
    }
    
    func getDirectoryPath(fileManager : FileManager) -> NSURL {
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("CorkTouristSpotImages")
        if !fileManager.fileExists(atPath: path) {
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        let url = NSURL(string: path)
        return url!
    }
    
    func saveImage(imageName: String, image: UIImage) {
        // create the file manager
        let fileManager = FileManager.default

        // get the path to document
        let url = getDirectoryPath(fileManager: fileManager)
        
        // append name to path
        let imagePath = url.appendingPathComponent(imageName)
        let urlString: String = imagePath!.absoluteString
        let imageData = image.jpegData(compressionQuality: 0.5)
        //let imageData = UIImagePNGRepresentation(image)
        fileManager.createFile(atPath: urlString as String, contents: imageData, attributes: nil)

    }
    
    func populatePlaceManagedObject() -> Bool {
        //Fill it with the data from textfields
        let name = nameTextField.text
        
        if ((name?.isEmpty)! || (addressTextField.text?.isEmpty)! || (distanceTextField.text?.isEmpty)! || descriptionTextView.text.isEmpty || (urlTextField.text?.isEmpty)! || (backgroundImageView.image == nil) || (firstImageView.image == nil)) {
            let alert = UIAlertController(title: "All the fields are mandatory. Please enter data for every field.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            return false
        }
        placeManagedObject.name              = name
        placeManagedObject.address           = addressTextField.text
        placeManagedObject.distance          = distanceTextField.text
        placeManagedObject.place_description = descriptionTextView.text
        placeManagedObject.url               = urlTextField.text
        
        //save images to document and add the names to the fields of the managed object
        let name_slug = name?.lowercased().replacingOccurrences(of: " ", with: "_")
        var imagesString : String = ""
        var imageName : String = ""
        if (firstImageView.image != nil) {
            imageName = name_slug! + "_1.jpg"
            saveImage(imageName: imageName, image: firstImageView.image!)
            imagesString = imagesString + imageName
        }
        if (secondImageView.image != nil) {
            imageName = name_slug! + "_2.jpg"
            saveImage(imageName: imageName, image: secondImageView.image!)
            imagesString = imagesString + ";" + imageName
        }
        if (thirdImageView.image != nil) {
            imageName = name_slug! + "_3.jpg"
            saveImage(imageName: imageName, image: thirdImageView.image!)
            imagesString = imagesString + ";" + imageName
        }
        if (backgroundImageView.image != nil) {
            imageName = name_slug! + "_background.jpg"
            saveImage(imageName: imageName, image: backgroundImageView.image!)
            placeManagedObject.background_image = imageName
        }
        placeManagedObject.images = imagesString
        return true
    }
    
    func add() {
        //Make a new managed object
        placeManagedObject = Places(context: context)
        
        //Fill it with the data from textfields
        if (populatePlaceManagedObject() == false) {
            return
        }
        
        // Save
        do{
            try context.save()
        }
        catch{
            print(" Core Data DOES Not Save")
        }
    }
    
    func update()
    {
        //Save  placeManagedObject
        if (populatePlaceManagedObject() == false) {
            return
        }
        
        // Save
        do{
            try context.save()
        }
        catch{
            print(" Core Data DOES Not Save")
        }
    }
    
    func getImageFromDocumentDirectory(imageName: String) -> UIImage {
        let fileManager = FileManager.default
        
        let imagePath = (getDirectoryPath(fileManager: fileManager) as NSURL).appendingPathComponent(imageName)
        let urlString: String = imagePath!.absoluteString
        
        var image : UIImage!
        if fileManager.fileExists(atPath: urlString) {
            image = UIImage(contentsOfFile: urlString)!
        } else {
            print("Image \(imageName) not found in documents")
        }
        return image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("in view did load of add/edit view controller")
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "texture.jpeg")!)
        
        firstImageView.isUserInteractionEnabled = true
        secondImageView.isUserInteractionEnabled = true
        thirdImageView.isUserInteractionEnabled = true
        backgroundImageView.isUserInteractionEnabled = true
        
        firstImageView.backgroundColor = UIColor(patternImage: UIImage(named: "place_holder.png")!)
        secondImageView.backgroundColor = UIColor(patternImage: UIImage(named: "place_holder.png")!)
        thirdImageView.backgroundColor = UIColor(patternImage: UIImage(named: "place_holder.png")!)
        backgroundImageView.backgroundColor = UIColor(patternImage: UIImage(named: "background_placeholder.png")!)
        
        if (placeManagedObject != nil) {
            self.title = "Update " + placeManagedObject.name! + " Details"
            nameTextField.text = placeManagedObject.name
            addressTextField.text = placeManagedObject.address
            distanceTextField.text = placeManagedObject.distance
            descriptionTextView.text = placeManagedObject.place_description
            urlTextField.text = placeManagedObject.url
            if !((placeManagedObject.images?.isEmpty)!) {
                let images : [String] = placeManagedObject.images!.components(separatedBy: ";")
                firstImageView.image = getImageFromDocumentDirectory(imageName: images[0])
                if (images.indices.contains(1)) {
                    secondImageView.image = getImageFromDocumentDirectory(imageName: images[1])
                }
                if (images.indices.contains(2)) {
                    thirdImageView.image = getImageFromDocumentDirectory(imageName: images[2])
                }
                
            }
            backgroundImageView.image = getImageFromDocumentDirectory(imageName: placeManagedObject.background_image!)
        } else {
            self.title = "Add a new Place"
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
