
    //  ViewController.swift
    //  Covid-19-Total
    //
    //  Created by MAC on 26.04.2020.
    //  Copyright © 2020 Alex. All rights reserved.
    //

    import UIKit
    import Foundation
    import Charts

    class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ChartViewDelegate {
        //MARK: - Variables
        private let covidJsonURL = "https://api.covid19api.com/summary"
        private let covidDailyJsonURL = "https://pomber.github.io/covid19/timeseries.json"
        private let RFC3339DateFormatter = DateFormatter()
        var date2 = ""
        var showCovidStat = [Country]()
        var sortedCovid = [Country]()
        var globalStat = [Global]()
        var recoveryArray = [Double]()
        var deathArray = [Double]()
        var confirmedArray = [Double]()
        var recovery2 = [Double]()
        var death2 = [Double]()
        
        //MARK: - Outlets
        @IBOutlet weak var regionsCovidInfoCollectionView: UICollectionView!
        @IBOutlet weak var totalConfirmedLabel: UILabel!
        @IBOutlet weak var totalRecoveryLabel: UILabel!
        @IBOutlet weak var totalDeathsLabel: UILabel!
        @IBOutlet weak var dailyConfirmedLabel: UILabel!
        @IBOutlet weak var dailyRecoveredLabel: UILabel!
        @IBOutlet weak var dailyDeathLabel: UILabel!
        @IBOutlet weak var countryChartsLabel: UILabel!
        
        @IBOutlet weak var summaryChartView: BarChartView!
        @IBOutlet weak var recoveryChartView: BarChartView!
        @IBOutlet weak var deathsChartView: BarChartView!
        @IBOutlet weak var summaryPieChartView: PieChartView!
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            regionsCovidInfoCollectionView.dataSource = self
            regionsCovidInfoCollectionView.delegate = self
            summaryPieChartView.delegate = self
            
            self.RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            self.RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: +5)
            
            self.regionsCovidInfoCollectionView.backgroundColor = UIColor.clear
            self.regionsCovidInfoCollectionView.backgroundView = UIView.init(frame: CGRect.zero)
            
            //MARK: - Global Statistic
            JSONParse.fetchGenericDatafromURL(urlString: covidJsonURL) { (showCovidStat2: GlobalStats) in
                //            showCovidStat2.countries.forEach({self.showCovidStat.append($0.country, $0.newConfirmed)})
                let string = showCovidStat2.date
                let date = self.RFC3339DateFormatter.date(from: string)
                self.RFC3339DateFormatter.dateFormat = "HH:mm dd.MM.yy"
                self.date2 = self.RFC3339DateFormatter.string(from: date!)
                guard !showCovidStat2.countries.isEmpty else {
                    self.showRedAllert(title: "Network error", message: "Server busy now. Try again later")
                    return
                }
                print(showCovidStat2.countries.isEmpty)
                showCovidStat2.countries.forEach { (data) in
                    self.showCovidStat = showCovidStat2.countries
                }
                self.sortedCovid = self.showCovidStat.sorted {$0.totalConfirmed > $1.totalConfirmed }
                
                DispatchQueue.main.async {
                    
                    self.totalConfirmedLabel.text = String(showCovidStat2.global.totalConfirmed)
                    self.totalRecoveryLabel.text = String(showCovidStat2.global.totalRecovered)
                    self.totalDeathsLabel.text = String(showCovidStat2.global.totalDeaths)
                    
                    self.dailyConfirmedLabel.text = "↑ \(String(showCovidStat2.global.newConfirmed))"
                    self.dailyRecoveredLabel.text = "↑ \(String(showCovidStat2.global.newRecovered))"
                    self.dailyDeathLabel.text = "↑ \(String(showCovidStat2.global.newDeaths))"
                    self.regionsCovidInfoCollectionView.reloadData()
                }
            }
            
            //MARK: - Russia Statistic by default
            JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
