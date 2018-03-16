//
//  ChartView.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 04.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class ChartView: UIView {
    
    // MARK: - Public Properites
    
    var data: [Double] = [] {
        didSet {
            let numberOfPoints = Int(bounds.width)
            points = [Double](repeating: 0.0, count: numberOfPoints)
            let k = Double(data.count) / Double(numberOfPoints)
            for i in 0..<numberOfPoints { points[i] = data[Int(Double(i) * k)] }
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let height = rect.height
        
        guard let minValue = points.min(), let maxValue = points.max() else { return }
        let columnYPoint = { (point: Double) -> CGFloat in
            let y = (CGFloat(point - minValue) / CGFloat(maxValue - minValue)) * height
            return height - y
        }
        
        Colors.controlEnabled.setFill()
        Colors.controlEnabled.setStroke()
        
        // Line
        
        let chartPath = UIBezierPath()
        chartPath.move(to: CGPoint(x: 0, y: columnYPoint(points[0])))
        
        for i in 1..<points.count - 1 {
            let nextPoint = CGPoint(x: CGFloat(i), y: columnYPoint(points[i]))
            chartPath.addLine(to: nextPoint)
        }
        
        chartPath.stroke()
        
        // Gradient
        
        let clippingPath = chartPath.copy() as! UIBezierPath
        
        clippingPath.addLine(to: CGPoint(x: CGFloat(points.count - 1), y: height))
        clippingPath.addLine(to: CGPoint(x: 0, y: height))
        clippingPath.close()
        clippingPath.addClip()
        
        let graphStartPoint = CGPoint(x: 0, y: 0)
        let graphEndPoint = CGPoint(x: 0, y: height)
        let context = UIGraphicsGetCurrentContext()!
        let colors = [Colors.controlDisabled.cgColor, UIColor.clear.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        context.drawLinearGradient(gradient, start: graphStartPoint, end: graphEndPoint, options: [])
    }
    
    // MARK: - Private Properties
    
    private var points: [Double] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
}
