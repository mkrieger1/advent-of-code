#include "recursive_circus.h"
#include <regex>

Program::InvalidFormat::InvalidFormat()
  : std::runtime_error("Line has invalid format.")
{}

Program::Program(const Name& n, Weight w, std::vector<Name> supported)
  : name_{n}, weight_{w}, supported_{supported}
{}

Program::Program(const std::string& line)
{
    std::smatch line_match;
    if (!std::regex_match(line, line_match,
            std::regex{R"((\w+) \((\d+)\)(?: -> ((?:\w+(, |$))+))?)"}
    )) throw InvalidFormat{};

    name_ = line_match[1];
    weight_ = std::stoi(line_match[2]);

    auto names{line_match[3]};
    if (!names.length()) return;

    auto names_str{names.str()};
    std::smatch names_match;
    while (std::regex_search(names_str, names_match,
            std::regex{R"(\w+)"}
    )) {
        supported_.push_back(names_match.str());
        names_str = names_match.suffix();
    }
}

std::istream& operator>>(std::istream& input, Program& prog)
{
    std::string line;
    while (std::getline(input, line)) {
        try {
            Program dummy{line};
            std::swap(prog, dummy);
            break;
        } catch (Program::InvalidFormat) {
            continue;
        }
    }
    return input;
}


ProgramTower::NoBase::NoBase()
  : std::runtime_error("The base of the tower cannot be determined.")
{}

ProgramTower::SupportMap
ProgramTower::build_support_map(const NameMap& programs)
{
    SupportMap result;
    for (auto const& name_prog : programs) {
        auto supporter{name_prog.second};
        for (auto const& supported : supporter.supported()) {
            result.insert({supported, supporter.name()});
        }
    }
    return result;
}

Program::Name
ProgramTower::find_base(const NameMap& programs, const SupportMap& support)
{
    for (auto const& name_prog : programs) {
        auto name{name_prog.first};
        if (support.find(name) == std::end(support)) return name;
    }
    throw NoBase{};
}

ProgramTower::ProgramTower(const NameMap& programs)
  : programs_{programs},
    support_{build_support_map(programs_)},
    base_{find_base(programs_, support_)}
{}

ProgramTower::ProgramTower(const std::vector<Program>& programs)
{
    NameMap map;
    for (auto const& prog : programs) map.insert({prog.name(), prog});
    ProgramTower dummy{map};
    std::swap(*this, dummy);
}

std::istream& operator>>(std::istream& input, ProgramTower& tower)
{
    ProgramTower::NameMap programs;
    Program prog;
    while (input >> prog) programs.insert({prog.name(), prog});
    ProgramTower dummy{programs};
    std::swap(tower, dummy);
    return input;
}

Program::Weight ProgramTower::total_weight(const Program::Name& name)
{
    auto base{programs_.at(name)};
    Program::Weight result{base.weight()};
    for (auto const& sub : base.supported()) {
        result += total_weight(sub);
    }
    return result;
}

ProgramTower::BalanceResult
ProgramTower::check_balance(const Program::Name& name)
{
    // Map from weight to list of supported sub-towers with that weight.
    std::unordered_map<Program::Weight, std::vector<Program::Name>> weights;
    for (auto const& sub : programs_.at(name).supported()) {
        weights[total_weight(sub)].push_back(sub);
    }

    // All sub-towers have the same weight or there are no sub-towers.
    // -> This tower is balanced, no program in it has the wrong weight.
    if (weights.size() <= 1) {
        return {true, "", 0};
    }

    // Not all supported sub-towers have the same total weight.
    // According to the problem description we can assume that there is exactly
    // one sub-tower that has a different weight than all the others, and that
    // this is caused by exactly one program with the wrong weight.
    int correct_total_weight{0};
    Program::Name wrong_program{""};

    for (auto const& weight_subs : weights) {
        auto subs{weight_subs.second};
        if (subs.size() != 1) {
            // Found the "correct" total weight of all but one sub-tower.
            correct_total_weight = weight_subs.first;
            continue;
        }
        // The one sub-tower with the wrong total weight.
        for (auto const& sub : subs) {
            auto result{check_balance(sub)};
            if (result.balanced) {
                // The sub-tower is balanced, its base is the wrong program.
                wrong_program = sub;
                continue;
            }
            // The sub-tower is not balanced, the wrong program is further up.
            return result;
        }
    }

    // Determine the correct weight of the "wrong" program.
    auto correct_weight{
        programs_.at(wrong_program).weight()
        + correct_total_weight - total_weight(wrong_program)
    };
    return {false, wrong_program, correct_weight};
}
