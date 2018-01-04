#include <array>
#include <sstream>
#include <iostream>

class MemoryBanks {
public:
    MemoryBanks() = default;

    friend std::istream& operator>>(std::istream& input, MemoryBanks& mem)
    {
        std::string line;
        std::getline(input, line);
        std::stringstream linestream{line};
        int value;
        for (
            auto bank{std::begin(mem.banks_)};
            bank != std::end(mem.banks_);
            ++bank
        ) {
            linestream >> value;
            *bank = value;
        }
        return input;
    }

    void reallocate()
    {
        // find bank with maximum number of blocks
        auto bank{std::begin(banks_)};
        int max{0};
        for (
            auto search_max{std::begin(banks_)};
            search_max != std::end(banks_);
            ++search_max
        ) {
            if (*search_max <= max) continue;
            max = *search_max;
            bank = search_max;
        }
        // redistribute blocks
        *bank = 0;
        for (auto blocks{max}; blocks > 0; --blocks) {
            ++bank;
            if (bank == std::end(banks_)) bank = std::begin(banks_);
            ++(*bank);
        }
    }

    void print()
    {
        for (auto n : banks_) {
            std::cout << n << ' ';
        }
        std::cout << '\n';
    }

private:
    std::array<int, 16> banks_;
};

int main()
{
    MemoryBanks memory;
    std::cin >> memory;

    for (auto i{0}; i < 10; ++i) {
        memory.reallocate();
        memory.print();
    }
}
