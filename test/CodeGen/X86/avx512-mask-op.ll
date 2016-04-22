; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -stack-symbol-ordering=0 -march=x86-64 -mtriple=x86_64-apple-darwin -mcpu=knl | FileCheck %s --check-prefix=CHECK --check-prefix=KNL
; RUN: llc < %s -stack-symbol-ordering=0 -march=x86-64 -mtriple=x86_64-apple-darwin -mcpu=skx | FileCheck %s --check-prefix=CHECK --check-prefix=SKX

define i16 @mask16(i16 %x) {
; CHECK-LABEL: mask16:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edi, %k0
; CHECK-NEXT:    knotw %k0, %k0
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %m0 = bitcast i16 %x to <16 x i1>
  %m1 = xor <16 x i1> %m0, <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>
  %ret = bitcast <16 x i1> %m1 to i16
  ret i16 %ret
}

define i8 @mask8(i8 %x) {
; KNL-LABEL: mask8:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw %edi, %k0
; KNL-NEXT:    knotw %k0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    retq
;
; SKX-LABEL: mask8:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovb %edi, %k0
; SKX-NEXT:    knotb %k0, %k0
; SKX-NEXT:    kmovb %k0, %eax
; SKX-NEXT:    retq
  %m0 = bitcast i8 %x to <8 x i1>
  %m1 = xor <8 x i1> %m0, <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>
  %ret = bitcast <8 x i1> %m1 to i8
  ret i8 %ret
}

define void @mask16_mem(i16* %ptr) {
; CHECK-LABEL: mask16_mem:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw (%rdi), %k0
; CHECK-NEXT:    knotw %k0, %k0
; CHECK-NEXT:    kmovw %k0, (%rdi)
; CHECK-NEXT:    retq
  %x = load i16, i16* %ptr, align 4
  %m0 = bitcast i16 %x to <16 x i1>
  %m1 = xor <16 x i1> %m0, <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>
  %ret = bitcast <16 x i1> %m1 to i16
  store i16 %ret, i16* %ptr, align 4
  ret void
}

define void @mask8_mem(i8* %ptr) {
; KNL-LABEL: mask8_mem:
; KNL:       ## BB#0:
; KNL-NEXT:    movzbw (%rdi), %ax
; KNL-NEXT:    kmovw %eax, %k0
; KNL-NEXT:    knotw %k0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    movb %al, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: mask8_mem:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovb (%rdi), %k0
; SKX-NEXT:    knotb %k0, %k0
; SKX-NEXT:    kmovb %k0, (%rdi)
; SKX-NEXT:    retq
  %x = load i8, i8* %ptr, align 4
  %m0 = bitcast i8 %x to <8 x i1>
  %m1 = xor <8 x i1> %m0, <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>
  %ret = bitcast <8 x i1> %m1 to i8
  store i8 %ret, i8* %ptr, align 4
  ret void
}

define i16 @mand16(i16 %x, i16 %y) {
; CHECK-LABEL: mand16:
; CHECK:       ## BB#0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    xorl %esi, %eax
; CHECK-NEXT:    andl %esi, %edi
; CHECK-NEXT:    orl %eax, %edi
; CHECK-NEXT:    movw %di, %ax
; CHECK-NEXT:    retq
  %ma = bitcast i16 %x to <16 x i1>
  %mb = bitcast i16 %y to <16 x i1>
  %mc = and <16 x i1> %ma, %mb
  %md = xor <16 x i1> %ma, %mb
  %me = or <16 x i1> %mc, %md
  %ret = bitcast <16 x i1> %me to i16
  ret i16 %ret
}

define i16 @mand16_mem(<16 x i1>* %x, <16 x i1>* %y) {
; CHECK-LABEL: mand16_mem:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw (%rdi), %k0
; CHECK-NEXT:    kmovw (%rsi), %k1
; CHECK-NEXT:    kandw %k1, %k0, %k2
; CHECK-NEXT:    kxorw %k1, %k0, %k0
; CHECK-NEXT:    korw %k0, %k2, %k0
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %ma = load <16 x i1>, <16 x i1>* %x
  %mb = load <16 x i1>, <16 x i1>* %y
  %mc = and <16 x i1> %ma, %mb
  %md = xor <16 x i1> %ma, %mb
  %me = or <16 x i1> %mc, %md
  %ret = bitcast <16 x i1> %me to i16
  ret i16 %ret
}

define i8 @shuf_test1(i16 %v) nounwind {
; KNL-LABEL: shuf_test1:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw %edi, %k0
; KNL-NEXT:    kshiftrw $8, %k0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    retq
;
; SKX-LABEL: shuf_test1:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovw %edi, %k0
; SKX-NEXT:    kshiftrw $8, %k0, %k0
; SKX-NEXT:    kmovb %k0, %eax
; SKX-NEXT:    retq
   %v1 = bitcast i16 %v to <16 x i1>
   %mask = shufflevector <16 x i1> %v1, <16 x i1> undef, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
   %mask1 = bitcast <8 x i1> %mask to i8
   ret i8 %mask1
}

define i32 @zext_test1(<16 x i32> %a, <16 x i32> %b) {
; CHECK-LABEL: zext_test1:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpnleud %zmm1, %zmm0, %k0
; CHECK-NEXT:    kshiftlw $10, %k0, %k0
; CHECK-NEXT:    kshiftrw $15, %k0, %k0
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    retq
  %cmp_res = icmp ugt <16 x i32> %a, %b
  %cmp_res.i1 = extractelement <16 x i1> %cmp_res, i32 5
  %res = zext i1 %cmp_res.i1 to i32
  ret i32 %res
}define i16 @zext_test2(<16 x i32> %a, <16 x i32> %b) {
  %cmp_res = icmp ugt <16 x i32> %a, %b
  %cmp_res.i1 = extractelement <16 x i1> %cmp_res, i32 5
  %res = zext i1 %cmp_res.i1 to i16
  ret i16 %res
}define i8 @zext_test3(<16 x i32> %a, <16 x i32> %b) {
  %cmp_res = icmp ugt <16 x i32> %a, %b
  %cmp_res.i1 = extractelement <16 x i1> %cmp_res, i32 5
  %res = zext i1 %cmp_res.i1 to i8
  ret i8 %res
}

