// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<3x2xbf16> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0 = call @inputs() : () -> tensor<2x3xbf16>
    %1 = call @expected() : () -> tensor<3x2xbf16>
    %2 = stablehlo.transpose %0, dims = [1, 0] : (tensor<2x3xbf16>) -> tensor<3x2xbf16>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<3x2xbf16>, tensor<3x2xbf16>) -> ()
    return %2 : tensor<3x2xbf16>
  }
  func.func private @inputs() -> (tensor<2x3xbf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[3.281250e+00, -3.261720e-01, 1.906250e+00], [-4.316410e-01, 2.453130e+00, 5.843750e+00]]> : tensor<2x3xbf16>
    return %cst : tensor<2x3xbf16>
  }
  func.func private @expected() -> (tensor<3x2xbf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[3.281250e+00, -4.316410e-01], [-3.261720e-01, 2.453130e+00], [1.906250e+00, 5.843750e+00]]> : tensor<3x2xbf16>
    return %cst : tensor<3x2xbf16>
  }
}