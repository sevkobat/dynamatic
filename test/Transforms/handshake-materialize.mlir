// NOTE: Assertions have been autogenerated by utils/generate-test-checks.py
// RUN: dynamatic-opt --handshake-materialize --remove-operation-names %s --split-input-file | FileCheck %s

// CHECK-LABEL:   handshake.func @forkArgument(
// CHECK-SAME:                                 %[[VAL_0:.*]]: i32,
// CHECK-SAME:                                 %[[VAL_1:.*]]: none, ...) -> i32 attributes {argNames = ["toFork", "start"], resNames = ["out0"]} {
// CHECK:           sink %[[VAL_1]] : none
// CHECK:           %[[VAL_2:.*]]:2 = fork [2] %[[VAL_0]] : i32
// CHECK:           %[[VAL_3:.*]] = arith.addi %[[VAL_2]]#0, %[[VAL_2]]#1 : i32
// CHECK:           %[[VAL_4:.*]] = return %[[VAL_3]] : i32
// CHECK:           end %[[VAL_4]] : i32
// CHECK:         }
handshake.func @forkArgument(%toFork : i32, %start: none) -> i32 {
  %add = arith.addi %toFork, %toFork : i32
  %returnVal = return %add : i32
  end %returnVal : i32
}

// -----

// CHECK-LABEL:   handshake.func @sinkArgument(
// CHECK-SAME:                                 %[[VAL_0:.*]]: i32,
// CHECK-SAME:                                 %[[VAL_1:.*]]: none, ...) -> none attributes {argNames = ["toSink", "start"], resNames = ["out0"]} {
// CHECK:           sink %[[VAL_0]] : i32
// CHECK:           %[[VAL_2:.*]] = return %[[VAL_1]] : none
// CHECK:           end %[[VAL_2]] : none
// CHECK:         }
handshake.func @sinkArgument(%toSink : i32, %start: none) -> none {
  %returnVal = return %start : none
  end %returnVal : none
}

// -----

// CHECK-LABEL:   handshake.func @forkResult(
// CHECK-SAME:                               %[[VAL_0:.*]]: none, ...) -> i32 attributes {argNames = ["start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_1:.*]] = constant %[[VAL_0]] {value = 42 : i32} : i32
// CHECK:           %[[VAL_2:.*]]:2 = fork [2] %[[VAL_1]] : i32
// CHECK:           %[[VAL_3:.*]] = arith.addi %[[VAL_2]]#0, %[[VAL_2]]#1 : i32
// CHECK:           %[[VAL_4:.*]] = return %[[VAL_3]] : i32
// CHECK:           end %[[VAL_4]] : i32
// CHECK:         }
handshake.func @forkResult(%start: none) -> i32 {
  %cst = constant %start {value = 42 : i32 } : i32
  %add = arith.addi %cst, %cst : i32
  %returnVal = return %add : i32
  end %returnVal : i32
}

// -----

// CHECK-LABEL:   handshake.func @sinkResult(
// CHECK-SAME:                               %[[VAL_0:.*]]: none, ...) -> none attributes {argNames = ["start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_1:.*]], %[[VAL_2:.*]] = control_merge %[[VAL_0]] : none, i32
// CHECK:           sink %[[VAL_2]] : i32
// CHECK:           %[[VAL_3:.*]] = return %[[VAL_1]] : none
// CHECK:           end %[[VAL_3]] : none
// CHECK:         }
handshake.func @sinkResult(%start: none) -> none {
  %ctrl, %idx = control_merge %start : none, i32
  %returnVal = return %ctrl : none
  end %returnVal : none
}

// -----

