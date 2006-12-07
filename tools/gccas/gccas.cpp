//===-- gccas.cpp - The "optimizing assembler" used by the GCC frontend ---===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This utility is designed to be used by the GCC frontend for creating bytecode
// files from its intermediate LLVM assembly.  The requirements for this utility
// are thus slightly different than that of the standard `as' util.
//
//===----------------------------------------------------------------------===//

#include "llvm/Module.h"
#include "llvm/PassManager.h"
#include "llvm/Analysis/LoadValueNumbering.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/Assembly/Parser.h"
#include "llvm/Bytecode/WriteBytecodePass.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Streams.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/System/Signals.h"
#include <iostream>
#include <memory>
#include <fstream>
using namespace llvm;

namespace {
  cl::opt<std::string>
  InputFilename(cl::Positional,cl::desc("<input llvm assembly>"),cl::init("-"));

  cl::opt<std::string>
  OutputFilename("o", cl::desc("Override output filename"),
                 cl::value_desc("filename"));

  cl::opt<bool>
  Verify("verify", cl::desc("Verify each pass result"));

  cl::opt<bool>
  DisableInline("disable-inlining", cl::desc("Do not run the inliner pass"));

  cl::opt<bool>
  DisableOptimizations("disable-opt",
                       cl::desc("Do not run any optimization passes"));

  cl::opt<bool>
  StripDebug("strip-debug",
             cl::desc("Strip debugger symbol info from translation unit"));

  cl::opt<bool>
  NoCompress("disable-compression", cl::init(false),
             cl::desc("Don't compress the generated bytecode"));

  cl::opt<bool> TF("traditional-format", cl::Hidden,
    cl::desc("Compatibility option: ignored"));
}


static inline void addPass(PassManager &PM, Pass *P) {
  // Add the pass to the pass manager...
  PM.add(P);

  // If we are verifying all of the intermediate steps, add the verifier...
  if (Verify) PM.add(createVerifierPass());
}


void AddConfiguredTransformationPasses(PassManager &PM) {
  PM.add(createVerifierPass());                  // Verify that input is correct

  addPass(PM, createLowerSetJmpPass());          // Lower llvm.setjmp/.longjmp
  addPass(PM, createFunctionResolvingPass());    // Resolve (...) functions

  // If the -strip-debug command line option was specified, do it.
  if (StripDebug)
    addPass(PM, createStripSymbolsPass(true));

  if (DisableOptimizations) return;

  addPass(PM, createRaiseAllocationsPass());     // call %malloc -> malloc inst
  addPass(PM, createCFGSimplificationPass());    // Clean up disgusting code
  addPass(PM, createPromoteMemoryToRegisterPass());// Kill useless allocas
  addPass(PM, createGlobalOptimizerPass());      // Optimize out global vars
  addPass(PM, createGlobalDCEPass());            // Remove unused fns and globs
  addPass(PM, createIPConstantPropagationPass());// IP Constant Propagation
  addPass(PM, createDeadArgEliminationPass());   // Dead argument elimination
  addPass(PM, createInstructionCombiningPass()); // Clean up after IPCP & DAE
  addPass(PM, createCFGSimplificationPass());    // Clean up after IPCP & DAE

  addPass(PM, createPruneEHPass());              // Remove dead EH info

  if (!DisableInline)
    addPass(PM, createFunctionInliningPass());   // Inline small functions
  addPass(PM, createSimplifyLibCallsPass());     // Library Call Optimizations
  addPass(PM, createArgumentPromotionPass());    // Scalarize uninlined fn args

  addPass(PM, createRaisePointerReferencesPass());// Recover type information
  addPass(PM, createTailDuplicationPass());      // Simplify cfg by copying code
  addPass(PM, createCFGSimplificationPass());    // Merge & remove BBs
  addPass(PM, createScalarReplAggregatesPass()); // Break up aggregate allocas
  addPass(PM, createInstructionCombiningPass()); // Combine silly seq's
  addPass(PM, createCondPropagationPass());      // Propagate conditionals

  addPass(PM, createTailCallEliminationPass());  // Eliminate tail calls
  addPass(PM, createCFGSimplificationPass());    // Merge & remove BBs
  addPass(PM, createReassociatePass());          // Reassociate expressions
  addPass(PM, createLICMPass());                 // Hoist loop invariants
  addPass(PM, createLoopUnswitchPass());         // Unswitch loops.
  addPass(PM, createInstructionCombiningPass()); // Clean up after LICM/reassoc
  addPass(PM, createIndVarSimplifyPass());       // Canonicalize indvars
  addPass(PM, createLoopUnrollPass());           // Unroll small loops
  addPass(PM, createInstructionCombiningPass()); // Clean up after the unroller
  addPass(PM, createLoadValueNumberingPass());   // GVN for load instructions
  addPass(PM, createGCSEPass());                 // Remove common subexprs
  addPass(PM, createSCCPPass());                 // Constant prop with SCCP

  // Run instcombine after redundancy elimination to exploit opportunities
  // opened up by them.
  addPass(PM, createInstructionCombiningPass());
  addPass(PM, createCondPropagationPass());      // Propagate conditionals

  addPass(PM, createDeadStoreEliminationPass()); // Delete dead stores
  addPass(PM, createAggressiveDCEPass());        // SSA based 'Aggressive DCE'
  addPass(PM, createCFGSimplificationPass());    // Merge & remove BBs
  addPass(PM, createDeadTypeEliminationPass());  // Eliminate dead types
  addPass(PM, createConstantMergePass());        // Merge dup global constants
}


