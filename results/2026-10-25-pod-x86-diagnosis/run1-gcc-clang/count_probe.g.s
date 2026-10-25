	.file	"count_probe.cpp"
	.text
	.p2align 4
	.globl	_Z16probe_u16_leaf55PKttm
	.type	_Z16probe_u16_leaf55PKttm, @function
_Z16probe_u16_leaf55PKttm:
.LFB46:
	.cfi_startproc
	endbr64
	vmovdqu16	(%rdi), %xmm6
	vmovdqu16	16(%rdi), %xmm4
	vpbroadcastw	%esi, %xmm0
	vpxor	%xmm2, %xmm2, %xmm2
	vpcmpeqd	%xmm3, %xmm3, %xmm3
	vmovdqu16	94(%rdi), %xmm8
	vmovdqa	.LC0(%rip), %xmm7
	vpsubusw	%xmm6, %xmm0, %xmm1
	vpcmpeqw	%xmm6, %xmm0, %xmm6
	vpsubusw	%xmm4, %xmm0, %xmm5
	vpcmpeqw	%xmm2, %xmm1, %xmm1
	vpcmpeqw	%xmm2, %xmm5, %xmm5
	vpandn	%xmm3, %xmm5, %xmm5
	vpcmpeqw	%xmm4, %xmm0, %xmm4
	vpandn	%xmm3, %xmm1, %xmm1
	vpaddw	%xmm5, %xmm1, %xmm1
	vmovdqu16	32(%rdi), %xmm5
	vpaddw	%xmm6, %xmm4, %xmm6
	vpsubusw	%xmm5, %xmm0, %xmm4
	vpcmpeqw	%xmm5, %xmm0, %xmm5
	vpaddw	%xmm6, %xmm5, %xmm6
	vmovdqu16	48(%rdi), %xmm5
	vpcmpeqw	%xmm2, %xmm4, %xmm4
	vpandn	%xmm3, %xmm4, %xmm4
	vpaddw	%xmm1, %xmm4, %xmm4
	vpsubusw	%xmm5, %xmm0, %xmm1
	vpcmpeqw	%xmm5, %xmm0, %xmm5
	vpaddw	%xmm6, %xmm5, %xmm6
	vmovdqu16	64(%rdi), %xmm5
	vpcmpeqw	%xmm2, %xmm1, %xmm1
	vpandn	%xmm3, %xmm1, %xmm1
	vpaddw	%xmm4, %xmm1, %xmm1
	vpsubusw	%xmm5, %xmm0, %xmm4
	vpcmpeqw	%xmm5, %xmm0, %xmm5
	vpaddw	%xmm6, %xmm5, %xmm6
	vmovdqu16	80(%rdi), %xmm5
	vpcmpeqw	%xmm2, %xmm4, %xmm4
	vpandn	%xmm3, %xmm4, %xmm4
	vpaddw	%xmm1, %xmm4, %xmm4
	vpsubusw	%xmm5, %xmm0, %xmm1
	vpcmpeqw	%xmm5, %xmm0, %xmm5
	vpcmpeqw	%xmm2, %xmm1, %xmm1
	vpaddw	%xmm6, %xmm5, %xmm5
	vpsubusw	%xmm8, %xmm0, %xmm6
	vpandn	%xmm3, %xmm1, %xmm1
	vpcmpeqw	%xmm2, %xmm6, %xmm6
	vpaddw	%xmm4, %xmm1, %xmm1
	vmovdqa	%xmm7, %xmm4
	vpternlogd	$64, %xmm6, %xmm3, %xmm4
	vpaddw	%xmm1, %xmm4, %xmm3
	vpcmpeqw	%xmm8, %xmm0, %xmm1
	vpand	%xmm7, %xmm1, %xmm1
	vpaddw	%xmm5, %xmm1, %xmm1
	vpsubw	%xmm1, %xmm2, %xmm0
	vpsrldq	$8, %xmm0, %xmm0
	vpsubw	%xmm1, %xmm0, %xmm1
	vpsrldq	$4, %xmm1, %xmm0
	vpaddw	%xmm0, %xmm1, %xmm1
	vpsubw	%xmm3, %xmm2, %xmm0
	vpsrldq	$8, %xmm0, %xmm0
	vpsubw	%xmm3, %xmm0, %xmm0
	vpsrldq	$4, %xmm0, %xmm2
	vpaddw	%xmm2, %xmm0, %xmm0
	vpsrldq	$2, %xmm0, %xmm2
	vpaddw	%xmm2, %xmm0, %xmm0
	vpextrw	$0, %xmm0, %eax
	cmpq	%rdx, %rax
	vpsrldq	$2, %xmm1, %xmm0
	vpaddw	%xmm0, %xmm1, %xmm1
	cmova	%rdx, %rax
	movq	%rax, %rcx
	vpextrw	$0, %xmm1, %eax
	addq	%rcx, %rax
	cmpq	%rdx, %rax
	cmovbe	%rax, %rdx
	movq	%rcx, %rax
	ret
	.cfi_endproc
