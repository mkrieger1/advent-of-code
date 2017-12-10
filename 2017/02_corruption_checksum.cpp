#include <iostream>
#include <iterator>
#include <string>
#include <sstream>
#include <vector>

// A row in the spreadsheet consists of a list of numbers.
class Row {
    std::vector<int> numbers;

    friend std::ostream& operator<<(std::ostream& output, const Row& row) {
        std::copy(
            std::begin(row.numbers), std::end(row.numbers),
            std::ostream_iterator<int>{output, " "}
        );
        return output;
    }

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

    friend std::ostream&
    operator<<(std::ostream& output, const Spreadsheet& sheet) {
        std::copy(
            std::begin(sheet.rows), std::end(sheet.rows),
            std::ostream_iterator<Row>{output, "\n"}
        );
        return output;
    }

public:
    int size() { return rows.size(); }
};


int main() {
    Spreadsheet sheet;
    std::cin >> sheet;
    std::cout << "The spreadsheet has " << sheet.size() << " rows:\n";
    std::cout << sheet << '\n';
}