// CHECK-LABEL:   handshake.func @minimizeForkSizes(
// CHECK-SAME:                                      %[[VAL_0:.*]]: i32,
// CHECK-SAME:                                      %[[VAL_1:.*]]: none, ...) -> i32 attributes {argNames = ["arg0", "start"], resNames = ["out0"]} {
// CHECK:           sink %[[VAL_1]] : none
// CHECK:           %[[VAL_2:.*]]:2 = fork [2] %[[VAL_0]] : i32
// CHECK:           %[[VAL_3:.*]] = arith.addi %[[VAL_2]]#0, %[[VAL_2]]#1 : i32
// CHECK:           %[[VAL_4:.*]] = return %[[VAL_3]] : i32
// CHECK:           end %[[VAL_4]] : i32
// CHECK:         }
handshake.func @minimizeForkSizes(%arg0: i32, %start: none) -> i32 {
  sink %start : none
  %fork:4 = fork [4] %arg0 : i32
  sink %fork#0 : i32
  sink %fork#2 : i32
  %add = arith.addi %fork#1, %fork#3 : i32
  %returnVal = return %add : i32
  end %returnVal : i32
}

// -----

// CHECK-LABEL:   handshake.func @eliminateForkToFork(
// CHECK-SAME:                                        %[[VAL_0:.*]]: i32,
// CHECK-SAME:                                        %[[VAL_1:.*]]: none, ...) -> i32 attributes {argNames = ["arg0", "start"], resNames = ["out0"]} {
// CHECK:           sink %[[VAL_1]] : none
// CHECK:           %[[VAL_2:.*]]:4 = fork [4] %[[VAL_0]] : i32
// CHECK:           %[[VAL_3:.*]] = arith.addi %[[VAL_2]]#0, %[[VAL_2]]#1 : i32
// CHECK:           %[[VAL_4:.*]] = arith.addi %[[VAL_2]]#2, %[[VAL_2]]#3 : i32
// CHECK:           %[[VAL_5:.*]] = arith.addi %[[VAL_3]], %[[VAL_4]] : i32
// CHECK:           %[[VAL_6:.*]] = return %[[VAL_5]] : i32
// CHECK:           end %[[VAL_6]] : i32
// CHECK:         }
handshake.func @eliminateForkToFork(%arg0: i32, %start: none) -> i32 {
  sink %start : none
  %fork1:3 = fork [3] %arg0 : i32
  %fork2:2 = fork [2] %fork1#0 : i32
  %add1 = arith.addi %fork1#1, %fork1#2 : i32
  %add2 = arith.addi %fork2#0, %fork2#1 : i32
  %add = arith.addi %add1, %add2 : i32
  %returnVal = return %add : i32
  end %returnVal : i32
}

// -----

// CHECK-LABEL:   handshake.func @eliminateForkToForkMultipleUses(
// CHECK-SAME:                                                    %[[VAL_0:.*]]: i32,
// CHECK-SAME:                                                    %[[VAL_1:.*]]: none, ...) -> i32 attributes {argNames = ["arg0", "start"], resNames = ["out0"]} {
// CHECK:           sink %[[VAL_1]] : none
// CHECK:           %[[VAL_2:.*]]:4 = fork [4] %[[VAL_0]] : i32
// CHECK:           %[[VAL_3:.*]] = arith.addi %[[VAL_2]]#1, %[[VAL_2]]#0 : i32
// CHECK:           %[[VAL_4:.*]] = arith.addi %[[VAL_2]]#2, %[[VAL_2]]#3 : i32
// CHECK:           %[[VAL_5:.*]] = arith.addi %[[VAL_3]], %[[VAL_4]] : i32
// CHECK:           %[[VAL_6:.*]] = return %[[VAL_5]] : i32
// CHECK:           end %[[VAL_6]] : i32
// CHECK:         }
handshake.func @eliminateForkToForkMultipleUses(%arg0: i32, %start: none) -> i32 {
  sink %start : none
  %fork1:2 = fork [2] %arg0 : i32
  %fork2:2 = fork [2] %fork1#0 : i32
  %add1 = arith.addi %fork1#0, %fork1#1 : i32
  %add2 = arith.addi %fork2#0, %fork2#1 : i32
  %add = arith.addi %add1, %add2 : i32
  %returnVal = return %add : i32
  end %returnVal : i32
}

// -----

