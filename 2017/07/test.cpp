#include "recursive_circus.h"
#include <cassert>
#include <string>
#include <vector>

struct ProgramInputTest {
    std::string input;
    Program::Name name;
    Program::Weight weight;
    std::vector<Program::Name> supported;
};

const std::vector<ProgramInputTest> program_input_tests {
    {"a (1)",                         "a",     1, {}},
    {"a (2) -> b",                    "a",     2, {"b"}},
    {"pbga (66)",                     "pbga", 66, {}},
    {"fwft (72) -> ktlj, cntj, xhth", "fwft", 72, {"ktlj", "cntj", "xhth"}}
};

void test_program_input()
{
    for (auto const& test : program_input_tests) {
        Program p{test.input};
        assert(p.name() == test.name);
        assert(p.weight() == test.weight);
        assert(p.supported() == test.supported);
    }
}


struct ProgramTowerTest {
    std::vector<Program> programs;
    Program::Name base;
    Program::Weight total_weight;
    bool balanced;
    Program::Name wrong_program;
    Program::Weight correct_weight;
};

const std::vector<ProgramTowerTest> program_tower_tests {
    {{{"a", 3, {}}
     },
     "a", 3, true, "", 0},

    {{{"a", 3, {"b", "c"}},
      {"b", 1, {}},
      {"c", 1, {}}
     },
     "a", 5, true, "", 0},

    {{{"a", 3, {"b", "c", "d"}},
      {"b", 1, {}},
      {"c", 2, {}},
      {"d", 2, {}}
     },
     "a", 8, false, "b", 2},

    {{{"pbga", 66, {}},
      {"xhth", 57, {}},
      {"ebii", 61, {}},
      {"havc", 66, {}},
      {"ktlj", 57, {}},
      {"fwft", 72, {"ktlj", "cntj", "xhth"}},
      {"qoyq", 66, {}},
      {"padx", 45, {"pbga", "havc", "qoyq"}},
      {"tknk", 41, {"ugml", "padx", "fwft"}},
      {"jptl", 61, {}},
      {"ugml", 68, {"gyxo", "ebii", "jptl"}},
      {"gyxo", 61, {}},
      {"cntj", 57, {}}
     },
     "tknk", 778, false, "ugml", 60},
};

void test_program_tower()
{
    for (auto const& test : program_tower_tests) {
        ProgramTower tower{test.programs};

        assert(tower.base() == test.base);
        assert(tower.total_weight() == test.total_weight);

        ProgramTower::BalanceResult b{tower.check_balance()};
        assert(b.balanced == test.balanced);
        assert(b.wrong_program == test.wrong_program);
        assert(b.correct_weight == test.correct_weight);
    }
}

int main()
{
    test_program_input();
    test_program_tower();
}
