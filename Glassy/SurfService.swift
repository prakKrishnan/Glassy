//
//  SurfService.swift
//  Glassy
//
//  Created by Prakatish Krishnan on 10/15/25.
//
import Foundation

class SurfService
{
    private let apiKey = "628a4570-a994-11f0-a260-0242ac130006-628a45d4-a994-11f0-a260-0242ac130006"
    private let baseURL = "https://api.stormglass.io/v2/weather/point"
    
    // Fetch surf conditions for a specific spot
    func fetchConditions(for spot: SurfSpot) async throws -> SurfConditions
    {
        let params = "lat=\(spot.latitude)&lng=\(spot.longitude)&params=waveHeight,wavePeriod,waveDirection,windSpeed,windDirection,waterTemperature"
        guard let url = URL(string: "\(baseURL)?\(params)") else {
            throw URLError(.badURL)
        }
        
        // Create request with API key in header
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        // Make the API call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for valid response
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Parse the JSON Response
        let apiResponse = try JSONDecoder().decode(StormglassResponse.self, from: data)
        
        // Get the first (current) data point
        guard let current = apiResponse.hours.first else {
            throw URLError(.cannotParseResponse)
        }
        
        // Convert to our SurfConditions model
        return SurfConditions(
            waveHeight: (current.waveHeight.noaa ?? 0) * 3.28084,
            wavePeriod: current.wavePeriod.noaa ?? 0,
            waveDirection: current.waveDirection.noaa ?? 0,
            windSpeed: (current.windSpeed.noaa ?? 0) * 2.23694,
            windDirection: current.windDirection.noaa ?? 0,
            waterTemp: ((current.waterTemperature.noaa ?? 0) * 9/5) + 32
        )
    }
}

struct StormglassResponse: Codable
{
    let hours: [HourData]
}

struct HourData: Codable
{
    let waveHeight: DataPoint
    let wavePeriod: DataPoint
    let waveDirection: DataPoint
    let windSpeed: DataPoint
    let windDirection: DataPoint
    let waterTemperature: DataPoint
}

struct DataPoint: Codable
{
    let noaa: Double?
}
