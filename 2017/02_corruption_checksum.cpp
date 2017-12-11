#include <iostream>
#include <iterator>
#include <sstream>
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
};


int main() {
    Spreadsheet sheet;
    std::cin >> sheet;
}
