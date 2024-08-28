// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<2xbf16> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0:2 = call @inputs() : () -> (tensor<2xbf16>, tensor<2xbf16>)
    %1 = call @expected() : () -> tensor<2xbf16>
    %2 = stablehlo.divide %0#0, %0#1 : tensor<2xbf16>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<2xbf16>, tensor<2xbf16>) -> ()
    return %2 : tensor<2xbf16>
  }
  func.func private @inputs() -> (tensor<2xbf16> {mhlo.layout_mode = "default"}, tensor<2xbf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[-2.140630e+00, -1.328130e+00]> : tensor<2xbf16>
    %cst_0 = stablehlo.constant dense<[3.496090e-01, 1.687500e+00]> : tensor<2xbf16>
    return %cst, %cst_0 : tensor<2xbf16>, tensor<2xbf16>
  }
  func.func private @expected() -> (tensor<2xbf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[-6.125000e+00, -7.851560e-01]> : tensor<2xbf16>
    return %cst : tensor<2xbf16>
  }
}