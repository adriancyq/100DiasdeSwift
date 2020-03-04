import UIKit

let name = "Taylor"

for letter in name {
    print("Give me a \(letter)!")
}

//cant do this
//print(name[3])

//slow and annoying
let letter = name[name.index(name.startIndex, offsetBy: 3)]

//check for prefix
//check for suffix
let password = "12345"
password.hasPrefix("123")
password.hasSuffix("345")

//We can add extension methods to String to extend the way prefixing and suffixing works:
extension String {
    // remove a prefix if it exists
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    // remove a suffix if it exists
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}


//capitalize stuff
let weather = "it's going to rain"
print(weather.capitalized)

//We could add our own specialized capitalization that uppercases only the first letter in our string:
extension String {
    var capitalizedFirst: String {
        guard let firstLetter = self.first else { return "" }
        return firstLetter.uppercased() + self.dropFirst()
    }
}


//see if the string contains
let input = "Swift is like Objective-C without the C"
input.contains("Swift")

//see if array contains
let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")

extension String {
    func containsAny(of array: [String]) -> Bool {
        for item in array {
            if self.contains(item) {
                return true
            }
        }

        return false
    }
}

input.containsAny(of: languages)

//or

languages.contains(where: input.contains)


//attributes for a string
let string = "This is a test string"
let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.boldSystemFont(ofSize: 36)
]

//let attributedString = NSAttributedString(string: string, attributes: attributes)

//NSMutableAttributedString, which is an attributed string that you can modify
let attributedString = NSMutableAttributedString(string: string)
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))
