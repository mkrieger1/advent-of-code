#include <string>
#include <unordered_map>

class Machine {
public:
    using RegisterValue = int;
    using RegisterName = std::string;

    struct Instruction {
        enum class Operation { Inc, Dec };

        enum class Comparison {
            Equal, Unequal,
            Less, LessEqual,
            Greater, GreaterEqual
        };

        static Operation to_operation(const std::string&);
        static Comparison to_comparison(const std::string&);

        // evaluate "a <cmp> b"
        static bool evaluate(Comparison cmp, RegisterValue a, RegisterValue b);

        Instruction(const std::string& line);
        friend std::istream& operator>>(std::istream&, Instruction);

        RegisterName target;
        Operation operation;
        RegisterValue operation_amount;
        RegisterName source;
        Comparison comparison;
        RegisterValue compare_value;
    };

    void execute(const Instruction&);
    RegisterValue max_register_value() const;

private:
    std::unordered_map<RegisterName, RegisterValue> registers_;
};