// CHECK-LABEL:   handshake.func @eraseSingleInputFork(
// CHECK-SAME:                                         %[[VAL_0:.*]]: none, ...) -> none attributes {argNames = ["start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_1:.*]] = return %[[VAL_0]] : none
// CHECK:           end %[[VAL_1]] : none
// CHECK:         }
handshake.func @eraseSingleInputFork(%start: none) -> none {
  %forkedStart = fork [1] %start : none
  %returnVal = return %forkedStart : none
  end %returnVal : none
}

// -----

// CHECK-LABEL:   handshake.func @doNotEraseSingleInputFork(
// CHECK-SAME:                                              %[[VAL_0:.*]]: none, ...) -> none attributes {argNames = ["start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_1:.*]] = lazy_fork [1] %[[VAL_0]] : none
// CHECK:           %[[VAL_2:.*]] = fork [1] %[[VAL_1]] : none
// CHECK:           %[[VAL_3:.*]] = return %[[VAL_2]] : none
// CHECK:           end %[[VAL_3]] : none
// CHECK:         }
handshake.func @doNotEraseSingleInputFork(%start: none) -> none {
  %lazyForkedStart = lazy_fork [1] %start : none
  %forkedStart = fork [1] %lazyForkedStart : none
  %returnVal = return %forkedStart : none
  end %returnVal : none
}

// -----

// CHECK-LABEL:   handshake.func @makeLSQForkLazyDoNothingArg(
// CHECK-SAME:                                                %[[VAL_0:.*]]: memref<64xi32>,
// CHECK-SAME:                                                %[[VAL_1:.*]]: i32,
// CHECK-SAME:                                                %[[VAL_2:.*]]: none, ...) -> i32 attributes {argNames = ["memref", "addr", "start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_3:.*]], %[[VAL_4:.*]] = lsq{{\[}}%[[VAL_0]] : memref<64xi32>] (%[[VAL_2]], %[[VAL_5:.*]])  {groupSizes = [1 : i32]} : (none, i32) -> (i32, none)
// CHECK:           %[[VAL_5]], %[[VAL_6:.*]] = lsq_load{{\[}}%[[VAL_1]]] %[[VAL_3]] : i32, i32
// CHECK:           %[[VAL_7:.*]] = return %[[VAL_6]] : i32
// CHECK:           end %[[VAL_7]], %[[VAL_4]] : i32, none
// CHECK:         }
handshake.func @makeLSQForkLazyDoNothingArg(%memref: memref<64xi32>, %addr: i32, %start: none) -> i32 {
  %ldData1, %done = lsq [%memref: memref<64xi32>] (%start, %ldAddrToMem) {groupSizes = [1 : i32]} : (none, i32) -> (i32, none)
  %ldAddrToMem, %ldDataToSucc = lsq_load [%addr] %ldData1 : i32, i32
  %returnVal = return %ldDataToSucc : i32
  end %returnVal, %done : i32, none
}

// -----


