#include <algorithm>
#include <iostream>
#include <iterator>
#include <sstream>
#include <set>
#include <vector>

// A row in the spreadsheet consists of a list of numbers.
class Row {
    std::vector<int> numbers;

public:
    // Create a row from a string of whitespace-delimited numbers.
    Row(const std::string& line) {
        std::stringstream stream{line};
        std::copy(
            std::istream_iterator<int>{stream},
            std::istream_iterator<int>{},
            std::back_inserter(numbers)
        );
    }

    // Return the difference between the smallest and the largest number.
    int max_difference() {
        if (numbers.empty()) { return 0; }
        auto max{std::max_element(std::begin(numbers), std::end(numbers))};
        auto min{std::min_element(std::begin(numbers), std::end(numbers))};
        return *max - *min;
    }

    // Return the ratio between the only two evenly divisible numbers.
    // Assumes that there exists only one such pair of numbers.
    // Assumes that the row doesn't contain the same number more than once.
    int evenly_divisible_ratio() {
        if (numbers.empty()) { return 0; }

        std::set<int> nums{std::begin(numbers), std::end(numbers)};

        // guard against no pair of evenly divisible numbers exists
        auto max{std::max_element(std::begin(nums), std::end(nums))};

        for (auto x : nums) {
            for (int i = 2; i * x <= *max; ++i) {
                if (nums.find(i * x) != std::end(nums)) {
                    return i;
                }
            }
        }
        return 0;
    }
};


class Spreadsheet {
    std::vector<Row> rows;

    friend std::istream& operator>>(std::istream& input, Spreadsheet& sheet) {
        std::string line;
        while (std::getline(input, line)) {
            sheet.rows.push_back(Row(line));
        }
        return input;
    }

public:
    // Return the sum of the maximum difference between any two numbers in
    // each row.
    int sum_rows_max_difference() {
        int result{0};
        for (auto row : rows) {
            result += row.max_difference();
        }
        return result;
    }

    // Return the sum of the ratio between the two evenly divisible numbers in
    // each row.
    int sum_rows_evenly_divisible_ratio() {
        int result{0};
        for (auto row : rows) {
            result += row.evenly_divisible_ratio();
        }
        return result;
    }
};


int main() {
    Spreadsheet sheet;
    std::cin >> sheet;
    std::cout << sheet.sum_rows_evenly_divisible_ratio() << '\n';
}