int main(int argc, char **argv) {
  llvm_shutdown_obj X;  // Call llvm_shutdown() on exit.
  try {
    cl::ParseCommandLineOptions(argc, argv,
                                " llvm .s -> .o assembler for GCC\n");
    sys::PrintStackTraceOnErrorSignal();

    ParseError Err;
    std::auto_ptr<Module> M(ParseAssemblyFile(InputFilename,&Err));
    if (M.get() == 0) {
      cerr << argv[0] << ": " << Err.getMessage() << "\n"; 
      return 1;
    }

    std::ostream *Out = 0;
    if (OutputFilename == "") {   // Didn't specify an output filename?
      if (InputFilename == "-") {
        OutputFilename = "-";
      } else {
        std::string IFN = InputFilename;
        int Len = IFN.length();
        if (IFN[Len-2] == '.' && IFN[Len-1] == 's') {   // Source ends in .s?
          OutputFilename = std::string(IFN.begin(), IFN.end()-2);
        } else {
          OutputFilename = IFN;   // Append a .o to it
        }
        OutputFilename += ".o";
      }
    }

    if (OutputFilename == "-")
      // FIXME: cout is not binary!
      Out = &std::cout;
    else {
      std::ios::openmode io_mode = std::ios::out | std::ios::trunc |
                                   std::ios::binary;
      Out = new std::ofstream(OutputFilename.c_str(), io_mode);

      // Make sure that the Out file gets unlinked from the disk if we get a
      // signal
      sys::RemoveFileOnSignal(sys::Path(OutputFilename));
    }


    if (!Out->good()) {
      cerr << argv[0] << ": error opening " << OutputFilename << "!\n";
      return 1;
    }

    // In addition to just parsing the input from GCC, we also want to spiff 
    // it up a little bit.  Do this now.
    PassManager Passes;

    // Add an appropriate TargetData instance for this module...
    Passes.add(new TargetData(M.get()));

    // Add all of the transformation passes to the pass manager to do the 
    // cleanup and optimization of the GCC output.
    AddConfiguredTransformationPasses(Passes);

    // Make sure everything is still good.
    Passes.add(createVerifierPass());

    // Write bytecode to file...
    OStream L(*Out);
    Passes.add(new WriteBytecodePass(&L,false,!NoCompress));

    // Run our queue of passes all at once now, efficiently.
    Passes.run(*M.get());

    if (Out != &std::cout) delete Out;
    return 0;
  } catch (const std::string& msg) {
    cerr << argv[0] << ": " << msg << "\n";
  } catch (...) {
    cerr << argv[0] << ": Unexpected unknown exception occurred.\n";
  }
  return 1;
}
