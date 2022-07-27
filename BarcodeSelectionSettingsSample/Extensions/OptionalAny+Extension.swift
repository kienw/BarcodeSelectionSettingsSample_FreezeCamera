/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import CoreGraphics
import Foundation

extension Optional where Wrapped == Any {
    func valueString(roundedTo numberOfDecimalPlaces: Int) -> String? {
        guard let value = self else {
            return nil
        }

        let numberFormatter = NumberFormatter(maximumFractionDigits: numberOfDecimalPlaces)

        switch value {
        case let floatValue as CGFloat:
            return numberFormatter.string(from: floatValue)
        case let floatValue as Float:
            return numberFormatter.string(from: floatValue)
        default:
            return "\(value)"
        }
    }
}
