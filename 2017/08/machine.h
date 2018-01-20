#include <stdexcept>
#include <string>
#include <unordered_map>

class Machine {
public:
    using RegisterName = std::string;
    using RegisterValue = int;

    struct Instruction {
        enum class Operation { Inc, Dec };

        enum class Comparison {
            Equal, Unequal,
            Less, LessEqual,
            Greater, GreaterEqual
        };

        struct ParseError : public std::runtime_error {
            ParseError(const std::string& what_arg);
        };

        static Operation to_operation(const std::string&);
        static Comparison to_comparison(const std::string&);

        // evaluate "a <cmp> b"
        static bool evaluate(Comparison cmp, RegisterValue a, RegisterValue b);

        Instruction() = default;
        Instruction(const std::string& line);
        friend std::istream& operator>>(std::istream&, Instruction&);

        RegisterName target;
        Operation operation;
        RegisterValue operation_amount;
        RegisterName source;
        Comparison comparison;
        RegisterValue compare_value;
    };

    void execute(const Instruction&);
    RegisterValue max_value() const;
    RegisterValue all_time_max_value() const { return all_time_max_; };

private:
    RegisterValue all_time_max_{0};
    std::unordered_map<RegisterName, RegisterValue> registers_;
};
