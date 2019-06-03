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
//    private let minSupport = 0
//
//    private let otherUsersHistoryData:[[String]] = [[String]()] //update every 30min time
//
//    private var candidateSet:[String] = []
//
//    private var refusingHistory: [String] = []
//
//    private func updateHistoryData(){
//        //30min time
//    }
    
    var interactionsByUser = [String:[InteractionStory]]()
    var lastUpdatedInteractionsDate:Date?
    var lastUpdatedPlace:CLLocation?
    var categories:[String:Double]? = nil
    var prferdCategories:[String]? = nil
    var lastUserInteractions:[InteractionStory]? = [InteractionStory]()
    
    
    // KNN weights constants
    private let distDeltaWeight = 0.8
    private let timeDeltaWeight = 1.9
    private let dayInWeekWeight = 1.0
    private let monthDeltaWeight = 1.2
    private let positiveCtgryWeight = 1.0
    private let negativeCtgryWeight = -0.7
    
    init() {
//        candidateSet = []
//        updateHistoryData()
    }
    
    func getAlgorithmNextPlace(_ location:CLLocation, _ lastInteraction:InteractionStory?, _ callback: @escaping (Interaction) -> Void) {
        if lastInteraction == nil {
            setCategories()
            //setPreferdCategories()
        }
        else{
            // TODO update grade for atrraction caregories
            lastUserInteractions?.append(lastInteraction!)
            for category in (lastInteraction?.categories)!{
                if categories![category] != nil {
                    categories![category] = (categories![category]! / 2)
                }
            }
        }
        
        GetCategoryByKnn(location) {
            var interactionToBack:Interaction? = nil
            var categoriesSortedByGrades = Array(self.categories!.sorted { $0.1 > $1.1 })
            
            while (interactionToBack == nil){
                let group = DispatchGroup()
                group.enter()
                
                self.getInteraction(category: categoriesSortedByGrades[0].key, location: location, {(interaction) in
                    
                    if (interaction != nil){
                        interactionToBack = interaction!
                    }else{
                        categoriesSortedByGrades = Array(self.categories!.sorted { $0.1 < $1.1 })
                    }
                    
                    group.leave()
                })
                
                group.wait()
            }
            print(interactionToBack?.place?.types!)
            callback(interactionToBack!)
        }
    }
    
    func GetCategoryByKnn(_ currUserLocation:CLLocation, _ callback: @escaping () -> Void){
        let currDate  = Date()
        let interval :Double =  (currDate.timeIntervalSince(lastUpdatedInteractionsDate ?? Date(timeIntervalSince1970: 0)) / 3600)
        let distance : Int
        
        if let loc = lastUpdatedPlace{
            distance = Int(loc.distance(from: currUserLocation))
        }else{
            distance = 5000
        }
        
        if (interval >= 1 || distance > 500){
            MainModel.instance.getInteractionsStories(currUserLocation, {(interactions:[InteractionStory]) in
                self.lastUpdatedPlace = currUserLocation
                self.lastUpdatedInteractionsDate = Date()
                self.interactionsByUser = self.GroupInteractionsByUser(interactions)
                self.knnAlgorithm(self.interactionsByUser, callback)
            })
        }
        else{
            callback()
        }
    }
    
    func knnAlgorithm(_ usersStory: [String:[InteractionStory]], _ callback: @escaping () -> Void){
        var categoryRankerCount = [String:Int]()
        
        for userData in usersStory{
            for userStory in userData.value{
                for category in userStory.categories{
                    let currAnswerWeight = userStory.answer == 1 ? positiveCtgryWeight : negativeCtgryWeight
                    let currDataGrade = (distanceGradeCalculator(distanceInMeters: userStory.distanceBetweenUsers ?? 5000,
                                                                 topGrade: 10, interestingKilometers: 5) * distDeltaWeight +
                        timeGradeCalculator(candidatesDate: userStory.date, topGrade: 10, interestingHourInterval: 6) * timeDeltaWeight +
                        dayInWeekGradeCalculator(candidatesDate: userStory.date, topGrade: 10, interestingDaysInterval: 6) * dayInWeekWeight +
                        monthGradeCalculator(candidatesDate: userStory.date, topGrade: 10, interestingMonthsInterval: 6) * monthDeltaWeight) * currAnswerWeight
                    
                    if (categories!.keys.contains(category)){
                        if(categories![category]! == 0){
                            categoryRankerCount[category] = 1
                        }
                        else{
                            categoryRankerCount[category]! += 1
                        }
                        
                        categories![category]! += currDataGrade
                    }
                }
            }
        }
        
        for category in categoryRankerCount.keys{
            categories![category] = categories![category]! / Double(categoryRankerCount[category]!)
        }
        
        callback()
    }
    
    func distanceGradeCalculator(distanceInMeters: Int, topGrade: Int, interestingKilometers: Double) -> Double{
        if distanceInMeters > 5000{
            return 0
        }
        
        return (Double(topGrade) - ((Double(distanceInMeters)/(interestingKilometers * 1000)) * Double(topGrade)))
    }
    
    func timeGradeCalculator(candidatesDate: Date, topGrade: Int, interestingHourInterval: Int) -> Double{
        let candidateHour = Calendar.current.component(.hour, from: candidatesDate)
        let currHour = Calendar.current.component(.hour, from: Date())
        
        return(Double(topGrade) - (Double(abs(candidateHour - currHour))/Double(interestingHourInterval)) * Double(topGrade))
    }
    
    func dayInWeekGradeCalculator(candidatesDate: Date, topGrade: Int, interestingDaysInterval: Int) -> Double{
        let candidateDay = Calendar.current.component(.weekday, from: candidatesDate)
        let currDay = Calendar.current.component(.weekday, from: Date())
        let dayDelta = abs(currDay - candidateDay)
        
        return(Double(topGrade) - (Double(dayDelta)/Double(interestingDaysInterval)) * Double(topGrade))
    }
    
    func monthGradeCalculator(candidatesDate: Date, topGrade: Int, interestingMonthsInterval: Int) -> Double{
        let candidateMonth = Calendar.current.component(.month, from: candidatesDate)
        let currMonth = Calendar.current.component(.month, from: Date())
        var monthDelta = abs(currMonth - candidateMonth)
        
        if (monthDelta > 6){
            monthDelta = 12 - monthDelta
        }
        
        return(Double(topGrade) - (Double(monthDelta)/Double(interestingMonthsInterval)) * Double(topGrade))
    }
    
    func getInteraction(category:String, location:CLLocation, _ callback: @escaping (Interaction?) -> Void) -> Void {
        MainModel.instance.fetchNearbyPlaces(location: location, radius: 2000, type: category, isOpen: true){(places, token, err) in
            if err == nil{
                
                var validPlaces = self.validPlacesByCategory(category: category, places:places!)
                validPlaces = self.removePlacesByInteractions(places: places!)
                
                if validPlaces.count >= 1 {
                    
                    let placeToInteraction = validPlaces.randomElement()
                    
                    MainModel.instance.getInteraction(placeToInteraction!.types) { intereaction in
                        if intereaction != nil {
                            intereaction!.place = placeToInteraction!
                            
                            callback(intereaction)
                        }
                        else{
                            callback(nil)
                        }
                    }
                }else{
                    self.categories?.removeValue(forKey: category)
                    callback(nil)
                }
            }else{
                callback(nil)
            }
        }
    }
    
    func GroupInteractionsByUser(_ interactions:[InteractionStory]) ->[String:[InteractionStory]] {
        
        var interactionsByUser = [String:[InteractionStory]]()
        
        if interactions.count > 0 {
            for story in interactions {
                if interactionsByUser[story.userID] == nil {
                    interactionsByUser[story.userID] = [InteractionStory]()
                }
                
                interactionsByUser[story.userID]?.append(story)
            }
        }
        
        let currUserId = MainModel.instance.currentUser()?.uid
        if (interactionsByUser[currUserId!] != nil){
            for interaction in interactionsByUser[currUserId!]!{
                let interval = -interaction.date.timeIntervalSinceNow
                if (interval < 60*60*24) {
                    lastUserInteractions?.append(interaction)
                }
            }
        }
        
        return(interactionsByUser)
    }
    
    func setCategories(){
        let group = DispatchGroup()
        group.enter()
        
        MainModel.instance.getAllCategories(){(_categories) in
            self.categories = [String:Double]()
            for cat in _categories{
                self.categories![cat] = 0
            }
            group.leave()
        }
        
        group.wait()
    }
    
    func setPreferdCategories() {
        let group = DispatchGroup()
        group.enter()
        
        MainModel.instance.getCurrentUserPreferences(){(_preferdCategories) in
            if _preferdCategories.count > 10  {
                self.prferdCategories?.append(contentsOf: _preferdCategories)
            }
            group.leave()
        }
        group.wait()
    }
    
    func removePlacesByInteractions(places:[Place]) -> [Place] {
        var placesToReturn = [Place]()
        
        for place in places{
            var ifAppend = true
            
            for interaction in lastUserInteractions!{
                if interaction.placeID == place.googleID{
                    ifAppend = false
                    break
                }
            }
            
            if ifAppend{
                placesToReturn.append(place)
            }
        }
        
        return (placesToReturn)
    }
    
    func validPlacesByCategory(category:String, places:[Place]) -> [Place] {
        var placesToReturn =  [Place]()
        for place in places{
            if place.types!.contains(category){
                placesToReturn.append(place)
            }
        }
        return placesToReturn
    }
    
