//===- BufferPlacementMILP.h - MILP-based buffer placement ------*- C++ -*-===//
//
// Dynamatic is under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Common infrastructure for MILP-based buffer placement (requires Gurobi). This
// mainly declares the abstract `BufferPlacementMILP` class, which contains some
// common logic to manage an MILP that represents a buffer placement problem.
// Buffer placements algorithms should subclass it to get some of the common
// boilerplate code they are likely to need for free.
//
//===----------------------------------------------------------------------===//

#ifndef DYNAMATIC_TRANSFORMS_BUFFERPLACEMENT_BUFFERPLACEMENTMILP_H
#define DYNAMATIC_TRANSFORMS_BUFFERPLACEMENT_BUFFERPLACEMENTMILP_H

#include "dynamatic/Analysis/NameAnalysis.h"
#include "dynamatic/Support/LLVM.h"
#include "dynamatic/Support/Logging.h"
#include "dynamatic/Support/MILP.h"
#include "dynamatic/Support/TimingModels.h"
#include "dynamatic/Transforms/BufferPlacement/BufferingSupport.h"
#include "dynamatic/Transforms/BufferPlacement/CFDFC.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Support/LLVM.h"
#include "llvm/ADT/MapVector.h"

#ifndef DYNAMATIC_GUROBI_NOT_INSTALLED
#include "gurobi_c++.h"
namespace dynamatic {
namespace buffer {

struct TimeVars {
  /// Time at channel's input (i.e., at source unit's output port).
  GRBVar tIn;
  /// Time at channel's output (i.e., at destination unit's input port).
  GRBVar tOut;
};

/// Abstract class holding the basic logic for the smart buffer placement pass,
/// which expresses the buffer placement problem in dataflow circuits as an MILP
/// (mixed-integer linear program) whose solution indicates the location and
/// nature of buffers that must be placed in the circuit to achieve functional
/// correctness and high performance. Specific implementations of MILP-based
/// buffer placement algorithms can inherit from this class to benefit from
/// some pre/post-processind steps and verification they are likely to need.
class BufferPlacementMILP : public MILP<BufferPlacement> {
public:
  /// Contains timing characterizations for dataflow components required to
  /// create the MILP constraints.
  const TimingDatabase &timingDB;

  /// Starts setting up a the buffer placement MILP for a Handshake function
  /// (with its CFDFCs) with specific component timing models. The constructor
  /// maps each of the function's channel to its specific buffering properties,
  /// adjusting for components' internal buffers given by the timing models. If
  /// some buffering properties become unsatisfiable following this step, the
  /// constructor sets the `unsatisfiable` flag to true.
  BufferPlacementMILP(GRBEnv &env, FuncInfo &funcInfo,
                      const TimingDatabase &timingDB);

  /// Follows the same pre-processing step as the other constructor; in
  /// addition, dumps the MILP model and solution under the provided name in the
  /// logger's directory.
  BufferPlacementMILP(GRBEnv &env, FuncInfo &funcInfo,
                      const TimingDatabase &timingDB, Logger &logger,
                      StringRef milpName);

protected:
  /// Aggregates all data members related to the Handshake function under
  /// optimization.
  FuncInfo &funcInfo;
  /// After construction, maps all channels (i.e, values) defined in the
  /// function to their specific channel buffering properties (unconstraining
  /// properties if none were explicitly specified).
  llvm::MapVector<Value, ChannelBufProps> channels;
  /// Logger; if not null the class will log setup and placement information.
  Logger *logger;

  /// Whether the MILP was detected to be unsatisfiable dureing creation.
  bool unsatisfiable = false;

  /// Adds pre-existing buffers that may exist as part of the units the channel
  /// connects to to the buffering properties. These are added to the minimum
  /// numbers of transparent and opaque slots so that the MILP is forced to
  /// place at least a certain quantity of slots on the channel and can take
  /// them into account in its constraints. Fails when buffering properties
  /// become unsatisfiable due to an increase in the minimum number of slots;
  /// succeeds otherwise.
  LogicalResult addInternalBuffers(Channel &channel);

  /// Removes pre-existing buffers that may exist as part of the units the
  /// channel connects to from the placement results. These are deducted from
  /// the numbers of transparent and opaque slots stored in the placement
  /// results. The latter are expected to specify more slots than what is going
  /// to be deducted (which should be guaranteed by the MILP constraints).
  void deductInternalBuffers(Value channel, PlacementResult &result);

  /// Returns an estimation of the number of times a token will traverse the
  /// input channel. The estimation is based on the extracted CFDFCs.
  unsigned getChannelNumExecs(Value channel);

  /// Helper method to run a callback function on each input/output port pair of
  /// the provided operation, unless one of the ports has `mlir::MemRefType`.
  void forEachIOPair(Operation *op,
                     const std::function<void(Value, Value)> &callback);

private:
  /// During object construction, map all the function's channels to their
  /// specific buffering properties, adjusting for buffers within units as
  /// described by the timing models. Fails if the buffering properties of a
  /// channel are unsatisfiable or become unsatisfiable after adjustment.
  LogicalResult mapChannelsToProperties();
};

} // namespace buffer
} // namespace dynamatic
#endif // DYNAMATIC_GUROBI_NOT_INSTALLED

#endif // DYNAMATIC_TRANSFORMS_BUFFERPLACEMENT_BUFFERPLACEMENTMILP_H
