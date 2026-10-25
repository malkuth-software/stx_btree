	.text
	.file	"find_probe.cpp"
	.globl	_Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm # -- Begin function _Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm
	.p2align	4, 0x90
	.type	_Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm,@function
_Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm: # @_Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rsi, (%rsp)
	movq	%rsp, %rsi
	callq	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm
	movq	%rdx, %rax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	_Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm, .Lfunc_end0-_Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm
	.cfi_endproc
                                        # -- End function
	.globl	_Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E # -- Begin function _Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E
	.p2align	4, 0x90
	.type	_Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E,@function
_Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E: # @_Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E
	.cfi_startproc
# %bb.0:
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	%rsi, 8(%rsp)
	movq	%rdx, 16(%rsp)
	leaq	8(%rsp), %rsi
	callq	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E
	movq	%rdx, %rax
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	_Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E, .Lfunc_end1-_Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E
	.cfi_endproc
                                        # -- End function
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0                          # -- Begin function _ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm
.LCPI2_0:
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	1                               # 0x1
.LCPI2_1:
	.short	0                               # 0x0
	.short	1                               # 0x1
	.short	1                               # 0x1
	.short	1                               # 0x1
	.short	1                               # 0x1
	.short	1                               # 0x1
	.short	1                               # 0x1
	.short	1                               # 0x1
	.section	.text._ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm,"axG",@progbits,_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm,comdat
	.weak	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm
	.p2align	4, 0x90
	.type	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm,@function
_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm: # @_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm
	.cfi_startproc
# %bb.0:
	movq	(%rdi), %r9
	testq	%r9, %r9
	je	.LBB2_4
# %bb.1:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	subq	$16, %rsp
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -32
	.cfi_offset %r14, -24
	.cfi_offset %rbp, -16
	movq	%rsi, %rbx
	movq	%r9, %rsi
	andq	$-2, %rsi
	movzbl	1024(%rsi), %edx
	testq	%rdx, %rdx
	je	.LBB2_6
# %bb.2:
	movq	%rdi, %r14
	addq	$1025, %rsi                     # imm = 0x401
	movq	(%rbx), %rdi
	callq	_ZN9stx_btree13IntegerPrefix7compareEmPKhm
	testl	%eax, %eax
	je	.LBB2_5
.LBB2_3:
	xorl	%eax, %eax
	xorl	%edx, %edx
	jmp	.LBB2_23
.LBB2_4:
	.cfi_def_cfa_offset 8
	.cfi_restore %rbx
	.cfi_restore %rbp
	.cfi_restore %r14
	xorl	%eax, %eax
	xorl	%edx, %edx
	retq
.LBB2_5:
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -32
	.cfi_offset %rbp, -16
	.cfi_offset %r14, -24
	movq	(%r14), %r9
.LBB2_6:
	testb	$1, %r9b
	jne	.LBB2_15
# %bb.7:
	xorl	%ebp, %ebp
	vmovdqa	.LCPI2_0(%rip), %xmm7           # xmm7 = [0,0,0,0,0,0,0,1]
	leaq	8(%rsp), %r14
	jmp	.LBB2_10
	.p2align	4, 0x90
.LBB2_8:                                #   in Loop: Header=BB2_10 Depth=1
	vmovdqa	.LCPI2_0(%rip), %xmm7           # xmm7 = [0,0,0,0,0,0,0,1]
.LBB2_9:                                #   in Loop: Header=BB2_10 Depth=1
	movq	8(%rsp), %rax
	movq	112(%rax,%rdx,8), %r9
	testb	$1, %r9b
	jne	.LBB2_15
.LBB2_10:                               # =>This Inner Loop Header: Depth=1
	movq	%r9, 8(%rsp)
	movzwl	4(%r9), %eax
	movl	%eax, %ecx
	shll	$3, %ecx
	shlxq	%rcx, (%rbx), %rcx
	shrq	$48, %rcx
	cmpw	$8, %ax
	cmovael	%ebp, %ecx
	movzwl	(%r9), %eax
	vpbroadcastw	%ecx, %xmm0
	vmovdqu	8(%r9), %xmm1
	vmovdqu	24(%r9), %xmm2
	vmovdqu	40(%r9), %xmm3
	vmovdqu	56(%r9), %xmm4
	vpcmpltuw	%xmm0, %xmm1, %k0
	vpcmpltuw	%xmm0, %xmm2, %k1
	vpmovm2w	%k1, %xmm5
	vpsrlw	$15, %xmm5, %xmm5
	vpmovm2w	%k0, %xmm6
	vpsubw	%xmm6, %xmm5, %xmm5
	vpcmpeqw	%xmm0, %xmm2, %xmm2
	vpsrlw	$15, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm1, %xmm1
	vpsubw	%xmm1, %xmm2, %xmm1
	vpcmpltuw	%xmm0, %xmm3, %k0
	vpmovm2w	%k0, %xmm2
	vpsubw	%xmm2, %xmm5, %xmm2
	vpcmpeqw	%xmm0, %xmm3, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vpcmpltuw	%xmm0, %xmm4, %k0
	vpmovm2w	%k0, %xmm3
	vpsubw	%xmm3, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm4, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vmovdqu	72(%r9), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k0
	vpmovm2w	%k0, %xmm4
	vpsubw	%xmm4, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm3, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vmovdqu	88(%r9), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k0
	vpmovm2w	%k0, %xmm4
	vpsubw	%xmm4, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm3, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vmovdqu	90(%r9), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k1
	vpaddw	%xmm7, %xmm2, %xmm2 {%k1}
	vpcmpeqw	%xmm0, %xmm3, %k1
	vpaddw	%xmm7, %xmm1, %xmm1 {%k1}
	vpshufd	$238, %xmm2, %xmm0              # xmm0 = xmm2[2,3,2,3]
	vpaddw	%xmm0, %xmm2, %xmm0
	vpshufd	$85, %xmm0, %xmm2               # xmm2 = xmm0[1,1,1,1]
	vpaddw	%xmm2, %xmm0, %xmm0
	vpsrld	$16, %xmm0, %xmm2
	vpaddw	%xmm2, %xmm0, %xmm0
	vmovd	%xmm0, %edx
	vpshufd	$238, %xmm1, %xmm0              # xmm0 = xmm1[2,3,2,3]
	vpaddw	%xmm0, %xmm1, %xmm0
	vpshufd	$85, %xmm0, %xmm1               # xmm1 = xmm0[1,1,1,1]
	vpaddw	%xmm1, %xmm0, %xmm0
	vpsrld	$16, %xmm0, %xmm1
	vpaddw	%xmm1, %xmm0, %xmm0
	vpextrw	$0, %xmm0, %ecx
	cmpw	%ax, %dx
	cmovael	%eax, %edx
	movzwl	%dx, %edx
	addq	%rdx, %rcx
	cmpq	%rax, %rcx
	cmovaeq	%rax, %rcx
	cmpq	%rdx, %rcx
	je	.LBB2_9
