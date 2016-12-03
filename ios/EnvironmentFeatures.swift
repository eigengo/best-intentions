/*
 * Best Intentions
 * Copyright (C) 2016 Jan Machacek
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
import Foundation
import HealthKit
import Contacts

enum FeatureExtractorFactoryError : Error {
    case Unauthorized
}

class FeatureExtractorFactory {

    init(locations: [(LocationType, LocationCoordinate)]) {
    }

    func extractor(onCompletion: (FeatureExtractor) -> Void) throws -> Void {

        fatalError()
    }

}

enum LocationType {
    case home
    case work
    case business
    case holiday
    case other
}

struct KnownLocation {
    var type: LocationType
    var coordinate: LocationCoordinate
}

protocol EnvironmentSource {

    func location() -> KnownLocation

    func weather() -> Weather

    func mood() -> Mood

    func activitySummary() -> HKActivitySummary

}

class EnvironmentFeatureExtractor : FeatureExtractor {
    private let environmentSource: EnvironmentSource

    init(environmentSource: EnvironmentSource) {
        self.environmentSource = environmentSource
    }

    var features: Features {
        get {
            return environmentSource.location().features +
                environmentSource.weather().features +
                environmentSource.mood().features +
                environmentSource.activitySummary().features
        }
    }
}

fileprivate extension HKActivitySummary /* : FeatureExtractor */ {

    var features: Features {
        let ae = Float((0.5 * activeEnergyBurned.doubleValue(for: HKUnit.calorie())) / activeEnergyBurnedGoal.doubleValue(for: HKUnit.calorie()))
        let et = Float((0.5 * appleExerciseTime.doubleValue(for: HKUnit.hour())) / appleExerciseTimeGoal.doubleValue(for: HKUnit.hour()))
        let st = Float((0.5 * appleStandHours.doubleValue(for: HKUnit.count())) / appleStandHoursGoal.doubleValue(for: HKUnit.count()))

        return [max(1.0, ae), max(1.0, st), max(1.0, et)]
    }

}

fileprivate extension LocationType /* : FeatureExtractor */ {

    var features: Features {
        switch self {
        case .other: return [-1]

        case .home: return [0]
        case .work: return [0.2]
        case .business: return [0.4]
        case .holiday: return [0.6]
        }
    }

}

fileprivate extension Mood /* : FeatureExtractor */ {

    var features: Features {
        switch self {
        case .other: return [-1]
        case .free: return [0]
        case .normal: return [0.2]
        case .busy: return [0.4]
        case .veryBusy: return [0.6]
        }
    }

}

fileprivate extension KnownLocation /* : FeatureExtractor */ {

    var features: Features {
        return coordinate.features + type.features
    }

}

fileprivate extension LocationCoordinate /*: FeatureExtractor */ {

    var features: Features {
        return [Float((latitude + 90.0) / 180.0), Float((longitude + 180.0) / 360.0)]
    }
}

fileprivate extension Weather {

    var features: Features {
        let min = -100.0
        let max = 100.0
        let t = Float((temperature.converted(to: UnitTemperature.celsius).value - min) / (max - min))
        return [min(-1.0, max(1.0, t))] + overall.features
    }

}

fileprivate extension Weather.Overall {

    var features: Features {
        switch self {
        case .other: return [-1]

        case .sun: return [0]
        case .cloud: return [0.2]
        case .rain: return [0.4]
        case .snow: return [0.6]
        }
    }

}
