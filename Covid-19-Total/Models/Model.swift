//
//  Model.swift
//  Covid-19-Total
//
//  Created by MAC on 26.04.2020.
//  Copyright © 2020 Alex. All rights reserved.

import Foundation

// MARK: - Covid3
struct GlobalStats: Codable {
    let global: Global
    let countries: [Country]
    let date: String

    enum CodingKeys: String, CodingKey {
        case global = "Global"
        case countries = "Countries"
        case date = "Date"
    }
}

// MARK: - Country
struct Country: Codable {
    let country, countryCode, slug: String
    let newConfirmed, totalConfirmed, newDeaths, totalDeaths: Int
    let newRecovered, totalRecovered: Int
    let date: String

    enum CodingKeys: String, CodingKey {
        case country = "Country"
        case countryCode = "CountryCode"
        case slug = "Slug"
        case newConfirmed = "NewConfirmed"
        case totalConfirmed = "TotalConfirmed"
        case newDeaths = "NewDeaths"
        case totalDeaths = "TotalDeaths"
        case newRecovered = "NewRecovered"
        case totalRecovered = "TotalRecovered"
        case date = "Date"
    }
}

// MARK: - Global
struct Global: Codable {
    let newConfirmed, totalConfirmed, newDeaths, totalDeaths: Int
    let newRecovered, totalRecovered: Int

    enum CodingKeys: String, CodingKey {
        case newConfirmed = "NewConfirmed"
        case totalConfirmed = "TotalConfirmed"
        case newDeaths = "NewDeaths"
        case totalDeaths = "TotalDeaths"
        case newRecovered = "NewRecovered"
        case totalRecovered = "TotalRecovered"
    }
}

//MARK: - Daily JSON
struct CovidStats: Codable {
    let france: [CovidNums]
    let russia: [CovidNums]
    let us: [CovidNums]
    let brazil : [CovidNums]
    let uk: [CovidNums]
    let spain: [CovidNums]
    let italy: [CovidNums]
    let germany: [CovidNums]
    let canada: [CovidNums]
    let india: [CovidNums]
    let turkey: [CovidNums]
    let peru: [CovidNums]
    let chile: [CovidNums]
    let mexico: [CovidNums]
    let china: [CovidNums]
//
    enum CodingKeys: String, CodingKey {
        case us = "US"
        case russia = "Russia"
        case france = "France"
        case brazil = "Brazil"
        case uk = "United Kingdom"
        case spain = "Spain"
        case italy = "Italy"
        case germany = "Germany"
        case canada = "Canada"
        case india = "India"
        case turkey = "Turkey"
        case peru = "Peru"
        case chile = "Chile"
        case mexico = "Mexico"
        case china = "China"
    }
}

struct CovidNums: Codable {
    let date: String
    let confirmed, deaths, recovered: Int
}
//MARK: - JSON Parsing
class JSONParse {
    
    static func fetchGenericDatafromURL<T: Decodable>(urlString: String, completion: @escaping (T) -> ()) {
        
        guard let url = URL(string: urlString) else {
            print("URL missing. Sorry, connection refused")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            guard error == nil else { return }
            do {
                let obj = try JSONDecoder().decode(T.self, from: data)
                
                completion(obj)
                
            }catch let error {
                print(error)
                print("Data missing. Sorry, can't decode data from URL")
            }
        }.resume()
    }
}

