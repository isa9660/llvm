; RUN: llc < %s -o /dev/null -mcpu=prescott
; RUN: llc < %s -o /dev/null -mcpu=nocona
; RUN: llc < %s -o /dev/null -mcpu=core2
; RUN: llc < %s -o /dev/null -mcpu=penryn
; RUN: llc < %s -o /dev/null -mcpu=nehalem
; RUN: llc < %s -o /dev/null -mcpu=westmere
; RUN: llc < %s -o /dev/null -mcpu=sandybridge
; RUN: llc < %s -o /dev/null -mcpu=ivybridge
; RUN: llc < %s -o /dev/null -mcpu=haswell
; RUN: llc < %s -o /dev/null -mcpu=broadwell
; RUN: llc < %s -o /dev/null -mcpu=bonnell
; RUN: llc < %s -o /dev/null -mcpu=silvermont
; RUN: llc < %s -o /dev/null -mcpu=k8
; RUN: llc < %s -o /dev/null -mcpu=opteron
; RUN: llc < %s -o /dev/null -mcpu=athlon64
; RUN: llc < %s -o /dev/null -mcpu=athlon-fx
; RUN: llc < %s -o /dev/null -mcpu=k8-sse3
; RUN: llc < %s -o /dev/null -mcpu=opteron-sse3
; RUN: llc < %s -o /dev/null -mcpu=athlon64-sse3
; RUN: llc < %s -o /dev/null -mcpu=amdfam10
; RUN: llc < %s -o /dev/null -mcpu=barcelona
; RUN: llc < %s -o /dev/null -mcpu=bdver1
; RUN: llc < %s -o /dev/null -mcpu=bdver2
; RUN: llc < %s -o /dev/null -mcpu=bdver3
; RUN: llc < %s -o /dev/null -mcpu=bdver4
; RUN: llc < %s -o /dev/null -mcpu=btver1
; RUN: llc < %s -o /dev/null -mcpu=btver2
; RUN: llc < %s -o /dev/null -mcpu=winchip-c6
; RUN: llc < %s -o /dev/null -mcpu=winchip2
; RUN: llc < %s -o /dev/null -mcpu=c3
; RUN: llc < %s -o /dev/null -mcpu=c3-2
; RUN: llc < %s -o /dev/null -mcpu=geode
