//===- WasmYAML.cpp - Wasm YAMLIO implementation --------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines classes for handling the YAML representation of wasm.
//
//===----------------------------------------------------------------------===//

#include "llvm/ObjectYAML/WasmYAML.h"
#include "llvm/Object/Wasm.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/MipsABIFlags.h"

namespace llvm {

namespace WasmYAML {

// Declared here rather than in the header to comply with:
// http://llvm.org/docs/CodingStandards.html#provide-a-virtual-method-anchor-for-classes-in-headers
Section::~Section() {}

} // end namespace WasmYAML

namespace yaml {

void MappingTraits<WasmYAML::FileHeader>::mapping(
    IO &IO, WasmYAML::FileHeader &FileHdr) {
  IO.mapRequired("Version", FileHdr.Version);
}

void MappingTraits<WasmYAML::Object>::mapping(IO &IO,
                                              WasmYAML::Object &Object) {
  IO.setContext(&Object);
  IO.mapTag("!WASM", true);
  IO.mapRequired("FileHeader", Object.Header);
  IO.mapOptional("Sections", Object.Sections);
  IO.setContext(nullptr);
}

static void commonSectionMapping(IO &IO, WasmYAML::Section &Section) {
  IO.mapRequired("Type", Section.Type);
  IO.mapOptional("Relocations", Section.Relocations);
}

static void sectionMapping(IO &IO, WasmYAML::CustomSection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapRequired("Name", Section.Name);
  if (Section.Name == "name") {
    IO.mapOptional("FunctionNames", Section.FunctionNames);
  } else {
    IO.mapRequired("Payload", Section.Payload);
  }
}

static void sectionMapping(IO &IO, WasmYAML::TypeSection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapOptional("Signatures", Section.Signatures);
}

static void sectionMapping(IO &IO, WasmYAML::ImportSection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapOptional("Imports", Section.Imports);
}

static void sectionMapping(IO &IO, WasmYAML::FunctionSection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapOptional("FunctionTypes", Section.FunctionTypes);
}

static void sectionMapping(IO &IO, WasmYAML::TableSection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapOptional("Tables", Section.Tables);
}

static void sectionMapping(IO &IO, WasmYAML::MemorySection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapOptional("Memories", Section.Memories);
}

static void sectionMapping(IO &IO, WasmYAML::GlobalSection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapOptional("Globals", Section.Globals);
}

static void sectionMapping(IO &IO, WasmYAML::ExportSection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapOptional("Exports", Section.Exports);
}

static void sectionMapping(IO &IO, WasmYAML::StartSection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapOptional("StartFunction", Section.StartFunction);
}

static void sectionMapping(IO &IO, WasmYAML::ElemSection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapOptional("Segments", Section.Segments);
}

static void sectionMapping(IO &IO, WasmYAML::CodeSection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapRequired("Functions", Section.Functions);
}

static void sectionMapping(IO &IO, WasmYAML::DataSection &Section) {
  commonSectionMapping(IO, Section);
  IO.mapRequired("Segments", Section.Segments);
}

void MappingTraits<std::unique_ptr<WasmYAML::Section>>::mapping(
    IO &IO, std::unique_ptr<WasmYAML::Section> &Section) {
  WasmYAML::SectionType SectionType;
  if (IO.outputting())
    SectionType = Section->Type;
  else
    IO.mapRequired("Type", SectionType);

  switch (SectionType) {
  case wasm::WASM_SEC_CUSTOM:
    if (!IO.outputting())
      Section.reset(new WasmYAML::CustomSection());
    sectionMapping(IO, *cast<WasmYAML::CustomSection>(Section.get()));
    break;
  case wasm::WASM_SEC_TYPE:
    if (!IO.outputting())
      Section.reset(new WasmYAML::TypeSection());
    sectionMapping(IO, *cast<WasmYAML::TypeSection>(Section.get()));
    break;
  case wasm::WASM_SEC_IMPORT:
    if (!IO.outputting())
      Section.reset(new WasmYAML::ImportSection());
    sectionMapping(IO, *cast<WasmYAML::ImportSection>(Section.get()));
    break;
  case wasm::WASM_SEC_FUNCTION:
    if (!IO.outputting())
      Section.reset(new WasmYAML::FunctionSection());
    sectionMapping(IO, *cast<WasmYAML::FunctionSection>(Section.get()));
    break;
  case wasm::WASM_SEC_TABLE:
    if (!IO.outputting())
      Section.reset(new WasmYAML::TableSection());
    sectionMapping(IO, *cast<WasmYAML::TableSection>(Section.get()));
    break;
  case wasm::WASM_SEC_MEMORY:
    if (!IO.outputting())
      Section.reset(new WasmYAML::MemorySection());
    sectionMapping(IO, *cast<WasmYAML::MemorySection>(Section.get()));
    break;
  case wasm::WASM_SEC_GLOBAL:
    if (!IO.outputting())
      Section.reset(new WasmYAML::GlobalSection());
    sectionMapping(IO, *cast<WasmYAML::GlobalSection>(Section.get()));
    break;
  case wasm::WASM_SEC_EXPORT:
    if (!IO.outputting())
      Section.reset(new WasmYAML::ExportSection());
    sectionMapping(IO, *cast<WasmYAML::ExportSection>(Section.get()));
    break;
  case wasm::WASM_SEC_START:
    if (!IO.outputting())
      Section.reset(new WasmYAML::StartSection());
    sectionMapping(IO, *cast<WasmYAML::StartSection>(Section.get()));
    break;
  case wasm::WASM_SEC_ELEM:
    if (!IO.outputting())
      Section.reset(new WasmYAML::ElemSection());
    sectionMapping(IO, *cast<WasmYAML::ElemSection>(Section.get()));
    break;
  case wasm::WASM_SEC_CODE:
    if (!IO.outputting())
      Section.reset(new WasmYAML::CodeSection());
    sectionMapping(IO, *cast<WasmYAML::CodeSection>(Section.get()));
    break;
  case wasm::WASM_SEC_DATA:
    if (!IO.outputting())
      Section.reset(new WasmYAML::DataSection());
    sectionMapping(IO, *cast<WasmYAML::DataSection>(Section.get()));
    break;
  default:
    llvm_unreachable("Unknown section type");
  }
}

void ScalarEnumerationTraits<WasmYAML::SectionType>::enumeration(
    IO &IO, WasmYAML::SectionType &Type) {
#define ECase(X) IO.enumCase(Type, #X, wasm::WASM_SEC_##X);
  ECase(CUSTOM);
  ECase(TYPE);
  ECase(IMPORT);
  ECase(FUNCTION);
  ECase(TABLE);
  ECase(MEMORY);
  ECase(GLOBAL);
  ECase(EXPORT);
  ECase(START);
  ECase(ELEM);
  ECase(CODE);
  ECase(DATA);
#undef ECase
}

void MappingTraits<WasmYAML::Signature>::mapping(
    IO &IO, WasmYAML::Signature &Signature) {
  IO.mapOptional("Index", Signature.Index);
  IO.mapRequired("ReturnType", Signature.ReturnType);
  IO.mapRequired("ParamTypes", Signature.ParamTypes);
}

void MappingTraits<WasmYAML::Table>::mapping(IO &IO, WasmYAML::Table &Table) {
  IO.mapRequired("ElemType", Table.ElemType);
  IO.mapRequired("Limits", Table.TableLimits);
}

void MappingTraits<WasmYAML::Function>::mapping(IO &IO,
                                                WasmYAML::Function &Function) {
  IO.mapRequired("Locals", Function.Locals);
  IO.mapRequired("Body", Function.Body);
}

void MappingTraits<WasmYAML::Relocation>::mapping(
    IO &IO, WasmYAML::Relocation &Relocation) {
  IO.mapRequired("Type", Relocation.Type);
  IO.mapRequired("Index", Relocation.Index);
  IO.mapRequired("Offset", Relocation.Offset);
  IO.mapOptional("Addend", Relocation.Addend, 0);
}

void MappingTraits<WasmYAML::NameEntry>::mapping(
    IO &IO, WasmYAML::NameEntry &NameEntry) {
  IO.mapRequired("Index", NameEntry.Index);
  IO.mapRequired("Name", NameEntry.Name);
}

void MappingTraits<WasmYAML::LocalDecl>::mapping(
    IO &IO, WasmYAML::LocalDecl &LocalDecl) {
  IO.mapRequired("Type", LocalDecl.Type);
  IO.mapRequired("Count", LocalDecl.Count);
}

void MappingTraits<WasmYAML::Limits>::mapping(IO &IO,
                                              WasmYAML::Limits &Limits) {
  if (!IO.outputting() || Limits.Flags)
    IO.mapOptional("Flags", Limits.Flags);
  IO.mapRequired("Initial", Limits.Initial);
  if (!IO.outputting() || Limits.Flags & wasm::WASM_LIMITS_FLAG_HAS_MAX)
    IO.mapOptional("Maximum", Limits.Maximum);
}

void MappingTraits<WasmYAML::ElemSegment>::mapping(
    IO &IO, WasmYAML::ElemSegment &Segment) {
  IO.mapRequired("Offset", Segment.Offset);
  IO.mapRequired("Functions", Segment.Functions);
}

void MappingTraits<WasmYAML::Import>::mapping(IO &IO,
                                              WasmYAML::Import &Import) {
  IO.mapRequired("Module", Import.Module);
  IO.mapRequired("Field", Import.Field);
  IO.mapRequired("Kind", Import.Kind);
  if (Import.Kind == wasm::WASM_EXTERNAL_FUNCTION) {
    IO.mapRequired("SigIndex", Import.SigIndex);
  } else if (Import.Kind == wasm::WASM_EXTERNAL_GLOBAL) {
    IO.mapRequired("GlobalType", Import.Global.Type);
    IO.mapRequired("GlobalMutable", Import.Global.Mutable);
  } else if (Import.Kind == wasm::WASM_EXTERNAL_TABLE) {
    IO.mapRequired("Table", Import.Table);
  } else if (Import.Kind == wasm::WASM_EXTERNAL_MEMORY ) {
    IO.mapRequired("Memory", Import.Memory);
  } else {
    llvm_unreachable("unhandled import type");
  }
}

void MappingTraits<WasmYAML::Export>::mapping(IO &IO,
                                              WasmYAML::Export &Export) {
  IO.mapRequired("Name", Export.Name);
  IO.mapRequired("Kind", Export.Kind);
  IO.mapRequired("Index", Export.Index);
}

void MappingTraits<WasmYAML::Global>::mapping(IO &IO,
                                              WasmYAML::Global &Global) {
  IO.mapRequired("Type", Global.Type);
  IO.mapRequired("Mutable", Global.Mutable);
  IO.mapRequired("InitExpr", Global.InitExpr);
}

void MappingTraits<wasm::WasmInitExpr>::mapping(IO &IO,
                                                wasm::WasmInitExpr &Expr) {
  WasmYAML::Opcode Op = Expr.Opcode;
  IO.mapRequired("Opcode", Op);
  Expr.Opcode = Op;
  switch (Expr.Opcode) {
  case wasm::WASM_OPCODE_I32_CONST:
    IO.mapRequired("Value", Expr.Value.Int32);
    break;
  case wasm::WASM_OPCODE_I64_CONST:
    IO.mapRequired("Value", Expr.Value.Int64);
    break;
  case wasm::WASM_OPCODE_F32_CONST:
    IO.mapRequired("Value", Expr.Value.Float32);
    break;
  case wasm::WASM_OPCODE_F64_CONST:
    IO.mapRequired("Value", Expr.Value.Float64);
    break;
  case wasm::WASM_OPCODE_GET_GLOBAL:
    IO.mapRequired("Index", Expr.Value.Global);
    break;
  }
}

void MappingTraits<WasmYAML::DataSegment>::mapping(
    IO &IO, WasmYAML::DataSegment &Segment) {
  IO.mapRequired("Index", Segment.Index);
  IO.mapRequired("Offset", Segment.Offset);
  IO.mapRequired("Content", Segment.Content);
}

void ScalarEnumerationTraits<WasmYAML::ValueType>::enumeration(
    IO &IO, WasmYAML::ValueType &Type) {
#define ECase(X) IO.enumCase(Type, #X, wasm::WASM_TYPE_##X);
  ECase(I32);
  ECase(I64);
  ECase(F32);
  ECase(F64);
  ECase(ANYFUNC);
  ECase(FUNC);
  ECase(NORESULT);
#undef ECase
}

void ScalarEnumerationTraits<WasmYAML::ExportKind>::enumeration(
    IO &IO, WasmYAML::ExportKind &Kind) {
#define ECase(X) IO.enumCase(Kind, #X, wasm::WASM_EXTERNAL_##X);
  ECase(FUNCTION);
  ECase(TABLE);
  ECase(MEMORY);
  ECase(GLOBAL);
#undef ECase
}

void ScalarEnumerationTraits<WasmYAML::Opcode>::enumeration(
    IO &IO, WasmYAML::Opcode &Code) {
#define ECase(X) IO.enumCase(Code, #X, wasm::WASM_OPCODE_##X);
  ECase(END);
  ECase(I32_CONST);
  ECase(I64_CONST);
  ECase(F64_CONST);
  ECase(F32_CONST);
  ECase(GET_GLOBAL);
#undef ECase
}

void ScalarEnumerationTraits<WasmYAML::TableType>::enumeration(
    IO &IO, WasmYAML::TableType &Type) {
#define ECase(X) IO.enumCase(Type, #X, wasm::WASM_TYPE_##X);
  ECase(ANYFUNC);
#undef ECase
}

void ScalarEnumerationTraits<WasmYAML::RelocType>::enumeration(
    IO &IO, WasmYAML::RelocType &Type) {
#define WASM_RELOC(name, value) IO.enumCase(Type, #name, wasm::name);
#include "llvm/Support/WasmRelocs/WebAssembly.def"
#undef WASM_RELOC
}

} // end namespace yaml
} // end namespace llvm
