// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<3x5x40xi64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<1> : tensor<2x1xi64>
    %0:2 = call @inputs() : () -> (tensor<3x5x40xi64>, tensor<3x5x2xi64>)
    %1 = call @expected() : () -> tensor<3x5x40xi64>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [2], scatter_dims_to_operand_dims = [2], index_vector_dim = 1>}> ({
    ^bb0(%arg0: tensor<i64>, %arg1: tensor<i64>):
      %3 = stablehlo.minimum %arg0, %arg1 : tensor<i64>
      stablehlo.return %3 : tensor<i64>
    }) : (tensor<3x5x40xi64>, tensor<2x1xi64>, tensor<3x5x2xi64>) -> tensor<3x5x40xi64>
    stablehlo.custom_call @check.expect_eq(%2, %1) {has_side_effect = true} : (tensor<3x5x40xi64>, tensor<3x5x40xi64>) -> ()
    return %2 : tensor<3x5x40xi64>
  }
  func.func private @inputs() -> (tensor<3x5x40xi64> {mhlo.layout_mode = "default"}, tensor<3x5x2xi64> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0x0000000000000000030000000000000005000000000000000600000000000000F9FFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFF0000000000000000070000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFF03000000000000000700000000000000FEFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF01000000000000000000000000000000FFFFFFFFFFFFFFFF01000000000000000000000000000000FFFFFFFFFFFFFFFF03000000000000000000000000000000FCFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFF03000000000000000100000000000000FBFFFFFFFFFFFFFF030000000000000000000000000000000200000000000000FAFFFFFFFFFFFFFF010000000000000000000000000000000200000000000000FEFFFFFFFFFFFFFF000000000000000002000000000000000000000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF01000000000000000400000000000000FCFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF00000000000000000200000000000000020000000000000005000000000000000000000000000000F9FFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0600000000000000F7FFFFFFFFFFFFFF00000000000000000500000000000000F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF0400000000000000FEFFFFFFFFFFFFFF0100000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFF00000000000000000000000000000000FDFFFFFFFFFFFFFF000000000000000000000000000000000200000000000000010000000000000005000000000000000200000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000200000000000000FEFFFFFFFFFFFFFF010000000000000002000000000000000000000000000000F7FFFFFFFFFFFFFF02000000000000000100000000000000000000000000000001000000000000000000000000000000FFFFFFFFFFFFFFFF000000000000000005000000000000000000000000000000000000000000000004000000000000000200000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF00000000000000000000000000000000FDFFFFFFFFFFFFFFF9FFFFFFFFFFFFFF01000000000000000100000000000000FEFFFFFFFFFFFFFF0000000000000000000000000000000003000000000000000500000000000000FDFFFFFFFFFFFFFF0300000000000000FFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF05000000000000000000000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFF0500000000000000FEFFFFFFFFFFFFFF0000000000000000030000000000000000000000000000000300000000000000040000000000000000000000000000000100000000000000020000000000000000000000000000000500000000000000010000000000000000000000000000000000000000000000FCFFFFFFFFFFFFFF0500000000000000FEFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF0000000000000000030000000000000004000000000000000000000000000000FAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000100000000000000020000000000000002000000000000000800000000000000FFFFFFFFFFFFFFFF010000000000000000000000000000000100000000000000FEFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFF000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFF0600000000000000FDFFFFFFFFFFFFFF010000000000000002000000000000000000000000000000FBFFFFFFFFFFFFFF020000000000000001000000000000000000000000000000FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0500000000000000FBFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF010000000000000004000000000000000000000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03000000000000000000000000000000FDFFFFFFFFFFFFFF00000000000000000000000000000000FDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0000000000000000000000000000000001000000000000000100000000000000FEFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF02000000000000000000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0100000000000000020000000000000001000000000000000000000000000000FEFFFFFFFFFFFFFF04000000000000000000000000000000FFFFFFFFFFFFFFFF00000000000000000400000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF07000000000000000200000000000000FEFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF01000000000000000500000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000100000000000000FCFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0000000000000000000000000000000000000000000000000100000000000000FBFFFFFFFFFFFFFF01000000000000000100000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF01000000000000000300000000000000FBFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF010000000000000003000000000000000000000000000000FDFFFFFFFFFFFFFF0200000000000000010000000000000000000000000000000200000000000000FFFFFFFFFFFFFFFF0200000000000000FCFFFFFFFFFFFFFF00000000000000000400000000000000FBFFFFFFFFFFFFFF00000000000000000000000000000000F8FFFFFFFFFFFFFFFBFFFFFFFFFFFFFF0200000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0200000000000000020000000000000000000000000000000300000000000000FFFFFFFFFFFFFFFF000000000000000000000000000000000200000000000000000000000000000001000000000000000300000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF02000000000000000300000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000500000000000000030000000000000002000000000000000100000000000000030000000000000000000000000000000400000000000000FEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0600000000000000FDFFFFFFFFFFFFFF01000000000000000200000000000000040000000000000000000000000000000300000000000000000000000000000002000000000000000400000000000000FEFFFFFFFFFFFFFF0000000000000000010000000000000000000000000000000000000000000000FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF000000000000000002000000000000000200000000000000040000000000000000000000000000000000000000000000FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000100000000000000060000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFF04000000000000000100000000000000FBFFFFFFFFFFFFFF0200000000000000000000000000000000000000000000000300000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0100000000000000030000000000000002000000000000000100000000000000070000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFF00000000000000000200000000000000FBFFFFFFFFFFFFFF0300000000000000000000000000000002000000000000000100000000000000040000000000000000000000000000000300000000000000010000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000FDFFFFFFFFFFFFFF00000000000000000000000000000000FEFFFFFFFFFFFFFF0200000000000000F9FFFFFFFFFFFFFF000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FAFFFFFFFFFFFFFF05000000000000000400000000000000F9FFFFFFFFFFFFFF04000000000000000000000000000000F9FFFFFFFFFFFFFF0100000000000000FFFFFFFFFFFFFFFF0400000000000000FFFFFFFFFFFFFFFF000000000000000002000000000000000100000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF030000000000000001000000000000000000000000000000FAFFFFFFFFFFFFFF03000000000000000200000000000000FEFFFFFFFFFFFFFF01000000000000000000000000000000FFFFFFFFFFFFFFFF00000000000000000100000000000000FEFFFFFFFFFFFFFF0100000000000000010000000000000003000000000000000100000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF050000000000000003000000000000000400000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF040000000000000003000000000000000300000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000010000000000000002000000000000000000000000000000FBFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF00000000000000000000000000000000000000000000000002000000000000000000000000000000FDFFFFFFFFFFFFFF0200000000000000000000000000000000000000000000000000000000000000FDFFFFFFFFFFFFFF01000000000000000300000000000000FEFFFFFFFFFFFFFF00000000000000000000000000000000FFFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000300000000000000FEFFFFFFFFFFFFFF0400000000000000FFFFFFFFFFFFFFFF00000000000000000300000000000000FEFFFFFFFFFFFFFF0300000000000000FDFFFFFFFFFFFFFF000000000000000003000000000000000000000000000000FDFFFFFFFFFFFFFF03000000000000000000000000000000FDFFFFFFFFFFFFFF000000000000000002000000000000000000000000000000020000000000000000000000000000000000000000000000050000000000000002000000000000000000000000000000FEFFFFFFFFFFFFFF0100000000000000070000000000000000000000000000000400000000000000FDFFFFFFFFFFFFFF000000000000000003000000000000000000000000000000000000000000000003000000000000000100000000000000FDFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFF04000000000000000000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF030000000000000000000000000000000000000000000000040000000000000001000000000000000200000000000000FEFFFFFFFFFFFFFF03000000000000000000000000000000F9FFFFFFFFFFFFFF0300000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF040000000000000003000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0400000000000000FAFFFFFFFFFFFFFF010000000000000004000000000000000700000000000000FDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF0000000000000000000000000000000000000000000000000200000000000000FFFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF010000000000000003000000000000000200000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0500000000000000FFFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFF00000000000000000000000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF00000000000000000000000000000000FDFFFFFFFFFFFFFF"> : tensor<3x5x40xi64>
    %c_0 = stablehlo.constant dense<[[[5, 1], [3, 1], [0, 0], [8, -1], [0, 0]], [[6, 3], [-6, 3], [1, 1], [-3, 2], [2, 0]], [[1, -1], [0, 0], [-6, -1], [-1, 3], [0, -2]]]> : tensor<3x5x2xi64>
    return %c, %c_0 : tensor<3x5x40xi64>, tensor<3x5x2xi64>
  }
  func.func private @expected() -> (tensor<3x5x40xi64> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0x0000000000000000010000000000000005000000000000000600000000000000F9FFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFF0000000000000000070000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFF03000000000000000700000000000000FEFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF01000000000000000000000000000000FFFFFFFFFFFFFFFF01000000000000000000000000000000FFFFFFFFFFFFFFFF03000000000000000000000000000000FCFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFF03000000000000000100000000000000FBFFFFFFFFFFFFFF030000000000000000000000000000000200000000000000FAFFFFFFFFFFFFFF010000000000000000000000000000000200000000000000FEFFFFFFFFFFFFFF000000000000000002000000000000000000000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF01000000000000000400000000000000FCFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF00000000000000000200000000000000020000000000000005000000000000000000000000000000F9FFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0600000000000000F7FFFFFFFFFFFFFF00000000000000000500000000000000F7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF0400000000000000FEFFFFFFFFFFFFFF0100000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFF00000000000000000000000000000000FDFFFFFFFFFFFFFF000000000000000000000000000000000200000000000000010000000000000005000000000000000200000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000200000000000000FEFFFFFFFFFFFFFF010000000000000002000000000000000000000000000000F7FFFFFFFFFFFFFF02000000000000000100000000000000000000000000000001000000000000000000000000000000FFFFFFFFFFFFFFFF000000000000000005000000000000000000000000000000000000000000000004000000000000000200000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFF9FFFFFFFFFFFFFF01000000000000000100000000000000FEFFFFFFFFFFFFFF0000000000000000000000000000000003000000000000000500000000000000FDFFFFFFFFFFFFFF0300000000000000FFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF05000000000000000000000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFF0500000000000000FEFFFFFFFFFFFFFF0000000000000000030000000000000000000000000000000300000000000000040000000000000000000000000000000100000000000000020000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000FCFFFFFFFFFFFFFF0500000000000000FEFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF0000000000000000030000000000000004000000000000000000000000000000FAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000100000000000000020000000000000002000000000000000800000000000000FFFFFFFFFFFFFFFF010000000000000000000000000000000100000000000000FEFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFF000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFF0600000000000000FDFFFFFFFFFFFFFF010000000000000002000000000000000000000000000000FBFFFFFFFFFFFFFF020000000000000001000000000000000000000000000000FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0500000000000000FBFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF010000000000000004000000000000000000000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03000000000000000000000000000000FDFFFFFFFFFFFFFF00000000000000000000000000000000FDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0000000000000000000000000000000001000000000000000100000000000000FEFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF02000000000000000000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0100000000000000020000000000000001000000000000000000000000000000FAFFFFFFFFFFFFFF04000000000000000000000000000000FFFFFFFFFFFFFFFF00000000000000000400000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF07000000000000000200000000000000FEFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF01000000000000000500000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000100000000000000FCFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0000000000000000000000000000000000000000000000000100000000000000FBFFFFFFFFFFFFFF01000000000000000100000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF01000000000000000300000000000000FBFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF010000000000000003000000000000000000000000000000FDFFFFFFFFFFFFFF0200000000000000010000000000000000000000000000000200000000000000FFFFFFFFFFFFFFFF0200000000000000FCFFFFFFFFFFFFFF00000000000000000400000000000000FBFFFFFFFFFFFFFF00000000000000000000000000000000F8FFFFFFFFFFFFFFFBFFFFFFFFFFFFFF0200000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0200000000000000020000000000000000000000000000000300000000000000FFFFFFFFFFFFFFFF000000000000000000000000000000000200000000000000000000000000000001000000000000000300000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0200000000000000FDFFFFFFFFFFFFFF000000000000000000000000000000000400000000000000000000000000000000000000000000000500000000000000030000000000000002000000000000000100000000000000030000000000000000000000000000000400000000000000FEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0600000000000000FDFFFFFFFFFFFFFF01000000000000000200000000000000040000000000000000000000000000000300000000000000000000000000000002000000000000000400000000000000FEFFFFFFFFFFFFFF0000000000000000010000000000000000000000000000000000000000000000FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF000000000000000002000000000000000200000000000000040000000000000000000000000000000000000000000000FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000100000000000000060000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFF04000000000000000100000000000000FBFFFFFFFFFFFFFF0200000000000000000000000000000000000000000000000300000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0100000000000000030000000000000002000000000000000100000000000000070000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFF00000000000000000200000000000000FBFFFFFFFFFFFFFF030000000000000000000000000000000200000000000000010000000000000004000000000000000000000000000000030000000000000001000000000000000000000000000000060000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF00000000000000000000000000000000FEFFFFFFFFFFFFFF0200000000000000F9FFFFFFFFFFFFFF000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FAFFFFFFFFFFFFFF05000000000000000400000000000000F9FFFFFFFFFFFFFF04000000000000000000000000000000F9FFFFFFFFFFFFFF0100000000000000FFFFFFFFFFFFFFFF0400000000000000FFFFFFFFFFFFFFFF000000000000000002000000000000000100000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF030000000000000001000000000000000000000000000000FAFFFFFFFFFFFFFF03000000000000000200000000000000FEFFFFFFFFFFFFFF01000000000000000000000000000000FFFFFFFFFFFFFFFF00000000000000000100000000000000FEFFFFFFFFFFFFFF0100000000000000010000000000000003000000000000000100000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF050000000000000003000000000000000400000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF040000000000000003000000000000000300000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000010000000000000002000000000000000000000000000000FBFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF00000000000000000000000000000000000000000000000002000000000000000000000000000000FDFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000FDFFFFFFFFFFFFFF01000000000000000300000000000000FEFFFFFFFFFFFFFF00000000000000000000000000000000FFFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000300000000000000FEFFFFFFFFFFFFFF0400000000000000FFFFFFFFFFFFFFFF00000000000000000300000000000000FEFFFFFFFFFFFFFF0300000000000000FDFFFFFFFFFFFFFF000000000000000003000000000000000000000000000000FDFFFFFFFFFFFFFF03000000000000000000000000000000FDFFFFFFFFFFFFFF0000000000000000020000000000000000000000000000000200000000000000000000000000000000000000000000000500000000000000FFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF0100000000000000070000000000000000000000000000000400000000000000FDFFFFFFFFFFFFFF000000000000000003000000000000000000000000000000000000000000000003000000000000000100000000000000FDFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFF04000000000000000000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF030000000000000000000000000000000000000000000000040000000000000001000000000000000200000000000000FEFFFFFFFFFFFFFF03000000000000000000000000000000F9FFFFFFFFFFFFFF0300000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF040000000000000003000000000000000000000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0400000000000000FAFFFFFFFFFFFFFF010000000000000004000000000000000700000000000000FDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF0000000000000000000000000000000000000000000000000200000000000000FFFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF010000000000000003000000000000000200000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0500000000000000FFFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFF00000000000000000000000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF00000000000000000000000000000000FDFFFFFFFFFFFFFF"> : tensor<3x5x40xi64>
    return %c : tensor<3x5x40xi64>
  }
}