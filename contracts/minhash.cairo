%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le

from contracts.hasher import get_a, get_b, HASH_LENGTH, C

func minhash{range_check_ptr}(input_len: felt, input: felt*) -> felt* {
    alloc_locals;
    tempvar a = get_a();
    tempvar b = get_b();
    let (local hash) = alloc();
    loop_hash(input_len=input_len, input=input, hash_len=0, hash=hash, a=a, b=b);
    return hash;
}

func loop_hash{range_check_ptr}(
    input_len: felt, input: felt*, hash_len: felt, hash: felt*, a: felt*, b: felt*
) {
    if (hash_len == HASH_LENGTH) {
        return ();
    }
    let temp = hash_function(input_len=input_len, input=input, min=10 ** 5, a=[a], b=[b]);
    assert [hash] = temp;
    return loop_hash(
        input_len=input_len, input=input, hash_len=hash_len + 1, hash=hash + 1, a=a + 1, b=b + 1
    );
}

func hash_function{range_check_ptr}(
    input_len: felt, input: felt*, min: felt, a: felt, b: felt
) -> felt {
    if (input_len == 0) {
        return min;
    }
    let (_, r) = unsigned_div_rem([input] * a + b, C);
    let is_r_less = is_le(r, min);
    if (is_r_less == 1) {
        return hash_function(input_len=input_len - 1, input=input + 1, min=r, a=a, b=b);
    }
    return hash_function(input_len=input_len - 1, input=input + 1, min=min, a=a, b=b);
}