# %bb.11:                               #   in Loop: Header=BB2_10 Depth=1
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE
	testb	$1, %al
	je	.LBB2_8
# %bb.12:
	movq	8(%rsp), %rax
	movq	120(%rax,%rdx,8), %rdx
	testb	$1, %dl
	jne	.LBB2_14
	.p2align	4, 0x90
.LBB2_13:                               # =>This Inner Loop Header: Depth=1
	movq	112(%rdx), %rdx
	testb	$1, %dl
	je	.LBB2_13
.LBB2_14:
	andq	$-2, %rdx
	leaq	128(%rdx), %rax
	addq	$136, %rdx
	jmp	.LBB2_23
.LBB2_15:
	andq	$-2, %r9
	movq	%r9, 8(%rsp)
	movzwl	4(%r9), %ecx
	movq	(%rbx), %rdx
	movl	%ecx, %eax
	shll	$3, %eax
	shlxq	%rax, %rdx, %rdi
	shrq	$48, %rdi
	xorl	%eax, %eax
	cmpw	$8, %cx
	cmovael	%eax, %edi
	movzwl	(%r9), %esi
	vpbroadcastw	%edi, %xmm0
	vmovdqu	8(%r9), %xmm1
	vmovdqu	24(%r9), %xmm2
	vmovdqu	40(%r9), %xmm3
	vmovdqu	56(%r9), %xmm4
	vpcmpltuw	%xmm0, %xmm1, %k0
	vpcmpltuw	%xmm0, %xmm2, %k1
	vpmovm2w	%k1, %xmm5
	vpsrlw	$15, %xmm5, %xmm5
	vpmovm2w	%k0, %xmm6
	vpsubw	%xmm6, %xmm5, %xmm5
	vpcmpeqw	%xmm0, %xmm2, %xmm2
	vpsrlw	$15, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm1, %xmm1
	vpsubw	%xmm1, %xmm2, %xmm1
	vpcmpltuw	%xmm0, %xmm3, %k0
	vpmovm2w	%k0, %xmm2
	vpsubw	%xmm2, %xmm5, %xmm2
	vpcmpeqw	%xmm0, %xmm3, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vpcmpltuw	%xmm0, %xmm4, %k0
	vpmovm2w	%k0, %xmm3
	vpsubw	%xmm3, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm4, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vmovdqu	72(%r9), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k0
	vpmovm2w	%k0, %xmm4
	vpsubw	%xmm4, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm3, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vmovdqu	88(%r9), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k0
	vpmovm2w	%k0, %xmm4
	vpsubw	%xmm4, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm3, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vmovdqu	102(%r9), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k1
	vmovdqa	.LCPI2_1(%rip), %xmm4           # xmm4 = [0,1,1,1,1,1,1,1]
	vpaddw	%xmm4, %xmm2, %xmm2 {%k1}
	vpcmpeqw	%xmm0, %xmm3, %k1
	vpaddw	%xmm4, %xmm1, %xmm1 {%k1}
	vpshufd	$238, %xmm2, %xmm0              # xmm0 = xmm2[2,3,2,3]
	vpaddw	%xmm0, %xmm2, %xmm0
	vpshufd	$85, %xmm0, %xmm2               # xmm2 = xmm0[1,1,1,1]
	vpaddw	%xmm2, %xmm0, %xmm0
	vpsrld	$16, %xmm0, %xmm2
	vpaddw	%xmm2, %xmm0, %xmm0
	vpshufd	$238, %xmm1, %xmm2              # xmm2 = xmm1[2,3,2,3]
	vpaddw	%xmm2, %xmm1, %xmm1
	vpshufd	$85, %xmm1, %xmm2               # xmm2 = xmm1[1,1,1,1]
	vpaddw	%xmm2, %xmm1, %xmm1
	vpsrld	$16, %xmm1, %xmm2
	vpaddw	%xmm2, %xmm1, %xmm1
	vpextrw	$0, %xmm1, %ecx
	vmovd	%xmm0, %edi
	cmpw	%si, %di
	cmovael	%esi, %edi
	movzwl	%di, %r8d
	addq	%r8, %rcx
	cmpq	%rsi, %rcx
	cmovaeq	%rsi, %rcx
	movq	%rcx, %rsi
	subq	%r8, %rsi
	jne	.LBB2_17
.LBB2_16:
	xorl	%edx, %edx
	jmp	.LBB2_23
.LBB2_17:
	cmpq	$1, %rsi
	jne	.LBB2_19
# %bb.18:
	shll	$4, %r8d
	cmpq	144(%r9,%r8), %rdx
	jne	.LBB2_3
	jmp	.LBB2_22
.LBB2_19:
	leaq	8(%rsp), %rdi
	movq	%rbx, %rsi
	movq	%r8, %rdx
	callq	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE
	movl	%eax, %ecx
	xorl	%eax, %eax
	testb	$1, %cl
	je	.LBB2_16
