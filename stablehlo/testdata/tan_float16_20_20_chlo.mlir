// RUN: stablehlo-opt --chlo-pre-serialization-pipeline -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-opt --chlo-pre-serialization-pipeline %s | stablehlo-translate --serialize --target=current | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt --chlo-pre-serialization-pipeline %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xf16> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0 = call @inputs() : () -> tensor<20x20xf16>
    %1 = call @expected() : () -> tensor<20x20xf16>
    %2 = chlo.tan %0 : tensor<20x20xf16> -> tensor<20x20xf16>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<20x20xf16>, tensor<20x20xf16>) -> ()
    return %2 : tensor<20x20xf16>
  }
  func.func private @inputs() -> (tensor<20x20xf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x3F42B0454AC4D93047C48040623C61C59745E32FFA41B3BC8544BE3447C19DBF9A4020BE0A41B83BDCC50BC5D1C2C5C0C1B58442813E8A4334400A46BFBEFBA708BB3F3E06C5613A81C14DBD6EC334BD88BA2142753933C17BC1D4BFB63EDEB1B2BF60C2FF3C103EC5360D3CFEAA183B06B6C7C7193F033A34B98DBC4446EBBF114509C10A4009C67E4420B30740FA3DB6445C3FA94425C273BC25BE8A34D1BDD2B813C023C0FBC4E7BEFF4350B234337C4729C288471C3F6747A1291ABD8A3938C5A23C6D4435425EBF77BB4EB649416DC0173E1FC0324340BDAD3FA943FAB84FBC40B38439E6BE233DFAC3BEBAE6B1553ECD444EC4C146D4B246C15FBB0DC224C42AB78030EF3CF7BDFF430544DEC14947EFC542C0654055BCBEC4BA3FC4C162B1923C5E456FB7FB206CBFDAC5673F53B601C29E449144BDB209BD54431334C1BD42B88442E9B624C258B418C09A3C80BC0B3E2DC490B8B6C542BB52BC24C4E0B0EFB7783DF9394E41B7C1C9C502411F3F1A3E6B3FA1C13A33A9C4D843DD3E9845043C8CC53A3FBD379A41D53CA43C9140C5B985434CBEAF431AC57DBD423E62C53FB723C1373AA740D043BAB3314059C49E3EC040C03913C44AC06CBD573EE1BD543616B016BC98C31AC1CE455D3C9D4609C4A54429C00C407B3F00457CC352B20D40323ED243743E6CAA6938E84608BC59C294C4933D73460EC10ABE7EB862C3B3423041E0B8C93AE63EF0C4D33473C17CC2B84166BCEE3F1E47F3C22A3B4A40C4B86344B1313DC28EBC5CC1043DD0C60F39AEC207C550BFEDBF4EBE639E43393EB6AABD38405B396CC28C328DBA044525B3A244073FCE41653E2947EDBBEB42FAB56AB912389A44B8BFA3A690C0173C14407C3F9DC6E1B539C21B40B0B1F03C8741F231943D6040D2C5DB37F33E6B3363B7BD3F41B997BD34BAE9C4B943CC3D6DC647C0FDC05D40BDBD80C54546EF4201C5C1B9C444BC3AAEBB5EC0C941113F823F7AC00F40A5436BC33B3564BD4943C041BC3D0D44FEC34C3A81C03F38473A02B4E93C5FC2F7C066BE244658B9E23BF3C045BC264064C439BA1DC4D641C6462BC6E9BDB136FD41933D0EBDCEC321C3AD405441F13D3E2B6EBC85B9563C"> : tensor<20x20xf16>
    return %cst : tensor<20x20xf16>
  }
  func.func private @expected() -> (tensor<20x20xf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0xBFA46CB970C0E2304EC0F4BCC63F163DA6BAEE2FF2B0C9C01F45E2346738CB4178BC51CEBCB9C63D3737D3415EB48E3B03B6792F87CCCF39D0BEF9B34D48FCA7D4BCBE563842183C9336FBC32AB939C341BCF3AC7F3AD138CA36EB40A8C8EFB16E41E1A90042874C3537673E00ABE83C53B683CAD8C47A3B16BA53C07FA49E4069C1C33927C00D3478443FB337C0824A626140C3C84C722C0DC035CFAA3444C881B9F23F5E3F484369469C3C66B254332A41E22BFB41C5C41F40A22993C2A23A363F9240C942E0A8334367BDA8B65CB85A3D2C4D803FD93792C383C1953ABCB96EBF60B3993A7346C94286BC7DBCF7B11ED5A5C9A1C01338EFB26C3845BD792F37BEAFB78730B44145CA9C3CD23CC132423ED535673E87BD8ABF31504DC13C3470B1624036BD02B8FB20D7425F37F6C2ADB67F303D49CC46D6B234C29B382A3483C7B6B8792F60B7922C74B4C23F794030C0284CB9BE22B927391EBD7CBF37BEEAB054B8D844673B42B8AC345A38EDB9B4C4814DDDC26E355A33C8CCEB3BD9C699BA493E403B29C43438ADB545419840A1BC08BBB139915CBE3AE140F8C4ED580C3DC8B72A39DE3B3FBCAD3BE1B3E9BE3DC1FAC9B5BB003B65BD303E93C469D4EEC8AE361CB089BE26BA5E3926B8B03F7C35FABC5B4B2A3F1DC07BC2C3C27AB968B217C0B051BD3BE1CD6DAAEB38C03957BE21A867C796455D31A43917CC09B9E7B8C132E2B896B98A3C73C65D44F934163775AEA4B4DBBF95C0693C89B5FF3C30BE6CB9EC41C031C02557C0F7371A42AEB8DC396DB223429B439840D059639E2E3A95B669C6B2BE553A72ACA43247BC65C244B3464A51C5CEB37DD0CF3C1BBE413546B66DBA76387E485541A4A6A63C8C3EE9BF75C27CB528B6C027A6BFBFB1B8415AB603329E45A5BDFD374738F3C58E33F6B741C12ABAB6C5D7BBFD44033B184898B0453E0C3AB6BD4BC7F83BFEA26535AB4201BBB1CC7A3CB6BDB03D12B40BC553C2133D0DC07A3A1AB96C3568C461385EB43F47233D98BC043CEF3CB338FD3B18B49841A1A9323A565098B050BA083E4D3A43BF43BF00C2E1BBDBBD47B34538692F58C91D37C1B096454FC29EBB33B726BC23B8D749402B01C09ABA8F3F"> : tensor<20x20xf16>
    return %cst : tensor<20x20xf16>
  }
}