define i8 @conv1(<8 x i1>* %R) {
; KNL-LABEL: conv1:
; KNL:       ## BB#0: ## %entry
; KNL-NEXT:    kxnorw %k0, %k0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    movb %al, (%rdi)
; KNL-NEXT:    movb $-2, -{{[0-9]+}}(%rsp)
; KNL-NEXT:    movb $-2, %al
; KNL-NEXT:    retq
;
; SKX-LABEL: conv1:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    kxnorw %k0, %k0, %k0
; SKX-NEXT:    kmovb %k0, (%rdi)
; SKX-NEXT:    movb $-2, -{{[0-9]+}}(%rsp)
; SKX-NEXT:    movb $-2, %al
; SKX-NEXT:    retq
entry:
  store <8 x i1> <i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1>, <8 x i1>* %R

  %maskPtr = alloca <8 x i1>
  store <8 x i1> <i1 0, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1>, <8 x i1>* %maskPtr
  %mask = load <8 x i1>, <8 x i1>* %maskPtr
  %mask_convert = bitcast <8 x i1> %mask to i8
  ret i8 %mask_convert
}

define <4 x i32> @test4(<4 x i64> %x, <4 x i64> %y, <4 x i64> %x1, <4 x i64> %y1) {
; KNL-LABEL: test4:
; KNL:       ## BB#0:
; KNL-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm0
; KNL-NEXT:    vpmovqd %zmm0, %ymm0
; KNL-NEXT:    vpslld $31, %xmm0, %xmm0
; KNL-NEXT:    vpsrad $31, %xmm0, %xmm0
; KNL-NEXT:    vpcmpgtq %ymm3, %ymm2, %ymm1
; KNL-NEXT:    vpmovqd %zmm1, %ymm1
; KNL-NEXT:    vpslld $31, %xmm1, %xmm1
; KNL-NEXT:    vpsrad $31, %xmm1, %xmm1
; KNL-NEXT:    vpcmpgtd %xmm1, %xmm0, %xmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: test4:
; SKX:       ## BB#0:
; SKX-NEXT:    vpcmpgtq %ymm3, %ymm2, %k0
; SKX-NEXT:    knotw %k0, %k1
; SKX-NEXT:    vpcmpgtq %ymm1, %ymm0, %k0 {%k1}
; SKX-NEXT:    vpmovm2d %k0, %xmm0
; SKX-NEXT:    retq
  %x_gt_y = icmp sgt <4 x i64> %x, %y
  %x1_gt_y1 = icmp sgt <4 x i64> %x1, %y1
  %res = icmp sgt <4 x i1>%x_gt_y, %x1_gt_y1
  %resse = sext <4 x i1>%res to <4 x i32>
  ret <4 x i32> %resse
}

define <2 x i64> @test5(<2 x i64> %x, <2 x i64> %y, <2 x i64> %x1, <2 x i64> %y1) {
; KNL-LABEL: test5:
; KNL:       ## BB#0:
; KNL-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm0
; KNL-NEXT:    vpcmpgtq %xmm3, %xmm2, %xmm1
; KNL-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: test5:
; SKX:       ## BB#0:
; SKX-NEXT:    vpcmpgtq %xmm0, %xmm1, %k0
; SKX-NEXT:    knotw %k0, %k1
; SKX-NEXT:    vpcmpgtq %xmm3, %xmm2, %k0 {%k1}
; SKX-NEXT:    vpmovm2q %k0, %xmm0
; SKX-NEXT:    retq
  %x_gt_y = icmp slt <2 x i64> %x, %y
  %x1_gt_y1 = icmp sgt <2 x i64> %x1, %y1
  %res = icmp slt <2 x i1>%x_gt_y, %x1_gt_y1
  %resse = sext <2 x i1>%res to <2 x i64>
  ret <2 x i64> %resse
}define void @test6(<16 x i1> %mask)  {
allocas:
  %a= and <16 x i1> %mask, <i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false>
  %b = bitcast <16 x i1> %a to i16
  %c = icmp eq i16 %b, 0
  br i1 %c, label %true, label %false

true:
  ret void

false:
  ret void
}
define void @test7(<8 x i1> %mask)  {
; KNL-LABEL: test7:
; KNL:       ## BB#0: ## %allocas
; KNL-NEXT:    vpmovsxwq %xmm0, %zmm0
; KNL-NEXT:    vpsllq $63, %zmm0, %zmm0
; KNL-NEXT:    vptestmq %zmm0, %zmm0, %k0
; KNL-NEXT:    movb $85, %al
; KNL-NEXT:    kmovw %eax, %k1
; KNL-NEXT:    korw %k1, %k0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    testb %al, %al
; KNL-NEXT:    retq
;
; SKX-LABEL: test7:
; SKX:       ## BB#0: ## %allocas
; SKX-NEXT:    vpsllw $15, %xmm0, %xmm0
; SKX-NEXT:    vpmovw2m %xmm0, %k0
; SKX-NEXT:    movb $85, %al
; SKX-NEXT:    kmovb %eax, %k1
; SKX-NEXT:    korb %k1, %k0, %k0
; SKX-NEXT:    ktestb %k0, %k0
; SKX-NEXT:    retq
allocas:
  %a= or <8 x i1> %mask, <i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false>
  %b = bitcast <8 x i1> %a to i8
  %c = icmp eq i8 %b, 0
  br i1 %c, label %true, label %false

true:
  ret void

false:
  ret void
}
define <16 x i8> @test8(<16 x i32>%a, <16 x i32>%b, i32 %a1, i32 %b1) {
; KNL-LABEL: test8:
; KNL:       ## BB#0:
; KNL-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; KNL-NEXT:    cmpl %esi, %edi
; KNL-NEXT:    jg LBB15_1
; KNL-NEXT:  ## BB#2:
; KNL-NEXT:    vpcmpltud %zmm2, %zmm1, %k1
; KNL-NEXT:    jmp LBB15_3
; KNL-NEXT:  LBB15_1:
; KNL-NEXT:    vpcmpgtd %zmm2, %zmm0, %k1
; KNL-NEXT:  LBB15_3:
; KNL-NEXT:    vpbroadcastd {{.*}}(%rip), %zmm0 {%k1} {z}
; KNL-NEXT:    vpmovdb %zmm0, %xmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: test8:
; SKX:       ## BB#0:
; SKX-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; SKX-NEXT:    cmpl %esi, %edi
; SKX-NEXT:    jg LBB15_1
; SKX-NEXT:  ## BB#2:
; SKX-NEXT:    vpcmpltud %zmm2, %zmm1, %k0
; SKX-NEXT:    vpmovm2b %k0, %xmm0
; SKX-NEXT:    retq
; SKX-NEXT:  LBB15_1:
; SKX-NEXT:    vpcmpgtd %zmm2, %zmm0, %k0
; SKX-NEXT:    vpmovm2b %k0, %xmm0
; SKX-NEXT:    retq
  %cond = icmp sgt i32 %a1, %b1
  %cmp1 = icmp sgt <16 x i32> %a, zeroinitializer
  %cmp2 = icmp ult <16 x i32> %b, zeroinitializer
  %mix = select i1 %cond, <16 x i1> %cmp1, <16 x i1> %cmp2
  %res = sext <16 x i1> %mix to <16 x i8>
  ret <16 x i8> %res
}
define <16 x i1> @test9(<16 x i1>%a, <16 x i1>%b, i32 %a1, i32 %b1) {
; KNL-LABEL: test9:
; KNL:       ## BB#0:
; KNL-NEXT:    cmpl %esi, %edi
; KNL-NEXT:    jg LBB16_1
; KNL-NEXT:  ## BB#2:
; KNL-NEXT:    vpmovsxbd %xmm1, %zmm0
; KNL-NEXT:    jmp LBB16_3
; KNL-NEXT:  LBB16_1:
; KNL-NEXT:    vpmovsxbd %xmm0, %zmm0
; KNL-NEXT:  LBB16_3:
; KNL-NEXT:    vpslld $31, %zmm0, %zmm0
; KNL-NEXT:    vptestmd %zmm0, %zmm0, %k1
; KNL-NEXT:    vpbroadcastd {{.*}}(%rip), %zmm0 {%k1} {z}
; KNL-NEXT:    vpmovdb %zmm0, %xmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: test9:
; SKX:       ## BB#0:
; SKX-NEXT:    cmpl %esi, %edi
; SKX-NEXT:    jg LBB16_1
; SKX-NEXT:  ## BB#2:
; SKX-NEXT:    vpsllw $7, %xmm1, %xmm0
; SKX-NEXT:    jmp LBB16_3
; SKX-NEXT:  LBB16_1:
; SKX-NEXT:    vpsllw $7, %xmm0, %xmm0
; SKX-NEXT:  LBB16_3:
; SKX-NEXT:    vpmovb2m %xmm0, %k0
; SKX-NEXT:    vpmovm2b %k0, %xmm0
; SKX-NEXT:    retq
  %mask = icmp sgt i32 %a1, %b1
  %c = select i1 %mask, <16 x i1>%a, <16 x i1>%b
  ret <16 x i1>%c
}define <8 x i1> @test10(<8 x i1>%a, <8 x i1>%b, i32 %a1, i32 %b1) {
  %mask = icmp sgt i32 %a1, %b1
  %c = select i1 %mask, <8 x i1>%a, <8 x i1>%b
  ret <8 x i1>%c
}

