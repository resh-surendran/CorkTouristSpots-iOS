//
//  XMLPlacesParser.swift
//  Cork Tourist Spots
//
//  Created by Reshma Surendran on 21/02/2019.
//  Copyright © 2019 UCC. All rights reserved.
//

import UIKit

class XMLPlacesParser: NSObject,XMLParserDelegate {
    
    var name : String
    
    init(name:String) {self.name = name }
    
    // vars to hold tag data
    var pName, pAddress, pDescription, pDistance, pImage1, pImage2, pImage3, pUrl, pBackground : String!
    
    // vars to spy during parsing
    var elementId = -1
    var passData = false
    
    // vars to manage whole data
    var place = Place()
    var places = [Place]()
    
    var parser = XMLParser()
    
    var tags = ["name", "address", "description", "distance", "image1", "image2", "image3", "url", "background"]
    
    // parser delegate methods
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        // Based on the spies grab some data into pVars
        if passData{
            switch elementId {
            case 0 : pName = string
            case 1 : pAddress = string
            case 2 : pDescription = string
            case 3 : pDistance = string
            case 4 : pImage1 = string
            case 5 : pImage2 = string
            case 6 : pImage3 = string
            case 7 : pUrl = string
            case 8 : pBackground = string
            default : break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        // if elementName is in tags then spy
        if tags.contains(elementName) {
            
            passData = true
            
            switch elementName {
                case "name"        : elementId = 0
                case "address"     : elementId = 1
                case "description" : elementId = 2
                case "distance"    : elementId = 3
                case "image1"      : elementId = 4
                case "image2"      : elementId = 5
                case "image3"      : elementId = 6
                case "url"         : elementId = 7
                case "background"  : elementId = 8
                default            : break
                
            }
        }
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        // reset the spies
        if tags.contains(elementName) {
            passData  = false
            elementId = -1
        }
        
        // if elementName is person then make a person and append to people
        if elementName == "place" {
            let pImages = [pImage1, pImage2, pImage3]
            place = Place(name: pName, address: pAddress, description: pDescription, distance: pDistance, images: pImages as! [String], url: pUrl, background: pBackground)
            places.append(place)
        }
    }
    
    func parsing() {
        
        // get the path of the xml file
        let bundleUrl = Bundle.main.bundleURL
        let fileUrl = URL(string: self.name, relativeTo: bundleUrl)
        
        // make a parser for this file
        parser = XMLParser(contentsOf: fileUrl!)!
        
        // give the delegate and parse
        parser.delegate = self
        parser.parse()
        
    }
}

