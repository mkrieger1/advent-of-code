#include <iostream>
#include <iterator>
#include <sstream>
#include <vector>

class JumpMaze {
public:
    JumpMaze() = default;
    JumpMaze(const std::vector<int>& instructions)
      : position_{0}, instructions_{instructions}
    {}

    friend std::istream& operator>>(std::istream& input, JumpMaze& maze)
    {
        std::string line;
        while (std::getline(input, line)) {
            int instruction;
            std::stringstream linestream{line};
            linestream >> instruction;
            maze.instructions_.push_back(instruction);
        }
        return input;
    }

    bool would_exit()
    {
        auto max{instructions_.size() - 1};
        auto target{position_ + instructions_[position_]};
        return target < 0 || target > max;
    }

    // assumes the jump would not exit the maze
    void jump()
    {
        auto old_position{position_};
        position_ += instructions_[position_];
        if (instructions_[old_position] >= 3) {
            --instructions_[old_position];
        } else {
            ++instructions_[old_position];
        }
    }

private:
    int position_;
    std::vector<int> instructions_;
};

int main()
{
    JumpMaze maze;
    std::cin >> maze;

    int steps{1};
    while (!maze.would_exit()) {
        maze.jump();
        ++steps;
    }

    std::cout << steps << '\n';
}
