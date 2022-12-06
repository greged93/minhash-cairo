import json
from dataclasses import dataclass
from collections import defaultdict
import logging

LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(5)

MECH_STATUS = {
    "open": 0,
    "close": 1,
}
MECH_TYPE = {
    "SINGLETON": 0,
}
OPERATOR_TYPE = {
    "&": 0,
    "%": 1,
    "^": 2,
    "#": 3,
    "§": 4,
    "|": 5,
    "~": 6,
    "!": 7,
}
INSTRUCTIONS = {
    "W": 0,
    "A": 1,
    "S": 2,
    "D": 3,
    "Z": 4,
    "X": 5,
    "G": 6,
    "H": 7,
    "C": 8,
    ".": 9,
    "_": 9,
}


@dataclass
class Grid:
    x: int
    y: int


@dataclass
class Operator:
    x: int
    y: int
    type: int


def convert_mech(mech={}):
    if not mech:
        raise ValueError("expected mech")
    mech_id = mech["id"]
    id = int(mech_id[-1 - len(mech_id) % 5 :])
    return (
        id,
        MECH_TYPE[mech["typ"]],
        (mech["index"]["x"], mech["index"]["y"]),
    )


def convert_instructions(instructions=[]):
    if not instructions:
        raise ValueError("expected instructions")
    return [INSTRUCTIONS[i] for i in instructions if i != ","]


def import_json(path: str):
    with open(path, "r") as f:
        data = json.load(f)

    mechs = [convert_mech(mech) for mech in data["mechs"]]
    inputs = [
        (input["x"], input["y"], OPERATOR_TYPE[op["typ"]["symbol"]])
        for op in data["operators"]
        for input in op["input"]
    ]
    outputs = [
        (output["x"], output["y"], OPERATOR_TYPE[op["typ"]["symbol"]])
        for op in data["operators"]
        for output in op["output"]
    ]

    programs = [p.upper() for p in data["programs"]]
    instructions = sum(list(map(convert_instructions, programs)), [])

    return mechs, instructions, inputs, outputs


def mapping_instructions(instructions=[], local_offset=128):
    offset = defaultdict(lambda: 0)
    new = []
    for i in instructions:
        o = offset[i]
        new.append(o + (i + 1) * local_offset)
        offset[i] += 1
    return new


def mapping_mechs(grids=[Grid], global_offset=2048):
    offset = defaultdict(lambda: 0)
    new = []
    for g in grids:
        o = offset[g.x * 512 + g.y * 32]
        new.append(o + g.x * 512 + g.y * 32 + global_offset)
        offset[g.x * 512 + g.y * 32] += 1
    return new


def mapping_operators(operators=[Operator], global_offset=12288):
    new = []
    for o in operators:
        new.append(o.type * 256 + o.x * 16 + o.y + global_offset)
    return new


def test_mapping_instructions():
    result = mapping_instructions(
        instructions=[2, 4, 1, 0, 5, 7, 1, 6, 8, 3, 6, 2, 2, 2, 2, 5]
    )
    assert result == [
        384,
        640,
        256,
        128,
        768,
        1024,
        257,
        896,
        1152,
        512,
        897,
        385,
        386,
        387,
        388,
        769,
    ]


def test_mapping_mechs():
    result = mapping_mechs(
        grids=[
            Grid(1, 2),
            Grid(1, 3),
            Grid(0, 0),
            Grid(0, 0),
            Grid(0, 0),
            Grid(4, 6),
            Grid(9, 9),
            Grid(2, 9),
        ]
    )
    assert result == [
        2048 + 1 * 512 + 32 * 2,
        2048 + 1 * 512 + 32 * 3,
        2048,
        2049,
        2050,
        2048 + 4 * 512 + 32 * 6,
        2048 + 9 * 512 + 32 * 9,
        2048 + 2 * 512 + 32 * 9,
    ]


def test_mapping_operators():
    result = mapping_operators(
        operators=[
            Operator(1, 2, 2),
            Operator(1, 3, 5),
            Operator(0, 0, 3),
            Operator(4, 6, 6),
            Operator(8, 9, 1),
            Operator(2, 9, 0),
        ]
    )
    assert result == [
        12288 + 2 * 256 + 1 * 16 + 2,
        12288 + 5 * 256 + 1 * 16 + 3,
        12288 + 3 * 256,
        12288 + 6 * 256 + 4 * 16 + 6,
        12288 + 1 * 256 + 8 * 16 + 9,
        12288 + 2 * 16 + 9,
    ]


def test_compare_hashes():
    # Notes:
    import numpy as np

    solutions = [1, 4, 5, 11, 12, 13, 14, 15, 17, 18]
    hashes = np.zeros((10, 20))
    for (i, index) in enumerate(solutions):
        with open(f"./tests/data/hashed/solution_{index}.json", "r") as file:
            hashes[i] = np.array(json.load(file))
    differences = np.zeros((10, 10, 20))
    for (i, h1) in enumerate(hashes):
        for (j, h2) in enumerate(hashes):
            differences[i, j] = np.subtract(h1, h2)
    null = np.sum(differences == 0, axis=2)
    LOGGER.info(f"\n {null}")
