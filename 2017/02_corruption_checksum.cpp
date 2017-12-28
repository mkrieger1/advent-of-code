#include <algorithm>
#include <iostream>
#include <iterator>
#include <sstream>
#include <vector>

// A row in the spreadsheet consists of a list of numbers.
class Row {
    std::vector<int> numbers;

public:
    // Create a row from a string of whitespace-delimited numbers.
    Row(const std::string& line)
    {
        std::stringstream stream{line};
        std::copy(
            std::istream_iterator<int>{stream},
            std::istream_iterator<int>{},
            std::back_inserter(numbers)
        );
    }

    // Return the difference between the smallest and the largest number.
    int max_difference() const
    {
        if (numbers.empty()) { return 0; }
        auto max{std::max_element(std::begin(numbers), std::end(numbers))};
        auto min{std::min_element(std::begin(numbers), std::end(numbers))};
        return *max - *min;
    }

    // Return the ratio between the only two evenly divisible numbers.
    // Assumes that there exists only one such pair of numbers.
    // Assumes that the row doesn't contain the same number more than once.
    int evenly_divisible_ratio() const
    {
        for (auto p = std::begin(numbers); p != std::end(numbers); ++p) {
            for (auto q = p + 1; q != std::end(numbers); ++q) {
                int small, large;

                if (*p < *q) { small = *p; large = *q; }
                else         { small = *q; large = *p; }

                if (large % small == 0) { return large / small; }
            }
        }
        return 0;
    }
};


class Spreadsheet {
    std::vector<Row> rows;

    friend std::istream& operator>>(std::istream& input, Spreadsheet& sheet)
    {
        std::string line;
        while (std::getline(input, line)) {
            sheet.rows.push_back(Row(line));
        }
        return input;
    }

public:
    // Return the sum of the maximum difference between any two numbers in
    // each row.
    int sum_rows_max_difference()
    {
        int result{0};
        for (const auto &row : rows) {
            result += row.max_difference();
        }
        return result;
    }

    // Return the sum of the ratio between the two evenly divisible numbers in
    // each row.
    int sum_rows_evenly_divisible_ratio()
    {
        int result{0};
        for (const auto &row : rows) {
            result += row.evenly_divisible_ratio();
        }
        return result;
    }
};


int main()
{
    Spreadsheet sheet;
    std::cin >> sheet;
    std::cout << sheet.sum_rows_evenly_divisible_ratio() << '\n';
}
