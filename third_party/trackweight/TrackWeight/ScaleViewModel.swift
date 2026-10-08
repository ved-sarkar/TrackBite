//
//  ScaleViewModel.swift
//  TrackWeight
//

import OpenMultitouchSupport
import SwiftUI
import Combine

@MainActor
final class ScaleViewModel: ObservableObject {
    @Published var currentWeight: Float = 0.0
    @Published var zeroOffset: Float = 0.0
    @Published var isListening = false
    @Published var hasTouch = false
    
    private let manager = OMSManager.shared
    private var task: Task<Void, Never>?
    
    func startListening() {
        if manager.startListening() {
            isListening = true
        }
        
        task = Task { [weak self, manager] in
            for await touchData in manager.touchDataStream {
                await MainActor.run {
                    self?.processTouchData(touchData)
                }
            }
        }
    }
    
    func stopListening() {
        task?.cancel()
        if manager.stopListening() {
            isListening = false
            hasTouch = false
            currentWeight = 0.0
        }
    }
    
    func zeroScale() {
        if hasTouch {
            zeroOffset = currentWeight + zeroOffset
        }
    }
    
    private func processTouchData(_ touchData: [OMSTouchData]) {
        if touchData.isEmpty {
            hasTouch = false
            currentWeight = 0.0
            zeroOffset = 0.0  // Reset zero when finger is lifted
        } else {
            hasTouch = true
            let rawWeight = touchData.first?.pressure ?? 0.0
            currentWeight = max(0, rawWeight - zeroOffset)
        }
    }
    
    deinit {
        task?.cancel()
        manager.stopListening()
    }
}