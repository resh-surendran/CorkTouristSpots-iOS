//
//  PlaceDetailsViewController.swift
//  Cork Tourist Spots
//
//  Created by Reshma Surendran on 21/02/2019.
//  Copyright © 2019 UCC. All rights reserved.
//

import UIKit

class PlaceDetailsViewController: UIViewController {

    var placeData : Place!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var adrressLabel: UILabel!
//    @IBOutlet weak var distanceLabel: UILabel!
//    @IBOutlet weak var urlLabel: UILabel!
    
    @IBAction func webInfoAction(_ sender: Any) {
    }
    
    func getDirectoryPath() -> NSURL {
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("CorkTouristSpotImages")
        let url = NSURL(string: path)
        return url!
    }
    
    func getImageFromDocumentDirectory(imageName: String) -> UIImage {
        let fileManager = FileManager.default
        
        let imagePath = (getDirectoryPath() as NSURL).appendingPathComponent(imageName)
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

        // Do any additional setup after loading the view.
        self.title = "Some Info on \(placeData.name)"
        
        nameLabel.text = placeData.name
        descriptionLabel.text = placeData.description
        addressLabel.text = placeData.address
        distanceLabel.text = placeData.distance
        urlLabel.text = placeData.url
        
        //Setting background image for the view
        let background = getImageFromDocumentDirectory(imageName: placeData.background)
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.isOpaque = false
        imageView.alpha = 0.3
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destination = segue.destination as! WebViewController
        
        // Pass the selected object to the new view controller.
        destination.webData = self.placeData.url
    }
    

}
