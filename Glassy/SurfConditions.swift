//
//  SurfConditions.swift
//  Glassy
//
//  Created by Prakatish Krishnan on 10/15/25.
//
import Foundation

struct SurfConditions: Codable
{
    let waveHeight: Double
    let wavePeriod: Double
    let waveDirection: Double
    let windSpeed: Double
    let windDirection: Double
    let waterTemp: Double
    
    var rating: String
    {
        if waveHeight >= 4 && waveHeight <= 8 && windSpeed < 10
        {
            return "Epic"
        } else if waveHeight >= 2 && waveHeight <= 6
        {
            return "Good"
        } else if waveHeight >= 1
        {
            return "Fair"
        } else
        {
            return "Flat"
        }
    }
    
    var waveHeightFormatted: String
    {
        return String(format: "%.1f ft", waveHeight)
    }
    
    var windSpeedFormatted: String
    {
        return String(format: "%.0f mph", windSpeed)
    }
    
    var windDirectionCompass: String
    {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((windDirection + 22.5) / 45.0) % 8
        return directions[index]
    }
    
    // Check if wind is offshore (good for surfing)
    var isOffshore: Bool
    {
        // Generally, NE to E winds are offshore in SoCal
        return windDirection >= 0 && windDirection <= 135
    }
}
