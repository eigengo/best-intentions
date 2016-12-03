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
import XCTest
import HealthKit
import CoreLocation

class EnvironmentFeatureExtractorTests : XCTestCase, EnvironmentSource {

    func testExtract() {
        let features = EnvironmentFeatureExtractor(environmentSource: self).features
        print(features)
    }

    func location() -> KnownLocation {
        return KnownLocation(type: .home, coordinate: CLLocationCoordinate2D(latitude: 53.42, longitude: -2.23))
    }

    func weather() -> Weather {
        return Weather(overall: .cloud, temperature: Measurement(value: 100, unit: UnitTemperature.celsius))
    }

    func mood() -> Mood {
        return .free
    }

    func activitySummary() -> HKActivitySummary {
        return HealthKit.HKActivitySummary()
    }


}
