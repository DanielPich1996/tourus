//
//  AlgorithmModel.swift
//  Tourus
//
//  Created by aliceka on 23/03/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//


import Foundation

class AlgorithmModel{
    private let minSupport = 2
    
    private let otherUsersHistoryData:[[String]] = [[String]()] //update every 30min time
    //private let data:[[String]] = [["A","B","C"],["A","C"],["A","D"],["B","E","F"],["D","C","A"],["B","C","F"]]
    private var candidateSet:[String] = ["A","B","C","D","E","F"]//update after every question
    
    private var refusingHistory: [String] = []
    
    private func updateHistoryData(){
        //30min time
    }
    private func updateCandidateSet(){
        //30min time
    }
    
    init() {
        
        
        // MainModel.instance.currentUser()
        
        
        
        //init updateHistoryData
        
        //consts:
        //minUserCategory = 0
        //minOthersCategory = 1
        
        //user1:
        //q1 - coffee? -yes
        //q2 - food? -no
        
        //history:
        //-coffee: 1
        //-sleep: 2
        //-food: -1
        
        //user category > minUserCategory
        //candidateSet = ["coffee", "sleep"]
        
        //places:
        //p1- "food"
        //p2- "food"
        //p3- "coffee"
        //p1- "watch"
        
        //user2:
        //["food": 3, "tv": -2, "pizza": 1]
        //user3:
        //["food": -4, "sleep": 2, "tv": 1]
        
        //data = all users categories where category_value > minOthersCategory
        //data = [["food", "pizza"], ["sleep", "tv"]]
        //if data is empty - take Baruch's places categories as the data
        // if not empty and there is a place with preffered category - send place
        updateHistoryData()
    }
    
    //func algorithmOrchestra(_ )
    
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
    
    private func getRelevantHistory(_ places:[Place]) ->  [[String]] {
        let data:[[String]] = [[String]]()
        
        //TODO
        
        return data
    }
    
    //Algo
    func choosePlace(_ places: [Place]) -> [String] {
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
        return genereteTable[lastFreqCounts.index(of: lastFreqCounts.max()!)!]
    }
    //print(apriori(minSupport: 3)) // [A,C]
}