# %bb.20:
	movq	%rdx, %r8
	movl	$0, %edx
	cmpq	$-1, %r8
	je	.LBB2_23
# %bb.21:
	shlq	$4, %r8
.LBB2_22:
	movq	8(%rsp), %rcx
	leaq	(%rcx,%r8), %rax
	addq	$144, %rax
	leaq	(%rcx,%r8), %rdx
	addq	$152, %rdx
.LBB2_23:
	addq	$16, %rsp
	.cfi_def_cfa_offset 32
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	.cfi_restore %rbx
	.cfi_restore %r14
	.cfi_restore %rbp
	retq
.Lfunc_end2:
	.size	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm, .Lfunc_end2-_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm
	.cfi_endproc
                                        # -- End function
	.section	.text._ZN9stx_btree13IntegerPrefix7compareEmPKhm,"axG",@progbits,_ZN9stx_btree13IntegerPrefix7compareEmPKhm,comdat
	.weak	_ZN9stx_btree13IntegerPrefix7compareEmPKhm # -- Begin function _ZN9stx_btree13IntegerPrefix7compareEmPKhm
	.p2align	4, 0x90
	.type	_ZN9stx_btree13IntegerPrefix7compareEmPKhm,@function
_ZN9stx_btree13IntegerPrefix7compareEmPKhm: # @_ZN9stx_btree13IntegerPrefix7compareEmPKhm
	.cfi_startproc
# %bb.0:
	testq	%rdx, %rdx
	je	.LBB3_1
# %bb.2:
	cmpq	$8, %rdx
	movl	$8, %ecx
	cmovbq	%rdx, %rcx
	leal	(,%rcx,8), %r8d
	movl	$64, %eax
	subq	%r8, %rax
	cmpq	$8, %rdx
	jb	.LBB3_4
# %bb.3:
	movbeq	(%rsi), %r8
	jmp	.LBB3_9
.LBB3_1:
	xorl	%eax, %eax
	retq
.LBB3_4:
	cmpq	$4, %rdx
	jb	.LBB3_6
# %bb.5:
	movzbl	(%rsi), %edx
	movzbl	1(%rsi), %r8d
	shll	$16, %edx
	shll	$8, %r8d
	orl	%edx, %r8d
	movzbl	2(%rsi), %edx
	orl	%r8d, %edx
	movzbl	3(%rsi), %r9d
	movbel	-4(%rsi,%rcx), %ecx
	shlq	$40, %rdx
	shlq	$32, %r9
	orq	%rdx, %r9
	shlxq	%rax, %rcx, %r8
	orq	%r9, %r8
	jmp	.LBB3_9
.LBB3_6:
	movzbl	(%rsi), %r8d
	cmpq	$1, %rdx
	jne	.LBB3_7
# %bb.8:
	shlq	$56, %r8
	jmp	.LBB3_9
.LBB3_7:
	movzbl	1(%rsi), %edx
	movzbl	-1(%rsi,%rcx), %ecx
	shlq	$56, %r8
	shlq	$48, %rdx
	orq	%r8, %rdx
	shlxq	%rax, %rcx, %r8
	orq	%rdx, %r8
.LBB3_9:
	andb	$-8, %al
	shrxq	%rax, %rdi, %rcx
	shrxq	%rax, %r8, %rdx
	xorl	%esi, %esi
	cmpq	%rdx, %rcx
	movl	$0, %eax
	sbbl	%eax, %eax
	orl	$1, %eax
	cmpq	%rdx, %rcx
	cmovel	%esi, %eax
	retq
.Lfunc_end3:
	.size	_ZN9stx_btree13IntegerPrefix7compareEmPKhm, .Lfunc_end3-_ZN9stx_btree13IntegerPrefix7compareEmPKhm
	.cfi_endproc
                                        # -- End function
	.section	.text._ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE,"axG",@progbits,_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE,comdat
	.weak	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE # -- Begin function _ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE
	.p2align	4, 0x90
	.type	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE,@function
_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE: # @_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE
	.cfi_startproc
# %bb.0:
	movq	(%rdi), %rax
	movq	(%rsi), %rsi
	jmp	.LBB4_1
	.p2align	4, 0x90
.LBB4_6:                                #   in Loop: Header=BB4_1 Depth=1
	andq	$-2, %r8
	leaq	1(%rdi), %r9
	cmpq	128(%r8), %rsi
	cmovaeq	%r9, %rdx
	cmovbq	%rdi, %rcx
	je	.LBB4_7
.LBB4_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_4 Depth 2
	movq	%rcx, %rdi
	subq	%rdx, %rdi
	jbe	.LBB4_2
# %bb.3:                                #   in Loop: Header=BB4_1 Depth=1
	shrq	%rdi
	addq	%rdx, %rdi
	movq	120(%rax,%rdi,8), %r8
	testb	$1, %r8b
	jne	.LBB4_6
	.p2align	4, 0x90
.LBB4_4:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	112(%r8), %r8
	testb	$1, %r8b
	je	.LBB4_4
	jmp	.LBB4_6
.LBB4_2:
	xorl	%eax, %eax
                                        # kill: def $al killed $al killed $eax
	retq
.LBB4_7:
	movb	$1, %al
	movq	%rdi, %rdx
                                        # kill: def $al killed $al killed $eax
	retq
.Lfunc_end4:
	.size	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE, .Lfunc_end4-_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE
	.cfi_endproc
                                        # -- End function
	.section	.text._ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE,"axG",@progbits,_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE,comdat
	.weak	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE # -- Begin function _ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE
	.p2align	4, 0x90
	.type	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE,@function
_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE: # @_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE
	.cfi_startproc
# %bb.0:
	movq	(%rdi), %rax
	movq	(%rsi), %rsi
	jmp	.LBB5_1
	.p2align	4, 0x90
.LBB5_5:                                #   in Loop: Header=BB5_1 Depth=1
	leaq	1(%r8,%rdx), %rdx
	je	.LBB5_7
