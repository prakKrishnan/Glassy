//
//  SpotListView.swift
//  Glassy
//
//  Created by Prakatish Krishnan on 10/15/25.
//
import SwiftUI

struct SpotListView: View
{
    @State private var spots = SurfSpot.sampleSpots
    @State private var conditionsCache: [UUID: SurfConditions] = [:]
    @State private var loadingSpots: Set<UUID> = []
    
    let surfService = SurfService()
    
    var body: some View
    {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(spots) { spot in
                        SpotCard (
                            spot: spot,
                            conditions: conditionsCache[spot.id],
                            isLoading: loadingSpots.contains(spot.id)
                        )
                        .onTapGesture {
                            // TODO: add navigation later
                            print("Tapped: \(spot.name)")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Glassy")
            .onAppear {
                loadAllConditions()
            }
            .refreshable {
                loadAllConditions()
            }
        }
    }
    
    func loadAllConditions()
    {
        // load conditions for all spots
        for spot in spots {
            loadingSpots.insert(spot.id)
            
            Task {
                do {
                    let conditions = try await surfService.fetchConditions(for: spot)
                    conditionsCache[spot.id] = conditions
                    loadingSpots.remove(spot.id)
                } catch {
                    print("Error loading \(spot.name): \(error)")
                    loadingSpots.remove(spot.id)
                }
            }
        }
    }
}

// Mark: - Spot Card Component

struct SpotCard: View {
    let spot: SurfSpot
    let conditions: SurfConditions?
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            //Header with spot name
            HStack {
                Text(spot.name)
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                // Heart icon for favorites (TODO: make this work later)
                Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(spot.isFavorite ? .red : .gray)
            }
            
            if isLoading {
                // Loading state
                HStack {
                    ProgressView()
                    Text("Loading conditions...")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else if let conditions = conditions {
                // Show conditions
                HStack(spacing: 20) {
                    // Wave height - biggest display
                    VStack {
                        Text(conditions.waveHeightFormatted)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Wave Height")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Wind Info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "wind")
                                .foregroundColor(.gray)
                            Text(conditions.windSpeedFormatted)
                                .font(.subheadline)
                        }
                        Text(conditions.windDirectionCompass)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if conditions.isOffshore {
                            Text("Offshore 🤙")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                    
                    // Rating
                    VStack {
                        Text(conditions.rating)
                            .font(.headline)
                            .foregroundColor(ratingColor(conditions.rating))
                        Text("Rating")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 0)
            } else {
                // Error state
                Text("Unable to load conditions")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
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

#Preview {
    SpotListView()
}