// CHECK-LABEL:   handshake.func @makeLSQForkLazyDoNothingFork(
// CHECK-SAME:                                                 %[[VAL_0:.*]]: memref<64xi32>,
// CHECK-SAME:                                                 %[[VAL_1:.*]]: none, ...) -> i32 attributes {argNames = ["memref", "start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_2:.*]], %[[VAL_3:.*]] = lsq{{\[}}%[[VAL_0]] : memref<64xi32>] (%[[VAL_4:.*]]#0, %[[VAL_5:.*]])  {groupSizes = [1 : i32]} : (none, i32) -> (i32, none)
// CHECK:           %[[VAL_4]]:2 = fork [2] %[[VAL_1]] : none
// CHECK:           %[[VAL_6:.*]] = constant %[[VAL_4]]#1 {value = 0 : i32} : i32
// CHECK:           %[[VAL_5]], %[[VAL_7:.*]] = lsq_load{{\[}}%[[VAL_6]]] %[[VAL_2]] : i32, i32
// CHECK:           %[[VAL_8:.*]] = return %[[VAL_7]] : i32
// CHECK:           end %[[VAL_8]], %[[VAL_3]] : i32, none
// CHECK:         }
handshake.func @makeLSQForkLazyDoNothingFork(%memref: memref<64xi32>, %start: none) -> i32 {
  %ldData1, %done = lsq [%memref: memref<64xi32>] (%forkCtrl#0, %ldAddrToMem) {groupSizes = [1 : i32]} : (none, i32) -> (i32, none)
  %forkCtrl:2 = fork [2] %start : none
  %addr = constant %forkCtrl#1 {value = 0 : i32} : i32
  %ldAddrToMem, %ldDataToSucc = lsq_load [%addr] %ldData1 : i32, i32
  %returnVal = return %ldDataToSucc : i32
  end %returnVal, %done : i32, none
}

// -----

// CHECK-LABEL:   handshake.func @makeLSQForkLazyEasy(
// CHECK-SAME:                                        %[[VAL_0:.*]]: memref<64xi32>,
// CHECK-SAME:                                        %[[VAL_1:.*]]: i32, %[[VAL_2:.*]]: i32,
// CHECK-SAME:                                        %[[VAL_3:.*]]: none, ...) -> i32 attributes {argNames = ["memref", "addr1", "addr2", "start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_4:.*]]:2, %[[VAL_5:.*]] = lsq{{\[}}%[[VAL_0]] : memref<64xi32>] (%[[VAL_6:.*]]#0, %[[VAL_7:.*]], %[[VAL_6]]#1, %[[VAL_8:.*]])  {groupSizes = [1 : i32, 1 : i32]} : (none, i32, none, i32) -> (i32, i32, none)
// CHECK:           %[[VAL_6]]:2 = lazy_fork [2] %[[VAL_3]] : none
// CHECK:           %[[VAL_7]], %[[VAL_9:.*]] = lsq_load{{\[}}%[[VAL_1]]] %[[VAL_4]]#0 : i32, i32
// CHECK:           %[[VAL_8]], %[[VAL_10:.*]] = lsq_load{{\[}}%[[VAL_2]]] %[[VAL_4]]#1 : i32, i32
// CHECK:           %[[VAL_11:.*]] = arith.addi %[[VAL_9]], %[[VAL_10]] : i32
// CHECK:           %[[VAL_12:.*]] = return %[[VAL_11]] : i32
// CHECK:           end %[[VAL_12]], %[[VAL_5]] : i32, none
// CHECK:         }
handshake.func @makeLSQForkLazyEasy(%memref: memref<64xi32>, %addr1 : i32, %addr2 : i32, %start: none) -> i32 {
  %ldData1, %ldData2, %done = lsq [%memref: memref<64xi32>] (%forkCtrl#0, %ldAddrToMem1, %forkCtrl#1, %ldAddrToMem2) {groupSizes = [1 : i32, 1 : i32]} : (none, i32, none, i32) -> (i32, i32, none)
  %forkCtrl:2 = fork [2] %start : none
  %ldAddrToMem1, %ldDataToSucc1 = lsq_load [%addr1] %ldData1 : i32, i32
  %ldAddrToMem2, %ldDataToSucc2 = lsq_load [%addr2] %ldData2 : i32, i32
  %add = arith.addi %ldDataToSucc1, %ldDataToSucc2 : i32
  %returnVal = return %add : i32
  end %returnVal, %done : i32, none
}

// -----

// CHECK-LABEL:   handshake.func @makeLSQForkLazyNeedEager(
// CHECK-SAME:                                             %[[VAL_0:.*]]: memref<64xi32>,
// CHECK-SAME:                                             %[[VAL_1:.*]]: none, ...) -> i32 attributes {argNames = ["memref", "start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_2:.*]]:2, %[[VAL_3:.*]] = lsq{{\[}}%[[VAL_0]] : memref<64xi32>] (%[[VAL_4:.*]]#0, %[[VAL_5:.*]], %[[VAL_4]]#1, %[[VAL_6:.*]])  {groupSizes = [1 : i32, 1 : i32]} : (none, i32, none, i32) -> (i32, i32, none)
// CHECK:           %[[VAL_4]]:3 = lazy_fork [3] %[[VAL_1]] : none
// CHECK:           %[[VAL_7:.*]]:2 = fork [2] %[[VAL_4]]#2 : none
// CHECK:           %[[VAL_8:.*]] = constant %[[VAL_7]]#0 {value = 0 : i32} : i32
// CHECK:           %[[VAL_5]], %[[VAL_9:.*]] = lsq_load{{\[}}%[[VAL_8]]] %[[VAL_2]]#0 : i32, i32
// CHECK:           %[[VAL_10:.*]] = constant %[[VAL_7]]#1 {value = 1 : i32} : i32
// CHECK:           %[[VAL_6]], %[[VAL_11:.*]] = lsq_load{{\[}}%[[VAL_10]]] %[[VAL_2]]#1 : i32, i32
// CHECK:           %[[VAL_12:.*]] = arith.addi %[[VAL_9]], %[[VAL_11]] : i32
// CHECK:           %[[VAL_13:.*]] = return %[[VAL_12]] : i32
// CHECK:           end %[[VAL_13]], %[[VAL_3]] : i32, none
// CHECK:         }
handshake.func @makeLSQForkLazyNeedEager(%memref: memref<64xi32>, %start: none) -> i32 {
  %ldData1, %ldData2, %done = lsq [%memref: memref<64xi32>] (%forkCtrl1#0, %ldAddrToMem1, %forkCtrl2#0, %ldAddrToMem2) {groupSizes = [1 : i32, 1 : i32]} : (none, i32, none, i32) -> (i32, i32, none)
  %forkCtrl1:3 = fork [3] %start : none
  %addr1 = constant %forkCtrl1#1 {value = 0 : i32} : i32
  %ldAddrToMem1, %ldDataToSucc1 = lsq_load [%addr1] %ldData1 : i32, i32
  %forkCtrl2:2 = fork [2] %forkCtrl1 : none
  %addr2 = constant %forkCtrl2#1 {value = 1 : i32} : i32
  %ldAddrToMem2, %ldDataToSucc2 = lsq_load [%addr2] %ldData2 : i32, i32
  %add = arith.addi %ldDataToSucc1, %ldDataToSucc2 : i32
  %returnVal = return %add : i32
  end %returnVal, %done : i32, none
}

// CHECK-LABEL:   handshake.func @makeLSQForkLazyComplex(
// CHECK-SAME:                                           %[[VAL_0:.*]]: memref<64xi32>,
// CHECK-SAME:                                           %[[VAL_1:.*]]: none, ...) -> i32 attributes {argNames = ["memref", "start"], resNames = ["out0"]} {
// CHECK:           %[[VAL_2:.*]]:3, %[[VAL_3:.*]] = lsq{{\[}}%[[VAL_0]] : memref<64xi32>] (%[[VAL_4:.*]]#0, %[[VAL_5:.*]], %[[VAL_6:.*]]#0, %[[VAL_7:.*]], %[[VAL_8:.*]]#0, %[[VAL_9:.*]])  {groupSizes = [1 : i32, 1 : i32, 1 : i32]} : (none, i32, none, i32, none, i32) -> (i32, i32, i32, none)
// CHECK:           %[[VAL_10:.*]] = merge %[[VAL_1]], %[[VAL_6]]#1 {bb = 1 : ui32} : none
// CHECK:           %[[VAL_4]]:3 = lazy_fork [3] %[[VAL_10]] {bb = 1 : ui32} : none
// CHECK:           %[[VAL_11:.*]]:2 = fork [2] %[[VAL_4]]#2 {bb = 1 : ui32} : none
// CHECK:           %[[VAL_12:.*]] = constant %[[VAL_11]]#0 {bb = 1 : ui32, value = false} : i1
// CHECK:           %[[VAL_13:.*]] = constant %[[VAL_11]]#1 {bb = 1 : ui32, value = 0 : i32} : i32
// CHECK:           %[[VAL_5]], %[[VAL_14:.*]] = lsq_load{{\[}}%[[VAL_13]]] %[[VAL_2]]#0 {bb = 1 : ui32} : i32, i32
// CHECK:           %[[VAL_15:.*]], %[[VAL_16:.*]] = cond_br %[[VAL_12]], %[[VAL_4]]#1 {bb = 1 : ui32} : none
// CHECK:           sink %[[VAL_14]] : i32
// CHECK:           %[[VAL_6]]:3 = lazy_fork [3] %[[VAL_15]] {bb = 2 : ui32} : none
// CHECK:           %[[VAL_17:.*]] = fork [1] %[[VAL_6]]#2 {bb = 2 : ui32} : none
// CHECK:           %[[VAL_18:.*]] = constant %[[VAL_17]] {bb = 2 : ui32, value = 1 : i32} : i32
// CHECK:           %[[VAL_7]], %[[VAL_19:.*]] = lsq_load{{\[}}%[[VAL_18]]] %[[VAL_2]]#1 {bb = 2 : ui32} : i32, i32
// CHECK:           sink %[[VAL_19]] : i32
// CHECK:           %[[VAL_8]]:2 = fork [2] %[[VAL_16]] {bb = 3 : ui32} : none
// CHECK:           %[[VAL_20:.*]] = constant %[[VAL_8]]#1 {bb = 3 : ui32, value = 2 : i32} : i32
// CHECK:           %[[VAL_9]], %[[VAL_21:.*]] = lsq_load{{\[}}%[[VAL_20]]] %[[VAL_2]]#2 {bb = 3 : ui32} : i32, i32
// CHECK:           %[[VAL_22:.*]] = return {bb = 3 : ui32} %[[VAL_21]] : i32
// CHECK:           end {bb = 3 : ui32} %[[VAL_22]], %[[VAL_3]] : i32, none
// CHECK:         }
handshake.func @makeLSQForkLazyComplex(%memref: memref<64xi32>, %start: none) -> i32 {
  %ldData1, %ldData2, %ldData3, %done = lsq [%memref: memref<64xi32>] (%forkCtrl1#0, %ldAddrToMem1, %forkCtrl2#0, %ldAddrToMem2, %forkCtrl3#0, %ldAddrToMem3) {groupSizes = [1 : i32, 1 : i32, 1 : i32]} : (none, i32, none, i32, none, i32) -> (i32, i32, i32, none)
// ^^bb0
// ^^bb1 (from ^^bb0, ^bb2, to ^bb2, ^bb3):
  %ctrl1 = merge %start#0, %forkCtrl2#2 {bb = 1 : ui32} : none
  %forkCtrl1:4 = fork [4] %ctrl1 {bb = 1 : ui32} : none
  %cond = constant %forkCtrl1#1 {value = 0 : i1, bb = 1 : ui32} : i1
  %addr1 = constant %forkCtrl1#2 {value = 0 : i32, bb = 1 : ui32} : i32
  %ldAddrToMem1, %ldDataToSucc1 = lsq_load [%addr1] %ldData1 {bb = 1 : ui32} : i32, i32
  %ctrl1To2, %ctrl1To3 = cond_br %cond, %forkCtrl1#3 {bb = 1 : ui32} : none
  sink %ldDataToSucc1 : i32
// ^^bb2 (from ^^bb1, to ^^bb1):
  %forkCtrl2:3 = fork [3] %ctrl1To2 {bb = 2 : ui32} : none
  %addr2 = constant %forkCtrl2#1 {value = 1 : i32, bb = 2 : ui32} : i32
  %ldAddrToMem2, %ldDataToSucc2 = lsq_load [%addr2] %ldData2 {bb = 2 : ui32} : i32, i32
  sink %ldDataToSucc2 : i32
// ^^bb3:
  %forkCtrl3:2 = fork [2] %ctrl1To3 {bb = 3 : ui32} : none
  %addr3 = constant %forkCtrl3#1 {value = 2 : i32, bb = 3 : ui32} : i32
  %ldAddrToMem3, %ldDataToSucc3 = lsq_load [%addr3] %ldData3 {bb = 3 : ui32} : i32, i32
  %returnVal = return {bb = 3 : ui32} %ldDataToSucc3 : i32
  end {bb = 3 : ui32} %returnVal, %done : i32, none
}
