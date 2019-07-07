//
//  TouristPlaces.swift
//  Cork Tourist Spots
//
//  Created by Reshma Surendran on 21/02/2019.
//  Copyright © 2019 UCC. All rights reserved.
//

import Foundation

class TouristPlaces {
    
    // properties
    var placesData : [Place]!
    
    
    init(fromContentOfXML : String) {
        
        // make a XMLPeopleParser
        let parser = XMLPlacesParser(name: fromContentOfXML)
        
        // parsing
        parser.parsing()
        
        // set peopleData with what comes from parsing
        placesData = parser.places
        
    }
    
    // methods
    func count() -> Int {return placesData.count}
    func placeData(index:Int) -> Place {return placesData[index]}
    
    
}
