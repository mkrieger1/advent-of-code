#include <array>
#include <sstream>
#include <iostream>
#include <set>

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

    // implement comparison to be able to insert it into a set
    bool operator<(const MemoryBanks& other) const
    {
        for (auto i{0}; i < banks_.size(); ++i) {
            if (banks_[i] == other.banks_[i]) continue;
            return banks_[i] < other.banks_[i];
        }
        return false;
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

private:
    std::array<int, 16> banks_;
};


std::size_t reallocations_until_loop(MemoryBanks& memory)
{
    std::set<MemoryBanks> seen;
    while (seen.count(memory) == 0) {
        MemoryBanks copy{memory};
        seen.insert(copy);
        memory.reallocate();
    }
    return seen.size();
}


int main()
{
    MemoryBanks memory;
    std::cin >> memory;

    std::cout << reallocations_until_loop(memory) << '\n';
    // count again, starting from the last allocation before a cycle
    std::cout << reallocations_until_loop(memory) << '\n';
}
