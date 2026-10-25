	.text
	.file	"count_probe.cpp"
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0                          # -- Begin function _Z16probe_u16_leaf55PKttm
.LCPI0_0:
	.short	0                               # 0x0
	.short	1                               # 0x1
	.short	1                               # 0x1
	.short	1                               # 0x1
	.short	1                               # 0x1
	.short	1                               # 0x1
	.short	1                               # 0x1
	.short	1                               # 0x1
	.text
	.globl	_Z16probe_u16_leaf55PKttm
	.p2align	4, 0x90
	.type	_Z16probe_u16_leaf55PKttm,@function
_Z16probe_u16_leaf55PKttm:              # @_Z16probe_u16_leaf55PKttm
	.cfi_startproc
# %bb.0:
	vpbroadcastw	%esi, %xmm0
	vmovdqu	(%rdi), %xmm1
	vmovdqu	16(%rdi), %xmm2
	vmovdqu	32(%rdi), %xmm3
	vmovdqu	48(%rdi), %xmm4
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
	vmovdqu	64(%rdi), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k0
	vpmovm2w	%k0, %xmm4
	vpsubw	%xmm4, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm3, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vmovdqu	80(%rdi), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k0
	vpmovm2w	%k0, %xmm4
	vpsubw	%xmm4, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm3, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vmovdqu	94(%rdi), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k1
	vmovdqa	.LCPI0_0(%rip), %xmm4           # xmm4 = [0,1,1,1,1,1,1,1]
	vpaddw	%xmm4, %xmm2, %xmm2 {%k1}
	vpcmpeqw	%xmm0, %xmm3, %k1
	vpaddw	%xmm4, %xmm1, %xmm1 {%k1}
	vpshufd	$238, %xmm2, %xmm0              # xmm0 = xmm2[2,3,2,3]
	vpaddw	%xmm0, %xmm2, %xmm0
	vpshufd	$85, %xmm0, %xmm2               # xmm2 = xmm0[1,1,1,1]
	vpaddw	%xmm2, %xmm0, %xmm0
	vpsrld	$16, %xmm0, %xmm2
	vpaddw	%xmm2, %xmm0, %xmm0
	vpextrw	$0, %xmm0, %eax
	vpshufd	$238, %xmm1, %xmm0              # xmm0 = xmm1[2,3,2,3]
	vpaddw	%xmm0, %xmm1, %xmm0
	vpshufd	$85, %xmm0, %xmm1               # xmm1 = xmm0[1,1,1,1]
	vpaddw	%xmm1, %xmm0, %xmm0
	vpsrld	$16, %xmm0, %xmm1
	vpaddw	%xmm1, %xmm0, %xmm0
	vpextrw	$0, %xmm0, %ecx
	cmpq	%rdx, %rax
	cmovaeq	%rdx, %rax
	addq	%rax, %rcx
	cmpq	%rdx, %rcx
	cmovbq	%rcx, %rdx
	retq
.Lfunc_end0:
	.size	_Z16probe_u16_leaf55PKttm, .Lfunc_end0-_Z16probe_u16_leaf55PKttm
	.cfi_endproc
                                        # -- End function
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0                          # -- Begin function _Z20probe_u16_internal49PKttm
.LCPI1_0:
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	0                               # 0x0
	.short	1                               # 0x1
	.text
	.globl	_Z20probe_u16_internal49PKttm
	.p2align	4, 0x90
	.type	_Z20probe_u16_internal49PKttm,@function
_Z20probe_u16_internal49PKttm:          # @_Z20probe_u16_internal49PKttm
	.cfi_startproc
# %bb.0:
	vpbroadcastw	%esi, %xmm0
	vmovdqu	(%rdi), %xmm1
	vmovdqu	16(%rdi), %xmm2
	vmovdqu	32(%rdi), %xmm3
	vmovdqu	48(%rdi), %xmm4
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
	vmovdqu	64(%rdi), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k0
	vpmovm2w	%k0, %xmm4
	vpsubw	%xmm4, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm3, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vmovdqu	80(%rdi), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k0
	vpmovm2w	%k0, %xmm4
	vpsubw	%xmm4, %xmm2, %xmm2
	vpcmpeqw	%xmm0, %xmm3, %xmm3
	vpsubw	%xmm3, %xmm1, %xmm1
	vmovdqu	82(%rdi), %xmm3
	vpcmpltuw	%xmm0, %xmm3, %k1
	vmovdqa	.LCPI1_0(%rip), %xmm4           # xmm4 = [0,0,0,0,0,0,0,1]
	vpaddw	%xmm4, %xmm2, %xmm2 {%k1}
	vpcmpeqw	%xmm0, %xmm3, %k1
	vpaddw	%xmm4, %xmm1, %xmm1 {%k1}
	vpshufd	$238, %xmm2, %xmm0              # xmm0 = xmm2[2,3,2,3]
	vpaddw	%xmm0, %xmm2, %xmm0
	vpshufd	$85, %xmm0, %xmm2               # xmm2 = xmm0[1,1,1,1]
	vpaddw	%xmm2, %xmm0, %xmm0
	vpsrld	$16, %xmm0, %xmm2
	vpaddw	%xmm2, %xmm0, %xmm0
	vpextrw	$0, %xmm0, %eax
	vpshufd	$238, %xmm1, %xmm0              # xmm0 = xmm1[2,3,2,3]
	vpaddw	%xmm0, %xmm1, %xmm0
	vpshufd	$85, %xmm0, %xmm1               # xmm1 = xmm0[1,1,1,1]
	vpaddw	%xmm1, %xmm0, %xmm0
	vpsrld	$16, %xmm0, %xmm1
	vpaddw	%xmm1, %xmm0, %xmm0
	vpextrw	$0, %xmm0, %ecx
	cmpq	%rdx, %rax
	cmovaeq	%rdx, %rax
	addq	%rax, %rcx
	cmpq	%rdx, %rcx
	cmovbq	%rcx, %rdx
	retq
