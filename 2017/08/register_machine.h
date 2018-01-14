#include <string>

struct Instruction {
    Instruction(const std::string& line);
};

class RegisterMachine {
public:
    using RegisterValue = int;
    RegisterValue max_register_value() const;
    void execute(const Instruction&);
};