.LBB5_1:                                # =>This Inner Loop Header: Depth=1
	movq	%rcx, %r8
	subq	%rdx, %r8
	jbe	.LBB5_2
# %bb.3:                                #   in Loop: Header=BB5_1 Depth=1
	shrq	%r8
	leaq	(%r8,%rdx), %rdi
	movq	%rdi, %r9
	shlq	$4, %r9
	cmpq	144(%rax,%r9), %rsi
	jae	.LBB5_5
# %bb.4:                                #   in Loop: Header=BB5_1 Depth=1
	movq	%rdi, %rcx
	jne	.LBB5_1
.LBB5_7:
	movb	$1, %al
	movq	%rdi, %rdx
                                        # kill: def $al killed $al killed $eax
	retq
.LBB5_2:
	xorl	%eax, %eax
                                        # kill: def $al killed $al killed $eax
	retq
.Lfunc_end5:
	.size	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE, .Lfunc_end5-_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE
	.cfi_endproc
                                        # -- End function
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0                          # -- Begin function _ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E
.LCPI6_0:
	.long	0                               # 0x0
	.long	0                               # 0x0
	.long	0                               # 0x0
	.long	1                               # 0x1
.LCPI6_1:
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	1                               # 0x1
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.section	.text._ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E,"axG",@progbits,_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E,comdat
	.weak	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E
	.p2align	4, 0x90
	.type	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E,@function
_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E: # @_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E
	.cfi_startproc
# %bb.0:
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	subq	$16, %rsp
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	(%rdi), %r15
	testq	%r15, %r15
	je	.LBB6_15
# %bb.1:
	movq	%rsi, %rbx
	movq	%r15, %r14
	andq	$-2, %r14
	movzbl	1024(%r14), %r12d
	testq	%r12, %r12
	je	.LBB6_5
# %bb.2:
	movq	(%rbx), %r13
	testq	%r13, %r13
	je	.LBB6_15
# %bb.3:
	cmpq	%r12, %r13
	movq	%r12, %rdx
	cmovbq	%r13, %rdx
	leaq	1025(%r14), %rsi
	movq	8(%rbx), %rdi
	callq	bcmp@PLT
	movl	%eax, %ecx
	xorl	%eax, %eax
	cmpq	%r12, %r13
	jb	.LBB6_16
# %bb.4:
	movl	$0, %edx
	testl	%ecx, %ecx
	jne	.LBB6_17
.LBB6_5:
	testb	$1, %r15b
	jne	.LBB6_14
# %bb.6:
	leaq	8(%rsp), %r14
	jmp	.LBB6_8
	.p2align	4, 0x90
.LBB6_7:                                #   in Loop: Header=BB6_8 Depth=1
	movq	8(%rsp), %rax
	movq	176(%rax,%rdx,8), %r15
	testb	$1, %r15b
	jne	.LBB6_13
.LBB6_8:                                # =>This Inner Loop Header: Depth=1
	movq	%r15, 8(%rsp)
	movzwl	4(%r15), %esi
	movq	%rbx, %rdi
	callq	_ZN9stx_btree15InlineKeyTraitsINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEE6windowERKSt17basic_string_viewIcS4_Em
	shrq	$32, %rax
	movq	8(%rsp), %rcx
	movzwl	(%rcx), %esi
	vpbroadcastd	%eax, %xmm0
	vmovdqu	8(%rcx), %xmm1
	vmovdqu	24(%rcx), %xmm2
	vmovdqu	40(%rcx), %xmm3
	vmovdqu	56(%rcx), %xmm4
	vpcmpltud	%xmm0, %xmm1, %k0
	vpcmpltud	%xmm0, %xmm2, %k1
	vpmovm2d	%k1, %xmm5
	vpsrld	$31, %xmm5, %xmm5
	vpmovm2d	%k0, %xmm6
	vpsubd	%xmm6, %xmm5, %xmm5
	vpcmpeqd	%xmm0, %xmm2, %xmm2
	vpsrld	$31, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm1, %xmm1
	vpsubd	%xmm1, %xmm2, %xmm1
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm2
	vpsubd	%xmm2, %xmm5, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vpcmpltud	%xmm0, %xmm4, %k0
	vpmovm2d	%k0, %xmm3
	vpsubd	%xmm3, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm4, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	72(%rcx), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	88(%rcx), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	104(%rcx), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	120(%rcx), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	136(%rcx), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	152(%rcx), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	156(%rcx), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k1
	vmovdqa	.LCPI6_0(%rip), %xmm4           # xmm4 = [0,0,0,1]
	vpaddd	%xmm4, %xmm2, %xmm2 {%k1}
	vpcmpeqd	%xmm0, %xmm3, %k1
	vpaddd	%xmm4, %xmm1, %xmm1 {%k1}
	vpshufd	$238, %xmm2, %xmm0              # xmm0 = xmm2[2,3,2,3]
	vpaddd	%xmm0, %xmm2, %xmm0
	vpshufd	$85, %xmm0, %xmm2               # xmm2 = xmm0[1,1,1,1]
	vpaddd	%xmm2, %xmm0, %xmm0
	vmovd	%xmm0, %edx
	vpshufd	$238, %xmm1, %xmm0              # xmm0 = xmm1[2,3,2,3]
	vpaddd	%xmm0, %xmm1, %xmm0
	vpshufd	$85, %xmm0, %xmm1               # xmm1 = xmm0[1,1,1,1]
	vpaddd	%xmm1, %xmm0, %xmm0
	vmovd	%xmm0, %ecx
	cmpq	%rsi, %rdx
	cmovaeq	%rsi, %rdx
	addq	%rdx, %rcx
	cmpq	%rsi, %rcx
	cmovaeq	%rsi, %rcx
	cmpq	%rcx, %rdx
	je	.LBB6_7
# %bb.9:                                #   in Loop: Header=BB6_8 Depth=1
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	testb	$1, %al
	je	.LBB6_7
