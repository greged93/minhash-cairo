%lang starknet
from starkware.cairo.common.registers import get_label_location

const C = 65537;
const HASH_LENGTH = 20;

func get_a() -> felt* {
    let (data_address) = get_label_location(data_start);
    return cast(data_address, felt*);

    data_start:
    dw 64954;
    dw 8736;
    dw 38583;
    dw 45773;
    dw 6795;
    dw 14171;
    dw 13674;
    dw 24461;
    dw 2096;
    dw 27535;
    dw 62882;
    dw 42808;
    dw 37438;
    dw 65114;
    dw 22209;
    dw 5336;
    dw 34232;
    dw 39561;
    dw 19132;
    dw 55464;
}

func get_b() -> felt* {
    let (data_address) = get_label_location(data_start);
    return cast(data_address, felt*);

    data_start:
    dw 12617;
    dw 65125;
    dw 34074;
    dw 22447;
    dw 59473;
    dw 23542;
    dw 55930;
    dw 29237;
    dw 5336;
    dw 21350;
    dw 41294;
    dw 34601;
    dw 17507;
    dw 27755;
    dw 16220;
    dw 61921;
    dw 19189;
    dw 42033;
    dw 42777;
    dw 16746;
}
