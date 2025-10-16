//
//  ProfileView.swift
//  Glassy
//
//  Created by Prakatish Krishnan on 10/15/25.
//
import SwiftUI

struct ProfileView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "figure.surfing")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .frame(width: 70, height: 70)
                        .background(Circle().fill(Color.blue.opacity(0.1)))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Surfer")
                            .font(.title2)
                            .bold()
                        Text("SoCal Local")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 8)
            }
            
            Section("Preferences") {
                HStack {
                    Image(systemName: "wind")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    Text("Units")
                    Spacer()
                    Text("Imperial")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    Text("Notifications")
                    Spacer()
                    Text("Off")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("About") {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    Text("Help & Support")
                }
            }
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