# %bb.10:
	movq	8(%rsp), %rax
	movq	184(%rax,%rdx,8), %rdx
	testb	$1, %dl
	jne	.LBB6_12
	.p2align	4, 0x90
.LBB6_11:                               # =>This Inner Loop Header: Depth=1
	movq	176(%rdx), %rdx
	testb	$1, %dl
	je	.LBB6_11
.LBB6_12:
	andq	$-2, %rdx
	leaq	184(%rdx), %rax
	addq	$216, %rdx
	jmp	.LBB6_17
.LBB6_13:
	andq	$-2, %r15
	movq	%r15, %r14
.LBB6_14:
	movq	%r14, 8(%rsp)
	movzwl	4(%r14), %esi
	movq	%rbx, %rdi
	callq	_ZN9stx_btree15InlineKeyTraitsINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEE6windowERKSt17basic_string_viewIcS4_Em
	movzwl	(%r14), %esi
	vpbroadcastq	%rax, %xmm0
	vmovdqu	8(%r14), %xmm1
	vmovdqu	24(%r14), %xmm2
	vmovdqu	40(%r14), %xmm3
	vmovdqu	56(%r14), %xmm4
	vpcmpltuq	%xmm0, %xmm1, %k0
	vpcmpltuq	%xmm0, %xmm2, %k1
	vpmovm2q	%k1, %xmm5
	vpsrlq	$63, %xmm5, %xmm5
	vpmovm2q	%k0, %xmm6
	vpsubq	%xmm6, %xmm5, %xmm5
	vpcmpeqq	%xmm0, %xmm2, %xmm2
	vpsrlq	$63, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm1, %xmm1
	vpsubq	%xmm1, %xmm2, %xmm1
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm2
	vpsubq	%xmm2, %xmm5, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vpcmpltuq	%xmm0, %xmm4, %k0
	vpmovm2q	%k0, %xmm3
	vpsubq	%xmm3, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm4, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	72(%r14), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	88(%r14), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	104(%r14), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	120(%r14), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	136(%r14), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	144(%r14), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k1
	vmovdqa	.LCPI6_1(%rip), %xmm4           # xmm4 = [0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0]
	vpaddq	%xmm4, %xmm2, %xmm2 {%k1}
	vpcmpeqq	%xmm0, %xmm3, %k1
	vpaddq	%xmm4, %xmm1, %xmm1 {%k1}
	vpshufd	$238, %xmm2, %xmm0              # xmm0 = xmm2[2,3,2,3]
	vpaddq	%xmm2, %xmm0, %xmm0
	vmovq	%xmm0, %rdx
	vpshufd	$238, %xmm1, %xmm0              # xmm0 = xmm1[2,3,2,3]
	vpaddq	%xmm1, %xmm0, %xmm0
	vmovq	%xmm0, %rcx
	cmpq	%rsi, %rdx
	cmovaeq	%rsi, %rdx
	addq	%rdx, %rcx
	cmpq	%rsi, %rcx
	cmovaeq	%rsi, %rcx
	movq	%rcx, %rax
	subq	%rdx, %rax
	jne	.LBB6_18
.LBB6_15:
	xorl	%eax, %eax
.LBB6_16:
	xorl	%edx, %edx
.LBB6_17:
	addq	$16, %rsp
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.LBB6_18:
	.cfi_def_cfa_offset 64
	movzwl	4(%r14), %r8d
	addq	$8, %r8
	cmpq	$1, %rax
	jne	.LBB6_21
# %bb.19:
	shlq	$3, %rdx
	leaq	(%rdx,%rdx,4), %r15
	movq	(%rbx), %rcx
	cmpq	232(%r14,%r15), %rcx
	jne	.LBB6_15
# %bb.20:
	movq	224(%r14,%r15), %rdx
	movq	8(%rbx), %rdi
	movq	%rcx, %rsi
	callq	_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm
	testl	%eax, %eax
	jne	.LBB6_15
	jmp	.LBB6_23
.LBB6_21:
	leaq	8(%rsp), %rdi
	movq	%rbx, %rsi
	callq	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm
	cmpq	$-1, %rax
	je	.LBB6_15
# %bb.22:
	movq	8(%rsp), %r14
	shlq	$3, %rax
	leaq	(%rax,%rax,4), %r15
.LBB6_23:
	leaq	(%r14,%r15), %rax
	addq	$224, %rax
	leaq	(%r14,%r15), %rdx
	addq	$256, %rdx                      # imm = 0x100
	jmp	.LBB6_17
.Lfunc_end6:
	.size	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E, .Lfunc_end6-_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E
	.cfi_endproc
                                        # -- End function
	.section	.text._ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE,"axG",@progbits,_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE,comdat
	.weak	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE # -- Begin function _ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	.p2align	4, 0x90
	.type	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE,@function
_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE: # @_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	pushq	%rax
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rcx, %r14
	movq	%rdx, %rbx
	movq	%rsi, %r15
	movq	%rdi, %r12
	movq	(%rdi), %rax
	movzwl	4(%rax), %r13d
	addq	$4, %r13
	jmp	.LBB7_1
	.p2align	4, 0x90
.LBB7_6:                                #   in Loop: Header=BB7_1 Depth=1
	andq	$-2, %rax
	movq	184(%rax), %rdx
	movq	192(%rax), %rcx
	movq	(%r15), %rsi
	movq	8(%r15), %rdi
	movq	%r13, %r8
	callq	_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm
	leaq	1(%rbp), %rcx
	testl	%eax, %eax
	cmovnsq	%rcx, %rbx
	cmovsq	%rbp, %r14
	je	.LBB7_7
.LBB7_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB7_4 Depth 2
	movq	%r14, %rbp
	subq	%rbx, %rbp
	jbe	.LBB7_2
# %bb.3:                                #   in Loop: Header=BB7_1 Depth=1
	shrq	%rbp
	addq	%rbx, %rbp
	movq	(%r12), %rax
	movq	184(%rax,%rbp,8), %rax
	testb	$1, %al
	jne	.LBB7_6
	.p2align	4, 0x90
