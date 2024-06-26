/* Copyright 2024 The StableHLO Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

//
// This file is generated using functional_algorithms tool (0.4.0).
// See build_tools/math/README.md for more information.

// Arcus sine on complex input.
//
//     arcsin(z) = 2 * arctan2(z, (1 + sqrt(1 - z * z)))
//
//     Here we well use a modified version of the [Hull et
//     al]((https://dl.acm.org/doi/10.1145/275323.275324) algorithm with
//     a reduced number of approximation regions.
//
//     Hull et al define complex arcus sine as
//
//       arcsin(x + I*y) = arcsin(x/a) + sign(y; x) * I * log(a + sqrt(a*a-1))
//
//     where
//
//       x and y are real and imaginary parts of the input to arcsin, and
//       I is imaginary unit,
//       a = (hypot(x+1, y) + hypot(x-1, y))/2,
//       sign(y; x) = 1 when y >= 0 and abs(x) <= 1, otherwise -1.
//
//     x and y are assumed to be non-negative as the arcus sine on other
//     quadrants of the complex plane are defined by
//
//       arcsin(-z) == -arcsin(z)
//       arcsin(conj(z)) == conj(arcsin(z))
//
//     where z = x + I*y.
//
//     Hull et al split the first quadrant into 11 regions in total, each
//     region using a different approximation of the arcus sine
//     function. It turns out that when considering the evaluation of
//     arcus sine real and imaginary parts separately, the 11 regions can
//     be reduced to 3 regions for the real part, and to 4 regions for
//     the imaginary part. This reduction of the appriximation regions
//     constitutes the modification of the Hull et al algorithm that is
//     implemented below and it is advantageous for functional
//     implmentations as there will be less branches. The modified Hull
//     et al algorithm is validated against the original Hull algorithm
//     implemented in MPMath.
//
//     Per Hull et al Sec. "Analyzing Errors", in the following we'll use
//     symbol ~ (tilde) to denote "approximately equal" relation with the
//     following meaning:
//
//       A ~ B  iff  A = B * (1 + s * eps)
//
//     where s * eps is a small multiple of eps that quantification
//     depends on the particular case of error analysis.
//     To put it simply, A ~ B means that the numerical values of A and B
//     within the given floating point system are equal or very
//     close. So, from the numerical evaluation point of view it does not
//     matter which of the expressions, A or B, to use as the numerical
//     results will be the same.
//
//     We define:
//       safe_min = sqrt(<smallest normal value>) * 4
//       safe_max = sqrt(<largest finite value>) / 8
//
//     Real part
//     ---------
//     In general, the real part of arcus sine input can be expressed as
//     follows:
//
//       arcsin(x / a) = arctan((x/a) / sqrt(1 - (x/a)**2))
//                     = arctan(x / sqrt(a**2 - x**2))
//                     = arctan2(x, sqrt(a**2 - x**2))              Eq. 1
//                     = arctan2(x, sqrt((a + x) * (a - x)))        Eq. 2
//
//     for which the following approximations will be used (in the
//     missing derivation cases, see Hull et al paper for details):
//
//     - Hull et al Case 5:
//       For x > safe_max and any y, we have
//         x + 1 ~ x - 1 ~ x
//       so that
//         a ~ hypot(x, y)
//       For y > safe_max and x < safe_max, we have
//         hypot(x + 1, y) ~ hypot(x - 1, y) ~ hypot(x, y) ~ a.
//       Combining these together gives: if max(x, y) > safe_max then
//         a**2 ~ hypot(x, y)**2 ~ x**2 + y**2
//       and Eq. 1 becomes
//         arcsin(x / a) ~ arctan2(x, y)
//
//     - Hull et al Safe region: for max(x, y) < safe_max, we have (see
//       `a - x` approximation in Hull et al Fig. 2):
//
//       If x <= 1 then
//         arcsin(x / a) ~ arctan2(x, sqrt(0.5 * (a + x) * (y * y / (hypot(x + 1, y) + x + 1) + hypot(x - 1, y) - x - 1)))
//       else
//         arcsin(x / a) ~ arctan2(x, y * sqrt(0.5 * (a + x) * (1 / (hypot(x + 1, y) + x + 1) + 1 / (hypot(x - 1, y) + x - 1))))
//
//     Imaginary part
//     --------------
//     In general, the unsigned imaginary part of arcus sine input can be
//     expressed as follows:
//
//       log(a + sqrt(a*a-1)) = log(a + sqrt((a + 1) * (a - 1)))
//                            = log1p(a - 1 + sqrt((a + 1) * (a - 1)))   # Eq.3
//
//     for which the following approximations will be used (for the
//     derivation, see Hull et al paper):
//
//     - modified Hull et al Case 5: for y > safe_max_opt we have
//         log(a + sqrt(a*a-1)) ~ log(2) + log(y) + 0.5 * log1p((x / y) * (x / y))
//       where using
//         safe_max_opt = safe_max * 1e-6 if x < safe_max * 1e12 else safe_max * 1e2
//       will expand the approximation region to capture also the Hull et
//       Case 4 (x is large but less that eps * y) that does not have
//       log1p term but under the Case 4 conditions, log(y) +
//       0.5*log1p(...) ~ log(y).
//
//     - Hull et al Case 1 & 2: for 0 <= y < safe_min and x < 1, we have
//         log(a + sqrt(a*a-1)) ~ y / sqrt((a - 1) * (a + 1))
//       where
//         a - 1 ~ -(x + 1) * (x - 1) / (a + 1)
//
//     - Hull et al Safe region. See the approximation of `a -
//       1` in Hull et al Fig. 2 for Eq. 3:
//         log(a + sqrt(a*a-1)) ~ log1p(a - 1 + sqrt((a + 1) * (a - 1)))
//       where
//         a - 1 ~ 0.5 * y * y / (hypot(x + 1, y) + x + 1) + 0.5 * (hypot(x - 1, y) + x - 1)        if x >= 1
//         a - 1 ~ 0.5 * y * y * (1 / (hypot(x + 1, y) + x + 1) + 1 / (hypot(x - 1, y) - x - 1))    if x < 1 and a < 1.5
//         a - 1 ~ a - 1                                                                            otherwise
//
//     Different from Hull et al, we don't handle Cases 3 and 6 because
//     these only minimize the number of operations which may be
//     advantageous for procedural implementations but for functional
//     implementations these would just increase the number of branches
//     with no gain in accuracy.
//
//
def : Pat<(CHLO_AsinOp ComplexElementType:$z),
  (StableHLO_ComplexOp
    (StableHLO_Atan2Op:$real
      (StableHLO_RealOp:$signed_x $z),
      (StableHLO_SelectOp
        (StableHLO_CompareOp
         (StableHLO_MaxOp
           (StableHLO_AbsOp:$x $signed_x),
           (StableHLO_AbsOp:$y
             (StableHLO_ImagOp:$signed_y $z))),
         (StableHLO_DivOp:$safe_max
           (StableHLO_SqrtOp
             (StableHLO_ConstantLikeMaxFiniteValue $signed_x)),
           (StableHLO_ConstantLike<"8"> $signed_x)),
          StableHLO_ComparisonDirectionValue<"GE">,
          (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
        $y,
        (StableHLO_SelectOp
          (StableHLO_CompareOp
           $x,
           (StableHLO_ConstantLike<"1">:$one $signed_x),
            StableHLO_ComparisonDirectionValue<"LE">,
            (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
          (StableHLO_SqrtOp
            (StableHLO_MulOp
              (StableHLO_MulOp:$half_apx
                (StableHLO_ConstantLike<"0.5">:$half $signed_x),
                (StableHLO_AddOp
                  (StableHLO_MulOp:$a
                    $half,
                    (StableHLO_AddOp
                      (StableHLO_SelectOp:$r
                        (StableHLO_CompareOp
                         (StableHLO_MaxOp:$_hypot_1_mx
                           (StableHLO_AbsOp:$abs_xp1
                             (StableHLO_AddOp:$xp1 $x, $one)),
                           $y),
                         (StableHLO_MinOp:$mn $abs_xp1, $y),
                          StableHLO_ComparisonDirectionValue<"EQ">,
                          (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
                        (StableHLO_MulOp
                          (StableHLO_SqrtOp:$sqrt_two
                            (StableHLO_ConstantLike<"2">:$two $signed_x)),
                          $_hypot_1_mx),
                        (StableHLO_SelectOp
                          (StableHLO_AndOp
                            (StableHLO_CompareOp
                             (StableHLO_SqrtOp:$sqa
                               (StableHLO_AddOp
                                 $one,
                                 (StableHLO_MulOp:$_hypot_1_r
                                   (StableHLO_DivOp:$mn_over_mx $mn, $_hypot_1_mx),
                                   $mn_over_mx))),
                             $one,
                              StableHLO_ComparisonDirectionValue<"EQ">,
                              (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
                            (StableHLO_CompareOp
                             $_hypot_1_r,
                             (StableHLO_ConstantLike<"0">:$zero $signed_x),
                              StableHLO_ComparisonDirectionValue<"GT">,
                              (STABLEHLO_DEFAULT_COMPARISON_TYPE))),
                          (StableHLO_AddOp
                            $_hypot_1_mx,
                            (StableHLO_DivOp
                              (StableHLO_MulOp $_hypot_1_mx, $_hypot_1_r),
                              $two)),
                          (StableHLO_MulOp $_hypot_1_mx, $sqa))),
                      (StableHLO_SelectOp:$s
                        (StableHLO_CompareOp
                         (StableHLO_MaxOp:$_hypot_2_mx
                           (StableHLO_AbsOp:$abs_xm1
                             (StableHLO_SubtractOp:$xm1 $x, $one)),
                           $y),
                         (StableHLO_MinOp:$_hypot_2_mn $abs_xm1, $y),
                          StableHLO_ComparisonDirectionValue<"EQ">,
                          (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
                        (StableHLO_MulOp $sqrt_two, $_hypot_2_mx),
                        (StableHLO_SelectOp
                          (StableHLO_AndOp
                            (StableHLO_CompareOp
                             (StableHLO_SqrtOp:$_hypot_2_sqa
                               (StableHLO_AddOp
                                 $one,
                                 (StableHLO_MulOp:$_hypot_2_r
                                   (StableHLO_DivOp:$_hypot_2_mn_over_mx $_hypot_2_mn, $_hypot_2_mx),
                                   $_hypot_2_mn_over_mx))),
                             $one,
                              StableHLO_ComparisonDirectionValue<"EQ">,
                              (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
                            (StableHLO_CompareOp
                             $_hypot_2_r,
                             $zero,
                              StableHLO_ComparisonDirectionValue<"GT">,
                              (STABLEHLO_DEFAULT_COMPARISON_TYPE))),
                          (StableHLO_AddOp
                            $_hypot_2_mx,
                            (StableHLO_DivOp
                              (StableHLO_MulOp $_hypot_2_mx, $_hypot_2_r),
                              $two)),
                          (StableHLO_MulOp $_hypot_2_mx, $_hypot_2_sqa))))),
                  $x)),
              (StableHLO_AddOp
                (StableHLO_DivOp
                  (StableHLO_MulOp:$yy $y, $y),
                  (StableHLO_AddOp:$rpxp1 $r, $xp1)),
                (StableHLO_SubtractOp:$smxm1 $s, $xm1)))),
          (StableHLO_MulOp
            $y,
            (StableHLO_SqrtOp
              (StableHLO_AddOp
                (StableHLO_DivOp $half_apx, $rpxp1),
                (StableHLO_DivOp
                  $half_apx,
                  (StableHLO_AddOp:$spxm1 $s, $xm1)))))))),
    (StableHLO_SelectOp
      (StableHLO_CompareOp
       $signed_y,
       $zero,
        StableHLO_ComparisonDirectionValue<"LT">,
        (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
      (StableHLO_NegOp
        (StableHLO_SelectOp:$imag
          (StableHLO_CompareOp
           (StableHLO_SelectOp:$mx
             (StableHLO_CompareOp:$y_gt_safe_max_opt
              $y,
              (StableHLO_SelectOp:$safe_max_opt
                (StableHLO_CompareOp
                 $x,
                 (StableHLO_MulOp
                   $safe_max,
                   (StableHLO_ConstantLike<"1000000000000.0"> $signed_x)),
                  StableHLO_ComparisonDirectionValue<"LT">,
                  (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
                (StableHLO_MulOp
                  $safe_max,
                  (StableHLO_ConstantLike<"1e-06"> $signed_x)),
                (StableHLO_MulOp
                  $safe_max,
                  (StableHLO_ConstantLike<"100.0"> $signed_x))),
               StableHLO_ComparisonDirectionValue<"GE">,
               (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
             $y,
             $x),
           (StableHLO_SelectOp $y_gt_safe_max_opt, $safe_max_opt, $safe_max),
            StableHLO_ComparisonDirectionValue<"GE">,
            (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
          (StableHLO_AddOp
            (StableHLO_AddOp
              (StableHLO_LogOp $two),
              (StableHLO_LogOp $mx)),
            (StableHLO_MulOp
              $half,
              (StableHLO_Log1pOp
                (StableHLO_MulOp
                  (StableHLO_SelectOp:$xoy
                    (StableHLO_AndOp
                      $y_gt_safe_max_opt,
                      (StableHLO_NotOp
                        (StableHLO_CompareOp
                         $y,
                         (StableHLO_ConstantLikePosInfValue $signed_y),
                          StableHLO_ComparisonDirectionValue<"EQ">,
                          (STABLEHLO_DEFAULT_COMPARISON_TYPE)))),
                    (StableHLO_DivOp $x, $y),
                    $zero),
                  $xoy)))),
          (StableHLO_SelectOp
            (StableHLO_AndOp:$logical_and_lt_y_safe_min_lt_x_one
              (StableHLO_CompareOp
               $y,
               (StableHLO_MulOp
                 (StableHLO_SqrtOp
                   (StableHLO_ConstantLikeSmallestNormalizedValue $signed_x)),
                 (StableHLO_ConstantLike<"4"> $signed_x)),
                StableHLO_ComparisonDirectionValue<"LT">,
                (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
              (StableHLO_CompareOp
               $x,
               $one,
                StableHLO_ComparisonDirectionValue<"LT">,
                (STABLEHLO_DEFAULT_COMPARISON_TYPE))),
            (StableHLO_DivOp
              $y,
              (StableHLO_SqrtOp:$sq
                (StableHLO_MulOp
                  (StableHLO_SelectOp:$am1
                    $logical_and_lt_y_safe_min_lt_x_one,
                    (StableHLO_NegOp
                      (StableHLO_DivOp
                        (StableHLO_MulOp $xp1, $xm1),
                        (StableHLO_AddOp:$ap1 $a, $one))),
                    (StableHLO_SelectOp:$x_ge_1_or_not
                      (StableHLO_CompareOp
                       $x,
                       $one,
                        StableHLO_ComparisonDirectionValue<"GE">,
                        (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
                      (StableHLO_AddOp
                        (StableHLO_DivOp:$divide_half_yy_rpxp1
                          (StableHLO_MulOp:$half_yy $half, $yy),
                          $rpxp1),
                        (StableHLO_MulOp $half, $spxm1)),
                      (StableHLO_SelectOp
                        (StableHLO_CompareOp
                         $a,
                         (StableHLO_ConstantLike<"1.5"> $signed_x),
                          StableHLO_ComparisonDirectionValue<"LE">,
                          (STABLEHLO_DEFAULT_COMPARISON_TYPE)),
                        (StableHLO_AddOp
                          $divide_half_yy_rpxp1,
                          (StableHLO_DivOp $half_yy, $smxm1)),
                        (StableHLO_SubtractOp $a, $one)))),
                  $ap1))),
            (StableHLO_Log1pOp
              (StableHLO_AddOp $am1, $sq))))),
      $imag))>;

// Arcus sine on real input:
//
//     arcsin(x) = 2 * arctan2(x, (1 + sqrt(1 - x * x)))
//
//     To avoid cancellation errors at abs(x) close to 1, we'll use
//
//       1 - x * x == (1 - x) * (1 + x)
//
def : Pat<(CHLO_AsinOp NonComplexElementType:$x),
  (StableHLO_MulOp
    (StableHLO_ConstantLike<"2"> $x),
    (StableHLO_Atan2Op
      $x,
      (StableHLO_AddOp
        (StableHLO_ConstantLike<"1">:$one $x),
        (StableHLO_SqrtOp
          (StableHLO_MulOp
            (StableHLO_SubtractOp $one, $x),
            (StableHLO_AddOp $one, $x))))))>;