.LFE46:
	.size	_Z16probe_u16_leaf55PKttm, .-_Z16probe_u16_leaf55PKttm
	.p2align 4
	.globl	_Z20probe_u16_internal49PKttm
	.type	_Z20probe_u16_internal49PKttm, @function
_Z20probe_u16_internal49PKttm:
.LFB47:
	.cfi_startproc
	endbr64
	vmovdqu16	(%rdi), %xmm6
	vmovdqu16	16(%rdi), %xmm4
	vpbroadcastw	%esi, %xmm0
	vpxor	%xmm2, %xmm2, %xmm2
	vpcmpeqd	%xmm3, %xmm3, %xmm3
	vmovdqu16	82(%rdi), %xmm8
	vmovdqa	.LC1(%rip), %xmm7
	vpsubusw	%xmm6, %xmm0, %xmm1
	vpcmpeqw	%xmm6, %xmm0, %xmm6
	vpsubusw	%xmm4, %xmm0, %xmm5
	vpcmpeqw	%xmm2, %xmm1, %xmm1
	vpcmpeqw	%xmm2, %xmm5, %xmm5
	vpandn	%xmm3, %xmm5, %xmm5
	vpcmpeqw	%xmm4, %xmm0, %xmm4
	vpandn	%xmm3, %xmm1, %xmm1
	vpaddw	%xmm5, %xmm1, %xmm1
	vmovdqu16	32(%rdi), %xmm5
	vpaddw	%xmm6, %xmm4, %xmm6
	vpsubusw	%xmm5, %xmm0, %xmm4
	vpcmpeqw	%xmm5, %xmm0, %xmm5
	vpaddw	%xmm6, %xmm5, %xmm6
	vmovdqu16	48(%rdi), %xmm5
	vpcmpeqw	%xmm2, %xmm4, %xmm4
	vpandn	%xmm3, %xmm4, %xmm4
	vpaddw	%xmm1, %xmm4, %xmm4
	vpsubusw	%xmm5, %xmm0, %xmm1
	vpcmpeqw	%xmm5, %xmm0, %xmm5
	vpaddw	%xmm6, %xmm5, %xmm6
	vmovdqu16	64(%rdi), %xmm5
	vpcmpeqw	%xmm2, %xmm1, %xmm1
	vpandn	%xmm3, %xmm1, %xmm1
	vpaddw	%xmm4, %xmm1, %xmm1
	vpsubusw	%xmm5, %xmm0, %xmm4
	vpcmpeqw	%xmm5, %xmm0, %xmm5
	vpaddw	%xmm6, %xmm5, %xmm6
	vmovdqu16	80(%rdi), %xmm5
	vpcmpeqw	%xmm2, %xmm4, %xmm4
	vpandn	%xmm3, %xmm4, %xmm4
	vpaddw	%xmm1, %xmm4, %xmm4
	vpsubusw	%xmm5, %xmm0, %xmm1
	vpcmpeqw	%xmm5, %xmm0, %xmm5
	vpcmpeqw	%xmm2, %xmm1, %xmm1
	vpaddw	%xmm6, %xmm5, %xmm5
	vpsubusw	%xmm8, %xmm0, %xmm6
	vpandn	%xmm3, %xmm1, %xmm1
	vpcmpeqw	%xmm2, %xmm6, %xmm6
	vpaddw	%xmm4, %xmm1, %xmm1
	vmovdqa	%xmm7, %xmm4
	vpternlogd	$64, %xmm6, %xmm3, %xmm4
	vpaddw	%xmm1, %xmm4, %xmm3
	vpcmpeqw	%xmm8, %xmm0, %xmm1
	vpand	%xmm7, %xmm1, %xmm1
	vpaddw	%xmm5, %xmm1, %xmm1
	vpsubw	%xmm1, %xmm2, %xmm0
	vpsrldq	$8, %xmm0, %xmm0
	vpsubw	%xmm1, %xmm0, %xmm1
	vpsrldq	$4, %xmm1, %xmm0
	vpaddw	%xmm0, %xmm1, %xmm1
	vpsubw	%xmm3, %xmm2, %xmm0
	vpsrldq	$8, %xmm0, %xmm0
	vpsubw	%xmm3, %xmm0, %xmm0
	vpsrldq	$4, %xmm0, %xmm2
	vpaddw	%xmm2, %xmm0, %xmm0
	vpsrldq	$2, %xmm0, %xmm2
	vpaddw	%xmm2, %xmm0, %xmm0
	vpextrw	$0, %xmm0, %eax
	cmpq	%rdx, %rax
	vpsrldq	$2, %xmm1, %xmm0
	vpaddw	%xmm0, %xmm1, %xmm1
	cmova	%rdx, %rax
	movq	%rax, %rcx
	vpextrw	$0, %xmm1, %eax
	addq	%rcx, %rax
	cmpq	%rdx, %rax
	cmovbe	%rax, %rdx
	movq	%rcx, %rax
	ret
	.cfi_endproc