.LBB7_4:                                #   Parent Loop BB7_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	176(%rax), %rax
	testb	$1, %al
	je	.LBB7_4
	jmp	.LBB7_6
.LBB7_2:
	xorl	%eax, %eax
	jmp	.LBB7_8
.LBB7_7:
	movb	$1, %al
	movq	%rbp, %rbx
.LBB7_8:
                                        # kill: def $al killed $al killed $eax
	movq	%rbx, %rdx
	addq	$8, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end7:
	.size	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE, .Lfunc_end7-_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	.cfi_endproc
                                        # -- End function
	.section	.text._ZN9stx_btree15InlineKeyTraitsINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEE6windowERKSt17basic_string_viewIcS4_Em,"axG",@progbits,_ZN9stx_btree15InlineKeyTraitsINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEE6windowERKSt17basic_string_viewIcS4_Em,comdat
	.weak	_ZN9stx_btree15InlineKeyTraitsINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEE6windowERKSt17basic_string_viewIcS4_Em # -- Begin function _ZN9stx_btree15InlineKeyTraitsINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEE6windowERKSt17basic_string_viewIcS4_Em
	.p2align	4, 0x90
	.type	_ZN9stx_btree15InlineKeyTraitsINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEE6windowERKSt17basic_string_viewIcS4_Em,@function
_ZN9stx_btree15InlineKeyTraitsINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEE6windowERKSt17basic_string_viewIcS4_Em: # @_ZN9stx_btree15InlineKeyTraitsINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEE6windowERKSt17basic_string_viewIcS4_Em
	.cfi_startproc
# %bb.0:
	movq	(%rdi), %rax
	movq	%rax, %rdx
	subq	%rsi, %rdx
	jbe	.LBB8_1
# %bb.3:
	movq	8(%rdi), %rcx
	cmpq	$8, %rdx
	jb	.LBB8_5
# %bb.4:
	movbeq	(%rcx,%rsi), %rax
	retq
.LBB8_1:
	xorl	%eax, %eax
	retq
.LBB8_5:
	cmpq	$8, %rax
	jb	.LBB8_7
# %bb.6:
	movbeq	-8(%rcx,%rax), %rcx
	subl	%eax, %esi
	shll	$3, %esi
	shlxq	%rsi, %rcx, %rax
	retq
.LBB8_7:
	cmpq	$4, %rax
	jb	.LBB8_9
# %bb.8:
	movzbl	(%rcx), %edx
	movzbl	1(%rcx), %edi
	shll	$16, %edx
	shll	$8, %edi
	orl	%edx, %edi
	movzbl	2(%rcx), %edx
	orl	%edi, %edx
	movbel	-4(%rcx,%rax), %edi
	movzbl	3(%rcx), %ecx
	shlq	$40, %rdx
	shlq	$32, %rcx
	orq	%rdx, %rcx
	shll	$3, %eax
	negb	%al
	shlxq	%rax, %rdi, %rdx
	orq	%rcx, %rdx
	shll	$3, %esi
	shlxq	%rsi, %rdx, %rax
	retq
.LBB8_9:
	movzbl	(%rcx), %edx
	cmpq	$2, %rax
	jb	.LBB8_11
# %bb.10:
	movzbl	1(%rcx), %edi
	movzbl	-1(%rcx,%rax), %ecx
	shlq	$56, %rdx
	shlq	$48, %rdi
	orq	%rdx, %rdi
	shll	$3, %eax
	negb	%al
	shlxq	%rax, %rcx, %rdx
	orq	%rdi, %rdx
	shll	$3, %esi
	shlxq	%rsi, %rdx, %rax
	retq
.LBB8_11:
	shlq	$56, %rdx
	shll	$3, %esi
	shlxq	%rsi, %rdx, %rax
	retq
.Lfunc_end8:
	.size	_ZN9stx_btree15InlineKeyTraitsINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEE6windowERKSt17basic_string_viewIcS4_Em, .Lfunc_end8-_ZN9stx_btree15InlineKeyTraitsINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEE6windowERKSt17basic_string_viewIcS4_Em
	.cfi_endproc
                                        # -- End function
	.section	.text._ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm,"axG",@progbits,_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm,comdat
	.weak	_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm # -- Begin function _ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm
	.p2align	4, 0x90
	.type	_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm,@function
_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm: # @_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm
	.cfi_startproc
# %bb.0:
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	cmpq	%rcx, %rsi
	movq	%rcx, %r9
	cmovbq	%rsi, %r9
	leaq	(,%r8,8), %rax
	negq	%rax
	.p2align	4, 0x90
.LBB9_1:                                # =>This Inner Loop Header: Depth=1
	leaq	8(%r8), %r11
	cmpq	%r9, %r11
	ja	.LBB9_5
# %bb.2:                                #   in Loop: Header=BB9_1 Depth=1
	movbeq	(%rdi,%r8), %r10
	movbeq	(%rdx,%r8), %rbx
	addq	$-64, %rax
	movq	%r11, %r8
	cmpq	%rbx, %r10
	je	.LBB9_1
# %bb.3:
	xorl	%eax, %eax
	cmpq	%rbx, %r10
	sbbl	%eax, %eax
	jmp	.LBB9_4
.LBB9_5:
	cmpq	%r9, %r8
	jae	.LBB9_27
# %bb.6:
	movq	%rsi, %r9
	subq	%r8, %r9
	cmpq	$8, %r9
	jb	.LBB9_8
# %bb.7:
	movbeq	(%rdi,%r8), %rdi
	movq	%rcx, %r9
	subq	%r8, %r9
	cmpq	$8, %r9
	jb	.LBB9_18
	jmp	.LBB9_17
.LBB9_8:
	cmpq	$8, %rsi
	jb	.LBB9_10