//    private func updateCandidateSet(_ complition: @escaping ([String]?) -> Void){
//        MainModel.instance.getCurrentUserHistory { [weak self] (currUserHistory) in
//            if currUserHistory == nil{
//                complition(nil)
//            }
//            else{
//                self?.candidateSet = []
//
//                for (type, rating) in currUserHistory!{
//
//                    if (Int(rating) > self!.minSupport){
//                        self?.candidateSet.append(type)
//                    }
//                }
//
//                complition(self?.candidateSet)
//            }
//        }
//    }
//
//    func getAlgorithmNextPlace(_ location:CLLocation, _ lastInteraction:InteractionStory?, _ callback: @escaping (Interaction) -> Void) {
//        MainModel.instance.fetchNearbyPlaces(location: location, callback: { (places, err)  in
//            if ((places == nil) || (places?.count == 0)){
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Lonley:'(", message: "Couldn't fetch any place around you...", preferredStyle: UIAlertController.Style.alert)
//                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
//
//                    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
//                }
//            }
//            else{
//                MainModel.instance.getAllCategories({(categories) in
//                    if categories.count > 10
//                    {
//                        var filteredPlaces = self.getValidPlacesByTypes(places!, types: categories)
//
//                        self.algorithmOrchestra(location, filteredPlaces) { place in
//                            MainModel.instance.getInteraction(place.types) { intereaction in
//
//                                intereaction!.place = place
//
//                                DispatchQueue.main.async {
//                                    callback(intereaction!)
//                                }
//                            }
//                        }
//                    }
//                })
//            }
//        })
//    }
//
//    func algorithmOrchestra(_ currUserLocation:CLLocation, _ places: [Place], _ callback: @escaping (Place) -> Void){
//        let group = DispatchGroup()
//        var isKnn = false
//
//        group.enter()
//        updateCandidateSet { [weak self] (candidateSet) -> Void in
//            if candidateSet != nil{
//                self?.candidateSet = candidateSet!
//            }
//            group.leave()
//        }
//
//        group.wait()
//
//        if candidateSet == []{
//            callback(places.randomElement()!)
//        }
//        else{
//            group.enter()
//
//            GetCategoryByKnn(currUserLocation, {[weak self] (categories) in
//                if categories.count > 0 {
//                    isKnn = true
//
//                    let categoriesSortedByGrades = Array(categories.sorted { $0.1 < $1.1 })
//                    var validPlaces = [Place]()
//
//                    if categoriesSortedByGrades.endIndex > 5{
//                        validPlaces = self?.getValidPlacesByTypes(places, types: [categoriesSortedByGrades[0].key,
//                                                                                  categoriesSortedByGrades[1].key,
//                                                                                  categoriesSortedByGrades[2].key,
//                                                                                  categoriesSortedByGrades[3].key,
//                                                                                  categoriesSortedByGrades[4].key]) ?? [Place]()
//                    }
//                    else{
//                        var lessThanFiveCat = [String]()
//
//                        for cat in categoriesSortedByGrades{
//                            lessThanFiveCat.append(cat.key)
//                        }
//
//                        validPlaces = self?.getValidPlacesByTypes(places, types: lessThanFiveCat) ?? [Place]()
//                    }
//
//                    if validPlaces.count > 0{
//                        callback(validPlaces.randomElement()!)
//                    }
//                    else {
//                        callback(places.randomElement()!)
//                    }
//                }
//
//                group.leave()
//            })
//
//            group.wait()
//        }
//
//        if isKnn == false{
//            if let aprioriResults = choosePlace(places){
//                let validPlaces = getValidPlacesByTypes(places, types: aprioriResults)
//
//                if validPlaces.count > 0{
//                    callback(validPlaces.randomElement()!)
//                }
//                else {
//                    callback(places.randomElement()!)
//                }
//            }
//            else{
//                callback(places.randomElement()!)
//            }
//        }
//    }
//    
//    private func getValidPlacesByTypes(_ places: [Place],types: [String]) -> [Place]{
//        var validPlaces = [Place]()
//        
//        for place in places{
//            for type in place.types!{
//                if types.contains(type){
//                    validPlaces.append(place)
//                    
//                    break
//                }
//            }
//        }
//        
//        return validPlaces
//    }
//    
//    private func loadFreqSet(_ availableUsersCategories:[[String]]) -> [String:Int] {
//        var counter:Int = 0
//        var frequencyTable:[String:Int] = [:]
//        
//        for i in 0..<candidateSet.count {
//            counter = 0
//            for j in 0..<availableUsersCategories.count {
//                for q in 0..<availableUsersCategories[j].count {
//                    if candidateSet[i] == availableUsersCategories[j][q] {
//                        counter += 1
//                    }
//                }
//            }
//            
//            frequencyTable[candidateSet[i]] = counter
//            
//        }
//        
//        return frequencyTable
//    }
//    
//    //loadFreqSet()
//    
//    private func combineArray<T:Equatable>(data:[T]) -> [[T]] {
//        var c:[[T]] = []
//        
//        for i in 0..<data.count {
//            for j in i+1..<data.count {
//                if data[i] != data[j] {
//                    c.append([data[i],data[j]])
//                }
//            }
//        }
//        return c
//    }
//    
//    private func getValidTypes(_ places:[Place]) -> [String]{
//        var validTypes = [String]()
//        
//        for place in places{
//            if place.types != nil{
//                for type in place.types!{
//                    if (!validTypes.contains(type)){
//                        validTypes.append(type)
//                    }
//                }
//            }
//        }
//
//        return validTypes
//    }
//    
//    private func getRelevantHistory(_ places:[Place]) ->  [[String]] {
//        var data:[[String]] = [[String]]()
//        let validTypes = getValidTypes(places)
//        let group = DispatchGroup()
//
//        group.enter()
//        MainModel.instance.getAllUsersHistory { [weak self] (preferenceDict) in
//            for i in 0..<preferenceDict.count{
//                var newUserPref = [String]()
//                
//                for (type, rating) in preferenceDict[i]{
//                    if((self!.minSupport < Int(rating)) && validTypes.contains(type)){
//                        newUserPref.append(type)
//                    }
//                }
//                
//                if (newUserPref != []){
//                    data.append(newUserPref)
//                }
//            }
//            
//            group.leave()
//        }
//        
//        group.wait()
//        return data
//    }
//    
//    //Algo
//    func choosePlace(_ places: [Place]) -> [String]? {
//        var data:[[String]] = [[String]]()
//        var frequencyTable:[String:Int] = [:]
//        
//        //initialize data by places array from Baruch
//        data = getRelevantHistory(places)
//        
//        //Initialize FreqSet
//        frequencyTable = loadFreqSet(data)
//        
//        
//        var newFreqTable:[String:Int] = frequencyTable
//        
//        for (key,value) in newFreqTable {
//            if value < minSupport {
//                newFreqTable.removeValue(forKey: key)
//            }
//        }
//        
//        let fqTable:[String] = Array(newFreqTable.keys)
//        var genereteTable = [[String]](repeating: [], count: newFreqTable.count)
//        genereteTable = combineArray(data: fqTable)
//        var lastFreqCounts:[Int] = [Int](repeating: 0, count: genereteTable.count)
//        print(genereteTable)
//        
//        for i in 0..<data.count {
//            for w in 0..<genereteTable.count {
//                for r in 0..<genereteTable[w].count - 1 {
//                    if data[i].contains(genereteTable[w][r]) && data[i].contains(genereteTable[w][r + 1])  {
//                        print("\(i) -> \(genereteTable[w][r]),\(genereteTable[w][r + 1])")
//                        lastFreqCounts[w] += 1
//                    }
//                }
//            }
//        }
//        print(lastFreqCounts)
//        
//        if lastFreqCounts.count == 0{
//            return nil
//        }
//        
//        return genereteTable[lastFreqCounts.index(of: lastFreqCounts.max()!)!]
//    }
}
