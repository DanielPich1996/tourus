//
//  GraphView.swift
//  Tourus
//
//  Created by admin on 23/04/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    private var tapGesture:UITapGestureRecognizer? = nil
    private var data = [GraphData]()
    private var popTip:PopTip? = nil
    
    @IBInspectable var startColor: UIColor = .clear
    @IBInspectable var endColor: UIColor = .clear
    

    //managing the data array as a queue - first in last out
    func addData(_ story:InteractionStory) {
        
        if data.count >= consts.graph.maxGraphPoints {
            data.removeFirst()
        }
        
        if let iterator = data.last {
            let lat1 = iterator.lat
            let long1 = iterator.long
            let lat2 = story.userLocation.coordinate.latitude
            let long2 = story.userLocation.coordinate.longitude
            
            let degree = getBearingBetweenTwoPoints(lat1: lat1, long1: long1, lat2: lat2, long2: long2)
            data.append(GraphData(_story: story, _value: Int(degree)))
        }
        else {
             data.append(GraphData(_story: story, _value: consts.graph.maxDegree / 2))
        }
        
        setNeedsDisplay()
    }
    
    func overrideData(_ stories:[InteractionStory]) {
        //clear the data collection
        self.data.removeAll()
        //getting the first 10 stories and reverse the array
        let firstStories = stories.prefix(10).reversed()
        for story in firstStories {
            self.addData(story)
        }
    }
    
    override func draw(_ rect: CGRect) {
        initialize()
        
        //draw graph only when there are more then 1 point - just to be sure
        if data.count > 1 {
            let width = rect.width
            let height = rect.height
            backgroundColor = .clear
            popTip?.hide()
            
            //calculate the x point
            let margin = consts.graph.margin
            let graphWidth = width - margin * 2 - 4
            let columnXPoint = { (column: Int) -> CGFloat in
                //Calculate the gap between points
                let spacing = graphWidth / CGFloat(self.data.count - 1)
                return CGFloat(column) * spacing + margin + 2
            }
            
            // calculate the y point
            let topBorder = consts.graph.topBorder
            let bottomBorder = consts.graph.bottomBorder
            let graphHeight = height - topBorder - bottomBorder
            let columnYPoint = { (graphPoint: Int) -> CGFloat in
                let y = CGFloat(graphPoint) / CGFloat(consts.graph.maxDegree) * graphHeight
                return graphHeight + topBorder - y // Flip the graph
            }
            
            // draw the line graph
            UIColor.white.setFill()
            UIColor.white.setStroke()
            
            // set up the points line
            let graphPath = UIBezierPath()
            
            // go to start of line
            graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(data[0].value)))
            
            // add points for each item in the graphPoints array
            // at the correct (x, y) for the point
            for i in 1..<data.count {
                let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(data[i].value))
                graphPath.addLine(to: nextPoint)
            }
            graphPath.stroke()
            
            //Draw the circles on top of the graph stroke
            for i in 0..<data.count {
                
                var point = CGPoint(x: columnXPoint(i), y: columnYPoint(data[i].value))
                point.x -= consts.graph.circleDiameter / 2
                point.y -= consts.graph.circleDiameter / 2
                
                //a bigger circle for touch detection
                let backCircle = drawCircle(point, consts.graph.circleDiameter*2)
                //the actual circle
                let circle = drawCircle(point, consts.graph.circleDiameter)
                
                //update the shape and point in the data set
                data[i].shape = backCircle
                data[i].point = point
                
                if data[i].isPopulate {
                    if(i == data.count-1) { //the circle is the selected one - mark as selected
                        UIColor.lightBlueColor.setFill()
                    }
                    else { //the circle is not the selected one - paint as populate and not selected
                        UIColor.darkGray.setFill()
                    }
                } else { //the circle is not populate with any information - paint as disabled
                    UIColor.whiteSmokeColor.setFill()
                }
                
                UIColor.whiteSmokeColor.setStroke()
                circle.fill()
                circle.stroke()
            }
        }
    }
    
    @objc public func tapDetected(tapRecognizer:UITapGestureRecognizer){
        let tapLocation:CGPoint = tapRecognizer.location(in: self)
        self.hitTest(tapLocation: CGPoint(x: tapLocation.x, y: tapLocation.y))
    }
    
    var attributed:NSAttributedString? = nil
    private func hitTest(tapLocation:CGPoint) {
        
        for dataObj in data {
            
            if dataObj.isPopulate && dataObj.shape != nil && dataObj.shape!.contains(tapLocation) {
                
                let rect = CGRect(origin: dataObj.point!, size: CGSize(width: consts.graph.circleDiameter, height: consts.graph.circleDiameter))
                let attributedPopText = getAttributedPopText(dataObj)
                
                popTip?.show(attributedText: attributedPopText, direction: .down, maxWidth: 200, in: self, from: rect, duration: 30)
                
                break
            }
        }
    }
   
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    
    func getBearingBetweenTwoPoints(lat1:Double, long1:Double, lat2:Double, long2:Double) -> Double {
        
        let lat1 = degreesToRadians(degrees: lat1)
        let lon1 = degreesToRadians(degrees: long1)
        
        let lat2 = degreesToRadians(degrees: lat2)
        let lon2 = degreesToRadians(degrees: long2)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        var degrees = radiansToDegrees(radians: radiansBearing)
        degrees = (degrees + 360).truncatingRemainder(dividingBy: 360)

        return degrees
    }
    
    private func drawCircle(_ point:CGPoint, _ size:CGFloat) -> UIBezierPath {
        
        let rect = CGRect(origin: point, size: CGSize(width: size, height: size))
        let shape = UIBezierPath(ovalIn: rect)
        
        UIColor.clear.setFill()
        UIColor.clear.setStroke()
        shape.fill()
        shape.stroke()
        
        return shape
    }
    
    private func getAttributedPopText(_ data:GraphData) -> NSAttributedString{
        
        let subText = data.getSubText()
        let text = data.name + "\n" + subText
        
        let subTextCount = subText.count
        let mainTextCount = text.count - subTextCount
        
        let attributedString = NSMutableAttributedString(string: text)
        
        //first line - main text
        let paragraphStyle0 = NSMutableParagraphStyle()
        paragraphStyle0.alignment = .center
        let attributes0: [NSAttributedString.Key : Any] = [
            .font: UIFont(name: "HelveticaNeue", size: 13)!,
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle0
        ]
        attributedString.addAttributes(attributes0, range: NSRange(location: 0, length: mainTextCount))
        
        //sec line - sub text
        let paragraphStyle2 = NSMutableParagraphStyle()
        paragraphStyle2.alignment = .center
        let attributes2: [NSAttributedString.Key : Any] = [
            .font: UIFont(name: "HelveticaNeue", size: 10)!,
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle2
        ]
        attributedString.addAttributes(attributes2, range: NSRange(location: mainTextCount, length: subTextCount))
        
        return attributedString
    }
    
    private func initialize() {
        
        if popTip == nil {
            popTip = PopTip()
            popTip?.shouldDismissOnTap = true
            popTip?.shouldDismissOnTapOutside = true
            popTip?.shouldDismissOnSwipeOutside = true
            popTip?.edgeMargin = 5
            popTip?.offset = 2
            popTip?.edgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            popTip?.bubbleColor = .lightBlueColor
        }
        
        ///Catch layer by tap detection
        if tapGesture == nil {
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDetected(tapRecognizer:)))
            addGestureRecognizer(tapGesture!)
        }
        
        //set points if not exist
        if data.count == 0 {
            for _ in 0..<consts.graph.maxGraphPoints {
                data.append(GraphData())
            }
        }
    }
    
    
    class GraphData {
        var name:String = ""
        var date:Date? = nil
        var value:Int = consts.graph.maxDegree / 2
        var lat:Double = 0.0
        var long:Double = 0.0
        var isPopulate:Bool = false
        var shape:UIBezierPath? = nil
        var point:CGPoint? = nil
        
        init() {
            
        }
        
        init(_story:InteractionStory, _value:Int) {
            setData(_story: _story, _value: _value)
        }
        
        func setData(_story:InteractionStory, _value:Int) {
            name = _story.placeNmae ?? ""
            date = _story.date
            value = _value
            lat = _story.userLocation.coordinate.latitude
            long = _story.userLocation.coordinate.longitude
            isPopulate = true
        }
        
        func getSubText() -> String {
            if let date = date {
                let now = Date()
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.day, .weekOfMonth, .hour, .minute]
                formatter.unitsStyle = .full
                return formatter.string(from: date, to: now)! + " ago"
            }
            
            return ""
        }
    }
}
