//
//  SurfSpot.swift
//  Glassy
//
//  Created by Prakatish Krishnan on 10/15/25.
//
import Foundation

struct SurfSpot: Identifiable, Codable
{
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let description: String
    var isFavorite: Bool = false
    
    // Spots with real coordinates
    static let sampleSpots = [
        SurfSpot(
            name: "Huntington Beach Cliffs",
            latitude: 33.6595,
            longitude: -118.0089,
            description: "Consistent beach break with powerful waves. Good for intermediate to advanced surfers."
        ),
        SurfSpot(
            name: "Blackies",
            latitude: 33.6089,
            longitude: -117.9289,
            description: "Popular longboard spot with mellow, fun waves. Great for beginners."
        ),
        SurfSpot(
            name: "San Onofre State Beach",
            latitude: 33.3706,
            longitude: -117.5617,
            description: "Classic longboard wave, super fun and intuitive. Perfect for all skill levels."
        ),
        SurfSpot(
            name: "San Clemente",
            latitude: 33.4270,
            longitude: -117.6120,
            description: "Variety of breaks including the pier and Trestles. World-class waves."
        )
    ]
}

