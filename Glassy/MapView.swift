import SwiftUI
import MapKit

struct MapView: View {
    @State private var spots = SurfSpot.sampleSpots
    @State private var selectedSpot: SurfSpot?
    @State private var conditionsCache: [UUID: SurfConditions] = [:]
    @State private var camera = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 33.5, longitude: -117.8),
            span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
        )
    )
    @State private var isImageryStyle = true
    @State private var lastRefreshTime: Date?
    @State private var isRefreshing = false
    
    let surfService = SurfService()
    
    var body: some View {
        ZStack {
            // The Map - Always satellite view
            Map(position: $camera) {
                ForEach(spots) { spot in
                    Annotation(spot.name, coordinate: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)) {
                        SpotPin(spot: spot, isSelected: selectedSpot?.id == spot.id)
                            .onTapGesture {
                                selectSpot(spot)
                            }
                    }
                }
            }
            .mapStyle(isImageryStyle ? .imagery(elevation: .realistic) : .standard(elevation: .realistic))
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .ignoresSafeArea()
            .contentMargins(.bottom, 100, for: .automatic)
            .contentMargins(.leading, 20, for: .automatic)
            .contentMargins(.trailing, 20, for: .automatic)
            
            // Top bar with logo and map style toggle
            VStack {
                HStack {
                    // Logo - adaptive color
                    Text("Glassy")
                        .font(.system(size: 24, weight: .black, design: .default))
                        .foregroundColor(.primary)  // Changes: black in light mode, white in dark mode
                        .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                        .padding(.leading, 16)
                    
                    Spacer()
                    
                    // Refresh button
                    Button(action: {
                        loadAllConditions()
                    }) {
                        Image(systemName: isRefreshing ? "arrow.clockwise" : "arrow.clockwise")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                            .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                    }
                    .glassEffect(.regular.interactive())
                    .disabled(isRefreshing)
                    
                    // Map style toggle button with clear Liquid Glass
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            isImageryStyle.toggle()
                        }
                    }) {
                        Image(systemName: isImageryStyle ? "map.fill" : "globe.americas.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)  // Adaptive color
                            .frame(width: 44, height: 44)
                    }
                    .glassEffect(.clear.interactive())
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            
            // Small preview card at bottom when spot is selected
            if let spot = selectedSpot {
                VStack {
                    Spacer()
                    
                    SpotPreviewCard(
                        spot: spot,
                        conditions: conditionsCache[spot.id],
                        onClose: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedSpot = nil
                                resetCamera()
                            }
                        }
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadAllConditions()
        }
    }
    
    func selectSpot(_ spot: SurfSpot) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedSpot = spot
            
            // Animate camera to focus on selected spot with 3D perspective
            camera = MapCameraPosition.camera(
                MapCamera(
                    centerCoordinate: CLLocationCoordinate2D(
                        latitude: spot.latitude - 0.02,
                        longitude: spot.longitude
                    ),
                    distance: 15000,
                    heading: 0,
                    pitch: 45
                )
            )
        }
        
        // Load conditions if we haven't yet
        if conditionsCache[spot.id] == nil {
            loadConditions(for: spot)
        }
    }
    
    func resetCamera() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            camera = MapCameraPosition.region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 33.5, longitude: -117.8),
                    span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
                )
            )
        }
    }
    
    func loadAllConditions() {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        lastRefreshTime = Date()
        
        // Clear cache to force fresh data
        conditionsCache.removeAll()
        
        for spot in spots {
            loadConditions(for: spot)
        }
        
        // Reset refreshing state after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isRefreshing = false
        }
    }
    
    func loadConditions(for spot: SurfSpot) {
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

// MARK: - Enhanced Map Pin

struct SpotPin: View {
    let spot: SurfSpot
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Glow effect when selected
            if isSelected {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .blur(radius: 8)
            }
            
            VStack(spacing: 2) {
                // Main pin circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.9), Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isSelected ? 48 : 40, height: isSelected ? 48 : 40)
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                    
                    Image(systemName: "figure.surfing")
                        .font(isSelected ? .title2 : .title3)
                        .foregroundColor(.white)  // Keep white since it's on blue background
                        .fontWeight(.semibold)
                }
                
                // Pin pointer
                Image(systemName: "arrowtriangle.down.fill")
                    .font(isSelected ? .body : .caption)
                    .foregroundColor(.blue)
                    .offset(y: -4)
            }
        }
        .scaleEffect(isSelected ? 1.0 : 0.9)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Enhanced Preview Card

struct SpotPreviewCard: View {
    let spot: SurfSpot
    let conditions: SurfConditions?
    let onClose: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            HStack(spacing: 16) {
                // Spot icon - larger and bolder
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "figure.surfing")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                // Spot info
                VStack(alignment: .leading, spacing: 6) {
                    // Spot name - bigger and bolder
                    Text(spot.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if let conditions = conditions {
                        // Condensed info row
                        HStack(spacing: 12) {
                            // Wave height
                            Text(conditions.waveHeightFormatted)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.blue)
                            
                            Text("·")
                                .foregroundColor(.secondary.opacity(0.5))
                            
                            // Wind
                            HStack(spacing: 4) {
                                Text(conditions.windSpeedFormatted)
                                Text(conditions.windDirectionCompass)
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(conditions.isOffshore ? .green : .secondary)
                            
                            if conditions.isOffshore {
                                Text("🤙")
                                    .font(.system(size: 13))
                            }
                            
                            Text("·")
                                .foregroundColor(.secondary.opacity(0.5))
                            
                            // Rating with colored background
                            Text(conditions.rating)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(ratingColor(conditions.rating))
                                )
                        }
                    } else {
                        HStack(spacing: 6) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading conditions...")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Close button
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(20)
            
            // Tap to view details section
            if conditions != nil {
                NavigationLink(destination: SpotDetailView(spot: spot, conditions: conditions)) {
                    HStack {
                        Text("View Details")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.blue)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .glassEffect(.regular.tint(Color.primary.opacity(0.03)).interactive(), in: .rect(cornerRadius:32))
        .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
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
        MapView()
    }
}
