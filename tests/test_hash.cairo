%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

from contracts.minhash import hash_function, minhash
from contracts.hasher import get_a, get_b, C, HASH_LENGTH

@external
func setup{range_check_ptr}() {
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
    let minhash_value = minhash(input_len=test_len, input=input);
    %{
        for i in range(ids.HASH_LENGTH):
            assert minhash[i] == memory[ids.minhash_value + i], f'minhash error, expected {minhash[i]}, got {memory[ids.minhash_value + i]}'
    %}
    return ();
}
