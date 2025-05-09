# Copyright 2022 The StableHLO Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

add_subdirectory(conversions)
add_subdirectory(optimization)

set(LLVM_TARGET_DEFINITIONS Passes.td)
mlir_tablegen(Passes.h.inc -gen-pass-decls)
add_public_tablegen_target(PassesIncGen)

set(LLVM_TARGET_DEFINITIONS ChloDecompositionPatterns.td)
mlir_tablegen(ChloDecompositionPatterns.h.inc --gen-rewriters)
add_public_tablegen_target(ChloDecompositionPatternsIncGen)

set(LLVM_TARGET_DEFINITIONS StablehloCompatibilityExpanderPatterns.td)
mlir_tablegen(StablehloCompatibilityExpanderPatterns.h.inc --gen-rewriters)
add_public_tablegen_target(StablehloCompatibilityExpanderPatternsIncGen)

set(LLVM_TARGET_DEFINITIONS StablehloComplexMathExpanderPatterns.td)
mlir_tablegen(StablehloComplexMathExpanderPatterns.h.inc --gen-rewriters)
add_public_tablegen_target(StablehloComplexMathExpanderPatternsIncGen)

set(LLVM_TARGET_DEFINITIONS StablehloLegalizeDeprecatedOpsPatterns.td)
mlir_tablegen(StablehloLegalizeDeprecatedOpsPatterns.h.inc --gen-rewriters)
add_public_tablegen_target(StablehloLegalizeDeprecatedOpsPatternsIncGen)

set(LLVM_TARGET_DEFINITIONS VhloToVersionPatterns.td)
mlir_tablegen(VhloToVersionPatterns.h.inc --gen-rewriters)
add_public_tablegen_target(VhloToVersionPatterns)

add_mlir_dialect_library(StablehloPassUtils
  PARTIAL_SOURCES_INTENDED
  PassUtils.cpp

  DEPENDS
  PassesIncGen

  LINK_LIBS PUBLIC
  ChloOps
  StablehloBase
  StablehloOps
  MLIRSupport
  MLIRComplexDialect
  MLIRIR
)

add_mlir_dialect_library(StablehloPasses
  PARTIAL_SOURCES_INTENDED
  ChloLegalizeToStablehlo.cpp
  PassPipelines.cpp
  ShapeLegalizeToStablehlo.cpp
  StablehloCanonicalizeDynamism.cpp
  StablehloConvertToSignless.cpp
  StablehloCompatibilityExpander.cpp
  StablehloComplexMathExpander.cpp
  StablehloLegalizeCompositeToCall.cpp
  StablehloLegalizeDeprecatedOps.cpp
  StablehloLegalizeQuantToMath.cpp
  StablehloLegalizeQuantizedOpToQDQ.cpp
  StablehloLegalizeQDQToQuantizedOp.cpp
  StablehloLegalizeToVhlo.cpp
  StablehloRefineArguments.cpp
  StablehloRefineShapes.cpp
  StablehloWrapInComposite.cpp
  VhloLegalizeToStablehlo.cpp
  VhloToVersion.cpp

  DEPENDS
  ChloDecompositionPatternsIncGen
  PassesIncGen
  StablehloCompatibilityExpanderPatternsIncGen
  StablehloComplexMathExpanderPatternsIncGen
  StablehloLegalizeDeprecatedOpsPatternsIncGen
  VhloToVersionPatterns
  StablehloPassUtils

  LINK_LIBS PUBLIC
  ChloOps
  MLIRArithDialect
  MLIRAsmParser
  MLIRComplexDialect
  MLIRDialectUtils
  MLIRFuncDialect
  MLIRFuncTransforms
  MLIRFunctionInterfaces
  MLIRIR
  MLIRInferTypeOpInterface
  MLIRQuantDialect
  MLIRReconcileUnrealizedCasts
  MLIRSupport
  MLIRTensorDialect
  MLIRTransformUtils
  StablehloBase
  StablehloBroadcastUtils
  StablehloLinalgTransforms
  StablehloOps
  StablehloOptimizationPasses
  StablehloTypeInference
  VhloOps
  StablehloPassUtils
)
