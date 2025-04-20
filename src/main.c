#include <stdio.h>
#include "zig_calculator.h"

int main() {
    int result_sum = add(3, 7);
    printf("3 + 7 = %d\n", result_sum);
    int result_mul = mul(3, 7);
    printf("3 * 7 = %d\n", result_mul);
    return 0;
}

