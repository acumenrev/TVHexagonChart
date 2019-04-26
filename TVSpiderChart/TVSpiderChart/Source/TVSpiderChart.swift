//
//  TVSpiderChart.swift
//  TVSpiderChart
//
//  Created by Tri Vo on 4/20/19.
//  Copyright © 2019 Tri Vo. All rights reserved.
//

import UIKit

protocol TVSpiderChartDelegate : class {
    /*
     func colorOfLineForRadarChart(_ radarChart: TKRadarChart) -> UIColor
     func colorOfFillStepForRadarChart(_ radarChart: TKRadarChart, step: Int) -> UIColor
     
     func colorOfSectionFillForRadarChart(_ radarChart: TKRadarChart, section: Int) -> UIColor
     func colorOfSectionBorderForRadarChart(_ radarChart: TKRadarChart, section: Int) -> UIColor
     
     func fontOfTitleForRadarChart(_ radarChart: TKRadarChart) -> UIFont
     func colorOfTitleForRadarChart(_ radarChart: TKRadarChart) -> UIColor
     */
}

protocol TVSpiderChartDataSource : class {
    /*
    func numberOfStepForRadarChart(_ radarChart: TKRadarChart) -> Int
    func numberOfRowForRadarChart(_ radarChart: TKRadarChart) -> Int
    func numberOfSectionForRadarChart(_ radarChart: TKRadarChart) -> Int
    
    func titleOfRowForRadarChart(_ radarChart: TKRadarChart, row: Int) -> String
    func valueOfSectionForRadarChart(withRow row: Int, section: Int) -> CGFloat
 */
    
    func numberOfSectionsForSpiderChart(_ chart : TVSpiderChart) -> Int
    
    func numberOfRowsForSpiderChart(_ chart : TVSpiderChart) -> Int
    
    func numberOfStepsForSpiderChart(_ chart : TVSpiderChart) -> Int
    
}

struct TVSpiderChartConfiguration {
    
    public var radius: CGFloat
    public var minValue: CGFloat
    public var maxValue: CGFloat
    
    public var borderWidth: CGFloat
    public var lineWidth: CGFloat
    
    public var showPoint: Bool
    public var showBorder: Bool
    public var showBackgroundLine: Bool
    public var showBackgroundBorder: Bool
    public var fillArea: Bool
    public var clockwise: Bool
    public var autoCenterPoint: Bool

    
    static func defaultConfig() -> TVSpiderChartConfiguration {
        return TVSpiderChartConfiguration.init()
    }
    
    init() {
        self.radius = 80.0
        self.minValue = 0
        self.maxValue = 5
        self.borderWidth = 4.0
        self.lineWidth = 1.0
        self.showPoint = false
        self.showBorder = false
        self.showBackgroundLine = true
        self.showBackgroundBorder = true
        self.fillArea = true
        self.clockwise = false
        self.autoCenterPoint = true
    }
    
    init(radius : CGFloat, minValue : CGFloat, maxValue : CGFloat, borderWidth : CGFloat, lineWidth : CGFloat, showPoint : Bool, showBorder : Bool, showBackgroundLine : Bool, showBackgroundBorder : Bool, fillArea : Bool, clockwise : Bool, autoCenterPoint : Bool) {
        self.radius = radius
        self.minValue = minValue
        self.maxValue = maxValue
        self.borderWidth = borderWidth
        self.lineWidth = lineWidth
        self.showPoint = showPoint
        self.showBorder = showBorder
        self.showBackgroundLine = showBackgroundLine
        self.showBackgroundBorder = showBackgroundBorder
        self.fillArea = fillArea
        self.clockwise = clockwise
        self.autoCenterPoint = autoCenterPoint
    }
}

class TVSpiderChart: UIView {

    public weak var dataSource : TVSpiderChartDataSource?
    public weak var delegate : TVSpiderChartDelegate?
    public var centerPoint : CGPoint = CGPoint.zero
    
    public var configuration : TVSpiderChartConfiguration {
        didSet {
            reload()
        }
    }
    
