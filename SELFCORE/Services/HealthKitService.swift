// Services/HealthKitService.swift — Feature 10: Apple Health Integration
import Foundation
import HealthKit
import SwiftUI

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()

    private let store = HKHealthStore()
    @Published var isAuthorized: Bool = false
    @Published var isAvailable: Bool = HKHealthStore.isHealthDataAvailable()

    // Mindful session type for mood logging
    private let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        let writeTypes: Set<HKSampleType> = [mindfulType]
        store.requestAuthorization(toShare: writeTypes, read: nil) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                completion(success)
            }
        }
    }

    // Feature 10: Write mood check-in as mindful session
    func logMoodCheckIn(mood: Mood, duration: TimeInterval = 60) {
        guard isAuthorized else { return }
        let end = Date()
        let start = end.addingTimeInterval(-duration)
        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end,
            metadata: [
                HKMetadataKeyExternalUUID: UUID().uuidString,
                "SCMood": mood.rawValue,
                "SCMoodValue": mood.healthKitValue
            ]
        )
        store.save(sample) { success, error in
            if let error = error {
                print("HealthKit save error: \(error)")
            }
        }
    }

    // Feature 10: Write mindful minutes when user plays Signal audio
    func logMindfulAudioSession(trackTitle: String, duration: TimeInterval) {
        guard isAuthorized else { return }
        let end = Date()
        let start = end.addingTimeInterval(-duration)
        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end,
            metadata: [
                HKMetadataKeyExternalUUID: UUID().uuidString,
                "SCTrack": trackTitle,
                "SCSource": "GEN:SIGNAL"
            ]
        )
        store.save(sample) { _, _ in }
    }
}
