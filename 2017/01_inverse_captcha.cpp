#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

// Convert the first line of the input stream to a list of digits.
std::vector<int> read_digits(std::istream& input) {
    std::string line;
    std::getline(input, line);

    std::vector<int> digits(line.size());
    std::transform(
        std::cbegin(line), std::cend(line), std::begin(digits),
        [](char c) { return c - '0'; }
    );
    return digits;
}

// Return the sum of all digits in the list that match the next digit
// (the first digit is the "next" digit of the last digit).
int reverse_captcha(const std::vector<int>& digits) {
    int sum = 0;
    for (auto first = std::begin(digits); first != std::end(digits); first++) {
        auto second =
            (std::next(first) == std::end(digits)) ?
            std::begin(digits) : std::next(first);
        if (*first == *second) sum += *first;
    }
    return sum;
}

int main() {
    std::cout << reverse_captcha(read_digits(std::cin)) << '\n';
}