define <4 x i1> @test11(<4 x i1>%a, <4 x i1>%b, i32 %a1, i32 %b1) {
; KNL-LABEL: test11:
; KNL:       ## BB#0:
; KNL-NEXT:    cmpl %esi, %edi
; KNL-NEXT:    jg LBB18_2
; KNL-NEXT:  ## BB#1:
; KNL-NEXT:    vmovaps %zmm1, %zmm0
; KNL-NEXT:  LBB18_2:
; KNL-NEXT:    retq
;
; SKX-LABEL: test11:
; SKX:       ## BB#0:
; SKX-NEXT:    cmpl %esi, %edi
; SKX-NEXT:    jg LBB18_1
; SKX-NEXT:  ## BB#2:
; SKX-NEXT:    vpslld $31, %xmm1, %xmm0
; SKX-NEXT:    jmp LBB18_3
; SKX-NEXT:  LBB18_1:
; SKX-NEXT:    vpslld $31, %xmm0, %xmm0
; SKX-NEXT:  LBB18_3:
; SKX-NEXT:    vptestmd %xmm0, %xmm0, %k0
; SKX-NEXT:    vpmovm2d %k0, %xmm0
; SKX-NEXT:    retq
  %mask = icmp sgt i32 %a1, %b1
  %c = select i1 %mask, <4 x i1>%a, <4 x i1>%b
  ret <4 x i1>%c
}

define i32 @test12(i32 %x, i32 %y)  {
; CHECK-LABEL: test12:
; CHECK:       ## BB#0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %a = bitcast i16 21845 to <16 x i1>
  %b = extractelement <16 x i1> %a, i32 0
  %c = select i1 %b, i32 %x, i32 %y
  ret i32 %c
}

define i32 @test13(i32 %x, i32 %y)  {
; CHECK-LABEL: test13:
; CHECK:       ## BB#0:
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    retq
  %a = bitcast i16 21845 to <16 x i1>
  %b = extractelement <16 x i1> %a, i32 3
  %c = select i1 %b, i32 %x, i32 %y
  ret i32 %c
}define <4 x i1> @test14()  {
  %a = bitcast i16 21845 to <16 x i1>
  %b = extractelement <16 x i1> %a, i32 2
  %c = insertelement <4 x i1> <i1 true, i1 false, i1 false, i1 true>, i1 %b, i32 1
  ret <4 x i1> %c
}

define <16 x i1> @test15(i32 %x, i32 %y)  {
; KNL-LABEL: test15:
; KNL:       ## BB#0:
; KNL-NEXT:    cmpl %esi, %edi
; KNL-NEXT:    movw $21845, %ax ## imm = 0x5555
; KNL-NEXT:    movw $1, %cx
; KNL-NEXT:    cmovgw %ax, %cx
; KNL-NEXT:    kmovw %ecx, %k1
; KNL-NEXT:    vpbroadcastd {{.*}}(%rip), %zmm0 {%k1} {z}
; KNL-NEXT:    vpmovdb %zmm0, %xmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: test15:
; SKX:       ## BB#0:
; SKX-NEXT:    cmpl %esi, %edi
; SKX-NEXT:    movw $21845, %ax ## imm = 0x5555
; SKX-NEXT:    movw $1, %cx
; SKX-NEXT:    cmovgw %ax, %cx
; SKX-NEXT:    kmovw %ecx, %k0
; SKX-NEXT:    vpmovm2b %k0, %xmm0
; SKX-NEXT:    retq
  %a = bitcast i16 21845 to <16 x i1>
  %b = bitcast i16 1 to <16 x i1>
  %mask = icmp sgt i32 %x, %y
  %c = select i1 %mask, <16 x i1> %a, <16 x i1> %b
  ret <16 x i1> %c
}

define <64 x i8> @test16(i64 %x) {
;
; SKX-LABEL: test16:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovq %rdi, %k0
; SKX-NEXT:    kxnorw %k0, %k0, %k1
; SKX-NEXT:    kshiftrw $15, %k1, %k1
; SKX-NEXT:    kshiftlq $5, %k1, %k1
; SKX-NEXT:    korq %k1, %k0, %k0
; SKX-NEXT:    vpmovm2b %k0, %zmm0
; SKX-NEXT:    retq
  %a = bitcast i64 %x to <64 x i1>
  %b = insertelement <64 x i1>%a, i1 true, i32 5
  %c = sext <64 x i1>%b to <64 x i8>
  ret <64 x i8>%c
}

