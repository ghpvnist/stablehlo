// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xbf16> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0 = call @inputs() : () -> tensor<20x20xbf16>
    %1 = call @expected() : () -> tensor<20x20xbf16>
    %cst = stablehlo.constant dense<-1.000000e+00> : tensor<bf16>
    %2 = stablehlo.broadcast_in_dim %cst, dims = [] : (tensor<bf16>) -> tensor<20x20xbf16>
    %3 = stablehlo.compare  NE, %0, %2,  FLOAT : (tensor<20x20xbf16>, tensor<20x20xbf16>) -> tensor<20x20xi1>
    %4 = stablehlo.multiply %0, %0 : tensor<20x20xbf16>
    %cst_0 = stablehlo.constant dense<1.000000e+00> : tensor<bf16>
    %5 = stablehlo.broadcast_in_dim %cst_0, dims = [] : (tensor<bf16>) -> tensor<20x20xbf16>
    %6 = stablehlo.subtract %5, %4 : tensor<20x20xbf16>
    %7 = stablehlo.sqrt %6 : tensor<20x20xbf16>
    %cst_1 = stablehlo.constant dense<1.000000e+00> : tensor<bf16>
    %8 = stablehlo.broadcast_in_dim %cst_1, dims = [] : (tensor<bf16>) -> tensor<20x20xbf16>
    %9 = stablehlo.add %8, %0 : tensor<20x20xbf16>
    %10 = stablehlo.atan2 %7, %9 : tensor<20x20xbf16>
    %cst_2 = stablehlo.constant dense<2.000000e+00> : tensor<bf16>
    %11 = stablehlo.broadcast_in_dim %cst_2, dims = [] : (tensor<bf16>) -> tensor<20x20xbf16>
    %12 = stablehlo.multiply %11, %10 : tensor<20x20xbf16>
    %cst_3 = stablehlo.constant dense<3.140630e+00> : tensor<bf16>
    %13 = stablehlo.broadcast_in_dim %cst_3, dims = [] : (tensor<bf16>) -> tensor<20x20xbf16>
    %14 = stablehlo.select %3, %12, %13 : tensor<20x20xi1>, tensor<20x20xbf16>
    stablehlo.custom_call @check.expect_close(%14, %1) {has_side_effect = true} : (tensor<20x20xbf16>, tensor<20x20xbf16>) -> ()
    return %14 : tensor<20x20xbf16>
  }
  func.func private @inputs() -> (tensor<20x20xbf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x9340C1BF6E406E3FDF40B83E21C0DEBF823F3E3EB63E3ABF10C07CC01C40B33DD43FB93E423F203FF7BF7E40C2BF94C089C09640B440ECBF9240D6BFF73FD04023C0EDBF7F40C7BF69C0F93FA7BF733FABBFF8BF06C067C0CABF64C03F40C03F8C3E4D40F93B1D3F6CBF0B40C63E1B4081406340B6C07ABFE8C0E7BFDDBED8BED43F1C3EF8BED73F633D82407D3F99C073BFE23E81BF553E81C0E63F13401C40B2BE4E403A3F034187C0003F25C08D3F883FECBE83C0803F40C088BFB040BFBED53E01BD1840DA3F3EC0373F5D3E413EEDBF853F0FBFA7BF51C0BDC0883D874061C06240323F9DC048BFFE3FB44019BFA9BFBB3F43401240D43F9C408540B1BF6B3F89C0793F82C0EC3F8B3F9C3F98C0E9BF86C0AABF86BFE9BF20C0A540F43F8B3E2DC02640B440B74011C081BC573EDF40DCBE04409C40C340B4405F402840B7BED9C00AC018C0844022C011409D3FEBBF45403CC0D63FA2BF803E0341A340973E8140F3BFCF3E504086BFE83E27BF8840EFC0A33E03404EC0D93E14C052C0E03EA33F693E07BF80BF8A4044BFCA3F384055BF0FC0BFBF943DF53F7B3E3B407640BC3FF53F23BF80C084407E3F88402E3F04C034402DC0A2BD2EC0EE3E4C3E20C022403ABF4A40493F163FA83FDE3F5CBF883E7640A54032C0CB3FB13E88BFA33E5C40A03F19BD4B406AC00AC0C0C0083F00C0173ED9C0D8BF0CC0D03F0641BFBF913F92BF044069C0A9BF6BC030C09F408540963FFEBD49C086C03BC088BF1A40C1405AC0693F993E64BF8BC09FC0583FF0BF87BF1FBFF1401540BCBF11C0BD3F64BFAB3E67C05DC0053FB3BFD43FD8BF52C050C008BFC33EF93F643F1B4021C08EBF4ABF79C097BF62BF73C00CBF2BC0123FC43F64BFAC3C4C3F28BD89C0BCBF4A3E7740803F0B41F33FA2C034BF3E3FB7C089C06B40EB3E92BE94BF0741D5402F40DD3F1F40714040C0CABE133FB7C085BFDE3F8940A44062BFDD4073BFA1C0BD4058BF53BFEABF53C04740D5BF1340FF3D80405740AD3F7F4094BFB540724089C0EF3FDB40BE40D03F113E91C0F93F9BBFB3BF91BC95409CBE363E874059C0D83FB73FA6BF1ABF87BE184078BE22BFD2BF8FC027BF183FFEBFDBC05EC0"> : tensor<20x20xbf16>
    return %cst : tensor<20x20xbf16>
  }
  func.func private @expected() -> (tensor<20x20xbf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0xC0FFC0FFC0FFC23EC0FF9A3FC0FFC0FFC0FFB13F9A3F1940C0FFC0FFC0FFBE3FC0FF9A3F363F653FC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFA23EC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFA53FC0FFC83F693F2F40C0FF963FC0FFC0FFC0FFC0FF3B40C0FFC0FF01400040C0FFB53F0540C0FFC23FC0FF1E3EC0FF34408F3FC0FFAE3FC0FFC0FFC0FFC0FFF63FC0FF423FC0FFC0FF863FC0FFC0FFC0FF0340C0FF0000C0FFC0FFC0FFFA3F923FCD3FC0FFC0FFC0FF463FAD3FB13FC0FFC0FF0A40C0FFC0FFC0FFC13FC0FFC0FFC0FF4D3FC0FF1E40C0FFC0FF0D40C0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFCF3EC0FF723EC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFA53FC0FFC0FFC0FFC0FFC0FFCB3FAE3FC0FF0140C0FFC0FFC0FFC0FFC0FFC0FFF83FC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFA93FC0FFC0FFA33FC0FFC0FF943FC0FFC0FF8D3F1240C0FFC0FFA03FC0FFC0FF913FC0FFC0FF8F3FC0FFAC3F08404940C0FF1C40C0FFC0FF2340C0FFC0FFC03FC0FFAA3FC0FFC0FFC0FFC0FF1140C0FFC0FF003EC0FF533FC0FFC0FFC0FFD33FC0FF8B3FAF3FC0FFC0FF1940C0FF2B3F713FC0FFC0FF2740A73FC0FFC0FFC0FFC0FF9C3FC0FFA03FC0FFC0FFCE3FC0FFC0FFC0FFC0FF813FC0FFB63FC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFD93FC0FFC0FFC0FFC0FFC0FFC0FFC0FFDB3EA23F2B40C0FFC0FF123FC0FFC0FF0F40C0FFC0FFC0FFC0FFC0FF2B409E3FC0FFC0FF843FC0FFC0FFC0FFC0FFC0FF0840973FC0FFF23EC0FFC0FFC0FF1F40C0FFC0FF2A40C0FF0A40C0FF763FC0FF2B40C63F253FCE3FC0FFC0FFB03FC0FF0000C0FFC0FFC0FF16403C3FC0FFC0FFC0FF8C3FEE3FC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFFD3F753FC0FFC0FFC0FFC0FFC0FF2A40C0FF3440C0FFC0FF25402340C0FFC0FFC0FFC0FFC0FFB93FC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFC0FFB73FC0FFC0FFC0FFC0FFCC3FC0FFF13FB23FC0FFC0FFC0FFC0FFC0FF0E40EC3FC0FFE83F1140C0FFC0FF12406F3FC0FFC0FFC0FF"> : tensor<20x20xbf16>
    return %cst : tensor<20x20xbf16>
  }
}
