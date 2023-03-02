// RUN: diff <(stablehlo-opt %s.0_9_0.bc --vhlo-to-version=target=current --vhlo-legalize-to-stablehlo) <(stablehlo-opt %s)
// RUN: diff <(stablehlo-opt %s --stablehlo-legalize-to-vhlo --vhlo-to-version=target=current -emit-bytecode | stablehlo-opt --vhlo-legalize-to-stablehlo) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0:2 = call @inputs() : () -> (tensor<2x3x9x10xf16>, tensor<3x3x4x5xf16>)
    %1 = call @expected() : () -> tensor<2x3x6x6xf16>
    %2 = stablehlo.convolution(%0#0, %0#1) dim_numbers = [b, f, 0, 1]x[o, i, 0, 1]->[b, f, 0, 1], window = {} {batch_group_count = 1 : i64, feature_group_count = 1 : i64} : (tensor<2x3x9x10xf16>, tensor<3x3x4x5xf16>) -> tensor<2x3x6x6xf16>
    %3 = stablehlo.custom_call @check.eq(%2, %1) : (tensor<2x3x6x6xf16>, tensor<2x3x6x6xf16>) -> tensor<i1>
    return %3 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<2x3x9x10xf16>, tensor<3x3x4x5xf16>) {
    %0 = stablehlo.constant dense<"0x72B54D433A4449B5754438C72CC2AA42554418C4C1BEF0C0BD3C10C5C8C5EEBCC53849418B3D272B0138C616B5C39D33C44164C238C3C4411940C5BA0A372848EAC710427AB7A7414340B5C0633A70395B44E9C1A7C4D43853B91F3B7334E63D4FBCCBC32DBD5EC2B8BA94BE9CBDAFBB6BC1F63B453FD4C21E2F764371C4F53055BDADB271BED3BAF8BEFFB712C672B88744AE2A6145C3C423C1C539024331C3CDC3C7432DC538C03B3F58476DC217368646DFB9AE40ECC4954011427EC458B909C09845DBC27DBD48C347B764BD0F40BABC4EBB10C599BF9A3D1440A0BF8340863CEB43003DEEC2814798B5F8B8A6313A47783518B410C2FC3FEE3868BE0243F83811BB8340FD454A32773453449BC4EF4700408A423FC486C43FC31A427CC56AC41EC41EC108433EC12A3BD7B92244C0408EC3FDBE1F45A63E443C8A46A540B0BAFD424DC0E3B1173905BE173D24BDB7C0B73DE14029C1BB42D1C100C01B346C3F8F4223C1D7439CB6FE423A44C2B44F3D0EBE8ABB6EBDD2BCECC068464AC15945DD44CE3EA53A893A87BC47C392B6D8B7AEB9F9C549333EBF3EC54A43DB40144568B8BC3BA3B11ABDB6C1A436433543BD1138F9C3204498C195C2C04471BF4ABBC0C1953CFCC0D644AD353CC454C208C0153C93C2843A35B6C33E68C475BE6AC56446F5C410444643D5C426C2DD355743E04441B856BD10C4DC4116390ABEDE4062C0BDC7FE3D4945F23ED8C2B4BE3D44CFB13FC53CC0C43064424E39B2C2613CEC4300C2D23B64C1AEC07E3EAD3EE941D44022323FBF1BC3D13D11BC89C4BA35563B86374EC56338A62A16B8FBC1764545C2103B58391CBC1EB75EBCA23AEAC3A6C41540ADC54F44F9C4FCC106C284C145C55F42E13D31BE38C052AD0139D23E37C69EB16640614098BC31C2A7407CC1433A79458E309FBCCF3C37C6B541EC32C1C55E3E1B423E451B398EBB46BC87B877403FC304BF11BB37405F3CD8C77A44F4412844BE45084678C40FC09AC2AD44AFBC873F2A3BD1C243B4A1C3014247BCD34127C6A63D7BBE1B3EC3B55DC1D5C2C7BF2D4293BCB1C29EBDB9B8DDAD8E4302BF2CB0BD3938BCDEC031C5723524C53539EEC5B3B84ABD043C34BD4CBA60BEF140DAC43F3BAF40E6BAD8BE4238B2C078C4F3441FBB2D44EDC1FE4025BFD025DD3AC33B3CC415C625C4303FB1B78AC1D541AC40844017C30E44FCC066A709428BC2EC2EF73FA63E64C1052C7640173644C19AB5774165C18D39A8428EC37BC1034339350AC0A7BF694461BF57BCE4C5C143CA3CCC40794037B9DE2C55C23232C4C00AC4F1BDCD3C9BBDE941AE43303E4ABF293DD441C7B8ED4065444FBCE53FDB3DC5C129C30DC454BEC73C4BC2383CEEB87EC1DBC103C490BFBF4356B96D3DEEC5A6BB973E86C1A7BA05C1694603C1AF3F423B4EC0A545562A2CBD573CABBD0FC0EEC6C9407A41493223BDD0BE8D45C0B6BBBD0843923453C3303C78424CB33FBFF5B18E40F43B1538B6405ABAA0BE47B566B94F3D"> : tensor<2x3x9x10xf16>
    %1 = stablehlo.constant dense<"0x78C2DFB67CC47EBF5E3874BCF5B93CC4D7BF823B803C27BC47BC4941CBBC24BD8EBE924101C120C1AFC0BE3820C17AC4F93433C121344DBC9436593D16C4BF3E73B83C45BC44B043B6BFF7405D45844063B8FA44143CF3B24CC858C4D0C81FC090B8B4A61B45D741033F15C53D3F393BD3B441C67CBA293F383BC63F12B4A3C13EC571C4B640B43DB9C1664917B2F8C2DB4010C2193C4FC7FCC0753EEC450AC69BC11243ACBEACBDFB380042B5BF394452C17A450AC279414C3647BC6746424050244043A9B1EBC5ACC4A13C1F453FA6D9C1C83D6E4337BC883D4BBAD245E8431142F43E74BE5F443AB9314023C3723EFE3E7ABFD5B46CBD12B42A405043C444E645B53D29441C385CC088439EBC764702C4A43BC1BD35BE40C7D8BC42BF00BC0EB8BE223E3D863D954400BEB7C4FE457CC1B3B31E3EDB40AEAE0735D4BE0A3E71C033BBABBC09B999442141A43BC04235C192C0334121B186387CC1243C8C3EDA3A02B02D3607B1"> : tensor<3x3x4x5xf16>
    return %0, %1 : tensor<2x3x9x10xf16>, tensor<3x3x4x5xf16>
  }
  func.func private @expected() -> tensor<2x3x6x6xf16> {
    %0 = stablehlo.constant dense<"0x3DD0E54B1AD2A2347BCAC6BD97CB4D5941543F599159C940444C1ED6A5541CD1B4D6B64E1CD02CD8BCCE8F55FF5208520B509D546552015644D39ACD9A4C2ECC48435D4CD7569B5709D724D1BD5522CE19D62F54BDD22B528D4634D444535ED5DE4EBFD13959AAD73CD5C05747D8FCD579502754494527D716CE77544AD8024879D1C954E25590D67B565B4018CF17C821D1055087D733D34C4B8350B0542D529BD614CAEBD1E2461A5385D87E52114BE5D17854EFD79B581CD89B5484D1145058D7AFD589D52DD5E65439CE06D42254ABC7A7528CD0FA55FD4F065677548D4C3E50344A394AD1CDFC4CA0CC43D291B18850B9D4A95843C579527050E053DE57B7522A54E04B3CCD4B4334BD0DD26D5812D5DFCC014D04B7A652A25700D43FD3834C7256A1D387D59F4C86C72DD129D0DB57ADD5B3521CD172D87ECE15D195D4DBCA76D42B525BD20ED56D5881D3F7CD9EC64BD66C53DC55E9D4C9D2CAD4D05818D5974A6F4732CE3CCB40CB8DD67F5497D7FAD2035485D4CBC3E0D0DD4873524B566CD9D5D3BCD4E8C38FD229D5AB464BCBA155894FEAD1635525544651A6D376D5C754D25010D6D5D449CCF84E8051"> : tensor<2x3x6x6xf16>
    return %0 : tensor<2x3x6x6xf16>
  }
}
