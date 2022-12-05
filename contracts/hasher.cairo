%lang starknet
from starkware.cairo.common.registers import get_label_location

const C = 65537;
const HASH_LENGTH = 20;

func get_a() -> felt* {
    let (data_address) = get_label_location(data_start);
    return cast(data_address, felt*);

    data_start:
    dw 15831;
    dw 29294;
    dw 19012;
    dw 7318;
    dw 43096;
    dw 17766;
    dw 23277;
    dw 16089;
    dw 52362;
    dw 39966;
    dw 25327;
    dw 59654;
    dw 20816;
    dw 1290;
    dw 23891;
    dw 57036;
    dw 10225;
    dw 57019;
    dw 51045;
    dw 13855;
}

func get_b() -> felt* {
    let (data_address) = get_label_location(data_start);
    return cast(data_address, felt*);

    data_start:
    dw 47784;
    dw 50919;
    dw 3423;
    dw 56944;
    dw 14634;
    dw 36940;
    dw 34534;
    dw 52669;
    dw 64966;
    dw 43297;
    dw 30583;
    dw 37728;
    dw 54597;
    dw 18270;
    dw 25613;
    dw 36829;
    dw 51565;
    dw 48161;
    dw 4434;
    dw 41513;
}
