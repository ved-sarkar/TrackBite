//
//  WeighingState.swift
//  TrackWeight
//

import Foundation

enum WeighingState: Equatable {
    case welcome
    case waitingForFinger
    case waitingForItem
    case weighing
    case result(weight: Float)
}