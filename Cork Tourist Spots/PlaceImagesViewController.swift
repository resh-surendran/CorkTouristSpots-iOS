//
//  PlaceImagesViewController.swift
//  Cork Tourist Spots
//
//  Created by Reshma Surendran on 21/02/2019.
//  Copyright © 2019 UCC. All rights reserved.
//

import UIKit

class PlaceImagesViewController: UIViewController, UIScrollViewDelegate {

    var placeData: Place!
    var slides : [ImageSlideView]!
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var imagesScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Images of \(placeData.name)"
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "texture.jpeg")!)
        
        placeNameLabel.text = placeData.name
        imagesScrollView.delegate = self

        // Do any additional setup after loading the view.
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
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
    
    func createSlides() -> 	[ImageSlideView] {
        var slides : [ImageSlideView] = []
        for i in 0 ..< placeData.images.count {
            let slide:ImageSlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! ImageSlideView
            slide.placeImageView.image = getImageFromDocumentDirectory(imageName: placeData.images[i])
            slides.append(slide)
        }
//
//        let slide2:ImageSlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! ImageSlideView
//        slide2.placeImageView.image = getImageFromDocumentDirectory(imageName: placeData.images[1])
//
//        let slide3:ImageSlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! ImageSlideView
//        slide3.placeImageView.image = getImageFromDocumentDirectory(imageName: placeData.images[2])
//
        return slides
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(imagesScrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)

        let maximumHorizontalOffset: CGFloat = imagesScrollView.contentSize.width - imagesScrollView.frame.width
        let currentHorizontalOffset: CGFloat = imagesScrollView.contentOffset.x

        // vertical
        let maximumVerticalOffset: CGFloat = imagesScrollView.contentSize.height - imagesScrollView.frame.height
        let currentVerticalOffset: CGFloat = imagesScrollView.contentOffset.y

        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset


//        /*
//         * below code scales the imageview on paging the scrollview
//         */
//        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
//
//        if(percentOffset.x > 0 && percentOffset.x <= 0.50) {
//
//            slides[0].placeImageView.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.50, y: (0.50-percentOffset.x)/0.50)
//            slides[1].placeImageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
//
//        } else if(percentOffset.x > 0.50 && percentOffset.x <= 1) {
//            slides[1].placeImageView.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.50, y: (1-percentOffset.x)/0.50)
//            slides[2].placeImageView.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
//        }
    }
    
    func setupSlideScrollView(slides : [ImageSlideView]) {
        imagesScrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(slides.count), height: 250)
        imagesScrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame.size.width = self.view.bounds.size.width
            slides[i].frame.origin.x = CGFloat(i) * self.view.bounds.size.width
            imagesScrollView.contentSize.width = imagesScrollView.bounds.width * CGFloat(i + 1)
            imagesScrollView.addSubview(slides[i])
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destination = segue.destination as! PlaceDetailsViewController
        
        // Pass the selected object to the new view controller.
        destination.placeData = self.placeData
        
    }
    

}
