//
//  TVSpiderChart.swift
//  TVSpiderChart
//
//  Created by Tri Vo on 4/20/19.
//  Copyright © 2019 Tri Vo. All rights reserved.
//

import UIKit

protocol TVSpiderChartDelegate : class {
    
    
    /// Color of Line for chart
    ///
    /// - Parameter chart: TVSpiderChart
    /// - Returns: UIColor
    func colorOfLineForChart(_ chart : TVSpiderChart) -> UIColor
    
    
    /// Color of Fill Step for chart
    ///
    /// - Parameter chart: TVSpiderChart
    /// - Returns: UIColor
    func colorOfFillStepForChart(_ chart : TVSpiderChart) -> UIColor
    
    
    /// Color of section fill for chart
    ///
    /// - Parameter chart: TVSpiderChart
    /// - Returns: UIColor
    func colorOfSectionFillForChart(_ chart : TVSpiderChart) -> UIColor
    
    
    /// Color of section border for chart
    ///
    /// - Parameter chart: TVSpiderChart
    /// - Returns: UIColor
    func colorOfSectionBorderForChart(_ chart : TVSpiderChart) -> UIColor
    
    
    /// Font of title for chart
    ///
    /// - Parameter chart: TVSpiderChart
    /// - Returns: UIFont
    func fontOfTitleForChart(_ chart : TVSpiderChart) -> UIFont
    
    
    /// Color of title for chart
    ///
    /// - Parameter chart: TVSpiderChart
    /// - Returns: UIColor
    func colorOfTileForChart(_ chart : TVSpiderChart) -> UIColor
}


// MARK: - Default implementation of TVSpiderChartDelegate
extension TVSpiderChartDelegate {
    
    
    public func colorOfLineForChart(_ chart: TVSpiderChart) -> UIColor {
        return UIColor.yellow
    }
    
    public func colorOfFillStepForChart(_ chart: TVSpiderChart) -> UIColor {
        return UIColor.blue
    }
    
    public func colorOfSectionFillForChart(_ chart: TVSpiderChart) -> UIColor {
        return UIColor.green
    }
    
    public func colorOfSectionBorderForChart(_ chart: TVSpiderChart) -> UIColor {
        return UIColor.brown
    }
    
    public func fontOfTitleForChart(_ chart: TVSpiderChart) -> UIFont {
        return UIFont.boldSystemFont(ofSize: 12)
    }
    
    public func colorOfTileForChart(_ chart: TVSpiderChart) -> UIColor {
        return UIColor.black
    }
}

protocol TVSpiderChartDataSource : class {
   
    
    /// Number of sections for chart
    ///
    /// - Parameter chart: TVSpiderChart
    /// - Returns: Int value
    func numberOfSectionsForChart(_ chart : TVSpiderChart) -> Int
    
    
    /// Number of rows for chart
    ///
    /// - Parameter chart: TVSpiderChart
    /// - Returns: Int value
    func numberOfRowsForChart(_ chart : TVSpiderChart) -> Int
    
    
    /// Number of steps for chart
    ///
    /// - Parameter chart: TVSpiderChart
    /// - Returns: Int value
    func numberOfStepsForChart(_ chart : TVSpiderChart) -> Int
    
    
    /// Title of row for chart
    ///
    /// - Parameters:
    ///   - chart: TVSpiderChart
    ///   - row: Row index
    /// - Returns: String value
    func titleOfRowForChart(_ chart : TVSpiderChart, atRow row : Int) -> String
    
    
    /// Value of section for chart
    ///
    /// - Parameters:
    ///   - chart: TVSpiderChart
    ///   - row: Row
    ///   - section: Section
    /// - Returns: CGFloat value
    func valueOfSectionForChart(_ chart : TVSpiderChart, atRow row : Int, section : Int) -> CGFloat
    
}


// MARK: - Default implementation of TVSpiderChartDataSource
extension TVSpiderChartDataSource {
    public func numberOfSectionsForChart(_ chart : TVSpiderChart) -> Int {
        return 1
    }
    
    public func numberOfRowsForChart(_ chart : TVSpiderChart) -> Int {
        return 6
    }
    
