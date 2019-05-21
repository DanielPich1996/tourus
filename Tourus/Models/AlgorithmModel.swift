//
//  AlgorithmModel.swift
//  Tourus
//
//  Created by aliceka on 23/03/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//


import Foundation
import UIKit
import CoreLocation

class AlgorithmModel{
    private let minSupport = 0
    
    private let otherUsersHistoryData:[[String]] = [[String]()] //update every 30min time
    
    private var candidateSet:[String] = []
    
    private var refusingHistory: [String] = []
    
    private func updateHistoryData(){
        //30min time
    }
    
    private func updateCandidateSet(_ complition: @escaping ([String]?) -> Void){
        MainModel.instance.getCurrentUserHistory { [weak self] (currUserHistory) in
            if currUserHistory == nil{
                complition(nil)
            }
            else{
                self?.candidateSet = []
                
                for (type, rating) in currUserHistory!{
                    
                    if (Int(rating) > self!.minSupport){
                        self?.candidateSet.append(type)
                    }
                }
                
                complition(self?.candidateSet)
            }
        }
    }
    
    
    init() {
        candidateSet = []
        updateHistoryData()
    }
    
    func getAlgorithmNextPlace(_ location:String, _ callback: @escaping (Interaction) -> Void) {
        MainModel.instance.fetchNearbyPlaces(location: location, callback: { (places, err)  in
            if ((places == nil) || (places?.count == 0)){
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Lonley:'(", message: "Couldn't fetch any place around you...", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                    
                    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
                }
            }
            else{
                self.algorithmOrchestra(places!) { place in
                    MainModel.instance.getInteraction(place.types) { intereaction in
                        
                        intereaction!.place = place
                        
                        DispatchQueue.main.async {
                            callback(intereaction!)
                        }
                    }
                }
            }
        })
    }
    
    func algorithmOrchestra(_ places: [Place], _ callback: (Place) -> Void){
        let group = DispatchGroup()

        group.enter()
        updateCandidateSet { [weak self] (candidateSet) -> Void in
            if candidateSet != nil{
                self?.candidateSet = candidateSet!
            }
            group.leave()
        }
        
        group.wait()
        
        if candidateSet == []{
            callback(places.randomElement()!)
        }
        else{
            if let aprioriResults = choosePlace(places){
                let validPlaces = getValidPlacesByTypes(places, types: aprioriResults)
                
                if validPlaces.count > 0{
                    callback(validPlaces.randomElement()!)
                }
                else {
                    callback(places.randomElement()!)
                }
            }
            else{
                callback(places.randomElement()!)
            }
        }
    }
    
    private func getValidPlacesByTypes(_ places: [Place],types: [String]) -> [Place]{
        var validPlaces = [Place]()
        
        for place in places{
            for type in place.types!{
                if types.contains(type){
                    validPlaces.append(place)
                    
                    break
                }
            }
        }
        
        return validPlaces
    }
    
    private func loadFreqSet(_ availableUsersCategories:[[String]]) -> [String:Int] {
        var counter:Int = 0
        var frequencyTable:[String:Int] = [:]
        
        for i in 0..<candidateSet.count {
            counter = 0
            for j in 0..<availableUsersCategories.count {
                for q in 0..<availableUsersCategories[j].count {
                    if candidateSet[i] == availableUsersCategories[j][q] {
                        counter += 1
                    }
                }
            }
            
            frequencyTable[candidateSet[i]] = counter
            
        }
        
        return frequencyTable
    }
    
    //loadFreqSet()
    
    private func combineArray<T:Equatable>(data:[T]) -> [[T]] {
        var c:[[T]] = []
        
        for i in 0..<data.count {
            for j in i+1..<data.count {
                if data[i] != data[j] {
                    c.append([data[i],data[j]])
                }
            }
        }
        return c
    }
    
    private func getValidTypes(_ places:[Place]) -> [String]{
        var validTypes = [String]()
        
        for place in places{
            if place.types != nil{
                for type in place.types!{
                    if (!validTypes.contains(type)){
                        validTypes.append(type)
                    }
                }
            }
        }

        return validTypes
    }
    
    private func getRelevantHistory(_ places:[Place]) ->  [[String]] {
        var data:[[String]] = [[String]]()
        let validTypes = getValidTypes(places)
        let group = DispatchGroup()

        group.enter()
        MainModel.instance.getAllUsersHistory { [weak self] (preferenceDict) in
            for i in 0..<preferenceDict.count{
                var newUserPref = [String]()
                
                for (type, rating) in preferenceDict[i]{
                    if((self!.minSupport < Int(rating)) && validTypes.contains(type)){
                        newUserPref.append(type)
                    }
                }
                
                if (newUserPref != []){
                    data.append(newUserPref)
                }
            }
            
            group.leave()
        }
        
        group.wait()
        return data
    }
    
    //Algo
    func choosePlace(_ places: [Place]) -> [String]? {
        var data:[[String]] = [[String]]()
        var frequencyTable:[String:Int] = [:]
        
        //initialize data by places array from Baruch
        data = getRelevantHistory(places)
        
        //Initialize FreqSet
        frequencyTable = loadFreqSet(data)
        
        
        var newFreqTable:[String:Int] = frequencyTable
        
        for (key,value) in newFreqTable {
            if value < minSupport {
                newFreqTable.removeValue(forKey: key)
            }
        }
        
        let fqTable:[String] = Array(newFreqTable.keys)
        var genereteTable = [[String]](repeating: [], count: newFreqTable.count)
        genereteTable = combineArray(data: fqTable)
        var lastFreqCounts:[Int] = [Int](repeating: 0, count: genereteTable.count)
        print(genereteTable)
        
        for i in 0..<data.count {
            for w in 0..<genereteTable.count {
                for r in 0..<genereteTable[w].count - 1 {
                    if data[i].contains(genereteTable[w][r]) && data[i].contains(genereteTable[w][r + 1])  {
                        print("\(i) -> \(genereteTable[w][r]),\(genereteTable[w][r + 1])")
                        lastFreqCounts[w] += 1
                    }
                }
            }
        }
        print(lastFreqCounts)
        
        if lastFreqCounts.count == 0{
            return nil
        }
        
        return genereteTable[lastFreqCounts.index(of: lastFreqCounts.max()!)!]
    }
    
    
    
    func GroupInteractionsByUser(_ currUserLocation:CLLocation, _ callback: @escaping ([String:[InteractionStory]]) -> Void) {
        MainModel.instance.getInteractionsStories(currUserLocation, {(interactios:[InteractionStory]) in
            var interactionsByUser = [String:[InteractionStory]]()
            
            if interactios.count > 0 {
                for story in interactios {
                    if interactionsByUser[story.userID] == nil {
                        interactionsByUser[story.userID] = [InteractionStory]()
                    }
                    
                    interactionsByUser[story.userID]?.append(story)
                }
            }
            
            callback(interactionsByUser)
        })
    }
    
    
    
}





