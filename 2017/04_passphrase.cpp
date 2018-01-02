#include <cstddef>
#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

using Word = std::string;
using Phrase = std::vector<Word>;
using WordCounts = std::unordered_map<Word, std::size_t>;

Phrase split_line(const std::string& line)
{
    Phrase result;
    std::stringstream linestream{line};
    Word w;
    while (std::getline(linestream, w, ' ')) {
        if (!w.empty()) result.push_back(w);
    }
    return result;
}

WordCounts count_words(const Phrase& phrase)
{
    WordCounts result;
    for (auto const& word : phrase) {
        ++result[word];
    }
    return result;
}

bool is_valid(const Phrase& phrase)
{
    WordCounts counts{count_words(phrase)};
    for (auto const& count : counts) {
        if (count.second > 1) return false;
    }
    return true;
}

std::size_t count_valid_phrases(const std::istream& input)
{
    std::size_t result{0};
    std::string line;
    while (std::getline(std::cin, line)) {
        if (is_valid(split_line(line))) ++result;
    }
    return result;
}

int main()
{
    auto valid_phrases{count_valid_phrases(std::cin)};
    std::cout << valid_phrases << '\n';
}
