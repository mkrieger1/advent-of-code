from dataclasses import dataclass
from enum import Enum
from sys import stdin
from typing import Callable, Dict, List, Optional, Tuple, TypeVar


T = TypeVar("T")


def main() -> None:
    records = parseRecords()
    result1 = solve("Part1", records)
    result2 = 0 #solve("Part2", records)
    print(f"Part 1: {result1}")
    print(f"Part 2: {result2}")


class Condition(Enum):
    Operational = 0
    Damaged = 1
    Unknown = 2


@dataclass
class Records:
    conditions: List[Condition]
    groups: List[int]

    def __hash__(self):
        return hash((tuple(self.conditions), tuple(self.groups)))

    def __str__(self):
        return "".join(
            {
                Condition.Operational: ".",
                Condition.Damaged: "#",
                Condition.Unknown: "?"
            }[c]
            for c in self.conditions
        ) + " " + str(self.groups)


def parseRecords() -> List[Records]:
    return [parseLine(line) for line in stdin]


def parseLine(line: str) -> Records:
    x, y = line.split()
    conditions = parseConditions(x)
    groups = parseGroups(y)
    return Records(conditions, groups)


def parseConditions(s: str) -> List[Condition]:
    return [
        {
            ".": Condition.Operational,
            "#": Condition.Damaged,
            "?": Condition.Unknown
        }[c]
        for c in s
    ]


def parseGroups(s: str) -> List[int]:
    return list(map(int, s.split(",")))


def unfoldRecords(records: Records) -> Records:
    return Records(
        conditions=(
            (records.conditions + [Condition.Unknown]) * 4
            + records.conditions
        ),
        groups=records.groups * 5
    )


def dropPrefix(lst: List[T], elem: T) -> List[T]:
    for i, x in enumerate(lst):
        if x != elem:
            break
    else:
        return lst
    return lst[i:]


def dropOperational(conditions: List[Condition]) -> List[Condition]:
    return dropPrefix(conditions, Condition.Operational)


def prefixLength(lst: List[T], elem: T) -> int:
    for i, x in enumerate(lst):
        if x != elem:
            break
    else:
        return len(lst)
    return i


class MatchFirstResult(Enum):
    NoMatch = 0
    Match = 1
    ChoiceNeeded = 2


def matchFirstDamaged(
    conditions: List[Condition], expectedLength: int
) -> Tuple[MatchFirstResult, List[Condition]]:
    assert prefixLength(conditions, Condition.Operational) == 0

    numDamaged = prefixLength(conditions, Condition.Damaged)
    try:
        next_ = conditions[numDamaged]
    except IndexError:
        next_ = None

    if numDamaged > expectedLength:
        return MatchFirstResult.NoMatch, []

    elif numDamaged == expectedLength:
        if next_ == Condition.Unknown:
            return MatchFirstResult.ChoiceNeeded, []
        elif next_ in (Condition.Operational, None):
            return (
                MatchFirstResult.Match,
                dropOperational(conditions[numDamaged + 1:])
            )
        else:
            assert False, "impossible"

    else:
        assert numDamaged < expectedLength
        if next_ == Condition.Unknown:
            return MatchFirstResult.ChoiceNeeded, []
        else:
            return MatchFirstResult.NoMatch, []


def makeChoice(
    conditions: List[Condition]
) -> Optional[Callable[[Condition], List[Condition]]]:
    for i, c in enumerate(conditions):
        if c == Condition.Unknown:
            break
    else:
        return None

    def choose(condition):
        conditions[i] = condition
        return dropOperational(conditions)

    return choose


def arrangements(cache, r: Records) -> Tuple[Dict, int]:
    print(r)
    if not r.groups:
        if any(c == Condition.Damaged for c in r.conditions):
            return cache, 0
        else:
            return cache, 1

    choose = makeChoice(r.conditions)
    first, *rest = r.groups
    if choose is None:
        match, remaining = matchFirstDamaged(r.conditions, first)
        if match is MatchFirstResult.NoMatch:
            return cache, 0
        elif match is MatchFirstResult.Match:
            return memo(cache, arrangements, Records(remaining, rest))
        else:
            assert match is MatchFirstResult.ChoiceNeeded
            assert False, "impossible"

    result = 0
    for condition in (Condition.Operational, Condition.Damaged):
        choice = choose(condition)
        match, remaining = matchFirstDamaged(choice, first)
        if match is MatchFirstResult.NoMatch:
            pass
        elif match is MatchFirstResult.Match:
            cache, n = memo(cache, arrangements, Records(remaining, rest))
            result += n
        else:
            assert match is MatchFirstResult.ChoiceNeeded
            cache, n = memo(cache, arrangements, Records(choice, r.groups))
            result += n

    return cache, result


def memo(cache, f, arg: Records):
    try:
        value = cache[arg]
    except KeyError:
        cache, value = f(cache, arg)
        cache[arg] = value
    return cache, value


def solve(part: str, records: List[Records]) -> int:
    if part == "Part1":
        unfold = lambda r: r
    elif part == "Part2":
        unfold = unfoldRecords
    else:
        assert False

    result = 0
    for r in records:
        r = unfold(r)
        record = Records(dropOperational(r.conditions), r.groups)
        _, value = memo({}, arrangements, record)
        result += value

    return result


if __name__ == "__main__":
    main()
