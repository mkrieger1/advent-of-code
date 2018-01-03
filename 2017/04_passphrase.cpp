#include <cstddef>
#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

using Word = std::string;
using Phrase = std::vector<Word>;
using WordCounts = std::unordered_map<Word, std::size_t>;
using LetterCounts = std::unordered_map<char, std::size_t>;

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

LetterCounts count_letters(const Word& word)
{
    LetterCounts result;
    for (auto const& c : word) {
        ++result[c];
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

bool are_anagrams(const Word& w1, const Word& w2)
{
    return count_letters(w1) == count_letters(w2);
}

bool is_valid(const Phrase& phrase)
{
    for (auto i{0}; i < phrase.size(); ++i) {
        for (auto j{0}; j < i; ++j) {
            if (are_anagrams(phrase[i], phrase[j])) return false;
        }
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
