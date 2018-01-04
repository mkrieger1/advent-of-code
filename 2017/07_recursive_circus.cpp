#include <iostream>
#include <regex>
#include <vector>

int main()
{
    std::string line;
    while(std::getline(std::cin, line)) {
        std::regex outer{R"((\w+) \((\d+)\)(?: -> ((?:\w+(, |$))+))?)"};
        std::regex inner{R"(\w+)"};

        std::smatch match;
        if (!std::regex_match(line, match, outer)) continue;

        std::string name{match[1]};
        int weight{std::stoi(match[2])};
        std::cout << "name: " << name << '\n';
        std::cout << "weight: " << weight << '\n';

        auto rest{match[3].str()};
        if (!rest.length()) continue;

        std::cout << "rest: " << rest << '\n';

        std::vector<std::string> names;
        std::smatch subname;
        while (std::regex_search(rest, subname, inner)) {
            names.push_back(subname.str());
            rest = subname.suffix();
        }

        for (auto const& n : names) {
            std::cout << n << '\n';
        }
    }
}