.LFE47:
	.size	_Z20probe_u16_internal49PKttm, .-_Z20probe_u16_internal49PKttm
	.p2align 4
	.globl	_Z20probe_u32_internal41PKjjm
	.type	_Z20probe_u32_internal41PKjjm, @function
_Z20probe_u32_internal41PKjjm:
.LFB48:
	.cfi_startproc
	endbr64
	vmovdqu	16(%rdi), %xmm6
	vmovdqu	32(%rdi), %xmm3
	movl	$-2147483648, %eax
	vpbroadcastd	%esi, %xmm0
	vmovdqu	(%rdi), %xmm5
	vpbroadcastd	%eax, %xmm2
	vpsubd	%xmm2, %xmm0, %xmm1
	vpsubd	%xmm2, %xmm6, %xmm8
	vpcmpeqd	%xmm6, %xmm0, %xmm6
	vpsubd	%xmm2, %xmm3, %xmm4
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpcmpgtd	%xmm8, %xmm1, %xmm8
	vpsubd	%xmm2, %xmm5, %xmm7
	vpcmpeqd	%xmm5, %xmm0, %xmm5
	vpcmpgtd	%xmm4, %xmm1, %xmm4
	vpaddd	%xmm6, %xmm3, %xmm3
	vpaddd	%xmm5, %xmm3, %xmm3
	vmovdqu	48(%rdi), %xmm5
	vpcmpgtd	%xmm7, %xmm1, %xmm7
	vpaddd	%xmm8, %xmm4, %xmm4
	vpaddd	%xmm7, %xmm4, %xmm4
	vpsubd	%xmm2, %xmm5, %xmm6
	vpcmpeqd	%xmm5, %xmm0, %xmm5
	vpaddd	%xmm3, %xmm5, %xmm5
	vmovdqu	64(%rdi), %xmm3
	vpcmpgtd	%xmm6, %xmm1, %xmm6
	vpaddd	%xmm4, %xmm6, %xmm4
	vpsubd	%xmm2, %xmm3, %xmm6
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpcmpgtd	%xmm6, %xmm1, %xmm6
	vpaddd	%xmm4, %xmm6, %xmm6
	vpaddd	%xmm5, %xmm3, %xmm4
	vmovdqu	80(%rdi), %xmm3
	vpsubd	%xmm2, %xmm3, %xmm5
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	96(%rdi), %xmm3
	vpcmpgtd	%xmm5, %xmm1, %xmm5
	vpaddd	%xmm6, %xmm5, %xmm5
	vpsubd	%xmm2, %xmm3, %xmm6
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	112(%rdi), %xmm3
	vpcmpgtd	%xmm6, %xmm1, %xmm6
	vpaddd	%xmm5, %xmm6, %xmm6
	vpsubd	%xmm2, %xmm3, %xmm5
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	128(%rdi), %xmm3
	vpcmpgtd	%xmm5, %xmm1, %xmm5
	vpaddd	%xmm6, %xmm5, %xmm5
	vpsubd	%xmm2, %xmm3, %xmm6
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	144(%rdi), %xmm3
	vpcmpgtd	%xmm6, %xmm1, %xmm6
	vpaddd	%xmm5, %xmm6, %xmm6
	vpsubd	%xmm2, %xmm3, %xmm5
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm3
	vmovdqu	148(%rdi), %xmm4
	vpcmpgtd	%xmm5, %xmm1, %xmm5
	vpaddd	%xmm6, %xmm5, %xmm5
	vpsubd	%xmm2, %xmm4, %xmm2
	vpcmpeqd	%xmm4, %xmm0, %xmm0
	vpcmpgtd	%xmm2, %xmm1, %xmm1
	vmovdqa	.LC3(%rip), %xmm2
	vpand	%xmm2, %xmm0, %xmm0
	vpand	%xmm2, %xmm1, %xmm1
	vpxor	%xmm2, %xmm2, %xmm2
	vpaddd	%xmm3, %xmm0, %xmm0
	vpaddd	%xmm5, %xmm1, %xmm1
	vpsubd	%xmm0, %xmm2, %xmm3
	vpsrldq	$8, %xmm3, %xmm3
	vpsubd	%xmm0, %xmm3, %xmm3
	vpsubd	%xmm1, %xmm2, %xmm0
	vpsrldq	$8, %xmm0, %xmm0
	vpsubd	%xmm1, %xmm0, %xmm0
	vpsrldq	$4, %xmm0, %xmm1
	vpaddd	%xmm1, %xmm0, %xmm0
	vmovd	%xmm0, %eax
	vpsrldq	$4, %xmm3, %xmm0
	vpaddd	%xmm0, %xmm3, %xmm3
	cmpq	%rdx, %rax
	vmovd	%xmm3, %ecx
	cmova	%rdx, %rax
	addq	%rax, %rcx
	cmpq	%rdx, %rcx
	cmovbe	%rcx, %rdx
	ret
	.cfi_endproc