    override var frame: CGRect {
        didSet {
            if configuration.autoCenterPoint {
                centerPoint = CGPoint.init(x: frame.width/2, y: frame.height/2)
            }
            
            if min(frame.width, frame.height) < configuration.radius*2 {
                configuration.radius = min(frame.width, frame.height)/2
            }
            
            reload()
        }
    }
    
    override convenience init(frame: CGRect) {
        self.init(rect: frame, config: TVSpiderChartConfiguration.defaultConfig())
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        configuration = TVSpiderChartConfiguration.defaultConfig()
        super.init(coder: aDecoder)
        
    }
    
    init(rect : CGRect, config : TVSpiderChartConfiguration) {
        self.configuration = config
        super.init(frame: rect)
    }
    
    
    /// Re-render the spider chart
    func reload() {
        setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = .red
        /// Get current graphic context and datasource
//        guard let ds = dataSource, let currentContext = UIGraphicsGetCurrentContext() else {
//            return
//        }
        guard let currentContext = UIGraphicsGetCurrentContext() else { return }
        
        
        /// Draw titles
        self.drawTitles(frame: rect, context: currentContext)
        
        
        /// draw background
        self.drawBackgroundRectangles(context: currentContext)
        
        /// draw background lines
        self.drawBackgroundLines(context: currentContext)
        
        /// draw sections
        self.drawSections(context: currentContext)
        
    }
    
