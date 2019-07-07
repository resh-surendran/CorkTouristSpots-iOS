//
//  Place.swift
//  Cork Tourist Spots
//
//  Created by Reshma Surendran on 21/02/2019.
//  Copyright © 2019 UCC. All rights reserved.
//

import Foundation

class Place
{
    // properties
    var name : String
    var address : String
    var description : String
    var distance : String
    var images : [String]
    var url : String
    var background : String
    
    // initialisers
    init() {
        
        self.name        = "John Doe"
        self.address     = "no known address"
        self.description = "no description"
        self.distance    = "none"
        self.images      = []
        self.url         = "none"
        self.background  = "none"
        
    }
    
    init(name:String, address:String, description:String, distance:String, images:[String], url:String, background:String) {
        
        self.name        = name
        self.address     = address
        self.description = description
        self.distance    = distance
        self.images      = images
        self.url         = url
        self.background  = background
    }
    
    // methods
    func setName(name:String) {self.name = name}
    func getName()->String {return self.name}
    
    func setAddress(address:String) {self.address = address}
    func getAddress()->String {return self.address}
    
    func setDescription(description:String) {self.description = description}
    func getDescription()->String {return self.description}
    
    func setImages(images:[String]) {self.images = images}
    func getImages()->[String] {return self.images}
    
    func setUrl(url:String) {self.url = url}
    func getUrl()->String {return self.url}
    
    func setBackground(background:String) {self.background = background}
    func getBackground()->String {return self.background}
    
}