define <64 x i8> @test17(i64 %x, i32 %y, i32 %z) {
;
; SKX-LABEL: test17:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovq %rdi, %k0
; SKX-NEXT:    cmpl %edx, %esi
; SKX-NEXT:    setg %al
; SKX-NEXT:    andl $1, %eax
; SKX-NEXT:    kmovw %eax, %k1
; SKX-NEXT:    kshiftlq $5, %k1, %k1
; SKX-NEXT:    korq %k1, %k0, %k0
; SKX-NEXT:    vpmovm2b %k0, %zmm0
; SKX-NEXT:    retq
  %a = bitcast i64 %x to <64 x i1>
  %b = icmp sgt i32 %y, %z
  %c = insertelement <64 x i1>%a, i1 %b, i32 5
  %d = sext <64 x i1>%c to <64 x i8>
  ret <64 x i8>%d
}

define <8 x i1> @test18(i8 %a, i16 %y) {
; KNL-LABEL: test18:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw %edi, %k0
; KNL-NEXT:    kmovw %esi, %k1
; KNL-NEXT:    kshiftlw $7, %k1, %k2
; KNL-NEXT:    kshiftrw $15, %k2, %k2
; KNL-NEXT:    kshiftlw $6, %k1, %k1
; KNL-NEXT:    kshiftrw $15, %k1, %k1
; KNL-NEXT:    kshiftlw $6, %k1, %k1
; KNL-NEXT:    korw %k1, %k0, %k0
; KNL-NEXT:    kshiftlw $7, %k2, %k1
; KNL-NEXT:    korw %k1, %k0, %k1
; KNL-NEXT:    vpbroadcastq {{.*}}(%rip), %zmm0 {%k1} {z}
; KNL-NEXT:    vpmovqw %zmm0, %xmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: test18:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovb %edi, %k0
; SKX-NEXT:    kmovw %esi, %k1
; SKX-NEXT:    kshiftlw $6, %k1, %k2
; SKX-NEXT:    kshiftrw $15, %k2, %k2
; SKX-NEXT:    kshiftlw $7, %k1, %k1
; SKX-NEXT:    kshiftrw $15, %k1, %k1
; SKX-NEXT:    kshiftlb $7, %k1, %k1
; SKX-NEXT:    kshiftlb $6, %k2, %k2
; SKX-NEXT:    korb %k2, %k0, %k0
; SKX-NEXT:    korb %k1, %k0, %k0
; SKX-NEXT:    vpmovm2w %k0, %xmm0
; SKX-NEXT:    retq
  %b = bitcast i8 %a to <8 x i1>
  %b1 = bitcast i16 %y to <16 x i1>
  %el1 = extractelement <16 x i1>%b1, i32 8
  %el2 = extractelement <16 x i1>%b1, i32 9
  %c = insertelement <8 x i1>%b, i1 %el1, i32 7
  %d = insertelement <8 x i1>%c, i1 %el2, i32 6
  ret <8 x i1>%d
}
define <32 x i16> @test21(<32 x i16> %x , <32 x i1> %mask) nounwind readnone {
; KNL-LABEL: test21:
; KNL:       ## BB#0:
; KNL-NEXT:    vpmovzxbw {{.*#+}} ymm3 = xmm2[0],zero,xmm2[1],zero,xmm2[2],zero,xmm2[3],zero,xmm2[4],zero,xmm2[5],zero,xmm2[6],zero,xmm2[7],zero,xmm2[8],zero,xmm2[9],zero,xmm2[10],zero,xmm2[11],zero,xmm2[12],zero,xmm2[13],zero,xmm2[14],zero,xmm2[15],zero
; KNL-NEXT:    vpsllw $15, %ymm3, %ymm3
; KNL-NEXT:    vpsraw $15, %ymm3, %ymm3
; KNL-NEXT:    vpand %ymm0, %ymm3, %ymm0
; KNL-NEXT:    vextracti128 $1, %ymm2, %xmm2
; KNL-NEXT:    vpmovzxbw {{.*#+}} ymm2 = xmm2[0],zero,xmm2[1],zero,xmm2[2],zero,xmm2[3],zero,xmm2[4],zero,xmm2[5],zero,xmm2[6],zero,xmm2[7],zero,xmm2[8],zero,xmm2[9],zero,xmm2[10],zero,xmm2[11],zero,xmm2[12],zero,xmm2[13],zero,xmm2[14],zero,xmm2[15],zero
; KNL-NEXT:    vpsllw $15, %ymm2, %ymm2
; KNL-NEXT:    vpsraw $15, %ymm2, %ymm2
; KNL-NEXT:    vpand %ymm1, %ymm2, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: test21:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsllw $7, %ymm1, %ymm1
; SKX-NEXT:    vpmovb2m %ymm1, %k1
; SKX-NEXT:    vmovdqu16 %zmm0, %zmm0 {%k1} {z}
; SKX-NEXT:    retq
  %ret = select <32 x i1> %mask, <32 x i16> %x, <32 x i16> zeroinitializer
  ret <32 x i16> %ret
}

define void @test22(<4 x i1> %a, <4 x i1>* %addr) {
; KNL-LABEL: test22:
; KNL:       ## BB#0:
; KNL-NEXT:    vpslld $31, %ymm0, %ymm0
; KNL-NEXT:    vptestmd %zmm0, %zmm0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    movb %al, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: test22:
; SKX:       ## BB#0:
; SKX-NEXT:    vpslld $31, %xmm0, %xmm0
; SKX-NEXT:    vptestmd %xmm0, %xmm0, %k0
; SKX-NEXT:    kmovb %k0, (%rdi)
; SKX-NEXT:    retq
  store <4 x i1> %a, <4 x i1>* %addr
  ret void
}

define void @test23(<2 x i1> %a, <2 x i1>* %addr) {
; KNL-LABEL: test23:
; KNL:       ## BB#0:
; KNL-NEXT:    vpsllq $63, %zmm0, %zmm0
; KNL-NEXT:    vptestmq %zmm0, %zmm0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    movb %al, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: test23:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsllq $63, %xmm0, %xmm0
; SKX-NEXT:    vptestmq %xmm0, %xmm0, %k0
; SKX-NEXT:    kmovb %k0, (%rdi)
; SKX-NEXT:    retq
  store <2 x i1> %a, <2 x i1>* %addr
  ret void
}

define void @store_v1i1(<1 x i1> %c , <1 x i1>* %ptr) {
; KNL-LABEL: store_v1i1:
; KNL:       ## BB#0:
; KNL-NEXT:    andl $1, %edi
; KNL-NEXT:    kmovw %edi, %k0
; KNL-NEXT:    kxnorw %k0, %k0, %k1
; KNL-NEXT:    kshiftrw $15, %k1, %k1
; KNL-NEXT:    kxorw %k1, %k0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    movb %al, (%rsi)
; KNL-NEXT:    retq
;
; SKX-LABEL: store_v1i1:
; SKX:       ## BB#0:
; SKX-NEXT:    andl $1, %edi
; SKX-NEXT:    kmovw %edi, %k0
; SKX-NEXT:    kxnorw %k0, %k0, %k1
; SKX-NEXT:    kshiftrw $15, %k1, %k1
; SKX-NEXT:    kxorw %k1, %k0, %k0
; SKX-NEXT:    kmovb %k0, (%rsi)
; SKX-NEXT:    retq
  %x = xor <1 x i1> %c, <i1 1>
  store <1 x i1> %x, <1 x i1>*  %ptr, align 4
  ret void
}

define void @store_v2i1(<2 x i1> %c , <2 x i1>* %ptr) {
; KNL-LABEL: store_v2i1:
; KNL:       ## BB#0:
; KNL-NEXT:    vpxor {{.*}}(%rip), %xmm0, %xmm0
; KNL-NEXT:    vpsllq $63, %zmm0, %zmm0
; KNL-NEXT:    vptestmq %zmm0, %zmm0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    movb %al, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: store_v2i1:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsllq $63, %xmm0, %xmm0
; SKX-NEXT:    vptestmq %xmm0, %xmm0, %k0
; SKX-NEXT:    knotw %k0, %k0
; SKX-NEXT:    kmovb %k0, (%rdi)
; SKX-NEXT:    retq
  %x = xor <2 x i1> %c, <i1 1, i1 1>
  store <2 x i1> %x, <2 x i1>*  %ptr, align 4
  ret void
}

define void @store_v4i1(<4 x i1> %c , <4 x i1>* %ptr) {
; KNL-LABEL: store_v4i1:
; KNL:       ## BB#0:
; KNL-NEXT:    vpbroadcastd {{.*}}(%rip), %xmm1
; KNL-NEXT:    vpxor %xmm1, %xmm0, %xmm0
; KNL-NEXT:    vpslld $31, %ymm0, %ymm0
; KNL-NEXT:    vptestmd %zmm0, %zmm0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    movb %al, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: store_v4i1:
; SKX:       ## BB#0:
; SKX-NEXT:    vpslld $31, %xmm0, %xmm0
; SKX-NEXT:    vptestmd %xmm0, %xmm0, %k0
; SKX-NEXT:    knotw %k0, %k0
; SKX-NEXT:    kmovb %k0, (%rdi)
; SKX-NEXT:    retq
  %x = xor <4 x i1> %c, <i1 1, i1 1, i1 1, i1 1>
  store <4 x i1> %x, <4 x i1>*  %ptr, align 4
  ret void
}

define void @store_v8i1(<8 x i1> %c , <8 x i1>* %ptr) {
; KNL-LABEL: store_v8i1:
; KNL:       ## BB#0:
; KNL-NEXT:    vpmovsxwq %xmm0, %zmm0
; KNL-NEXT:    vpsllq $63, %zmm0, %zmm0
; KNL-NEXT:    vptestmq %zmm0, %zmm0, %k0
; KNL-NEXT:    knotw %k0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    movb %al, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: store_v8i1:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsllw $15, %xmm0, %xmm0
; SKX-NEXT:    vpmovw2m %xmm0, %k0
; SKX-NEXT:    knotb %k0, %k0
; SKX-NEXT:    kmovb %k0, (%rdi)
; SKX-NEXT:    retq
  %x = xor <8 x i1> %c, <i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1>
  store <8 x i1> %x, <8 x i1>*  %ptr, align 4
  ret void
}

define void @store_v16i1(<16 x i1> %c , <16 x i1>* %ptr) {
; KNL-LABEL: store_v16i1:
; KNL:       ## BB#0:
; KNL-NEXT:    vpmovsxbd %xmm0, %zmm0
; KNL-NEXT:    vpslld $31, %zmm0, %zmm0
; KNL-NEXT:    vptestmd %zmm0, %zmm0, %k0
; KNL-NEXT:    knotw %k0, %k0
; KNL-NEXT:    kmovw %k0, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: store_v16i1:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsllw $7, %xmm0, %xmm0
; SKX-NEXT:    vpmovb2m %xmm0, %k0
; SKX-NEXT:    knotw %k0, %k0
; SKX-NEXT:    kmovw %k0, (%rdi)
; SKX-NEXT:    retq
  %x = xor <16 x i1> %c, <i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1, i1 1>
  store <16 x i1> %x, <16 x i1>*  %ptr, align 4
  ret void
}

;void f2(int);
;void f1(int c)
;{
;  static int v = 0;
;  if (v == 0)
;    v = 1;
;  else
;    v = 0;
;  f2(v);
;}

@f1.v = internal unnamed_addr global i1 false, align 4

define void @f1(i32 %c) {
; KNL-LABEL: f1:
; KNL:       ## BB#0: ## %entry
; KNL-NEXT:    movzbl {{.*}}(%rip), %edi
; KNL-NEXT:    movl %edi, %eax
; KNL-NEXT:    andl $1, %eax
; KNL-NEXT:    kmovw %eax, %k0
; KNL-NEXT:    kxnorw %k0, %k0, %k1
; KNL-NEXT:    kshiftrw $15, %k1, %k1
; KNL-NEXT:    kxorw %k1, %k0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    movb %al, {{.*}}(%rip)
; KNL-NEXT:    xorl $1, %edi
; KNL-NEXT:    jmp _f2 ## TAILCALL
;
; SKX-LABEL: f1:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    movzbl {{.*}}(%rip), %edi
; SKX-NEXT:    movl %edi, %eax
; SKX-NEXT:    andl $1, %eax
; SKX-NEXT:    kmovw %eax, %k0
; SKX-NEXT:    kxnorw %k0, %k0, %k1
; SKX-NEXT:    kshiftrw $15, %k1, %k1
; SKX-NEXT:    kxorw %k1, %k0, %k0
; SKX-NEXT:    kmovb %k0, {{.*}}(%rip)
; SKX-NEXT:    xorl $1, %edi
; SKX-NEXT:    jmp _f2 ## TAILCALL
entry:
  %.b1 = load i1, i1* @f1.v, align 4
  %not..b1 = xor i1 %.b1, true
  store i1 %not..b1, i1* @f1.v, align 4
  %0 = zext i1 %not..b1 to i32
  tail call void @f2(i32 %0) #2
  ret void
}

declare void @f2(i32) #1

define void @store_i16_i1(i16 %x, i1 *%y) {
; CHECK-LABEL: store_i16_i1:
; CHECK:       ## BB#0:
; CHECK-NEXT:    andl $1, %edi
; CHECK-NEXT:    movb %dil, (%rsi)
; CHECK-NEXT:    retq
  %c = trunc i16 %x to i1
  store i1 %c, i1* %y
  ret void
}

define void @store_i8_i1(i8 %x, i1 *%y) {
; CHECK-LABEL: store_i8_i1:
; CHECK:       ## BB#0:
; CHECK-NEXT:    andl $1, %edi
; CHECK-NEXT:    movb %dil, (%rsi)
; CHECK-NEXT:    retq
  %c = trunc i8 %x to i1
  store i1 %c, i1* %y
  ret void
}

define <32 x i16> @test_build_vec_v32i1(<32 x i16> %x) {
; KNL-LABEL: test_build_vec_v32i1:
; KNL:       ## BB#0:
; KNL-NEXT:    vpmovzxbw {{.*#+}} ymm2 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero,mem[8],zero,mem[9],zero,mem[10],zero,mem[11],zero,mem[12],zero,mem[13],zero,mem[14],zero,mem[15],zero
; KNL-NEXT:    vpsllw $15, %ymm2, %ymm2
; KNL-NEXT:    vpsraw $15, %ymm2, %ymm2
; KNL-NEXT:    vpand %ymm0, %ymm2, %ymm0
; KNL-NEXT:    vpmovzxbw {{.*#+}} ymm2 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero,mem[8],zero,mem[9],zero,mem[10],zero,mem[11],zero,mem[12],zero,mem[13],zero,mem[14],zero,mem[15],zero
; KNL-NEXT:    vpsllw $15, %ymm2, %ymm2
; KNL-NEXT:    vpsraw $15, %ymm2, %ymm2
; KNL-NEXT:    vpand %ymm1, %ymm2, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: test_build_vec_v32i1:
; SKX:       ## BB#0:
; SKX-NEXT:    movl $1497715861, %eax ## imm = 0x59455495
; SKX-NEXT:    kmovd %eax, %k1
; SKX-NEXT:    vmovdqu16 %zmm0, %zmm0 {%k1} {z}
; SKX-NEXT:    retq
  %ret = select <32 x i1> <i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 false, i1 true, i1 false, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 false, i1 false, i1 true, i1 false, i1 true, i1 false, i1 false, i1 true, i1 true, i1 false, i1 true, i1 false>, <32 x i16> %x, <32 x i16> zeroinitializer
  ret <32 x i16> %ret
}

define <64 x i8> @test_build_vec_v64i1(<64 x i8> %x) {
; KNL-LABEL: test_build_vec_v64i1:
; KNL:       ## BB#0:
; KNL-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; KNL-NEXT:    vandps {{.*}}(%rip), %ymm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: test_build_vec_v64i1:
; SKX:       ## BB#0:
; SKX-NEXT:    movabsq $6432645796886517060, %rax ## imm = 0x5945594549549544
; SKX-NEXT:    kmovq %rax, %k1
; SKX-NEXT:    vmovdqu8 %zmm0, %zmm0 {%k1} {z}
; SKX-NEXT:    retq
  %ret = select <64 x i1> <i1 false, i1 false, i1 true, i1 false, i1 false, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 false, i1 true, i1 false, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 false, i1 true, i1 false, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 false, i1 false, i1 true, i1 false, i1 true, i1 false, i1 false, i1 true, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 true, i1 false, i1 false, i1 false, i1 true, i1 false, i1 true, i1 false, i1 false, i1 true, i1 true, i1 false, i1 true, i1 false>, <64 x i8> %x, <64 x i8> zeroinitializer
  ret <64 x i8> %ret
}

define void @ktest_1(<8 x double> %in, double * %base) {
; KNL-LABEL: ktest_1:
; KNL:       ## BB#0:
; KNL-NEXT:    vmovupd (%rdi), %zmm1
; KNL-NEXT:    vcmpltpd %zmm0, %zmm1, %k1
; KNL-NEXT:    vmovupd 8(%rdi), %zmm1 {%k1} {z}
; KNL-NEXT:    vcmpltpd %zmm1, %zmm0, %k0 {%k1}
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    testb %al, %al
; KNL-NEXT:    je LBB39_2
; KNL-NEXT:  ## BB#1: ## %L1
; KNL-NEXT:    vmovapd %zmm0, (%rdi)
; KNL-NEXT:    retq
; KNL-NEXT:  LBB39_2: ## %L2
; KNL-NEXT:    vmovapd %zmm0, 8(%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: ktest_1:
; SKX:       ## BB#0:
; SKX-NEXT:    vmovupd (%rdi), %zmm1
; SKX-NEXT:    vcmpltpd %zmm0, %zmm1, %k1
; SKX-NEXT:    vmovupd 8(%rdi), %zmm1 {%k1} {z}
; SKX-NEXT:    vcmpltpd %zmm1, %zmm0, %k0 {%k1}
; SKX-NEXT:    ktestb %k0, %k0
; SKX-NEXT:    je LBB39_2
; SKX-NEXT:  ## BB#1: ## %L1
; SKX-NEXT:    vmovapd %zmm0, (%rdi)
; SKX-NEXT:    retq
; SKX-NEXT:  LBB39_2: ## %L2
; SKX-NEXT:    vmovapd %zmm0, 8(%rdi)
; SKX-NEXT:    retq
  %addr1 = getelementptr double, double * %base, i64 0
  %addr2 = getelementptr double, double * %base, i64 1

  %vaddr1 = bitcast double* %addr1 to <8 x double>*
  %vaddr2 = bitcast double* %addr2 to <8 x double>*

  %val1 = load <8 x double>, <8 x double> *%vaddr1, align 1
  %val2 = load <8 x double>, <8 x double> *%vaddr2, align 1

  %sel1 = fcmp ogt <8 x double>%in, %val1
  %val3 = select <8 x i1> %sel1, <8 x double> %val2, <8 x double> zeroinitializer
  %sel2 = fcmp olt <8 x double> %in, %val3
  %sel3 = and <8 x i1> %sel1, %sel2

  %int_sel3 = bitcast <8 x i1> %sel3 to i8
  %res = icmp eq i8 %int_sel3, zeroinitializer
  br i1 %res, label %L2, label %L1
L1:
  store <8 x double> %in, <8 x double>* %vaddr1
  br label %End
L2:
  store <8 x double> %in, <8 x double>* %vaddr2
  br label %End
End:
  ret void
}

define void @ktest_2(<32 x float> %in, float * %base) {
;
; SKX-LABEL: ktest_2:
; SKX:       ## BB#0:
; SKX-NEXT:    vmovups 64(%rdi), %zmm2
; SKX-NEXT:    vmovups (%rdi), %zmm3
; SKX-NEXT:    vcmpltps %zmm0, %zmm3, %k1
; SKX-NEXT:    vcmpltps %zmm1, %zmm2, %k2
; SKX-NEXT:    kunpckwd %k1, %k2, %k0
; SKX-NEXT:    vmovups 68(%rdi), %zmm2 {%k2} {z}
; SKX-NEXT:    vmovups 4(%rdi), %zmm3 {%k1} {z}
; SKX-NEXT:    vcmpltps %zmm3, %zmm0, %k1
; SKX-NEXT:    vcmpltps %zmm2, %zmm1, %k2
; SKX-NEXT:    kunpckwd %k1, %k2, %k1
; SKX-NEXT:    kord %k1, %k0, %k0
; SKX-NEXT:    ktestd %k0, %k0
; SKX-NEXT:    je LBB40_2
; SKX-NEXT:  ## BB#1: ## %L1
; SKX-NEXT:    vmovaps %zmm0, (%rdi)
; SKX-NEXT:    vmovaps %zmm1, 64(%rdi)
; SKX-NEXT:    retq
; SKX-NEXT:  LBB40_2: ## %L2
; SKX-NEXT:    vmovaps %zmm0, 4(%rdi)
; SKX-NEXT:    vmovaps %zmm1, 68(%rdi)
; SKX-NEXT:    retq
  %addr1 = getelementptr float, float * %base, i64 0
  %addr2 = getelementptr float, float * %base, i64 1

  %vaddr1 = bitcast float* %addr1 to <32 x float>*
  %vaddr2 = bitcast float* %addr2 to <32 x float>*

  %val1 = load <32 x float>, <32 x float> *%vaddr1, align 1
  %val2 = load <32 x float>, <32 x float> *%vaddr2, align 1

  %sel1 = fcmp ogt <32 x float>%in, %val1
  %val3 = select <32 x i1> %sel1, <32 x float> %val2, <32 x float> zeroinitializer
  %sel2 = fcmp olt <32 x float> %in, %val3
  %sel3 = or <32 x i1> %sel1, %sel2

  %int_sel3 = bitcast <32 x i1> %sel3 to i32
  %res = icmp eq i32 %int_sel3, zeroinitializer
  br i1 %res, label %L2, label %L1
L1:
  store <32 x float> %in, <32 x float>* %vaddr1
  br label %End
L2:
  store <32 x float> %in, <32 x float>* %vaddr2
  br label %End
End:
  ret void
}

define <8 x i64> @load_8i1(<8 x i1>* %a) {
; KNL-LABEL: load_8i1:
; KNL:       ## BB#0:
; KNL-NEXT:    movzbw (%rdi), %ax
; KNL-NEXT:    kmovw %eax, %k1
; KNL-NEXT:    vpbroadcastq {{.*}}(%rip), %zmm0 {%k1} {z}
; KNL-NEXT:    retq
;
; SKX-LABEL: load_8i1:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovb (%rdi), %k0
; SKX-NEXT:    vpmovm2q %k0, %zmm0
; SKX-NEXT:    retq
  %b = load <8 x i1>, <8 x i1>* %a
  %c = sext <8 x i1> %b to <8 x i64>
  ret <8 x i64> %c
}

define <16 x i32> @load_16i1(<16 x i1>* %a) {
; KNL-LABEL: load_16i1:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw (%rdi), %k1
; KNL-NEXT:    vpbroadcastd {{.*}}(%rip), %zmm0 {%k1} {z}
; KNL-NEXT:    retq
;
; SKX-LABEL: load_16i1:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovw (%rdi), %k0
; SKX-NEXT:    vpmovm2d %k0, %zmm0
; SKX-NEXT:    retq
  %b = load <16 x i1>, <16 x i1>* %a
  %c = sext <16 x i1> %b to <16 x i32>
  ret <16 x i32> %c
}

define <2 x i16> @load_2i1(<2 x i1>* %a) {
; KNL-LABEL: load_2i1:
; KNL:       ## BB#0:
; KNL-NEXT:    movzbw (%rdi), %ax
; KNL-NEXT:    kmovw %eax, %k1
; KNL-NEXT:    vpbroadcastq {{.*}}(%rip), %zmm0 {%k1} {z}
; KNL-NEXT:    retq
;
; SKX-LABEL: load_2i1:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovb (%rdi), %k0
; SKX-NEXT:    vpmovm2q %k0, %xmm0
; SKX-NEXT:    retq
  %b = load <2 x i1>, <2 x i1>* %a
  %c = sext <2 x i1> %b to <2 x i16>
  ret <2 x i16> %c
}

define <4 x i16> @load_4i1(<4 x i1>* %a) {
; KNL-LABEL: load_4i1:
; KNL:       ## BB#0:
; KNL-NEXT:    movzbw (%rdi), %ax
; KNL-NEXT:    kmovw %eax, %k1
; KNL-NEXT:    vpbroadcastq {{.*}}(%rip), %zmm0 {%k1} {z}
; KNL-NEXT:    vpmovqd %zmm0, %ymm0
; KNL-NEXT:    retq
;
; SKX-LABEL: load_4i1:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovb (%rdi), %k0
; SKX-NEXT:    vpmovm2d %k0, %xmm0
; SKX-NEXT:    retq
  %b = load <4 x i1>, <4 x i1>* %a
  %c = sext <4 x i1> %b to <4 x i16>
  ret <4 x i16> %c
}

define <32 x i16> @load_32i1(<32 x i1>* %a) {
; KNL-LABEL: load_32i1:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw (%rdi), %k1
; KNL-NEXT:    movl {{.*}}(%rip), %eax
; KNL-NEXT:    vpbroadcastd %eax, %zmm0 {%k1} {z}
; KNL-NEXT:    vpmovdw %zmm0, %ymm0
; KNL-NEXT:    kmovw 2(%rdi), %k1
; KNL-NEXT:    vpbroadcastd %eax, %zmm1 {%k1} {z}
; KNL-NEXT:    vpmovdw %zmm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: load_32i1:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovd (%rdi), %k0
; SKX-NEXT:    vpmovm2w %k0, %zmm0
; SKX-NEXT:    retq
  %b = load <32 x i1>, <32 x i1>* %a
  %c = sext <32 x i1> %b to <32 x i16>
  ret <32 x i16> %c
}

define <64 x i8> @load_64i1(<64 x i1>* %a) {
; KNL-LABEL: load_64i1:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw (%rdi), %k1
; KNL-NEXT:    movl {{.*}}(%rip), %eax
; KNL-NEXT:    vpbroadcastd %eax, %zmm0 {%k1} {z}
; KNL-NEXT:    vpmovdb %zmm0, %xmm0
; KNL-NEXT:    kmovw 2(%rdi), %k1
; KNL-NEXT:    vpbroadcastd %eax, %zmm1 {%k1} {z}
; KNL-NEXT:    vpmovdb %zmm1, %xmm1
; KNL-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; KNL-NEXT:    kmovw 4(%rdi), %k1
; KNL-NEXT:    vpbroadcastd %eax, %zmm1 {%k1} {z}
; KNL-NEXT:    vpmovdb %zmm1, %xmm1
; KNL-NEXT:    kmovw 6(%rdi), %k1
; KNL-NEXT:    vpbroadcastd %eax, %zmm2 {%k1} {z}
; KNL-NEXT:    vpmovdb %zmm2, %xmm2
; KNL-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: load_64i1:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovq (%rdi), %k0
; SKX-NEXT:    vpmovm2b %k0, %zmm0
; SKX-NEXT:    retq
  %b = load <64 x i1>, <64 x i1>* %a
  %c = sext <64 x i1> %b to <64 x i8>
  ret <64 x i8> %c
}

define void @store_8i1(<8 x i1>* %a, <8 x i1> %v) {
; KNL-LABEL: store_8i1:
; KNL:       ## BB#0:
; KNL-NEXT:    vpmovsxwq %xmm0, %zmm0
; KNL-NEXT:    vpsllq $63, %zmm0, %zmm0
; KNL-NEXT:    vptestmq %zmm0, %zmm0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    movb %al, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: store_8i1:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsllw $15, %xmm0, %xmm0
; SKX-NEXT:    vpmovw2m %xmm0, %k0
; SKX-NEXT:    kmovb %k0, (%rdi)
; SKX-NEXT:    retq
  store <8 x i1> %v, <8 x i1>* %a
  ret void
}

define void @store_8i1_1(<8 x i1>* %a, <8 x i16> %v) {
; KNL-LABEL: store_8i1_1:
; KNL:       ## BB#0:
; KNL-NEXT:    vpmovsxwq %xmm0, %zmm0
; KNL-NEXT:    vpsllq $63, %zmm0, %zmm0
; KNL-NEXT:    vptestmq %zmm0, %zmm0, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    movb %al, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: store_8i1_1:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsllw $15, %xmm0, %xmm0
; SKX-NEXT:    vpmovw2m %xmm0, %k0
; SKX-NEXT:    kmovb %k0, (%rdi)
; SKX-NEXT:    retq
  %v1 = trunc <8 x i16> %v to <8 x i1>
  store <8 x i1> %v1, <8 x i1>* %a
  ret void
}

define void @store_16i1(<16 x i1>* %a, <16 x i1> %v) {
; KNL-LABEL: store_16i1:
; KNL:       ## BB#0:
; KNL-NEXT:    vpmovsxbd %xmm0, %zmm0
; KNL-NEXT:    vpslld $31, %zmm0, %zmm0
; KNL-NEXT:    vptestmd %zmm0, %zmm0, %k0
; KNL-NEXT:    kmovw %k0, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: store_16i1:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsllw $7, %xmm0, %xmm0
; SKX-NEXT:    vpmovb2m %xmm0, %k0
; SKX-NEXT:    kmovw %k0, (%rdi)
; SKX-NEXT:    retq
  store <16 x i1> %v, <16 x i1>* %a
  ret void
}

define void @store_32i1(<32 x i1>* %a, <32 x i1> %v) {
; KNL-LABEL: store_32i1:
; KNL:       ## BB#0:
; KNL-NEXT:    vextractf128 $1, %ymm0, %xmm1
; KNL-NEXT:    vpmovsxbd %xmm1, %zmm1
; KNL-NEXT:    vpslld $31, %zmm1, %zmm1
; KNL-NEXT:    vptestmd %zmm1, %zmm1, %k0
; KNL-NEXT:    kmovw %k0, 2(%rdi)
; KNL-NEXT:    vpmovsxbd %xmm0, %zmm0
; KNL-NEXT:    vpslld $31, %zmm0, %zmm0
; KNL-NEXT:    vptestmd %zmm0, %zmm0, %k0
; KNL-NEXT:    kmovw %k0, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: store_32i1:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsllw $7, %ymm0, %ymm0
; SKX-NEXT:    vpmovb2m %ymm0, %k0
; SKX-NEXT:    kmovd %k0, (%rdi)
; SKX-NEXT:    retq
  store <32 x i1> %v, <32 x i1>* %a
  ret void
}

define void @store_32i1_1(<32 x i1>* %a, <32 x i16> %v) {
; KNL-LABEL: store_32i1_1:
; KNL:       ## BB#0:
; KNL-NEXT:    vpmovsxwd %ymm0, %zmm0
; KNL-NEXT:    vpmovdb %zmm0, %xmm0
; KNL-NEXT:    vpmovsxwd %ymm1, %zmm1
; KNL-NEXT:    vpmovdb %zmm1, %xmm1
; KNL-NEXT:    vpmovsxbd %xmm1, %zmm1
; KNL-NEXT:    vpslld $31, %zmm1, %zmm1
; KNL-NEXT:    vptestmd %zmm1, %zmm1, %k0
; KNL-NEXT:    kmovw %k0, 2(%rdi)
; KNL-NEXT:    vpmovsxbd %xmm0, %zmm0
; KNL-NEXT:    vpslld $31, %zmm0, %zmm0
; KNL-NEXT:    vptestmd %zmm0, %zmm0, %k0
; KNL-NEXT:    kmovw %k0, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: store_32i1_1:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsllw $15, %zmm0, %zmm0
; SKX-NEXT:    vpmovw2m %zmm0, %k0
; SKX-NEXT:    kmovd %k0, (%rdi)
; SKX-NEXT:    retq
  %v1 = trunc <32 x i16> %v to <32 x i1>
  store <32 x i1> %v1, <32 x i1>* %a
  ret void
}


define void @store_64i1(<64 x i1>* %a, <64 x i1> %v) {
;
; SKX-LABEL: store_64i1:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsllw $7, %zmm0, %zmm0
; SKX-NEXT:    vpmovb2m %zmm0, %k0
; SKX-NEXT:    kmovq %k0, (%rdi)
; SKX-NEXT:    retq
  store <64 x i1> %v, <64 x i1>* %a
  ret void
}