.Lfunc_end1:
	.size	_Z20probe_u16_internal49PKttm, .Lfunc_end1-_Z20probe_u16_internal49PKttm
	.cfi_endproc
                                        # -- End function
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0                          # -- Begin function _Z20probe_u32_internal41PKjjm
.LCPI2_0:
	.long	0                               # 0x0
	.long	0                               # 0x0
	.long	0                               # 0x0
	.long	1                               # 0x1
	.text
	.globl	_Z20probe_u32_internal41PKjjm
	.p2align	4, 0x90
	.type	_Z20probe_u32_internal41PKjjm,@function
_Z20probe_u32_internal41PKjjm:          # @_Z20probe_u32_internal41PKjjm
	.cfi_startproc
# %bb.0:
	vpbroadcastd	%esi, %xmm0
	vmovdqu	(%rdi), %xmm1
	vmovdqu	16(%rdi), %xmm2
	vmovdqu	32(%rdi), %xmm3
	vmovdqu	48(%rdi), %xmm4
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
	vmovdqu	64(%rdi), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	80(%rdi), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	96(%rdi), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	112(%rdi), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	128(%rdi), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	144(%rdi), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k0
	vpmovm2d	%k0, %xmm4
	vpsubd	%xmm4, %xmm2, %xmm2
	vpcmpeqd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm3, %xmm1, %xmm1
	vmovdqu	148(%rdi), %xmm3
	vpcmpltud	%xmm0, %xmm3, %k1
	vmovdqa	.LCPI2_0(%rip), %xmm4           # xmm4 = [0,0,0,1]
	vpaddd	%xmm4, %xmm2, %xmm2 {%k1}
	vpcmpeqd	%xmm0, %xmm3, %k1
	vpaddd	%xmm4, %xmm1, %xmm1 {%k1}
	vpshufd	$238, %xmm2, %xmm0              # xmm0 = xmm2[2,3,2,3]
	vpaddd	%xmm0, %xmm2, %xmm0
	vpshufd	$85, %xmm0, %xmm2               # xmm2 = xmm0[1,1,1,1]
	vpaddd	%xmm2, %xmm0, %xmm0
	vmovd	%xmm0, %eax
	vpshufd	$238, %xmm1, %xmm0              # xmm0 = xmm1[2,3,2,3]
	vpaddd	%xmm0, %xmm1, %xmm0
	vpshufd	$85, %xmm0, %xmm1               # xmm1 = xmm0[1,1,1,1]
	vpaddd	%xmm1, %xmm0, %xmm0
	vmovd	%xmm0, %ecx
	cmpq	%rdx, %rax
	cmovaeq	%rdx, %rax
	addq	%rax, %rcx
	cmpq	%rdx, %rcx
	cmovbq	%rcx, %rdx
	retq
.Lfunc_end2:
	.size	_Z20probe_u32_internal41PKjjm, .Lfunc_end2-_Z20probe_u32_internal41PKjjm
	.cfi_endproc
                                        # -- End function
	.globl	_Z16probe_u64_leaf24PKmmm       # -- Begin function _Z16probe_u64_leaf24PKmmm
	.p2align	4, 0x90
	.type	_Z16probe_u64_leaf24PKmmm,@function
_Z16probe_u64_leaf24PKmmm:              # @_Z16probe_u64_leaf24PKmmm
	.cfi_startproc
# %bb.0:
	vpbroadcastq	%rsi, %xmm0
	vmovdqu	(%rdi), %xmm1
	vmovdqu	16(%rdi), %xmm2
	vmovdqu	32(%rdi), %xmm3
	vmovdqu	48(%rdi), %xmm4
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
	vmovdqu	64(%rdi), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	80(%rdi), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	96(%rdi), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	112(%rdi), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	128(%rdi), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	144(%rdi), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	160(%rdi), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpsubq	%xmm3, %xmm1, %xmm1
	vmovdqu	176(%rdi), %xmm3
	vpcmpltuq	%xmm0, %xmm3, %k0
	vpmovm2q	%k0, %xmm4
	vpsubq	%xmm4, %xmm2, %xmm2
	vpcmpeqq	%xmm0, %xmm3, %xmm0
	vpsubq	%xmm0, %xmm1, %xmm0
	vpshufd	$238, %xmm2, %xmm1              # xmm1 = xmm2[2,3,2,3]
	vpaddq	%xmm2, %xmm1, %xmm1
	vmovq	%xmm1, %rax
	vpshufd	$238, %xmm0, %xmm1              # xmm1 = xmm0[2,3,2,3]
	vpaddq	%xmm0, %xmm1, %xmm0
	vmovq	%xmm0, %rcx
	cmpq	%rdx, %rax
	cmovaeq	%rdx, %rax
	addq	%rax, %rcx
	cmpq	%rdx, %rcx
	cmovbq	%rcx, %rdx
	retq
.Lfunc_end3:
	.size	_Z16probe_u64_leaf24PKmmm, .Lfunc_end3-_Z16probe_u64_leaf24PKmmm
	.cfi_endproc
                                        # -- End function
	.section	".linker-options","e",@llvm_linker_options
	.ident	"Ubuntu clang version 18.1.3 (1ubuntu1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
