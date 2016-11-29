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

typealias Features = [Float]

class ViceFeatureExtractor {
    private var watchLocation: LocationCoordinate?
    private var phoneLocation: LocationCoordinate?
    private var weather: Weather?
    private var dayMood: DayMood?

    func with(watchLocation: LocationCoordinate) -> Self {
        self.watchLocation = watchLocation
        return self
    }

    func with(phoneLocation: LocationCoordinate) -> Self {
        self.phoneLocation = phoneLocation
        return self
    }

    func with(weather: Weather) -> Self {
        self.weather = weather
        return self
    }

    func with(dayMood: DayMood) -> Self {
        self.dayMood = dayMood
        return self
    }

    func extract() -> Features {

        let wlf = watchLocation?.features ?? LocationCoordinate.emptyFeatures

        fatalError("Implement me")
    }
}

extension LocationCoordinate {

    static var emptyFeatures: Features {
        return [0, 0]
    }

    var features: Features {
        return [Float((latitude + 90.0) / 180.0), Float((longitude + 180.0) / 360.0)]
    }
}


