#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

class Program {
public:
    using Name = std::string;
    using Weight = int;

    struct InvalidFormat : public std::runtime_error {
        InvalidFormat();
    };

    Program() = default;
    Program(const Name& n, Weight w, std::vector<Name> supported);
    Program(const std::string& line);

    friend std::istream& operator>>(std::istream& input, Program& prog);

    const Name& name() const { return name_; }
    Weight weight() const { return weight_; }
    const std::vector<Name>& supported() const { return supported_; }

private:
    Name name_;
    Weight weight_;
    std::vector<Name> supported_;
};

class ProgramTower {
public:
    // Map from name to program with that name.
    using NameMap = std::unordered_map<Program::Name, Program>;

    struct NoBase : public std::runtime_error {
        NoBase();
    };

    ProgramTower() = default;
    ProgramTower(const NameMap& programs);
    ProgramTower(const std::vector<Program>& programs);

    friend std::istream& operator>>(std::istream& input, ProgramTower& tower);

    // Return the total weight of the program with the given name, and all
    // sub-towers it is supporting.
    Program::Weight total_weight(const Program::Name& name);
    Program::Weight total_weight() { return total_weight(base()); }

    // Determine which program in the tower supported by the program with the
    // given name has the wrong weight (i.e. causes a sub-tower to be
    // unbalanced), assuming that there is exactly one such program.
    struct BalanceResult {
        bool balanced;
        Program::Name wrong_program;
        Program::Weight correct_weight;
    };
    BalanceResult check_balance(const Program::Name& name);
    BalanceResult check_balance() { return check_balance(base()); }

    Program::Name base() const { return base_; }

private:
    using SupportMap = std::unordered_map<Program::Name, Program::Name>;

    // Build a map from each program to the one it is supported by
    // (will contain all programs except the base of the tower).
    static SupportMap build_support_map(const NameMap&);
    // Find the base program (the one which is not supported by any other).
    static Program::Name find_base(const NameMap&, const SupportMap&);

    NameMap programs_;
    SupportMap support_;
    Program::Name base_;
};
