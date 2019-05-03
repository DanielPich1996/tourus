//
//  GraphView.swift
//  Tourus
//
//  Created by admin on 23/04/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit

private struct Constants {
    static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
    static let margin: CGFloat = 20.0
    static let topBorder: CGFloat = 20
    static let bottomBorder: CGFloat = 10
    static let colorAlpha: CGFloat = 0.3
    static let circleDiameter: CGFloat = 10.0
}

@IBDesignable class GraphView: UIView {
    //Weekly sample data
    var graphPoints = [4, 2, 6, 4, 5, 6, 3,4,3,1]

    // 1
    @IBInspectable var startColor: UIColor = .clear
    @IBInspectable var endColor: UIColor = .clear
    
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        
        backgroundColor = .clear
        
        //calculate the x point
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
            //Calculate the gap between points
            let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
            return CGFloat(column) * spacing + margin + 2
        }
        
        // calculate the y point
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.max()!
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
            return graphHeight + topBorder - y // Flip the graph
        }

        
        // draw the line graph
        UIColor.white.setFill()
        UIColor.white.setStroke()
        
        // set up the points line
        let graphPath = UIBezierPath()
        
        // go to start of line
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(graphPoints[0])))
        
        // add points for each item in the graphPoints array
        // at the correct (x, y) for the point
        for i in 1..<graphPoints.count {
            let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        
        graphPath.stroke()
        
        
        
        //Draw the circles on top of the graph stroke
        for i in 0..<graphPoints.count {
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            point.x -= Constants.circleDiameter / 2
            point.y -= Constants.circleDiameter / 2
            
            let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)))
            
            
            
            if(i==3) {
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
                if(graphPoints.count-1 > i && graphPoints[i] > graphPoints[i+1]) {
                    newY = -Constants.circleDiameter-5
                }

                let size = myText.count*10
                point.x = point.x - CGFloat(size/2)
                point.y += newY
                let stringRect = CGRect(origin: point, size: CGSize(width: size, height: 50))
                attributedString.draw(in: stringRect)
                
            }
            else {
                UIColor.darkGray.setFill()
                UIColor.white.setStroke()
            }
            circle.fill()
            circle.stroke()
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
}

