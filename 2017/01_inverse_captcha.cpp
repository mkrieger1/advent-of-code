#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

// Convert the line to a list of digits.
std::vector<int> read_digits(const std::string& line) {
    std::vector<int> digits(line.size());
    std::transform(
        std::cbegin(line), std::cend(line), std::begin(digits),
        [](char c) { return c - '0'; }
    );
    return digits;
}

// Return the sum of all digits that are equal to the digit halfway around the
// circular list (assuming that the number of digits is even).
int reverse_captcha(const std::vector<int>& digits) {
    std::vector<int> copy{digits};
    std::rotate(
        std::begin(copy), std::begin(copy) + digits.size() / 2,
        std::end(copy)
    ); // abcd -> cdab

    int sum = 0;
    for (
        auto first = std::begin(digits), second = std::cbegin(copy);
        first != std::end(digits);
        ++first, ++second
    ) {
        if (*first == *second) sum += *first;
    }
    return sum;
}

int main() {
    std::string line;
    while (std::getline(std::cin, line)) {
        std::cout << reverse_captcha(read_digits(line)) << '\n';
    }
}
