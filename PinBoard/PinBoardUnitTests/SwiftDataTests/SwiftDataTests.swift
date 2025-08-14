//
//  SwiftDataTests.swift
//  PinBoard
//
//  Created by Vadim Sorokolit on 14.08.2025.
//

import Foundation
import SwiftData
import Testing
import SwiftData
@testable import PinBoard

@Model
final class TestLocation {
    @Attribute(.unique) var id: UUID
    var index:Int
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.id = UUID()
        self.index = 1
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

@Suite(.serialized)
struct SwiftDataTests {
    
    // MARK: - Properties. Private
    
    private var container: ModelContainer!
    private var context: ModelContext!
    
    // MARK: - Initializer
    
    init() {
        let schema = Schema([TestLocation.self])
        container = try? ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        context = ModelContext(container)
    }
    
    // MARK: - Methods. Test
    
    @Test
    func getLocation() throws {
        let location = TestLocation(name: "Lviv", latitude: 49.84, longitude: 24.03)
        
        context.insert(location)
        try context.save()
        
        
        let fetchRequest = FetchDescriptor<TestLocation>(
            predicate: #Predicate { $0.name == "Lviv" }
        )
        let results = try context.fetch(fetchRequest)
        
        #expect(results.count == 1)
        #expect(results.first?.latitude == 49.84)
    }
    
    @Test
    func createLocation() throws {
        let location = TestLocation(name: "Kyiv", latitude: 50.45, longitude: 30.52)
        
        context.insert(location)
        try self.context.save()
        
        let fetchRequest = FetchDescriptor<TestLocation>(
            predicate: #Predicate { $0.name == "Kyiv" }
        )
        let results = try context.fetch(fetchRequest)
        
        #expect(results.first?.name == "Kyiv")
        #expect(results.first?.latitude == 50.45)
    }
    
    @Test
    func updateLocation() throws {
        let location = TestLocation(name: "Odesa", latitude: 46.48, longitude: 30.72)
        
        context.insert(location)
        try context.save()
        
        let fetchRequest = FetchDescriptor<TestLocation>(
            predicate: #Predicate { $0.name == "Odesa" }
        )
        let createdResults = try context.fetch(fetchRequest)
        
        #expect(createdResults.first?.name == "Odesa")
        #expect(createdResults.first?.latitude != 49.84)
        #expect(createdResults.first?.latitude == 46.48)
        
        location.name = "Odesa Updated"
        try context.save()
        
        let results = try context.fetch(FetchDescriptor<TestLocation>())
        
        #expect(results.first?.name == "Odesa Updated")
    }
    
    @Test
    func deleteLocation() throws {
        let location = TestLocation(name: "Dnipro", latitude: 48.45, longitude: 34.98)
        
        context.insert(location)
        try context.save()
        
        let fetchRequest = FetchDescriptor<TestLocation>(
            predicate: #Predicate { $0.name == "Dnipro" }
        )
        let createdResults = try context.fetch(fetchRequest)
        
        #expect(createdResults.first?.name != "Odessa")
        #expect(createdResults.first?.name == "Dnipro")
        #expect(createdResults.first?.longitude == 34.98)
        
        context.delete(location)
        try context.save()
        
        let results = try context.fetch(FetchDescriptor<TestLocation>())
        
        #expect(results.isEmpty)
    }
    
}