# %bb.9:
	movbeq	-8(%rdi,%rsi), %rdi
	leal	(%rax,%rsi,8), %r9d
	negb	%r9b
	shlxq	%r9, %rdi, %rdi
	movq	%rcx, %r9
	subq	%r8, %r9
	cmpq	$8, %r9
	jae	.LBB9_17
.LBB9_18:
	cmpq	$8, %rcx
	jb	.LBB9_20
# %bb.19:
	movbeq	-8(%rdx,%rcx), %rdx
	leal	(%rax,%rcx,8), %eax
	negb	%al
	shlxq	%rax, %rdx, %rdx
	jmp	.LBB9_26
.LBB9_10:
	cmpq	$4, %rsi
	jb	.LBB9_12
# %bb.11:
	movzbl	(%rdi), %r9d
	movzbl	1(%rdi), %r10d
	shll	$16, %r9d
	shll	$8, %r10d
	orl	%r9d, %r10d
	movzbl	2(%rdi), %r9d
	orl	%r10d, %r9d
	movbel	-4(%rdi,%rsi), %r10d
	movzbl	3(%rdi), %edi
	shlq	$40, %r9
	shlq	$32, %rdi
	orq	%r9, %rdi
	leal	(,%rsi,8), %r9d
	negb	%r9b
	shlxq	%r9, %r10, %r9
	orq	%rdi, %r9
	jmp	.LBB9_15
.LBB9_20:
	cmpq	$4, %rcx
	jb	.LBB9_22
# %bb.21:
	movzbl	(%rdx), %r8d
	movzbl	1(%rdx), %r9d
	shll	$16, %r8d
	shll	$8, %r9d
	orl	%r8d, %r9d
	movzbl	2(%rdx), %r8d
	orl	%r9d, %r8d
	movbel	-4(%rdx,%rcx), %r9d
	movzbl	3(%rdx), %edx
	shlq	$40, %r8
	shlq	$32, %rdx
	orq	%r8, %rdx
	leal	(,%rcx,8), %r8d
	negb	%r8b
	shlxq	%r8, %r9, %r8
	orq	%rdx, %r8
	jmp	.LBB9_25
.LBB9_12:
	movzbl	(%rdi), %r9d
	cmpq	$2, %rsi
	jb	.LBB9_14
# %bb.13:
	movzbl	1(%rdi), %r10d
	movzbl	-1(%rdi,%rsi), %edi
	shlq	$56, %r9
	shlq	$48, %r10
	orq	%r9, %r10
	leal	(,%rsi,8), %r9d
	negb	%r9b
	shlxq	%r9, %rdi, %r9
	orq	%r10, %r9
	jmp	.LBB9_15
.LBB9_22:
	movzbl	(%rdx), %r8d
	cmpq	$2, %rcx
	jb	.LBB9_24
# %bb.23:
	movzbl	1(%rdx), %r9d
	movzbl	-1(%rdx,%rcx), %edx
	shlq	$56, %r8
	shlq	$48, %r9
	orq	%r8, %r9
	leal	(,%rcx,8), %r8d
	negb	%r8b
	shlxq	%r8, %rdx, %r8
	orq	%r9, %r8
	jmp	.LBB9_25
.LBB9_14:
	shlq	$56, %r9
.LBB9_15:
	movl	%eax, %edi
	negb	%dil
	shlxq	%rdi, %r9, %rdi
	movq	%rcx, %r9
	subq	%r8, %r9
	cmpq	$8, %r9
	jb	.LBB9_18
.LBB9_17:
	movbeq	(%rdx,%r8), %rdx
	jmp	.LBB9_26
.LBB9_24:
	shlq	$56, %r8
.LBB9_25:
	negb	%al
	shlxq	%rax, %r8, %rdx
.LBB9_26:
	xorl	%eax, %eax
	cmpq	%rdx, %rdi
	sbbl	%eax, %eax
	cmpq	%rdx, %rdi
	jne	.LBB9_4
.LBB9_27:
	xorl	%edx, %edx
	cmpq	%rcx, %rsi
	movl	$0, %eax
	sbbl	%eax, %eax
	orl	$1, %eax
	cmpq	%rcx, %rsi
	cmovel	%edx, %eax
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.LBB9_4:
	.cfi_def_cfa_offset 16
	orl	$1, %eax
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end9:
	.size	_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm, .Lfunc_end9-_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm
	.cfi_endproc
                                        # -- End function
	.section	.text._ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm,"axG",@progbits,_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm,comdat
	.weak	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm # -- Begin function _ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm
	.p2align	4, 0x90
	.type	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm,@function
_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm: # @_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$24, %rsp
	.cfi_def_cfa_offset 80
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rsi, %r13
	movq	(%rsi), %rsi
	cmpq	$255, %rsi
	movl	$255, %ebx
	cmovbl	%esi, %ebx
	movq	%rcx, %r15
	subq	%rdx, %r15
	jbe	.LBB10_3
# %bb.1:
	movq	(%rdi), %r10
	leaq	-1(%rcx), %rax
	cmpq	%rdx, %rax
	jne	.LBB10_5
# %bb.2:
	xorl	%r11d, %r11d
	xorl	%r14d, %r14d
	xorl	%eax, %eax
	movq	%rdx, %r12
	testb	$1, %r15b
	jne	.LBB10_8
	jmp	.LBB10_9
.LBB10_5:
	movq	%r13, 8(%rsp)                   # 8-byte Spill
	movq	%r8, 16(%rsp)                   # 8-byte Spill
	movq	%r15, %r13
	andq	$-2, %r13
	xorl	%r11d, %r11d
	xorl	%r14d, %r14d
	xorl	%eax, %eax
	movq	%rdx, %r12
	.p2align	4, 0x90
