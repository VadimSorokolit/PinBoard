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
        self.container = try? ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        self.context = ModelContext(self.container)
    }
    
    // MARK: - Methods. Test
    
    @Test
    func testGetLocation() throws {
        let testLocationName: String = "Lviv"
        let testLocationLatitude: Double = 49.84
        let testLocationLongitude: Double = 24.03
        
        let testLocation = TestLocation(name: testLocationName, latitude: testLocationLatitude , longitude: testLocationLongitude)
        
        self.context.insert(testLocation)
        try self.context.save()
        
        
        let fetchRequest = FetchDescriptor<TestLocation>(
            predicate: #Predicate { $0.name == testLocationName }
        )
        let results = try self.context.fetch(fetchRequest)
        
        #expect(results.count == 1)
        #expect(results.first?.latitude == testLocation.latitude)
        #expect(results.first?.longitude == testLocation.longitude)
    }
    
    @Test
    func testCreateLocation() throws {
        let testLocationName: String = "Kyiv"
        let testLocationLatitude: Double = 50.45
        let testLocationLongitude: Double = 30.52
        let unexpectedLatitude: Double = 49.84
        
        let testLocation = TestLocation(name: testLocationName, latitude: testLocationLatitude , longitude: testLocationLongitude)
        
        self.context.insert(testLocation)
        try self.context.save()
        
        let fetchRequest = FetchDescriptor<TestLocation>(
            predicate: #Predicate { $0.name == testLocationName }
        )
        let results = try context.fetch(fetchRequest)
        
        #expect(results.first?.name == testLocation.name)
        #expect(results.first?.latitude == testLocation.latitude)
        #expect(results.first?.latitude == testLocationLatitude)
        #expect(results.first?.longitude == testLocation.longitude)
        #expect(results.first?.latitude != unexpectedLatitude)
    }
    
    @Test
    func testUpdateLocation() throws {
        let testLocationName: String = "Odesa"
        let testLocationNewName: String = "Odesa Updated"
        let testLocationLatitude: Double = 46.48
        let testLocationLongitude: Double = 30.72
        let unexpectedLocationLatitude: Double = 49.84
        let newLocationLatitude: Double = 50.00
        
        let testLocation = TestLocation(name: testLocationName, latitude: testLocationLatitude, longitude: testLocationLongitude)
        
        self.context.insert(testLocation)
        try self.context.save()
        
        let fetchRequest = FetchDescriptor<TestLocation>(
            predicate: #Predicate { $0.name == testLocationName }
        )
        let createdResults = try self.context.fetch(fetchRequest)
        
        #expect(createdResults.first?.name == testLocation.name)
        #expect(createdResults.first?.latitude != unexpectedLocationLatitude)
        #expect(createdResults.first?.latitude == testLocation.latitude)
        
        let oldLatitude: Double = testLocation.latitude
        testLocation.name = testLocationNewName
        testLocation.latitude = newLocationLatitude
        
        try self.context.save()
        
        let results = try context.fetch(FetchDescriptor<TestLocation>())
        
        #expect(results.first?.name == testLocation.name)
        #expect(testLocationName != testLocation.name)
        #expect(testLocation.name == testLocationNewName)
        #expect(results.first?.latitude != unexpectedLocationLatitude)
        #expect(results.first?.latitude == newLocationLatitude)
        #expect(oldLatitude != newLocationLatitude)
    }
    
    @Test
    func deleteLocation() throws {
        let testLocationName: String = "Dnipro"
        let unexpectedLocationName: String = "Odessa"
        let testLocationLatitude: Double = 48.45
        let testLocationLongitude: Double = 34.98
        let unexpectedLocationLatitude: Double = 49.84
        
        let location = TestLocation(name: testLocationName, latitude: testLocationLatitude, longitude: testLocationLongitude)
        
        self.context.insert(location)
        try self.context.save()
        
        let fetchRequest = FetchDescriptor<TestLocation>(
            predicate: #Predicate { $0.name == testLocationName }
        )
        let createdResults = try context.fetch(fetchRequest)
        
        #expect(createdResults.first?.name != unexpectedLocationName)
        #expect(createdResults.first?.name == testLocationName)
        #expect(createdResults.first?.longitude == testLocationLongitude)
        #expect(createdResults.first?.latitude == testLocationLatitude)
        #expect(createdResults.first?.latitude != unexpectedLocationLatitude)
        
        self.context.delete(location)
        try self.context.save()
        
        let results = try context.fetch(FetchDescriptor<TestLocation>())
        
        #expect(results.isEmpty)
    }
    
}
