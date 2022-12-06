%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

from contracts.minhash import hash_function, minhash
from contracts.hasher import get_a, get_b, C, HASH_LENGTH

@external
func __setup__{range_check_ptr}() {
    %{
        import importlib  
        utils = importlib.import_module("tests.utils")
        context.import_json = utils.import_json
        context.mapping_instructions = utils.mapping_instructions
        context.mapping_mechs = utils.mapping_mechs
        context.mapping_operators = utils.mapping_operators
        context.Grid = utils.Grid
        context.Operator = utils.Operator
    %}
    return ();
}

@external
func test_hash{range_check_ptr}() {
    alloc_locals;
    local a;
    local b;
    let (local input) = alloc();
    let test_len = 200;
    %{
        from random import randint
        input_data = []
        for i in range(ids.test_len):
            val = randint(1, ids.C - 1)
            memory[ids.input + i] = val
            input_data.append(val)
        ids.a = a = randint(1, ids.C - 1)
        ids.b = b = randint(1, ids.C - 1)
        hash_function = lambda x: (x*a+b)%ids.C
        minhash = min(map(hash_function, input_data))
    %}
    let minhash = hash_function(input_len=test_len, input=input, min=10 ** 6, a=a, b=b);
    %{ assert minhash == ids.minhash, f'minhash error, expected {minhash}, got {ids.minhash}' %}
    return ();
}

@external
func test_minhash{range_check_ptr}() {
    alloc_locals;
    local a: felt* = get_a();
    local b: felt* = get_b();
    let (local input) = alloc();
    let test_len = 200;
    %{
        from random import randint
        input_data = []
        minhash = []
        for i in range(ids.test_len):
            val = randint(1, ids.C - 1)
            memory[ids.input + i] = val
            input_data.append(val)
        for i in range(ids.HASH_LENGTH):
            a = memory[ids.a + i]
            b = memory[ids.b + i]
            hash_function = lambda x: (x*a+b)%ids.C
            minhash.append(min(map(hash_function, input_data)))
    %}
    let (minhash_value) = minhash(input_len=test_len, input=input);
    %{
        for i in range(ids.HASH_LENGTH):
            assert minhash[i] == memory[ids.minhash_value + i], f'minhash error, expected {minhash[i]}, got {memory[ids.minhash_value + i]}'
    %}
    return ();
}

@external
func test_minhash_different_solutions{range_check_ptr}() {
    alloc_locals;
    let (local set_1: felt*) = alloc();
    let (local set_2: felt*) = alloc();

    local len_1;
    local len_2;
    %{
        (mechs, instructions, inputs, outputs) = context.import_json("./tests/data/raw/solution_6.json")
        i = context.mapping_instructions(instructions)
        g = context.mapping_mechs([context.Grid(x, y) for (_, _, (x, y)) in mechs])
        inputs = context.mapping_operators([context.Operator(x, y, t) for (x, y, t) in inputs])
        ouputs = context.mapping_operators([context.Operator(x, y, t) for (x, y, t) in outputs])
        set_1 = i + g + inputs + ouputs
        segments.write_arg(ids.set_1, set_1)
        ids.len_1 = len(set_1)

        (mechs, instructions, inputs, outputs) = context.import_json("./tests/data/raw/solution_2.json")
        i = context.mapping_instructions(instructions)
        g = context.mapping_mechs([context.Grid(x, y) for (_, _, (x, y)) in mechs])
        inputs = context.mapping_operators([context.Operator(x, y, t) for (x, y, t) in inputs])
        ouputs = context.mapping_operators([context.Operator(x, y, t) for (x, y, t) in outputs])
        set_2 = i + g + inputs + ouputs
        segments.write_arg(ids.set_2, set_2)
        ids.len_2 = len(set_2)
    %}

    let (local minhash_value_1) = minhash(input_len=len_1, input=set_1);
    let (local minhash_value_2) = minhash(input_len=len_2, input=set_2);

    %{
        diff = 0
        for i in range(ids.HASH_LENGTH):
            if memory[ids.minhash_value_1 +i] != memory[ids.minhash_value_2 +i]: diff += 1
        assert 8 == diff, f'hash difference error, expected 8, got {diff}'
    %}
    return ();
}

@external
func setup_hash_all() {
    %{
        example(id=1)
        example(id=4)
        example(id=5)
        example(id=11)
        example(id=12)
        example(id=13)
        example(id=14)
        example(id=15)
        example(id=17)
        example(id=18)
    %}
    return ();
}

@external
func test_hash_all{range_check_ptr}(id: felt) {
    alloc_locals;
    let (local set: felt*) = alloc();
    local len;

    %{
        (mechs, instructions, inputs, outputs) = context.import_json(f'./tests/data/raw/solution_{ids.id}.json')
        i = context.mapping_instructions(instructions)
        g = context.mapping_mechs([context.Grid(x, y) for (_, _, (x, y)) in mechs])
        inputs = context.mapping_operators([context.Operator(x, y, t) for (x, y, t) in inputs])
        ouputs = context.mapping_operators([context.Operator(x, y, t) for (x, y, t) in outputs])
        s = i + g + inputs + ouputs
        segments.write_arg(ids.set, s)
        ids.len = len(s)
    %}

    let (local minhash_value) = minhash(input_len=len, input=set);
    %{
        import json
        h = []
        for i in range(ids.HASH_LENGTH):
            h.append(memory[ids.minhash_value + i])
        with open(f'./tests/data/hashed/solution_{ids.id}.json', "w") as file:
            json.dump(h, file)
    %}
    return ();
}