.LBB10_6:                               # =>This Inner Loop Header: Depth=1
	testq	%r11, %r11
	movq	%r14, %rbp
	cmoveq	%r12, %rbp
	xorl	%r9d, %r9d
	cmpb	%bl, 160(%r10,%r12)
	sete	%r9b
	cmoveq	%r12, %rax
	cmovneq	%r14, %rbp
	addq	%r11, %r9
	leaq	1(%r12), %r8
	testq	%r9, %r9
	movq	%rbp, %r14
	cmoveq	%r8, %r14
	xorl	%r11d, %r11d
	cmpb	%bl, 161(%r10,%r12)
	cmoveq	%r8, %rax
	cmovneq	%rbp, %r14
	sete	%r11b
	addq	%r9, %r11
	addq	$2, %r12
	addq	$-2, %r13
	jne	.LBB10_6
# %bb.7:
	movq	16(%rsp), %r8                   # 8-byte Reload
	movq	8(%rsp), %r13                   # 8-byte Reload
	testb	$1, %r15b
	je	.LBB10_9
.LBB10_8:
	testq	%r11, %r11
	movq	%r14, %r15
	cmoveq	%r12, %r15
	xorl	%r9d, %r9d
	cmpb	%bl, 160(%r10,%r12)
	cmoveq	%r12, %rax
	sete	%r9b
	cmoveq	%r15, %r14
	addq	%r9, %r11
.LBB10_9:
	testq	%r11, %r11
	je	.LBB10_3
# %bb.10:
	cmpq	$2, %r11
	je	.LBB10_15
# %bb.11:
	cmpq	$1, %r11
	jne	.LBB10_19
# %bb.12:
	leaq	(,%r14,8), %rax
	leaq	(%rax,%rax,4), %rcx
	movq	$-1, %rax
	cmpq	232(%r10,%rcx), %rsi
	jne	.LBB10_4
# %bb.13:
	movq	224(%r10,%rcx), %rdx
	movq	8(%r13), %rdi
	movq	%rsi, %rcx
.LBB10_14:
	callq	_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm
	movl	%eax, %ecx
	xorl	%eax, %eax
	negl	%ecx
	sbbq	%rax, %rax
	orq	%r14, %rax
	jmp	.LBB10_4
.LBB10_15:
	movq	%rdi, %r15
	leaq	(%rax,%rax,4), %rcx
	movq	224(%r10,%rcx,8), %rdx
	movq	232(%r10,%rcx,8), %rcx
	movq	8(%r13), %rdi
	movq	%r13, %r12
	movq	%r8, %rbx
	movq	%rax, %r13
	callq	_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm
	movl	%eax, %ecx
	movq	%r13, %rax
	testl	%ecx, %ecx
	je	.LBB10_4
# %bb.16:
	jle	.LBB10_20
.LBB10_3:
	movq	$-1, %rax
.LBB10_4:
	addq	$24, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB10_19:
	.cfi_def_cfa_offset 80
	movq	%r13, %rsi
	callq	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	movl	%eax, %ecx
	andb	$1, %cl
	xorl	%eax, %eax
	cmpb	$1, %cl
	sbbq	%rax, %rax
	orq	%rdx, %rax
	jmp	.LBB10_4
.LBB10_20:
	movq	%r12, %rsi
	movq	(%r15), %rdx
	leaq	(,%r14,8), %rax
	leaq	(%rax,%rax,4), %rdi
	movq	(%r12), %rcx
	movq	$-1, %rax
	cmpq	232(%rdx,%rdi), %rcx
	jne	.LBB10_4
# %bb.21:
	movq	224(%rdx,%rdi), %rdx
	movq	8(%rsi), %rdi
	movq	%rcx, %rsi
	movq	%rbx, %r8
	jmp	.LBB10_14
.Lfunc_end10:
	.size	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm, .Lfunc_end10-_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm
	.cfi_endproc
                                        # -- End function
	.section	.text._ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE,"axG",@progbits,_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE,comdat
	.weak	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE # -- Begin function _ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	.p2align	4, 0x90
	.type	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE,@function
_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE: # @_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	pushq	%rax
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rcx, %r12
	movq	%rdx, %rbx
	movq	%rsi, %r14
	movq	%rdi, (%rsp)                    # 8-byte Spill
	movq	(%rdi), %rax
	movzwl	4(%rax), %r13d
	addq	$8, %r13
	jmp	.LBB11_1
	.p2align	4, 0x90
.LBB11_5:                               #   in Loop: Header=BB11_1 Depth=1
	leaq	1(%r15,%rbx), %rbx
	je	.LBB11_7
.LBB11_1:                               # =>This Inner Loop Header: Depth=1
	movq	%r12, %r15
	subq	%rbx, %r15
	jbe	.LBB11_2
# %bb.3:                                #   in Loop: Header=BB11_1 Depth=1
	shrq	%r15
	leaq	(%r15,%rbx), %rbp
	movq	(%rsp), %rax                    # 8-byte Reload
	movq	(%rax), %rax
	leaq	(,%rbp,4), %rcx
	addq	%rbp, %rcx
	movq	224(%rax,%rcx,8), %rdx
	movq	232(%rax,%rcx,8), %rcx
	movq	(%r14), %rsi
	movq	8(%r14), %rdi
	movq	%r13, %r8
	callq	_ZN9stx_btree12ByteEncoding12compare_fromEPKhmS2_mm
	testl	%eax, %eax
	jns	.LBB11_5
# %bb.4:                                #   in Loop: Header=BB11_1 Depth=1
	movq	%rbp, %r12
	jne	.LBB11_1
.LBB11_7:
	movb	$1, %al
	movq	%rbp, %rbx
	jmp	.LBB11_8
.LBB11_2:
	xorl	%eax, %eax
.LBB11_8:
                                        # kill: def $al killed $al killed $eax
	movq	%rbx, %rdx
	addq	$8, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end11:
	.size	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE, .Lfunc_end11-_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	.cfi_endproc
                                        # -- End function
	.section	".linker-options","e",@llvm_linker_options
	.ident	"Ubuntu clang version 18.1.3 (1ubuntu1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __gxx_personality_v0