.LFE48:
	.size	_Z20probe_u32_internal41PKjjm, .-_Z20probe_u32_internal41PKjjm
	.p2align 4
	.globl	_Z16probe_u64_leaf24PKmmm
	.type	_Z16probe_u64_leaf24PKmmm, @function
_Z16probe_u64_leaf24PKmmm:
.LFB49:
	.cfi_startproc
	endbr64
	vmovdqu	16(%rdi), %xmm3
	vmovdqu	32(%rdi), %xmm7
	movabsq	$-9223372036854775808, %rax
	vpbroadcastq	%rsi, %xmm1
	vmovdqu	(%rdi), %xmm6
	vpbroadcastq	%rax, %xmm2
	vpsubq	%xmm2, %xmm1, %xmm0
	vmovq	%rdx, %xmm5
	vpsubq	%xmm2, %xmm3, %xmm4
	vpcmpeqq	%xmm3, %xmm1, %xmm3
	vpsubq	%xmm2, %xmm7, %xmm9
	vpcmpeqq	%xmm7, %xmm1, %xmm7
	vpcmpgtq	%xmm9, %xmm0, %xmm9
	vpsubq	%xmm2, %xmm6, %xmm8
	vpcmpeqq	%xmm6, %xmm1, %xmm6
	vpcmpgtq	%xmm4, %xmm0, %xmm4
	vpaddq	%xmm7, %xmm3, %xmm3
	vpaddq	%xmm6, %xmm3, %xmm3
	vmovdqu	48(%rdi), %xmm6
	vpcmpgtq	%xmm8, %xmm0, %xmm8
	vpaddq	%xmm9, %xmm4, %xmm4
	vpaddq	%xmm8, %xmm4, %xmm4
	vpsubq	%xmm2, %xmm6, %xmm7
	vpcmpeqq	%xmm6, %xmm1, %xmm6
	vpaddq	%xmm3, %xmm6, %xmm6
	vmovdqu	64(%rdi), %xmm3
	vpcmpgtq	%xmm7, %xmm0, %xmm7
	vpaddq	%xmm4, %xmm7, %xmm4
	vpsubq	%xmm2, %xmm3, %xmm8
	vpcmpeqq	%xmm3, %xmm1, %xmm3
	vpcmpgtq	%xmm8, %xmm0, %xmm8
	vpaddq	%xmm4, %xmm8, %xmm8
	vpaddq	%xmm6, %xmm3, %xmm4
	vmovdqu	80(%rdi), %xmm3
	vpsubq	%xmm2, %xmm3, %xmm7
	vpcmpeqq	%xmm3, %xmm1, %xmm3
	vpaddq	%xmm4, %xmm3, %xmm4
	vmovdqu	96(%rdi), %xmm3
	vpcmpgtq	%xmm7, %xmm0, %xmm7
	vpaddq	%xmm8, %xmm7, %xmm7
	vpsubq	%xmm2, %xmm3, %xmm6
	vpcmpeqq	%xmm3, %xmm1, %xmm3
	vpaddq	%xmm4, %xmm3, %xmm4
	vmovdqu	112(%rdi), %xmm3
	vpcmpgtq	%xmm6, %xmm0, %xmm6
	vpaddq	%xmm7, %xmm6, %xmm6
	vpsubq	%xmm2, %xmm3, %xmm7
	vpcmpeqq	%xmm3, %xmm1, %xmm3
	vpaddq	%xmm4, %xmm3, %xmm4
	vmovdqu	128(%rdi), %xmm3
	vpcmpgtq	%xmm7, %xmm0, %xmm7
	vpaddq	%xmm6, %xmm7, %xmm7
	vpsubq	%xmm2, %xmm3, %xmm6
	vpcmpeqq	%xmm3, %xmm1, %xmm3
	vpaddq	%xmm4, %xmm3, %xmm4
	vmovdqu	144(%rdi), %xmm3
	vpcmpgtq	%xmm6, %xmm0, %xmm6
	vpaddq	%xmm7, %xmm6, %xmm6
	vpsubq	%xmm2, %xmm3, %xmm7
	vpcmpeqq	%xmm3, %xmm1, %xmm3
	vpaddq	%xmm4, %xmm3, %xmm4
	vmovdqu	160(%rdi), %xmm3
	vpcmpgtq	%xmm7, %xmm0, %xmm7
	vpaddq	%xmm6, %xmm7, %xmm7
	vpsubq	%xmm2, %xmm3, %xmm6
	vpcmpeqq	%xmm3, %xmm1, %xmm3
	vpaddq	%xmm4, %xmm3, %xmm3
	vmovdqu	176(%rdi), %xmm4
	vpcmpgtq	%xmm6, %xmm0, %xmm6
	vpaddq	%xmm7, %xmm6, %xmm6
	vpsubq	%xmm2, %xmm4, %xmm2
	vpcmpeqq	%xmm4, %xmm1, %xmm1
	vpcmpgtq	%xmm2, %xmm0, %xmm0
	vpaddq	%xmm3, %xmm1, %xmm1
	vpxor	%xmm2, %xmm2, %xmm2
	vpaddq	%xmm6, %xmm0, %xmm0
	vpsubq	%xmm1, %xmm2, %xmm1
	vpsubq	%xmm0, %xmm2, %xmm0
	vmovdqa	%xmm0, %xmm2
	vpsrldq	$8, %xmm0, %xmm0
	vpaddq	%xmm0, %xmm2, %xmm2
	vmovdqa	%xmm1, %xmm0
	vpsrldq	$8, %xmm1, %xmm1
	vpminuq	%xmm5, %xmm2, %xmm2
	vpaddq	%xmm1, %xmm0, %xmm0
	vpaddq	%xmm2, %xmm0, %xmm0
	vmovq	%xmm2, %rax
	vpminuq	%xmm5, %xmm0, %xmm0
	vmovq	%xmm0, %rdx
	ret
	.cfi_endproc
.LFE49:
	.size	_Z16probe_u64_leaf24PKmmm, .-_Z16probe_u64_leaf24PKmmm
	.section	.rodata.cst16,"aM",@progbits,16
	.align 16
.LC0:
	.value	0
	.value	-1
	.value	-1
	.value	-1
	.value	-1
	.value	-1
	.value	-1
	.value	-1
	.align 16
.LC1:
	.value	0
	.value	0
	.value	0
	.value	0
	.value	0
	.value	0
	.value	0
	.value	-1
	.align 16
.LC3:
	.long	0
	.long	0
	.long	0
	.long	-1
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
