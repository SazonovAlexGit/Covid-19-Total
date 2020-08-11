//
//  ChartsView.swift
//  Covid-19-Total
//
//  Created by MAC on 30.04.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import Foundation
import Charts

class ChartsViewClass {
    
    static func totalChart(_ obj:BarChartView,_ array:[CovidNums]) {
        var chartEntry = [ChartDataEntry]()
        
        for i in 0..<array.count {
            let value = BarChartDataEntry(x: Double(i), yValues: [Double(array[i].deaths), Double(array[i].recovered), Double(array[i].confirmed)])
            print(array[i].confirmed)
            chartEntry.append(value)
        }
        
        let bar = BarChartDataSet(entries: chartEntry, label: "")
        bar.colors = [ChartColorTemplates.material()[2], ChartColorTemplates.material()[0], ChartColorTemplates.material()[1]]
        bar.stackLabels = ["Deaths", "Recovered", "Confirmed"]
        bar.drawValuesEnabled = false
        
        let data = BarChartData(dataSets: [bar])
        obj.data = data
        obj.chartDescription?.text = "Covid Count"
        obj.xAxis.drawGridLinesEnabled = false
        obj.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeOutBack)
       // obj.notifyDataSetChanged()
    }
    
    static func setUpCharts(barObj: BarChartView, arrayToCharts: [Double], legend: String, chartColor: NSUIColor ) {
        var chartEntry = [ChartDataEntry]()
        var mounth = [String]()
        
        for i in 0..<arrayToCharts.count {
            let value = BarChartDataEntry(x: Double(i), y: arrayToCharts[i])
            chartEntry.append(value)
            if i < 11 {
                mounth.append("January")
            }
            if i >= 11 && i < 41 {
                mounth.append("February")
            }
            if i >= 41 && i < 72 {
                mounth.append("March")
            }
            if i >= 72 && i < 102 {
                mounth.append("April")
            }
            if i >= 102 && i < 133 {
                mounth.append("May")
            }
            if i >= 133 && i < 163 {
                mounth.append("June")
            }
            if i >= 163 && i < 194 {
                mounth.append("July")
            }
            if i >= 194 && i < 225 {
                mounth.append("August")
            }
            if i >= 225 && i < 256 {
                mounth.append("September")
            }
            if i >= 256 && i < 287 {
                mounth.append("October")
            }
            if i >= 287 && i < 317 {
                mounth.append("November")
            }
            if i >= 317 && i < 347 {
                mounth.append("December")
            }
        }
        
        let bar = BarChartDataSet(entries: chartEntry, label: legend)
        bar.colors = [chartColor]
        bar.drawValuesEnabled = false
        
        
        let data = BarChartData(dataSets: [bar])
        
        barObj.xAxis.labelCount = 12
        barObj.xAxis.valueFormatter = IndexAxisValueFormatter(values: mounth)
        barObj.xAxis.granularity = 30
        barObj.data = data
        barObj.chartDescription?.text = "Covid Count"
        barObj.xAxis.drawGridLinesEnabled = false
        barObj.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeOutBack)
        barObj.notifyDataSetChanged()
    }
    
    static func pieChartData(barObj: PieChartView, confirmedArray:[Double], recoveryArray: [Double], deathArray: [Double])  {
        
            let track = ["Confirmed", "Recovered", "Deaths"]
        let money = [Double(confirmedArray.last ?? 0.0), Double(recoveryArray.last ?? 0.0), Double(deathArray.last ?? 0.0)] as [Double]

            var entries = [PieChartDataEntry]()
            for (index, value) in money.enumerated() {
                let entry = PieChartDataEntry()
                entry.y = value
                entry.label = track[index]
                entries.append( entry)
            }
            let set = PieChartDataSet( entries: entries )
                set.selectionShift = 5
        
            set.colors = [ChartColorTemplates.material()[1], ChartColorTemplates.material()[0], ChartColorTemplates.material()[2]]
            let data = PieChartData(dataSet: set)
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .percent
            pFormatter.maximumFractionDigits = 1
            pFormatter.multiplier = 1
            pFormatter.percentSymbol = " %"
            data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
            data.setValueFont(UIFont(name: "HelveticaNeue-Bold", size: 11)!)
            data.setValueTextColor(.black)
        
            barObj.data = data
            barObj.noDataText = "No data available"
            barObj.drawEntryLabelsEnabled = false
            barObj.usePercentValuesEnabled = true

            barObj.isUserInteractionEnabled = true
            barObj.centerText = "Covid19 Count"
            barObj.transparentCircleColor = UIColor.clear
            barObj.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        }
}