    public func numberOfStepsForChart(_ chart : TVSpiderChart) -> Int {
        return 1
    }
    
    public func titleOfRowForChart(_ chart : TVSpiderChart, atRow row : Int) -> String {
        return "\(row)"
    }
    
    public func valueOfSectionForChart(_ chart : TVSpiderChart, atRow row : Int, section : Int) -> CGFloat {
        return 1
    }
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
    public var centerOffset : CGFloat

    
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
        self.centerOffset = 10.0
    }
    
    init(radius : CGFloat, minValue : CGFloat, maxValue : CGFloat, borderWidth : CGFloat, lineWidth : CGFloat, showPoint : Bool, showBorder : Bool, showBackgroundLine : Bool, showBackgroundBorder : Bool, fillArea : Bool, clockwise : Bool, autoCenterPoint : Bool, centerOffset : CGFloat) {
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
        self.centerOffset = centerOffset
    }
}

class TVSpiderChart: UIView, TVSpiderChartDelegate, TVSpiderChartDataSource {
    
    

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
        centerPoint = .zero
        configuration = TVSpiderChartConfiguration.defaultConfig()
        super.init(coder: aDecoder)
        centerPoint = CGPoint.init(x: frame.width/2, y: frame.height/2)
        backgroundColor = .clear
    }
    
    init(rect : CGRect, config : TVSpiderChartConfiguration) {
        centerPoint = CGPoint.init(x: rect.width/2, y: rect.height/2)
        self.configuration = config
        super.init(frame: rect)
        backgroundColor = .clear
    }
    
    
    /// Re-render the spider chart
    func reload() {
        setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = .red
        /// Get current graphic context and datasource
        guard let currentContext = UIGraphicsGetCurrentContext() else { return }
        let myDs = self.dataSource ?? self
        self.centerPoint = CGPoint.init(x: rect.width/2, y: rect.height/2)
        print("center point: \(centerPoint)")
        let myDelegate = self.delegate ?? self
    
        /// draw background
        self.drawBackgroundRectangles(context: currentContext, ds: myDs, dlg: myDelegate)
        
        /// Draw titles
        self.drawTitles(frame: rect, context: currentContext, ds: myDs, dlg: myDelegate)
        
        /// draw background lines
        self.drawBackgroundLines(context: currentContext, ds: myDs, dlg: myDelegate)
        
        /// draw sections
//        self.drawSections(context: currentContext, ds: myDs, dlg: myDelegate)
        
    }
    
    
    
    /// Draw titles on the spider chart
    private func drawTitles(frame : CGRect, context : CGContext, ds : TVSpiderChartDataSource, dlg : TVSpiderChartDelegate) {
        let numberOfRows =  ds.numberOfRowsForChart(self)
        let titleColor = dlg.colorOfTileForChart(self)
        
        let radius = configuration.radius
        let perAngle = CGFloat.pi * 2 / CGFloat(numberOfRows) * CGFloat(configuration.clockwise ? 1 : -1)
        let padding : CGFloat = 10.0
        let textFont = dlg.fontOfTitleForChart(self)
        let height = textFont.lineHeight
        
        for i in 0..<numberOfRows {
            let title = ds.titleOfRowForChart(self, atRow: i)
            let index = CGFloat(i)
            let pointOnEdge = CGPoint.init(x: centerPoint.x - radius*sin(index*perAngle), y: centerPoint.y - radius*cos(index*perAngle))
            
            let attributeTextSize = (title as NSString).size(withAttributes: [NSAttributedString.Key.font : textFont])
            
            let width = attributeTextSize.width
            let xOffset = pointOnEdge.x >= centerPoint.x ? (width/2.0 + padding) : (-width/2.0) - padding
            let yOffset = pointOnEdge.y >= centerPoint.y ? (height/2.0 + padding) : (-height/2.0) - padding
//            let yOffset : CGFloat = 0
            var legendCenter = CGPoint.init(x: pointOnEdge.x + xOffset, y: pointOnEdge.y + yOffset)
            print("index: \(i)\txOffset: \(xOffset)\tyOffset:\(yOffset)")
            let paragraphStyle = NSMutableParagraphStyle.init()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byClipping
            let atts = [NSAttributedString.Key.font : textFont,
                        NSAttributedString.Key.paragraphStyle : paragraphStyle,
                        NSAttributedString.Key.foregroundColor : titleColor]
            
            if i == 0 ||
                (numberOfRows%2 == 0 && i == numberOfRows/2) {
                legendCenter.x = centerPoint.x
                legendCenter.y = centerPoint.y + (radius + padding + height/2.0) * CGFloat(i == 0 ? -1 : 1)
            }
            
            
            if i == 1 || (i == 4) {
                legendCenter.y = centerPoint.y
            }
            
            let rect = CGRect.init(x: (legendCenter.x - width/2), y: (legendCenter.y - height/2.0), width: width, height: height)
            (title as NSString).draw(in: rect, withAttributes: atts)
            
        }
        
        context.saveGState()
    }
    
    
    /// Draw background rectangles
    ///
    /// - Parameters:
    ///   - rect: CGRect
    ///   - context: CGContext
    private func drawBackgroundRectangles(context : CGContext, ds : TVSpiderChartDataSource, dlg : TVSpiderChartDelegate) {
        
        let numberOfSteps = ds.numberOfStepsForChart(self)
        let numberOfRows = ds.numberOfRowsForChart(self)
        let lineColor = dlg.colorOfLineForChart(self)
        let perAngle = CGFloat.pi * 2 / CGFloat(numberOfRows) * CGFloat(configuration.clockwise ? 1 : -1)
        lineColor.setStroke()
        
        let radius = configuration.radius
        
        for stepIndex in 1...numberOfSteps {
            let step = numberOfSteps - stepIndex + 1
            let fillColor = dlg.colorOfFillStepForChart(self)
            let scale = CGFloat(step)/CGFloat(numberOfSteps)
            let innerRadius = scale*radius

            let path = UIBezierPath()
            for index in 0...numberOfRows {
                let i = CGFloat(index)
                var x = centerPoint.x
                var y = centerPoint.y - innerRadius
                if index == 0 {
                    path.move(to: CGPoint.init(x: x, y: y))
                } else if index == numberOfRows {
                    path.addLine(to: CGPoint.init(x: x, y: y))
                } else {
                    x = centerPoint.x - innerRadius*sin(i*perAngle)
                    y = centerPoint.y - innerRadius*cos(i*perAngle)
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
    
    /// Draw background lines on the spider chart
    private func drawBackgroundLines(context : CGContext, ds : TVSpiderChartDataSource, dlg : TVSpiderChartDelegate) {
        guard configuration.showBackgroundLine else { return }
        let numberOfRows = ds.numberOfRowsForChart(self)
        let perAngle = CGFloat.pi * 2 / CGFloat(numberOfRows) * CGFloat(configuration.clockwise ? 1 : -1)
        let radius = configuration.radius
        let lineColor = dlg.colorOfLineForChart(self)
        
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
    
    /// Draw data
    private func drawSections(context : CGContext, ds : TVSpiderChartDataSource, dlg : TVSpiderChartDelegate) {
        let numberOfRows = ds.numberOfRowsForChart(self)
        let numberOfSections = ds.numberOfSectionsForChart(self)
        let radius = configuration.radius
        let minValue = configuration.minValue
        let maxValue = configuration.maxValue
        let perAngle = CGFloat.pi * 2 / CGFloat(numberOfRows) * CGFloat(configuration.clockwise ? 1 : -1)
        
        for section in 0..<numberOfSections {
            let fillColor = dlg.colorOfSectionFillForChart(self)
            let borderColor = dlg.colorOfSectionBorderForChart(self)
            
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

            self.drawPoints(context: context, ds: ds, dlg: dlg)
        }
    }
    
    private func drawPoints(context : CGContext, ds : TVSpiderChartDataSource, dlg : TVSpiderChartDelegate) {
        guard configuration.showPoint else { return }
        let borderColor = UIColor.black
        let numberOfRows = ds.numberOfRowsForChart(self)
        let numberOfSections = ds.numberOfSectionsForChart(self)
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