    private func drawTitles(frame : CGRect, context : CGContext) {
//        guard let ds = dataSource else { return }
        let numberOfRows = 5
        
        let titleColor = UIColor.black
        
        let radius = configuration.radius
        let perAngle = CGFloat.pi * 2 / CGFloat(numberOfRows) * CGFloat(configuration.clockwise ? 1 : -1)
        let padding : CGFloat = 2.0
        let textFont = UIFont.boldSystemFont(ofSize: 12)
        let height = textFont.lineHeight
        
        for i in 0..<numberOfRows {
            let title = "\(i)"
            let index = CGFloat(i)
            let pointOnEdge = CGPoint.init(x: centerPoint.x - radius*sin(index*perAngle), y: centerPoint.y - radius*cos(index*perAngle))
            
            let attributeTextSize = (title as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
            
            let width = attributeTextSize.width
            let xOffset = pointOnEdge.x >= centerPoint.x ? (width/2.0 + padding) : (-width/2.0 - padding)
            let yOffset = pointOnEdge.y >= centerPoint.y ? (height/2.0 + padding) : (-height/2.0 - padding)
            var legendCenter = CGPoint.init(x: pointOnEdge.x + xOffset, y: pointOnEdge.y + yOffset)
            
            let paragraphStyle = NSMutableParagraphStyle.init()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byClipping
            let atts = [NSAttributedString.Key.font : textFont,
                        NSAttributedString.Key.paragraphStyle : paragraphStyle,
                        NSAttributedString.Key.foregroundColor : titleColor]
            
            if index == 0 ||
                (numberOfRows%2 == 0 && i == numberOfRows%2) {
                legendCenter.x = centerPoint.x
                legendCenter.y = centerPoint.y + (radius + padding + height/2.0) * CGFloat(i == 0 ? -1 : 1)
            }
            
            let rect = CGRect.init(x: (legendCenter.x - width)/2.0, y: (legendCenter.y - height/2.0), width: width, height: height)
            (title as NSString).draw(in: rect, withAttributes: atts)
        }
        
        context.saveGState()
    }
    
    
    /// Draw background rectangles
    ///
    /// - Parameters:
    ///   - rect: CGRect
    ///   - context: CGContext
    private func drawBackgroundRectangles(context : CGContext) {
        
        let numberOfSteps = 5
        let numberOfRows = 5
        let lineColor = UIColor.blue
        let perAngle = CGFloat.pi * 2 / CGFloat(numberOfRows) * CGFloat(configuration.clockwise ? 1 : -1)
        lineColor.setStroke()
        
        let radius = configuration.radius
        
        for stepIndex in 1...numberOfSteps {
            let step = numberOfSteps - stepIndex + 1
            let fillColor = UIColor.yellow
            let scale = CGFloat(step)/CGFloat(numberOfSteps)
            let innerRadus = scale*radius
            
            let path = UIBezierPath()
            for index in 0...numberOfRows {
                let i = CGFloat(index)
                var x = centerPoint.x
                var y = centerPoint.y - innerRadus
                if index == 0 {
                    path.move(to: CGPoint.init(x: x, y: y))
                } else if index == numberOfRows {
                    path.addLine(to: CGPoint.init(x: x, y: y))
                } else {
                    x = centerPoint.x - innerRadus*sin(i*perAngle)
                    y = centerPoint.y - innerRadus*cos(i*perAngle)
                    path.addLine(to: CGPoint.init(x: x, y: y))
                }
            }
            
            
            path.close()
            fillColor.setFill()
            path.lineWidth = configuration.borderWidth
            path.fill()
            if configuration.showBorder {
                path.stroke()
            }
        }
        
        context.saveGState()
    }
    
    private func drawBackgroundLines(context : CGContext) {
        guard configuration.showBackgroundLine else { return }
        let numberOfRows = 5
        let perAngle = CGFloat.pi * 2 / CGFloat(numberOfRows) * CGFloat(configuration.clockwise ? 1 : -1)
        let radius = configuration.radius
        let lineColor = UIColor.blue
        
        lineColor.setStroke()
        for index in 0..<numberOfRows {
            let i = CGFloat(index)
            let path = UIBezierPath()
            path.move(to: centerPoint)
            let x = centerPoint.x - radius * sin(i * perAngle)
            let y = centerPoint.y - radius * cos(i * perAngle)
            path.addLine(to: CGPoint.init(x: x, y: y))
            path.lineWidth = configuration.lineWidth
            path.stroke()
        }
    }
    
    private func drawSections(context : CGContext) {
        let numberOfRows = 5
        let numberOfSections = 5
        let radius = configuration.radius
        let minValue = configuration.minValue
        let maxValue = configuration.maxValue
        let perAngle = CGFloat.pi * 2 / CGFloat(numberOfRows) * CGFloat(configuration.clockwise ? 1 : -1)
        
        for section in 0..<numberOfSections {
            let fillColor = UIColor.gray
            let borderColor = UIColor.green
            
            let path = UIBezierPath()
            for index in 0..<numberOfRows {
                let i = CGFloat(index)
                let value = i
                let scale = (value - minValue)/(maxValue - minValue)
                let innerRadius = scale * radius
                var x = centerPoint.x
                var y = centerPoint.y - innerRadius
                if index == 0 {
                    path.move(to: CGPoint.init(x: x, y: y))
                } else {
                    x = centerPoint.x - innerRadius * sin(i * perAngle)
                    y = centerPoint.y - innerRadius * cos(i * perAngle)
                    path.addLine(to: CGPoint.init(x: x, y: y))
                }
            }
            
            let value : CGFloat = 2.0
            let x = centerPoint.x
            let y = centerPoint.y - (value - minValue)/(maxValue - minValue)*radius
            path.addLine(to: CGPoint.init(x: x, y: y))
            
            fillColor.setFill()
            borderColor.setStroke()
            path.lineWidth = 2.0
            if configuration.fillArea {
                path.fill()
            }
            
            if configuration.showBorder {
                path.stroke()
            }

            self.drawPoints(context: context)
        }
    }
    
    private func drawPoints(context : CGContext) {
        guard configuration.showPoint else { return }
        let borderColor = UIColor.black
        let numberOfRows = 5
        let numberOfSections = 5
        let radius = configuration.radius
        let minValue = configuration.minValue
        let maxValue = configuration.maxValue
        let perAngle = CGFloat.pi * 2 / CGFloat(numberOfRows) * CGFloat(configuration.clockwise ? 1 : -1)
        
        for i in 0..<numberOfRows {
            let value = CGFloat(i)
            
            let xt = radius * sin(CGFloat(i) * perAngle)
            let yt = radius * cos(CGFloat(i) * perAngle)
            let xVal = centerPoint.x - (value - minValue)/(maxValue - minValue) * xt
            let yVal = centerPoint.y - (value - minValue)/(maxValue - minValue) * yt
            borderColor.setFill()
            context.fillEllipse(in: CGRect.init(x: xVal - 3, y: yVal - 3, width: 6, height: 6))
        }
        
    }
}

