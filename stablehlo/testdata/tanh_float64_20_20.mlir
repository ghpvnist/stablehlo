// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xf64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0 = call @inputs() : () -> tensor<20x20xf64>
    %1 = call @expected() : () -> tensor<20x20xf64>
    %2 = stablehlo.tanh %0 : tensor<20x20xf64>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<20x20xf64>, tensor<20x20xf64>) -> ()
    return %2 : tensor<20x20xf64>
  }
  func.func private @inputs() -> (tensor<20x20xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0xF165A4B74BC1F2BF0E4A64BEAA86D63FBE763204AF200EC04DE30FE7F6FC1340ECA55777FEBFBCBF1A441E10FE4019C073C6D44E001611C0B227FBD21A2FE83F28DA80CD882AE93F5FE2C48740510FC0302BA0F5A7511040C3F52AAA71F91EC0F6E3D833E56806C0080578FF8C23F13F0E2790A99EC1FD3FB9DDB1563D210A40D2181A4D15D20EC0204828AD9A7303C0252733EC752AC2BFEAB171B4284C0BC0BA7F7A77689514C001526A791F100540E8387FD5C2AFEB3F0BB312248AAD11402A8907BFE15012C081C6528D2E3617C0C8C1819493DDC3BFA14B25F390AC01408C13955D261FE3BFAA5A7B44AD471240F2DFA2A43BD5EEBFC66FB2095D39E8BF737952912C52FABFCCF8B56E30E00140CAA1826C32000F402B6F3F2E345BE5BFDC3832382F89F83F0F36A40E87DBB1BF96AFCE8C06EFCBBF72A45064202B04C0122DB86D7B8A16C0E9F6319CF0E211C085BB5D43C75C07C01F91E195A9B00D40B94D31A695FD0640E69E310BC02C523F943F1F362DDAED3F7CF446358C190640229F302A30AEF63FCA56D61FFE9AF23F7156A4D5470FE73FA73252B510C810C03057CED6DA621740BBE9E545338D06C00736F9A3AC4C0740B4A0829E9519E3BFC55BF07ABD111040CFE1CCEEF352BFBF28C929ECD007E03F1BAAA26EB9EE03C000509858C946F63F70F683CBCBB2D23F422921704B4812405F6BD07C04E3F33FB4711DD5DBFEACBFD29D3A836087CE3F5BE8B13A6DEFC83F4785FFD931B2154058CE4427F0F5FC3F9094850A385DF43F72BED6EC555C02406670C2E6909CEBBFC25498FB8B06FDBF891EEB67506D00409E6E826F867101C092C4A35A91FEFABFAAFF52CBA7F00BC06AFC1AB5DF7209C0E0C54B7232F71240CA7981CB0F97E13F2E949825F41801C0467F6A0151981DC0D67426DDA186EABFD234B68F010DEBBF80F30465CE2A10C0C757D7F5EE570EC0B32C22FF06B30AC07E21698698C911C00EE6F947E47209C0B2038246642C00407C2B4A1630EFD4BFA0BDA2261B26084027F108E1780813C03E12815015E5D3BF53733A2ADDE11340FCAA026B16A8BA3F4157EA20E9B3F6BF20CC852D8F1812C0A198AACFCE4EFC3F004D6253FE92E03F2808862D11681340E0BF80B609C7F5BF12D5C3655DEC0F4072CB83C985360040BC7ACB08EBBF0EC0F03D3E0EE91009C06213419A2D801440292FF0AE0C9A144054471E573721EEBF76833A46B22A0C401A25FC729671F5BF68589CF569FFDBBF6168BDE2D2F0004064710A5EBB6601C0F8BB382FE598FA3F376C10D460E012C05F120F22E22908C09E8F0D006EE58EBFE97C2760AAAD02C07A0B0F63FCFA0340AC5306567C4CFBBF10A8EFF10F79C03F93546446474CEC3F32DFD75C30E30740F00A2304CB8D14403D67CCED7A43F0BF8C8BDBB3FF730540951AE25704EF07C0683FE4CDC8F601C0C85EDE267B1414401E73F39436A3E0BF0183525B09E3E5BF3FE7DFD5A20CE23F5005F6D1141CD5BF9B4E7F0DBC15EEBF8692120AC66209C00E06DA74FA72D7BFF424772FF067134066D5A09BFEC414C0F8E40089D2B113C0989B658A99D6F83F50AE0033ADEDFC3F0C06BF15D3D3F53F8CD42AC20DCBF83F60426B9F5C6C0240E254643FFD7C08C01A0ECB563952F43F7C0953DB38D70040EA75ABC8143AE53F480886412F44CCBF06851554A151CFBFC64A697CA53EFEBFBE13676E00A1F73F2080E6CCF3181040BEA70F1CD4C2E33F02EA31F8DCBF1A4090573F88F4DBF4BF86F54AD902E1DCBF2EA4EDD929A9E23F804F4D5819A9903F8C03C6D7A5291140CABCC49F24F2144003A33045723C044048B94B41760F044016914FFA7613E3BF5C2A8B1BC72CF7BF1B10EE41413EFFBF250C7680AD0704C0C6415E5203F6C53FB8E0A5FDE700FB3F38785BFDC6DFEC3F52F0AF49511800403D7C17CC5E0A11C0B3575205DBC402C003D7F3B5764DE13FBB4BB05D3E300540EA1B32F3B5A19DBF4C6E3AEA4FE408400A5504284D87D2BFF2AFED3601640740AA7B96BEA8A701403254F13405A3F9BFFC09894C729B07C0800E2BDBDBBAD53F75DD692A46F5D93F8B690DA81E4402C0E11EEEC3B9BEF73FBA49C7A6FEE401C0D81F759AA26FF7BF3E3F8389DD6D04C018AFCB9757CAF5BF86A85009B18EE4BF0D8059BCFDA0F3BF356A11FB90F90D4032B28472B01DC2BF570B99E49B10FFBF5607C1DC5BAD0D4090CC3F7CF1B5DB3F85F829FE299F08C0EE8B1B59619C0CC0885C298C9EA2ECBF549E30EDB96EB83F42284F9F3F6CC1BFFF65B9BCB584DD3F8CF1DC7EA61C0FC01C6596B0CC83E03F6FEEDD2B51B710C0A36EE2E70A410D4030306E1984B3C2BF33A8A7F7C767F43FB6008355552702C0C5250F3B38062040251BD02BF5BC17409C861892CAA5DD3F545AEBFAA9BC1A4014C36EBBEA94DE3F5673ABB01404104056BAEA5FFE00F2BF35CC1D940C2410C0C05D9127737911409D44359EAA24EE3FA4E031E4864AF6BFD069BA735F820EC07F7DEABD017302C0F86BCAF5F3CE0140C6EBF49B42090240502715D5935C0A40E8A622B3531D20C00750A49CB211FC3F28BDEB757ACBA93FF5B6115F90C701C0BA4B732E47300640243E59B0382F1DC0895EC4390B4CF13FDC50BF7C283FF23F13EFEE9D6222E9BF673646EDFE780AC087BE0B1B046612C000BA96666ADBDF3FE1D95AA375BC07C0C5560AC7685A1240BDFA41D4EF7703408E65F84E518BD93F3666FA03C468F03F1ADBC258FCC101C0244F4315333FACBFE6732D401BDDF03F46E20673653B00408B2189D5AC056B3F01BFC8A1FCFF64BF19B8D4BEE5E802C0C37DA13C7771E73F27C1EDD5BD9704C04026EF12C84FC7BFF62BC2115F8F0A409997228536E515403F65A5182458FBBF40A4ABEB69C6E8BF480B41B137DCE4BF87DB4095CB170A404F1E84E9D46A03409083121F0BC401409CAEAD144F2A0540B87409647EE01AC0D49D2B355A6A0BC0EE5AE3242034FE3F301AEFEA155203C0224EECA513BD0A408EE342D254C41440948390AAD0661140F363EE7E36F0FABFFEDF0DCF8AF4F2BF26CA2D980BBF014061CBC6EEB032004090971EB0AAA4EB3FBC83901B3AF3E7BF7CE98DBEDD99B23F129F5A28B01615C02ECB348B4B3B0D40F828CD2C4AC91340604B466A0565C0BF961BC9CCCCAEFDBFDA7ECAB749FF01C0124E8979BF12EEBF167172733C5F0E4078B1BBFA01D5F8BFF2101CA4D83221401AB67A69A916EE3F73CC2D280CA3D33F6023533D1B6DED3F008FC2DC55B812C0225EBD926932EDBFB6EE3B6EB2930540041FFA2956AD18C0AAA36636A84D10C03F38B13F43CE09C02AD9CAE5CF55F3BF1ACA951E8C2EE53F4FA75FB26A731640DA893C0F8C150740A062A4C057A9F3BFA63472F2A342AF3F8C022FA596A503404430C0D4F74811409D0347AE668B12C0C5A019B35F2AD33F10736BFC304402C0967C09DE9ACADD3FC86023321C48E63F260F4082808E04C09E85B00F494304409CA6B82DB4FBFF3FACD40FA4D5F2CE3FDA475DF87784EBBF4B5BAEAEE1100C4054EBBA6FDF39ECBFE027D16626EEFB3F28EE526FFA4921C0AC4982B7AF8209408E5DA93BC861E53F60E638DA721517C0C750AC8C08BAEF3FBDA2A08B2BF1E33F6760349D660A02C0A5832940271815C0973A10FE90570F4061120737067C00C0CF95365BC154F43F54228F0B3D55FEBFF90DE76316D911C0D534C802AEBF04C0303E185B143213C0A32BF155BAEDEA3F27872A313A76ABBFD58E7245494404405BA7FF9078F9F1BFF8A6F9062707FB3F3618B8438131D4BF23560A84A4220040BFD9D2C77F72F13FC62C83C0F022F43F55A8CE6F9332C7BF3C4A89A689D2DDBFCA2E99D7EE29064018B7857B92430040739E7670A1AEE2BF33B46FAA69C2C33F42F5BCCB6F1F0E409ED6270F57C8C1BF525DC59F5C9AF13FDAAD11AD5C521040763DB456717C20C0015501E5BC1F12C0A46BE09BFD1EEABF7FED0A4C9DE411C01896DFE5C41B01C0C2338053C67EF6BFD65F031A3B64FBBF2DA89BC86EB9E7BF0F6DCB0980EFE43F901D93451AA701C08AE8D9C58DB807C0944943C13D86F53FE4949FA84A9E0440D2DB3879334B00C0087E1CCEBB960140E3A9DF12CAAFF8BFAA986CD9925816C033AC0EF56C9CF7BFE2E4704B912CFABF637502CA8D64FABF04D8AF51B5540740BD07157E57B618C0DB49B96E18B80E40E36E803DE520AD3FEE766E803D0EFD3F089BAE632B3305C0AA6CBA678594C3BFA8EC7EBE7551FF3F21F252624A340FC06A398B351D6A04408BE03AD4E1EA18C01471596733B519C0AC1C2092C3080B4076342EDB672D0CC0069A765BA73DCDBF1AF87A417E46034002D0401BDF9F0AC051DE9B2823C0F7BFB1C75ED390B4E5BFCB3535CBFD0FEEBF7FC2F39E47C107C0C1315B188D3010401AF680286938E2BF7C04AE1F16E603C09AC204E84EDECDBFC659BF0611ACF6BF4C5DE77B4D71F13FD8F6A20929E2E03FC759295F0E0209C0"> : tensor<20x20xf64>
    return %cst : tensor<20x20xf64>
  }
  func.func private @expected() -> (tensor<20x20xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x095B459B2E66EABF0E6C4821C6A3D53F64F6C6453AF7EFBFB0FD8F7440FFEF3FC56D400535A1BCBF891C923BF2FFEFBF78F670A5CEFCEFBF42170CC3236FE43FA0BDF01F2301E53F03BC3BD07BF9EFBF3D8025BB50FBEF3F9E273636FFFFEFBFEDD959A6C8C3EFBF06C48326E746E93FF1C3ACD92B7CEE3F98607E6530E8EF3F243776549FF8EFBFA2C403A85A82EFBFCDECA7DA7C0BC2BFBD50F5EC35EEEFBF657816C771FFEFBFECA4C07BCDABEF3F30937C11A25DE63F6B2A1D04A0FDEF3F2FC3EC1046FEEFBF19D73AC7D9FFEFBF8928405B22B5C3BF5E608612E43CEF3F17A8DF5C3921E1BF6350C00C3EFEEF3FD6BD3B9CFADDE7BFA568DDD83575E4BFF436A50AA0B3EDBF7B239BDC5F46EF3F18A2BB75F2F8EF3F106A676E08AAE2BF400D32181427ED3F94F6608A20D4B1BF8C4C83D29F7FCBBF7BC4446FD696EFBFFEFCB88CCAFFEFBFEA657D39DCFDEFBF8B2B9E2382D0EFBFB3E92BD036F6EF3FF68B2D7AE5CBEF3FDB9D1E8EBF2C523F7211794A036CE73F20842494F3BEEF3F049DD9975B73EC3F67CB3AE8854DEA3F5D912C93D7C0E33F63A5AD4A48FCEFBF6F2CC7F8DCFFEF3F386DE7B4DFC5EFBF8ABA6FFEC1CFEF3FD4FBCB82401DE1BF80F03253B1FAEF3F9BC8C4EB2B2BBFBF09CBF2B19D9FDD3F2AC0CDC97D90EFBFCF9BB34F0A47EC3F0BC6CC99172FD23FEC76A7973EFEEF3F49BCA697C914EB3F4807ABF4EEF6ACBFBCC724D37AF6CD3FB79E2860E29FC83F5DF9EA73AEFFEF3F6DE08DB9AC54EE3F834D71AF6B58EB3F13DC23FD5A5BEF3F73BBD27CCC53E6BF2DE935700958EEBF51D90D0BABF6EE3F30E5B0F07431EFBF28E2657B8DE1EDBF7478C122D9F0EFBF2943CBC8C6E3EFBFD0DCE3A0C0FEEF3F54DCEEDE5B02E03F9F5167730D1FEFBF8DA0CF6DFEFFEFBF6D705B09C5C1E5BF4D53F82E3909E6BF1C3B4938F2FAEFBFDF487B2BB0F7EFBFA4F50E4458EBEFBF2EC35C6EC0FDEFBFF77902E9C6E3EFBF569F44BB99E5EE3F623B0430E537D4BF749E2D01F7D8EF3F085E4339CBFEEFBF51D6EF3F2247D3BF17574A0B36FFEF3F4F52EFDA878FBA3F0884DDBFC075ECBF131EB8AE12FEEFBF8E5603A05D31EE3F772BEF679B78DE3F735D43CFFFFEEF3F664364B97C0DECBF25DDC93766FAEF3F869E0B4C55E8EE3F8AC7ED8A7DF8EFBFF3E422CCF2E0EFBF4A67B8C16BFFEF3F4A44A50F73FFEF3FF9698C1EC98CE7BFCFA2CCB0AEF1EF3F4E8E66B731E5EBBF61B2C14DAD56DABF8E66D6B53016EF3F80BEEACF4B2FEFBFBEC6F5FEE6C6ED3FD740ED12B2FEEFBF999D01B61BD9EFBFF048EF67D4E48EBFC5429E3CCF67EFBF30A32048CF91EF3F1C29511A28F5EDBF2B777B21EF61C03FAD21F273A0ACE63F88A783E155D6EF3FB68C8BA56FFFEF3F7071DDADF396E8BFEC43F83097B3EF3F3E991211D0D6EFBF48797971614AEFBFC7EDC30D49FFEF3F85B7F260AB91DEBF2FFE0761CA02E3BF1726E714DF59E03F9DD688F84560D4BF0A5B205D8487E7BF0A6C487C54E3EFBF03E1FEE90974D6BFF7EBC0BEFFFEEF3FE8796C667EFFEFBF0EF08A2D22FFEFBFA0FB1620F540ED3FA97ACB1DFE52EE3F214FA3186413EC3F72A1907D273DED3FFE675A08E35DEF3F76AC302022DCEFBF7AEDC0A27952EB3F99CFC5875B10EF3F8BACC46C2094E23FFB5545B6CED0CBBF8F8B58465FB5CEBF131C728AA092EEBFEE66DA39E9D3EC3F22F1CE52C4FAEF3F98C4FDD1BF94E13FABA57F7BF9FFEF3FE8130CA2039BEBBF4A0F978BFF10DBBF12B32A1966CCE03F8BFBC202B9A8903F37BFFC68EDFCEF3FEDDCAE5689FFEF3FC64FB61A9798EF3F347A2010FA93EF3F9927C588E118E1BF74994500F9A6ECBF168059DEA6BCEEBF1F300A722893EFBFDDA0F2B37DBFC53FC4DBB0B526E2ED3FD8B0002023F5E63F72D1E2A91BE0EE3FDF10B8DEBBFCEFBF8B17DCB82F6BEFBFCEEE6D2FDE95DF3FB801D9CA63AEEF3F1A2A9418989F9DBFEEC407A391DFEF3F2DE2171F1407D2BFE2F19B63D7D0EF3F77531D04F73BEF3FECB0198A2381EDBF95D9D7E951D3EFBF79BD2F6683EED43FB44544425B9FD83F5EDE4CBB7457EFBF66908C4E0ADFEC3F635F90D63B47EFBFE57A6B511AC1ECBFB44C17DD6E9DEFBF09232413040FECBF0D5C42CF2021E2BF3973ABD7CBEEEABF2A3BA6DFE2F6EF3F3989492EF8FEC1BF50A386D882B5EEBF21DB08B92EF6EF3F9557388E8919DA3F76A65FDD4EDDEFBFAC2DFA882FF3EFBF63C2C23C4CD7E6BF915881ECCD5BB83F1A9E24C2E750C1BF9419BF3FD996DB3F7D1913EB23F9EFBF3488963E1661DE3FF55219A728FCEFBFF429DC7D16F5EF3F593C3442BD91C2BF62B190451B5EEB3FEAFCC496B352EFBFBC0E118AFFFFEF3F4631C89FE2FFEF3F587B764CC2B1DB3F44610A71F9FFEF3FB8F9D1F5DF72DC3F6A45249A8CFAEF3F349FB3DB7AE6E9BFA7ED9709E1FAEFBF16BC61EA5EFDEF3F00F317E35D8EE73F03C6769DAD48ECBF95AC418306F8EFBFC395FBD4EC5EEFBF6B527F834243EF3F7A1A2FC2974DEF3F87DCF61B87E9EF3F13CF3E94FFFFEFBFB908A8AFC223EE3F5585EAA4E5C5A93F7AEF4BA9E841EFBF859C11BB5FC0EF3F273F2C12FEFFEFBF0EDA41ED1E65E93F62F87F43D610EA3F43482BFD7EFCE4BF85AB265C24EAEFBF3FF55AEF57FEEFBF6DBFE0B08676DD3FEEA88AD4BBD4EFBF025A7F364EFEEF3F1F35076DE182EF3FC58D9CF3DB44D83F3268B5F946B5E83FEE9A2EF2E140EFBFCFA8EE37DF37ACBF3CFAE38D3211E93F3143AA76A3E9EE3F12D23F69A6056B3F46B70A9EF9FF64BF8B590CB94970EFBF0AC026352AFDE33FD426121C5CA1EFBF7374921EAA0EC7BF54589E259DEAEF3FC13DCC2FB6FFEF3F78CC2E9207F8EDBF856220FAB1C7E4BFCBB5E0F97C55E2BFFC7CDCFFF7E7EF3F7C372C0E4881EF3F171725054341EF3FAD974EF7EAADEF3FE95A84E2F9FFEFBF30C21B1BBAEEEFBF8791C498C990EE3F90477FD8347EEFBF39F73ED78BEBEF3F50866B3B7EFFEF3F051A8DF845FDEF3FC45F1146DDDDEDBF5F3267879586EABF93EED0E55640EF3F0B5B96824DE7EE3F477262F7F357E63FAE623431834BE4BF53FD13F48091B23F0D764C8391FFEFBFE2A357C706F5EF3FF932741D2CFFEF3FB0680D40384EC0BFE1BD4F2EAD78EEBF566565B8DD4BEFBFFD3B91102586E7BFD4107048BFF7EF3F4473342C6F40EDBF5F258EDBFFFFEF3F09EE6B62F187E73FE7AD3E52040BD33F79ADAB23E138E73F9E5976E996FEEFBF457D0E66F31CE7BFE7D97EBAE8B5EF3F1CC86FA1EDFFEFBF1A81815447FBEFBFCD8505B42EE6EFBF6CEC05DE43C2EABF6A40426E798CE23F1ECA3516C8FFEF3FAFAC560719CDEF3F447451B4A8F3EABF11F43216B638AF3F6697DCD54B88EF3F5ACEC8131CFDEF3F296F00CB75FEEFBF6F713894C99CD23FD4D5A9B77757EFBF04C60C70A6CFDB3F1257FC30B643E33FF268BCCA81A0EFBFD4BD45374699EF3FD05EC5CDB4D8EE3F8599A989F85BCE3F1B8897406847E6BF19DEC23251F1EF3F443E049372A3E6BFDD08022AAB1BEE3F2E38B4DEFFFFEFBFFAF5904F35E4EF3F752BD2115FAEE23F6D033F41D7FFEFBFB50BD84A6741E83FD712438A00B5E13F5F954A0DCA4DEFBF95C41FD491FFEFBF47F5731086F9EF3F643B9A5E64FAEEBF82526EABD853EB3F1A05F90B8C96EEBF04CB4395D1FDEFBF858998B5F5A4EFBFFACD7152E3FEEFBFD3FF77F3BBF8E53FB6B76A4F7E6FABBFA8CBB3BE5F99EF3FF4ED447948E1E9BFFDBB5A33BFE3ED3F99E6FA0B868CD3BF75F5C031F2E2EE3F58190AE46181E93F8CD93E0E9838EB3F1DB9DAED66F2C6BFFE88516515D6DBBFF4988DE2FABFEF3F172E279CD0EBEE3FD3DE40A45BD0E0BFEBBAF56B9C9AC33F4159A58937F7EF3FA126D7E146ABC1BF76E69E353C9EE93F11CD076252FBEF3F5065AFB5FFFFEFBF64EBD18C19FEEFBF7275EFCC8E89E5BF796B5203DEFDEFBF4ACF4766A91FEFBFD31F755C485FECBFC8ED5954FEFAEDBFF496396CCF28E4BF4A000C786C62E23F43A16A0FDC3BEFBFABCF7F9D91D4EFBFBD55047311EFEB3F5A732DB4F5A1EF3FDEF1B69DD4EDEEBF2D697CCBBC38EF3F38FE2C621834EDBF10AEC113C5FFEFBFFCCAA9482FD2ECBF0B93A0AE1EA9EDBF88CD89DBB1B8EDBF2510E23922D0EF3F984F6CF3EDFFEFBF082897CE6EF8EF3FA4439559DC18AD3FA384DCE59559EE3F1570391B9FAEEFBFDF676B48C96DC3BFB239E45E9CBFEE3FA91E85FA4BF9EFBFCEE5B0D0129DEF3FD8E90EB6EFFFEFBF5CAF3807F5FFEFBFADE90D7900EDEF3FBD6CF75DB8F1EFBF2A25F43F19BECCBFE43A5B95BD7CEF3FA1A1D48BF4EAEFBF254EAEB190DFECBF3A07F3B49EE4E2BF292AE8A8E084E7BF50C3A3B5EFD4EFBF139FB8A600FBEF3F2DA79CE8207AE0BFF132F1A08D8FEFBF1E5860C07B56CDBF10DE74E07772ECBFDC77BB698280E93FF032111B7CF2DE3F6F1F56DE7EE0EFBF"> : tensor<20x20xf64>
    return %cst : tensor<20x20xf64>
  }
}