//
//  FavoritesView.swift
//  Glassy
//
//  Created by Prakatish Krishnan on 10/15/25.
//
import SwiftUI

struct FavoritesView: View {
    @State private var favoriteSpots = SurfSpot.sampleSpots.filter { $0.isFavorite }
    @State private var conditionsCache: [UUID: SurfConditions] = [:]
    
    let surfService = SurfService()
    
    var body: some View {
        ScrollView {
            if favoriteSpots.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Favorite Spots Yet")
                        .font(.title2)
                        .bold()
                    
                    Text("Tap the heart icon on any spot to add it to your favorites")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                VStack(spacing: 16) {
                    ForEach(favoriteSpots) { spot in
                        NavigationLink(destination: SpotDetailView(spot: spot, conditions: conditionsCache[spot.id])) {
                            FavoriteSpotCard(
                                spot: spot,
                                conditions: conditionsCache[spot.id]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            loadAllConditions()
        }
        .refreshable {
            loadAllConditions()
        }
    }
    
    func loadAllConditions() {
        for spot in favoriteSpots {
            Task {
                do {
                    let conditions = try await surfService.fetchConditions(for: spot)
                    conditionsCache[spot.id] = conditions
                } catch {
                    print("Error loading \(spot.name): \(error)")
                }
            }
        }
    }
}

struct FavoriteSpotCard: View {
    let spot: SurfSpot
    let conditions: SurfConditions?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(spot.name)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
            
            if let conditions = conditions {
                HStack(spacing: 20) {
                    VStack {
                        Text(conditions.waveHeightFormatted)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Wave Height")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
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
                    
                    VStack {
                        Text(conditions.rating)
                            .font(.headline)
                            .foregroundColor(ratingColor(conditions.rating))
                        Text("Rating")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
            } else {
                HStack {
                    ProgressView()
                    Text("Loading conditions...")
                        .foregroundColor(.gray)
                }
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
    NavigationView {
        FavoritesView()
    }
}