//                dailyCovidStat.russia.forEach({self.test.append($0.recovered, $0.deaths)})
                self.confirmedArray = dailyCovidStat.russia.map { Double($0.confirmed)}
                self.recoveryArray = dailyCovidStat.russia.map{ Double($0.recovered) }
                self.deathArray = dailyCovidStat.russia.map{ Double($0.deaths) }
            
                self.recoveryDeathArrayPreparation()
                
                DispatchQueue.main.async {
                    self.countryChartsLabel.text = "Russia Charts"
                    self.charts()
                }
            }
        }
        
        // MARK: - CollectionView Settings
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return sortedCovid.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CovidCollectionViewCell
            cell.configure()
            
            cell.regionLabel.text = self.sortedCovid[indexPath.row].country
            
            cell.conformedLabel.text = String(self.sortedCovid[indexPath.row].totalConfirmed)
            cell.recoveredLabel.text = String(self.sortedCovid[indexPath.row].totalRecovered)
            cell.deathsLabel.text = String(self.sortedCovid[indexPath.row].totalDeaths)
            
            cell.dayConfermedLabel.text = "↑ \(String(self.sortedCovid[indexPath.row].newConfirmed))"
            cell.dayRecoveredLabel.text = "↑ \(String(self.sortedCovid[indexPath.row].newRecovered))"
            cell.dayDeathsLabel.text = "↑ \(String(self.sortedCovid[indexPath.row].newDeaths))"
            
            cell.dateLabel.text = self.date2
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            //       regionsCovidInfoCollectionView.scrollToItem(at: IndexPath(row: 2, section: 0), at: .right, animated: true)
            
            print(self.sortedCovid[indexPath.row].country)
            
            countryChartsLabel.text = String (self.sortedCovid[indexPath.row].country) + " Charts"
            self.confirmedArray.removeAll()
            self.recovery2.removeAll()
            self.death2.removeAll()
            
            switch self.sortedCovid[indexPath.row].country {
                
            case "United States of America":
                JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                      self.confirmedArray = dailyCovidStat.us.map { Double($0.confirmed)}
                        self.recoveryArray = dailyCovidStat.us.map{ Double($0.recovered) }
                        self.deathArray = dailyCovidStat.us.map{ Double($0.deaths) }
                    
                        self.recoveryDeathArrayPreparation()
                        
                        DispatchQueue.main.async {
                            self.charts()
                    }
                }
            case "Russian Federation":
                JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                      self.confirmedArray = dailyCovidStat.russia.map { Double($0.confirmed)}
                        self.recoveryArray = dailyCovidStat.russia.map{ Double($0.recovered) }
                        self.deathArray = dailyCovidStat.russia.map{ Double($0.deaths) }
                    
                        self.recoveryDeathArrayPreparation()
                        
                        DispatchQueue.main.async {
                            self.charts()
                    }
                }
            case "Brazil" :
                JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                      self.confirmedArray = dailyCovidStat.brazil.map { Double($0.confirmed)}
                        self.recoveryArray = dailyCovidStat.brazil.map{ Double($0.recovered) }
                        self.deathArray = dailyCovidStat.brazil.map{ Double($0.deaths) }
                    
                        self.recoveryDeathArrayPreparation()
                        
                        DispatchQueue.main.async {
                            self.charts()
                        }
                }
            case "United Kingdom":
                JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                      self.confirmedArray = dailyCovidStat.uk.map { Double($0.confirmed)}
                        self.recoveryArray = dailyCovidStat.uk.map{ Double($0.recovered) }
                        self.deathArray = dailyCovidStat.uk.map{ Double($0.deaths) }
                    
                        self.recoveryDeathArrayPreparation()
                        
                        DispatchQueue.main.async {
                            self.charts()
                        }
                }
            case "Spain":
                JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                      self.confirmedArray = dailyCovidStat.spain.map { Double($0.confirmed)}
                        self.recoveryArray = dailyCovidStat.spain.map{ Double($0.recovered) }
                        self.deathArray = dailyCovidStat.spain.map{ Double($0.deaths) }
                    
                        self.recoveryDeathArrayPreparation()
                        
                        DispatchQueue.main.async {
                            self.charts()
                        }
                }
            case "Italy":
                JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                      self.confirmedArray = dailyCovidStat.italy.map { Double($0.confirmed)}
                        self.recoveryArray = dailyCovidStat.italy.map{ Double($0.recovered) }
                        self.deathArray = dailyCovidStat.italy.map{ Double($0.deaths) }
                    
                        self.recoveryDeathArrayPreparation()
                        
                        DispatchQueue.main.async {
                            self.charts()
                        }
                }
            case "France":
                JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                      self.confirmedArray = dailyCovidStat.france.map { Double($0.confirmed)}
                        self.recoveryArray = dailyCovidStat.france.map{ Double($0.recovered) }
                        self.deathArray = dailyCovidStat.france.map{ Double($0.deaths) }
                    
                        self.recoveryDeathArrayPreparation()
                        
                        DispatchQueue.main.async {
                            self.charts()
                        }
                }
            case "Germany":
                JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                      self.confirmedArray = dailyCovidStat.germany.map { Double($0.confirmed)}
                        self.recoveryArray = dailyCovidStat.germany.map{ Double($0.recovered) }
                        self.deathArray = dailyCovidStat.germany.map{ Double($0.deaths) }
                    
                        self.recoveryDeathArrayPreparation()
                        
                        DispatchQueue.main.async {
                            self.charts()
                        }
                }
            case "Canada":
                JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                      self.confirmedArray = dailyCovidStat.canada.map { Double($0.confirmed)}
                        self.recoveryArray = dailyCovidStat.canada.map{ Double($0.recovered) }
                        self.deathArray = dailyCovidStat.canada.map{ Double($0.deaths) }
                    
                        self.recoveryDeathArrayPreparation()
                        
                        DispatchQueue.main.async {
                            self.charts()
                        }
                }
            case "India":
                JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                      self.confirmedArray = dailyCovidStat.india.map { Double($0.confirmed)}
                        self.recoveryArray = dailyCovidStat.india.map{ Double($0.recovered) }
                        self.deathArray = dailyCovidStat.india.map{ Double($0.deaths) }
                    
                        self.recoveryDeathArrayPreparation()
                        
                        DispatchQueue.main.async {
                            self.charts()
                        }
                }
                case "Turkey":
                    JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                          self.confirmedArray = dailyCovidStat.turkey.map { Double($0.confirmed)}
                            self.recoveryArray = dailyCovidStat.turkey.map{ Double($0.recovered) }
                            self.deathArray = dailyCovidStat.turkey.map{ Double($0.deaths) }
                        
                            self.recoveryDeathArrayPreparation()
                            
                            DispatchQueue.main.async {
                                self.charts()
                            }
                    }
                case "Peru":
                    JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                          self.confirmedArray = dailyCovidStat.peru.map { Double($0.confirmed)}
                            self.recoveryArray = dailyCovidStat.peru.map{ Double($0.recovered) }
                            self.deathArray = dailyCovidStat.peru.map{ Double($0.deaths) }
                        
                            self.recoveryDeathArrayPreparation()
                            
                            DispatchQueue.main.async {
                                self.charts()
                            }
                    }
                case "Chile":
                    JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                          self.confirmedArray = dailyCovidStat.chile.map { Double($0.confirmed)}
                            self.recoveryArray = dailyCovidStat.chile.map{ Double($0.recovered) }
                            self.deathArray = dailyCovidStat.chile.map{ Double($0.deaths) }
                        
                            self.recoveryDeathArrayPreparation()
                            
                            DispatchQueue.main.async {
                                self.charts()
                            }
                    }
                case "Mexico":
                    JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                          self.confirmedArray = dailyCovidStat.mexico.map { Double($0.confirmed)}
                            self.recoveryArray = dailyCovidStat.mexico.map{ Double($0.recovered) }
                            self.deathArray = dailyCovidStat.mexico.map{ Double($0.deaths) }
                        
                            self.recoveryDeathArrayPreparation()
                            
                            DispatchQueue.main.async {
                                self.charts()
                            }
                    }
                case "China":
                    JSONParse.fetchGenericDatafromURL(urlString: covidDailyJsonURL) { (dailyCovidStat: CovidStats) in
                          self.confirmedArray = dailyCovidStat.china.map { Double($0.confirmed)}
                            self.recoveryArray = dailyCovidStat.china.map{ Double($0.recovered) }
                            self.deathArray = dailyCovidStat.china.map{ Double($0.deaths) }
                        
                            self.recoveryDeathArrayPreparation()
                            
                            DispatchQueue.main.async {
                                self.charts()
                            }
                    }
            default:
                self.confirmedArray.removeAll()
                self.recoveryArray.removeAll()
                self.deathArray.removeAll()
                self.charts()
                showRedAllert(title: "Sorry", message: "No data for this country. Wait for application update, please.")
                return
            }
        }
        
        private func charts() {
            ChartsViewClass.setUpCharts(barObj: self.recoveryChartView, arrayToCharts: self.recovery2, legend: "Covid Recovery Daily", chartColor: ChartColorTemplates.material()[0])
            
            ChartsViewClass.setUpCharts(barObj: self.summaryChartView, arrayToCharts: self.confirmedArray, legend: "Covid Confirmed Daily", chartColor: ChartColorTemplates.material()[1])
            
            ChartsViewClass.setUpCharts(barObj: self.deathsChartView, arrayToCharts: self.death2, legend: "Covid Death Daily", chartColor: ChartColorTemplates.material()[2])
            
            ChartsViewClass.pieChartData(barObj: self.summaryPieChartView, confirmedArray: self.confirmedArray, recoveryArray: self.recoveryArray, deathArray: self.deathArray)

        }
        private func recoveryDeathArrayPreparation() {
  //          self.recovery2 = self.recoveryArray.map { Double($1 - $0) }
            for i in 1...self.recoveryArray.count - 1 {
                if (self.recoveryArray[i] - self.recoveryArray[i-1]) >= 0 {
                    self.recovery2.append(self.recoveryArray[i] - self.recoveryArray[i-1])
                }
                if (self.deathArray[i] - self.deathArray[i-1]) >= 0 {
                    self.death2.append(self.deathArray[i] - self.deathArray[i-1])
                }
            }
        }
    }

// MARK: - Extensions
    extension ViewController {
        private func showRedAllert(title:String, message:String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            }
            alert.addAction(okAction)
            present(alert, animated: true)
        }
    }
