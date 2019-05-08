//
//  GraphView.swift
//  Tourus
//
//  Created by admin on 23/04/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit

private struct Constants {
    static let maxGraphPoints = 10
    static let maxDegree = 360
    static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
    static let margin: CGFloat = 25.0
    static let topBorder: CGFloat = 35.0
    static let bottomBorder: CGFloat = 25
    static let colorAlpha: CGFloat = 0.3
    static let circleDiameter: CGFloat = 10.0
}

class GraphData {
    var name:String = ""
    var value:Int = 0
    var lat:Double = 0.0
    var long:Double = 0.0
    var isPopulate:Bool = false
    
    init() {
        
    }
    
    init(_place:Place, _value:Int) {
        setData(_place: _place, _value: _value)
    }
    
    func setData(_place:Place, _value:Int) {
        name = _place.name
        value = _value
        lat = _place.location?.lat ?? 0
        long = _place.location?.lng ?? 0
        isPopulate = true
    }
}

@IBDesignable class GraphView: UIView {
    var data = [GraphData]()
    
    @IBInspectable var startColor: UIColor = .clear
    @IBInspectable var endColor: UIColor = .clear
    
    //managing the data array as a queue - first in last out
    func addData(_ place:Place) {
        
        if data.count >= Constants.maxGraphPoints {
            data.removeFirst()
        }
        
        if let iterator = data.last {
            let lat1 = iterator.lat
            let long1 = iterator.long
            let lat2 = place.location?.lat ?? 0
            let long2 = place.location?.lng ?? 0
            
            
            let degree = getBearingBetweenTwoPoints(lat1: lat1, long1: long1, lat2: lat2, long2: long2)
            
            if iterator.value == 0 {
                iterator.value = Int(degree)
            }
            
            data.append(GraphData(_place: place, _value: Int(degree)))
        }
        else {
             data.append(GraphData(_place: place, _value: 0))
        }
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        //set points if no exist
        if data.count == 0 {
            for _ in 0..<Constants.maxGraphPoints {
                data.append(GraphData())
            }
        }
        
        //draw graph only when there are more then 1 point - just to be sure
        if data.count > 1 {
            let width = rect.width
            let height = rect.height
            
            backgroundColor = .clear
            
            //calculate the x point
            let margin = Constants.margin
            let graphWidth = width - margin * 2 - 4
            let columnXPoint = { (column: Int) -> CGFloat in
                //Calculate the gap between points
                let spacing = graphWidth / CGFloat(self.data.count - 1)
                return CGFloat(column) * spacing + margin + 2
            }
            
            // calculate the y point
            let topBorder = Constants.topBorder
            let bottomBorder = Constants.bottomBorder
            let graphHeight = height - topBorder - bottomBorder
            let columnYPoint = { (graphPoint: Int) -> CGFloat in
                let y = CGFloat(graphPoint) / CGFloat(Constants.maxDegree) * graphHeight
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
                point.x -= Constants.circleDiameter / 2
                point.y -= Constants.circleDiameter / 2
                
                let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)))
                
                if data[i].isPopulate {
                    if(i == data.count-1) { //the circle the selected one - paint as selected
                        UIColor.yellow.setFill()
                        UIColor.yellow.setStroke()
                        
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .center
                        
                        let attributes: [NSAttributedString.Key : Any] = [
                            .paragraphStyle: paragraphStyle,
                            .font: UIFont.systemFont(ofSize: 12.0),
                            .foregroundColor: UIColor.yellow
                        ]
                        
                        let myText = "You"
                        let attributedString = NSAttributedString(string: myText, attributes: attributes)
                        
                        
                        var newY = Constants.circleDiameter
                        
                        if(data.count-1 > i && data[i].value < data[i+1].value) {
                            newY = -Constants.circleDiameter-5
                        }
                        
                        let size = myText.count*10
                        point.x -= CGFloat(size/2)
                        point.y += newY
                        let stringRect = CGRect(origin: point, size: CGSize(width: size, height: 50))
                        attributedString.draw(in: stringRect)
                        
                    }
                    else { //the circle is not the selected one - paint as populate and not selected
                        UIColor.darkGray.setFill()
                        UIColor.whiteSmokeColor.setStroke()
                    }
                } else { //the circle is not populate with any information - paint as disabled
                    UIColor.whiteSmokeColor.setFill()
                    UIColor.whiteSmokeColor.setStroke()
                }
                
                circle.fill()
                circle.stroke()
            }
        }
    }
    
    func setBackColors() {
        
        //let path = UIBezierPath(roundedRect: rect,
        //                        byRoundingCorners: .allCorners,
        //                       cornerRadii: Constants.cornerRadiusSize)
        //path.addClip()
        
        // 2
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor]
        
        // 3
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 4
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        // 5
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        // 6
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [])
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

}

