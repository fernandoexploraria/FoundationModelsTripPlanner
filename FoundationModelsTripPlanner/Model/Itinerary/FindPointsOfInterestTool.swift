/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A tool to use alongside the models to find points of interest for a landmark.
*/

import FoundationModels
import MapKit
import SwiftUI

@Observable
final class FindPointsOfInterestTool: Tool {
    let name = "findPointsOfInterest"
    let description = "Finds points of interest for a landmark."
    
    let landmark: Landmark
    
    @MainActor var lookupHistory: [Lookup] = []
    
    init(landmark: Landmark) {
        self.landmark = landmark
    }

    @Generable
    enum Category: String, CaseIterable {
        case campground
        case hotel
        case cafe
        case museum
        case marina
        case restaurant
        case nationalMonument
    }

    @Generable
    struct Arguments {
        @Guide(description: "This is the type of destination to look up for.")
        let pointOfInterest: Category

        @Guide(description: "The natural language query of what to search for.")
        let naturalLanguageQuery: String
    }
    
    @MainActor func recordLookup(arguments: Arguments) {
        lookupHistory.append(Lookup(history: arguments))
    }
    
    func call(arguments: Arguments) async throws -> String {
        let items = try await pointsOfInterest(location: landmark.locationCoordinate, arguments: arguments)
            let results = items.prefix(10).compactMap { $0.name}
            return "There are these \(arguments.pointOfInterest) in \(landmark.name): \(results.formatted())"
        }
        
        private func pointsOfInterest(location: CLLocationCoordinate2D, arguments: Arguments) async throws -> [MKMapItem] {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = arguments.naturalLanguageQuery
            request.pointOfInterestFilter = .init(including: [arguments.pointOfInterest.toMapKitCategory])
            request.region = MKCoordinateRegion(
                center: location, latitudinalMeters: 20_000, longitudinalMeters: 20_000
            )
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            return response.mapItems
        }
    
    
}

extension FindPointsOfInterestTool.Category {
    var toMapKitCategory: MKPointOfInterestCategory {
        switch self {
        case .restaurant: return .restaurant
        case .campground: return .campground
        case .hotel: return .hotel
        case .cafe: return .cafe
        case .museum: return .museum
        case .marina: return .marina
        case .nationalMonument: return .nationalMonument
        }
    }
}
