//
//  SpotDetailView.swift
//  Glassy
//
//  Created by Prakatish Krishnan on 10/15/25.
//
import SwiftUI
import MapKit

struct SpotDetailView: View {
    let spot: SurfSpot
    let conditions: SurfConditions?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero section with conditions
                if let conditions = conditions {
                    VStack(spacing: 16) {
                        // Big wave height display
                        VStack(spacing: 8) {
                            Text(conditions.waveHeightFormatted)
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(.blue)
                            
                            Text(conditions.rating)
                                .font(.title2)
                                .foregroundColor(ratingColor(conditions.rating))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(ratingColor(conditions.rating).opacity(0.2))
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(16)
                        
                        // Conditions grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ConditionCard(
                                icon: "wind",
                                title: "Wind",
                                value: conditions.windSpeedFormatted,
                                subtitle: conditions.windDirectionCompass,
                                color: conditions.isOffshore ? .green : .gray
                            )
                            
                            ConditionCard(
                                icon: "waveform.path",
                                title: "Period",
                                value: "\(Int(conditions.wavePeriod))s",
                                subtitle: "Wave period",
                                color: .blue
                            )
                            
                            ConditionCard(
                                icon: "thermometer.medium",
                                title: "Water",
                                value: "\(Int(conditions.waterTemp))°F",
                                subtitle: "Temperature",
                                color: .cyan
                            )
                            
                            ConditionCard(
                                icon: "location.north.fill",
                                title: "Direction",
                                value: "\(Int(conditions.waveDirection))°",
                                subtitle: "Wave direction",
                                color: .purple
                            )
                        }
                    }
                    .padding()
                } else {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading conditions...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                }
                
                // Spot description
                VStack(alignment: .leading, spacing: 12) {
                    Text("About this spot")
                        .font(.title3)
                        .bold()
                    
                    Text(spot.description)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5)
                .padding(.horizontal)
                
                // Mini map
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location")
                        .font(.title3)
                        .bold()
                    
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )), annotationItems: [spot]) { spot in
                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude), tint: .blue)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .allowsHitTesting(false) // Disable interaction
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5)
                .padding(.horizontal)
                
                // Favorite button
                Button(action: {
                    // We'll implement favorites later
                    print("Toggle favorite")
                }) {
                    HStack {
                        Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                        Text(spot.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                    }
                    .font(.headline)
                    .foregroundColor(spot.isFavorite ? .red : .blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(spot.isFavorite ? Color.red : Color.blue, lineWidth: 2)
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.top)
        }
        .navigationTitle(spot.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    func ratingColor(_ rating: String) -> Color {
        switch rating {
        case "Epic": return .green
        case "Good": return .blue
        case "Fair": return .orange
        default: return .gray
        }
    }
}

// MARK: - Condition Card Component

struct ConditionCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    NavigationView {
        SpotDetailView(
            spot: SurfSpot.sampleSpots[0],
            conditions: SurfConditions(
                waveHeight: 4.5,
                wavePeriod: 12,
                waveDirection: 270,
                windSpeed: 8,
                windDirection: 45,
                waterTemp: 68
            )
        )
    }
}
