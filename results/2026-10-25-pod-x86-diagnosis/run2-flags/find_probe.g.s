	.file	"find_probe.cpp"
	.text
	.section	.text._ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE.isra.0,"axG",@progbits,_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm,comdat
	.align 2
	.p2align 4
	.type	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE.isra.0, @function
_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE.isra.0:
.LFB5119:
	.cfi_startproc
	movq	%rdx, %rax
.L4:
	cmpq	%rcx, %rax
	jnb	.L9
.L5:
	movq	%rcx, %rdx
	subq	%rax, %rdx
	shrq	%rdx
	addq	%rax, %rdx
	movq	%rdx, %r8
	salq	$4, %r8
	movq	144(%rdi,%r8), %r8
	cmpq	%rsi, %r8
	je	.L6
	cmpq	%r8, %rsi
	jb	.L7
	leaq	1(%rdx), %rax
	cmpq	%rcx, %rax
	jb	.L5
.L9:
	movq	%rax, %rdx
	xorl	%eax, %eax
	andl	$1, %eax
	ret
	.p2align 4
	.p2align 3
.L7:
	movq	%rdx, %rcx
	jmp	.L4
	.p2align 4
	.p2align 3
.L6:
	movl	$1, %eax
	andl	$1, %eax
	ret
	.cfi_endproc
.LFE5119:
	.size	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE.isra.0, .-_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE.isra.0
	.section	.text._ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE.isra.0,"axG",@progbits,_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm,comdat
	.align 2
	.p2align 4
	.type	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE.isra.0, @function
_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE.isra.0:
.LFB5120:
	.cfi_startproc
	cmpq	%rcx, %rdx
	jnb	.L21
.L16:
	movq	%rcx, %rax
	subq	%rdx, %rax
	shrq	%rax
	leaq	1(%rdx,%rax), %r8
	leaq	(%rax,%rdx), %r9
	movq	112(%rdi,%r8,8), %rax
	testb	$1, %al
	jne	.L12
	.p2align 4
	.p2align 3
.L13:
	andq	$-2, %rax
	movq	112(%rax), %rax
	testb	$1, %al
	je	.L13
.L12:
	andq	$-2, %rax
	movq	128(%rax), %rax
	cmpq	%rsi, %rax
	je	.L17
	cmpq	%rax, %rsi
	cmovnb	%r8, %rdx
	cmovb	%r9, %rcx
	cmpq	%rcx, %rdx
	jb	.L16
.L21:
	movq	%rdx, %r9
	xorl	%eax, %eax
	movq	%r9, %rdx
	andl	$1, %eax
	ret
	.p2align 4
	.p2align 3
.L17:
	movl	$1, %eax
	movq	%r9, %rdx
	andl	$1, %eax
	ret
	.cfi_endproc
.LFE5120:
	.size	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE.isra.0, .-_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE.isra.0
	.section	.text._ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm,"axG",@progbits,_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm,comdat
	.align 2
	.p2align 4
	.weak	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm
	.type	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm, @function
_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm:
.LFB4778:
	.cfi_startproc
	endbr64
	movq	(%rdi), %rdi
	testq	%rdi, %rdi
	jne	.L60
	xorl	%eax, %eax
	xorl	%edx, %edx
	ret
	.p2align 4
	.p2align 3
.L60:
	movq	%rdi, %r9
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	movq	(%rsi), %rsi
	andq	$-2, %r9
	movzbl	1024(%r9), %eax
	testq	%rax, %rax
	je	.L32
	movl	$8, %edx
	cmpq	%rdx, %rax
	cmovbe	%rax, %rdx
	movq	%rdx, %r8
	movl	$8, %edx
	subq	%r8, %rdx
	cmpq	$7, %rax
	jbe	.L28
	movzbl	1025(%r9), %eax
	movzbl	1026(%r9), %r8d
	salq	$8, %rax
	orq	%r8, %rax
	movzbl	1027(%r9), %r8d
	salq	$8, %rax
	orq	%rax, %r8
	movzbl	1028(%r9), %eax
	salq	$8, %r8
	orq	%r8, %rax
	movzbl	1029(%r9), %r8d
	salq	$8, %rax
	orq	%rax, %r8
	movzbl	1030(%r9), %eax
	salq	$8, %r8
	orq	%r8, %rax
	movzbl	1031(%r9), %r8d
	salq	$8, %rax
	orq	%rax, %r8
	movzbl	1032(%r9), %eax
	salq	$8, %r8
	orq	%r8, %rax
.L29:
	sall	$3, %edx
	shrx	%rdx, %rsi, %r8
	shrx	%rdx, %rax, %rax
	cmpq	%rax, %r8
	je	.L32
.L24:
	xorl	%eax, %eax
	xorl	%edx, %edx
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
	.p2align 4
	.p2align 3
.L32:
	.cfi_restore_state
	testb	$1, %dil
	jne	.L26
	vmovdqa	.LC0(%rip), %xmm5
	vpcmpeqd	%xmm4, %xmm4, %xmm4
	jmp	.L27
	.p2align 4
	.p2align 3
.L37:
	movq	(%rdi,%rdx,8), %rdi
	testb	$1, %dil
	jne	.L61
.L27:
	andq	$-2, %rdi
	xorl	%edx, %edx
	movzwl	4(%rdi), %eax
	cmpq	$7, %rax
	ja	.L35
	salq	$3, %rax
	shlx	%rax, %rsi, %rdx
	shrq	$48, %rdx
.L35:
	vpbroadcastw	%edx, %xmm0
	vpxor	%xmm1, %xmm1, %xmm1
	vmovdqu16	8(%rdi), %xmm2
	vmovdqu16	24(%rdi), %xmm7
	movzwl	(%rdi), %r8d
	vmovdqu16	90(%rdi), %xmm8
	vpsubusw	%xmm2, %xmm0, %xmm3
	vpcmpeqw	%xmm2, %xmm0, %xmm2
	vpsubusw	%xmm7, %xmm0, %xmm6
	vpcmpeqw	%xmm1, %xmm3, %xmm3
	vpcmpeqw	%xmm1, %xmm6, %xmm6
	vpandn	%xmm4, %xmm6, %xmm6
	vpcmpeqw	%xmm7, %xmm0, %xmm7
	vpandn	%xmm4, %xmm3, %xmm3
	vpaddw	%xmm6, %xmm3, %xmm3
	vmovdqu16	40(%rdi), %xmm6
	vpaddw	%xmm7, %xmm2, %xmm7
	vpsubusw	%xmm6, %xmm0, %xmm2
	vpcmpeqw	%xmm6, %xmm0, %xmm6
	vpaddw	%xmm7, %xmm6, %xmm7
	vmovdqu16	56(%rdi), %xmm6
	vpcmpeqw	%xmm1, %xmm2, %xmm2
	vpandn	%xmm4, %xmm2, %xmm2
	vpaddw	%xmm3, %xmm2, %xmm2
	vpsubusw	%xmm6, %xmm0, %xmm3
	vpcmpeqw	%xmm6, %xmm0, %xmm6
	vpaddw	%xmm7, %xmm6, %xmm7
	vmovdqu16	72(%rdi), %xmm6
	vpcmpeqw	%xmm1, %xmm3, %xmm3
	vpandn	%xmm4, %xmm3, %xmm3
	vpaddw	%xmm2, %xmm3, %xmm3
	vpsubusw	%xmm6, %xmm0, %xmm2
	vpcmpeqw	%xmm6, %xmm0, %xmm6
	vpaddw	%xmm7, %xmm6, %xmm7
	vmovdqu16	88(%rdi), %xmm6
	vpcmpeqw	%xmm1, %xmm2, %xmm2
	vpandn	%xmm4, %xmm2, %xmm2
	vpaddw	%xmm3, %xmm2, %xmm2
	vpsubusw	%xmm6, %xmm0, %xmm3
	vpcmpeqw	%xmm6, %xmm0, %xmm6
	vpcmpeqw	%xmm1, %xmm3, %xmm3
	vpaddw	%xmm7, %xmm6, %xmm6
	vpsubusw	%xmm8, %xmm0, %xmm7
	vpcmpeqw	%xmm1, %xmm7, %xmm7
	vpcmpeqw	%xmm8, %xmm0, %xmm0
	vpandn	%xmm4, %xmm3, %xmm3
	vpaddw	%xmm2, %xmm3, %xmm3
	vmovdqa	%xmm5, %xmm2
	vpand	%xmm5, %xmm0, %xmm0
	vpternlogd	$64, %xmm7, %xmm4, %xmm2
	vpaddw	%xmm6, %xmm0, %xmm0
	vpaddw	%xmm3, %xmm2, %xmm2
	vpsubw	%xmm2, %xmm1, %xmm2
	vpsubw	%xmm0, %xmm1, %xmm1
	vpextrw	$6, %xmm2, %edx
	vpextrw	$4, %xmm2, %r9d
	vpextrw	$7, %xmm2, %eax
	addl	%edx, %eax
	vpextrw	$5, %xmm2, %edx
	addl	%r9d, %edx
	vpextrw	$2, %xmm2, %r10d
	vpextrw	$0, %xmm2, %r9d
	addl	%edx, %eax
	vpextrw	$1, %xmm2, %edx
	addl	%r9d, %edx
	vpextrw	$3, %xmm2, %r9d
	addl	%r10d, %r9d
	vpextrw	$2, %xmm1, %r10d
	vpextrw	$6, %xmm1, %r11d
	addl	%r9d, %edx
	vpextrw	$0, %xmm1, %r9d
	addl	%edx, %eax
	vpextrw	$1, %xmm1, %edx
	movzwl	%ax, %eax
	cmpq	%r8, %rax
	cmova	%r8, %rax
	addl	%r9d, %edx
	vpextrw	$3, %xmm1, %r9d
	addl	%r10d, %r9d
	addl	%r9d, %edx
	vpextrw	$4, %xmm1, %r10d
	vpextrw	$5, %xmm1, %r9d
	addl	%r10d, %r9d
	vpextrw	$7, %xmm1, %r10d
	addl	%r11d, %r10d
	vmovq	%rax, %xmm7
	addl	%r10d, %r9d
	addl	%r9d, %edx
	movzwl	%dx, %edx
	addq	%rax, %rdx
	cmpq	%r8, %rdx
	cmova	%r8, %rdx
	xorl	%r8d, %r8d
	vpinsrq	$1, %rdx, %xmm7, %xmm0
	cmpq	%rdx, %rax
	je	.L36
	vmovq	%xmm0, %rdx
	vpextrq	$1, %xmm0, %rcx
	call	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeImmLb0EEEE11search_tiesERKmNS0_10EqualRangeE.isra.0
	movq	%rax, %rcx
	movl	%eax, %r8d
.L36:
	movb	%r8b, %cl
	addq	$112, %rdi
	testb	%cl, %cl
	je	.L37
	movq	8(%rdi,%rdx,8), %rax
	testb	$1, %al
	jne	.L38
	.p2align 4
	.p2align 3
.L39:
	andq	$-2, %rax
	movq	112(%rax), %rax
	testb	$1, %al
	je	.L39
.L38:
	andq	$-2, %rax
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	movq	%rax, %rdx
	leaq	128(%rax), %rax
	addq	$136, %rdx
	ret
.L28:
	.cfi_restore_state
	leaq	1025(%r9), %r10
	cmpq	$3, %rax
	ja	.L62
	cmpq	$1, %rax
	jne	.L63
	movzbl	1025(%r9), %eax
	salq	$56, %rax
	jmp	.L29
	.p2align 4
	.p2align 3
.L61:
	andq	$-2, %rdi
	movq	%rdi, %r9
.L26:
	movzwl	4(%r9), %eax
	xorl	%edx, %edx
	cmpq	$7, %rax
	ja	.L40
	salq	$3, %rax
	shlx	%rax, %rsi, %rdx
	shrq	$48, %rdx
.L40:
	vpbroadcastw	%edx, %xmm0
	vpxor	%xmm2, %xmm2, %xmm2
	vpcmpeqd	%xmm4, %xmm4, %xmm4
	vmovdqu16	24(%r9), %xmm8
	vmovdqu16	40(%r9), %xmm3
	movzwl	(%r9), %ecx
	vmovdqu16	8(%r9), %xmm7
	vpsubusw	%xmm8, %xmm0, %xmm6
	vpcmpeqw	%xmm8, %xmm0, %xmm8
	vpsubusw	%xmm3, %xmm0, %xmm1
	vpcmpeqw	%xmm2, %xmm6, %xmm6
	vpcmpeqw	%xmm2, %xmm1, %xmm1
	vpsubusw	%xmm7, %xmm0, %xmm5
	vpcmpeqw	%xmm2, %xmm5, %xmm5
	vpcmpeqw	%xmm3, %xmm0, %xmm3
	vpandn	%xmm4, %xmm6, %xmm6
	vpandn	%xmm4, %xmm1, %xmm1
	vpaddw	%xmm6, %xmm1, %xmm1
	vmovdqu16	56(%r9), %xmm6
	vpandn	%xmm4, %xmm5, %xmm5
	vpaddw	%xmm8, %xmm3, %xmm3
	vpcmpeqw	%xmm7, %xmm0, %xmm7
	vpaddw	%xmm5, %xmm1, %xmm1
	vmovdqu16	102(%r9), %xmm8
	vpaddw	%xmm7, %xmm3, %xmm3
	vmovdqa	.LC1(%rip), %xmm7
	vpsubusw	%xmm6, %xmm0, %xmm5
	vpcmpeqw	%xmm6, %xmm0, %xmm6
	vpcmpeqw	%xmm2, %xmm5, %xmm5
	vpaddw	%xmm3, %xmm6, %xmm6
	vpandn	%xmm4, %xmm5, %xmm5
	vpaddw	%xmm1, %xmm5, %xmm1
	vmovdqu16	72(%r9), %xmm5
	vpsubusw	%xmm5, %xmm0, %xmm3
	vpcmpeqw	%xmm0, %xmm5, %xmm5
	vpaddw	%xmm6, %xmm5, %xmm6
	vmovdqu16	88(%r9), %xmm5
	vpcmpeqw	%xmm2, %xmm3, %xmm3
	vpandn	%xmm4, %xmm3, %xmm3
	vpaddw	%xmm1, %xmm3, %xmm3
	vpsubusw	%xmm5, %xmm0, %xmm1
	vpcmpeqw	%xmm2, %xmm1, %xmm1
	vpandn	%xmm4, %xmm1, %xmm1
	vpaddw	%xmm3, %xmm1, %xmm1
	vpcmpeqw	%xmm5, %xmm0, %xmm3
	vmovdqa	%xmm7, %xmm5
	vpaddw	%xmm6, %xmm3, %xmm3
	vpsubusw	%xmm8, %xmm0, %xmm6
	vpcmpeqw	%xmm2, %xmm6, %xmm6
	vpternlogd	$64, %xmm6, %xmm4, %xmm5
	vpaddw	%xmm1, %xmm5, %xmm4
	vpcmpeqw	%xmm8, %xmm0, %xmm1
	vpand	%xmm7, %xmm1, %xmm1
	vpaddw	%xmm3, %xmm1, %xmm1
	vpsubw	%xmm1, %xmm2, %xmm0
	vpsrldq	$8, %xmm0, %xmm0
	vpsubw	%xmm1, %xmm0, %xmm1
	vpsrldq	$4, %xmm1, %xmm0
	vpaddw	%xmm0, %xmm1, %xmm1
	vpsubw	%xmm4, %xmm2, %xmm0
	vpsrldq	$8, %xmm0, %xmm0
	vpsubw	%xmm4, %xmm0, %xmm0
	vpsrldq	$4, %xmm0, %xmm2
	vpaddw	%xmm2, %xmm0, %xmm0
	vpsrldq	$2, %xmm0, %xmm2
	vpaddw	%xmm2, %xmm0, %xmm0
	vpextrw	$0, %xmm0, %edx
	cmpq	%rcx, %rdx
	vpsrldq	$2, %xmm1, %xmm0
	vpaddw	%xmm0, %xmm1, %xmm1
	cmova	%rcx, %rdx
	vpextrw	$0, %xmm1, %eax
	addq	%rdx, %rax
	vmovq	%rdx, %xmm5
	cmpq	%rcx, %rax
	cmova	%rcx, %rax
	vpinsrq	$1, %rax, %xmm5, %xmm0
	subq	%rdx, %rax
	je	.L24
	cmpq	$1, %rax
	je	.L64
	vmovq	%xmm0, %rdx
	movq	%r9, %rdi
	vpextrq	$1, %xmm0, %rcx
	call	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeImmLb0EEEE17search_candidatesERKmNS0_10EqualRangeE.isra.0
	testb	%al, %al
	je	.L24
	cmpq	$-1, %rdx
	je	.L24
	salq	$4, %rdx
	leaq	144(%r9,%rdx), %rcx
.L44:
	movq	%rcx, %rax
	leaq	152(%r9,%rdx), %rdx
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L63:
	.cfi_restore_state
	movzbl	-1(%r10,%r8), %eax
	leaq	0(,%rdx,8), %r8
	shlx	%r8, %rax, %rax
	movbew	1025(%r9), %r8w
	salq	$48, %r8
	orq	%r8, %rax
	jmp	.L29
.L62:
	movzbl	1025(%r9), %eax
	movzbl	1026(%r9), %r11d
	movzbl	-3(%r10,%r8), %ebx
	salq	$8, %rax
	orq	%r11, %rax
	movzbl	1027(%r9), %r11d
	salq	$8, %rax
	orq	%rax, %r11
	movzbl	-4(%r10,%r8), %eax
	salq	$8, %r11
	salq	$8, %rax
	orq	%rbx, %rax
	movzbl	-2(%r10,%r8), %ebx
	salq	$8, %rax
	orq	%rbx, %rax
	salq	$8, %rax
	movq	%rax, %rbx
	movzbl	-1(%r10,%r8), %eax
	leaq	0(,%rdx,8), %r8
	orq	%rbx, %rax
	shlx	%r8, %rax, %rax
	movzbl	1028(%r9), %r8d
	orq	%r11, %r8
	salq	$32, %r8
	orq	%r8, %rax
	jmp	.L29
.L64:
	salq	$4, %rdx
	leaq	144(%r9,%rdx), %rcx
	cmpq	%rsi, (%rcx)
	jne	.L24
	jmp	.L44
	.cfi_endproc
.LFE4778:
	.size	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm, .-_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm
	.text
	.p2align 4
	.globl	_Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm
	.type	_Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm, @function
_Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm:
.LFB4140:
	.cfi_startproc
	endbr64
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	%rsi, 8(%rsp)
	leaq	8(%rsp), %rsi
	call	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeImmLb0EEENS_19GlobalPageAllocatorEE4findERKm
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	movq	%rdx, %rax
	ret
	.cfi_endproc
.LFE4140:
	.size	_Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm, .-_Z14probe_find_u64RKN9stx_btree6unsync9BBTreeMapImmNS_19GlobalPageAllocatorEEEm
	.section	.text._ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE,"axG",@progbits,_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE,comdat
	.align 2
	.p2align 4
	.weak	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	.type	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE, @function
_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE:
.LFB4999:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	movq	%rcx, %r9
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	movq	(%rdi), %rbp
	movzwl	4(%rbp), %ebx
	vmovq	%rbp, %xmm3
	leaq	4(%rbx), %rdi
	movq	%rbx, %r12
	movq	%rdi, -16(%rsp)
	movq	%rdx, %rdi
	movq	%rsi, %rdx
	cmpq	%r9, %rdi
	jnb	.L101
.L92:
	vmovq	%xmm3, %rbx
	movq	(%rdx), %r8
	movq	%rdx, -24(%rsp)
	leaq	176(%rbx), %rax
	vmovq	%rax, %xmm2
	movq	8(%rdx), %rax
	movq	%rax, %rdx
.L93:
	movq	%r9, %rcx
	vmovq	%xmm2, %rax
	subq	%rdi, %rcx
	shrq	%rcx
	leaq	1(%rcx,%rdi), %r10
	leaq	(%rcx,%rdi), %r11
	movq	(%rax,%r10,8), %rcx
	testb	$1, %cl
	jne	.L69
	.p2align 4
	.p2align 3
.L70:
	andq	$-2, %rcx
	movq	176(%rcx), %rcx
	testb	$1, %cl
	je	.L70
.L69:
	andq	$-2, %rcx
	movq	%r8, %r15
	movq	-16(%rsp), %r13
	leaq	(%rdx,%r12), %rbx
	movq	192(%rcx), %r14
	movq	184(%rcx), %rbp
	cmpq	%r8, %r14
	leaq	0(%rbp,%r12), %rsi
	vmovq	%rbp, %xmm0
	cmovbe	%r14, %r15
	jmp	.L71
	.p2align 4
	.p2align 3
.L102:
	movzbl	4(%rbx), %ecx
	movzbl	5(%rbx), %eax
	addq	$8, %rsi
	addq	$8, %rbx
	salq	$8, %rcx
	orq	%rcx, %rax
	movzbl	-2(%rbx), %ecx
	salq	$8, %rax
	orq	%rcx, %rax
	movzbl	-1(%rbx), %ecx
	salq	$8, %rax
	orq	%rcx, %rax
	movzbl	(%rbx), %ecx
	salq	$8, %rax
	orq	%rcx, %rax
	movzbl	1(%rbx), %ecx
	salq	$8, %rax
	orq	%rcx, %rax
	movzbl	2(%rbx), %ecx
	salq	$8, %rax
	orq	%rcx, %rax
	movzbl	3(%rbx), %ecx
	salq	$8, %rax
	orq	%rcx, %rax
	movzbl	-4(%rsi), %ecx
	salq	$8, %rcx
	movq	%rcx, %rbp
	movzbl	-3(%rsi), %ecx
	orq	%rbp, %rcx
	movzbl	-2(%rsi), %ebp
	salq	$8, %rcx
	orq	%rbp, %rcx
	movzbl	-1(%rsi), %ebp
	salq	$8, %rcx
	orq	%rbp, %rcx
	movzbl	(%rsi), %ebp
	salq	$8, %rcx
	orq	%rbp, %rcx
	movzbl	1(%rsi), %ebp
	salq	$8, %rcx
	orq	%rbp, %rcx
	movzbl	2(%rsi), %ebp
	salq	$8, %rcx
	orq	%rbp, %rcx
	movzbl	3(%rsi), %ebp
	salq	$8, %rcx
	orq	%rbp, %rcx
	cmpq	%rax, %rcx
	jne	.L100
.L71:
	movq	%r13, %rcx
	addq	$8, %r13
	cmpq	%r13, %r15
	jnb	.L102
	vmovq	%xmm0, %rbp
	cmpq	%r15, %rcx
	jnb	.L76
	cmpq	%r8, %rcx
	jnb	.L103
	movq	%r8, %rax
	subq	%rcx, %rax
	cmpq	$7, %rax
	jbe	.L79
	movzbl	(%rdx,%rcx), %eax
	movzbl	1(%rdx,%rcx), %esi
	salq	$8, %rax
	orq	%rsi, %rax
	movzbl	2(%rdx,%rcx), %esi
	salq	$8, %rax
	orq	%rax, %rsi
	movzbl	3(%rdx,%rcx), %eax
	salq	$8, %rsi
	orq	%rsi, %rax
	movzbl	4(%rdx,%rcx), %esi
	salq	$8, %rax
	orq	%rax, %rsi
	movzbl	5(%rdx,%rcx), %eax
	salq	$8, %rsi
	orq	%rsi, %rax
	movzbl	6(%rdx,%rcx), %esi
	salq	$8, %rax
	orq	%rax, %rsi
	movzbl	7(%rdx,%rcx), %eax
	salq	$8, %rsi
	orq	%rsi, %rax
.L80:
	cmpq	%r14, %rcx
	jnb	.L98
.L78:
	movq	%r14, %rsi
	subq	%rcx, %rsi
	cmpq	$7, %rsi
	jbe	.L85
	movzbl	0(%rbp,%rcx), %ebx
	movzbl	1(%rbp,%rcx), %esi
	salq	$8, %rbx
	orq	%rbx, %rsi
	movq	%rsi, %rbx
	movzbl	2(%rbp,%rcx), %esi
	salq	$8, %rbx
	orq	%rbx, %rsi
	movq	%rsi, %rbx
	movzbl	3(%rbp,%rcx), %esi
	salq	$8, %rbx
	orq	%rbx, %rsi
	movq	%rsi, %rbx
	movzbl	4(%rbp,%rcx), %esi
	salq	$8, %rbx
	orq	%rbx, %rsi
	movq	%rsi, %rbx
	movzbl	5(%rbp,%rcx), %esi
	salq	$8, %rbx
	orq	%rbx, %rsi
	movq	%rsi, %rbx
	movzbl	6(%rbp,%rcx), %esi
	movzbl	7(%rbp,%rcx), %ecx
	salq	$8, %rbx
	orq	%rbx, %rsi
	salq	$8, %rsi
	orq	%rsi, %rcx
.L86:
	cmpq	%rax, %rcx
	jne	.L100
.L76:
	cmpq	%r8, %r14
	je	.L94
.L104:
	cmpq	%r14, %r8
	jb	.L72
.L98:
	movq	%r10, %rdi
	movq	-24(%rsp), %rdx
	cmpq	%r9, %rdi
	jb	.L92
.L101:
	movq	%rdi, %r11
	xorl	%eax, %eax
	jmp	.L91
.L100:
	cmpq	%rcx, %rax
	jnb	.L98
.L72:
	cmpq	%r11, %rdi
	jnb	.L101
	movq	%r11, %r9
	jmp	.L93
.L85:
	cmpq	$7, %r14
	jbe	.L87
	movzbl	-8(%rbp,%r14), %esi
	movzbl	-7(%rbp,%r14), %ebx
	subq	%r14, %rcx
	leaq	64(,%rcx,8), %rcx
	salq	$8, %rsi
	orq	%rbx, %rsi
	movq	%rsi, %rbx
	movzbl	-6(%rbp,%r14), %esi
	salq	$8, %rbx
	orq	%rbx, %rsi
	movq	%rsi, %rbx
	movzbl	-5(%rbp,%r14), %esi
	salq	$8, %rbx
	orq	%rbx, %rsi
	movq	%rsi, %rbx
	movzbl	-4(%rbp,%r14), %esi
	salq	$8, %rbx
	orq	%rbx, %rsi
	movq	%rsi, %rbx
	movzbl	-3(%rbp,%r14), %esi
	salq	$8, %rbx
	orq	%rbx, %rsi
	movq	%rsi, %rbx
	movzbl	-2(%rbp,%r14), %esi
	salq	$8, %rbx
	orq	%rbx, %rsi
	movq	%rsi, %rbx
	movzbl	-1(%rbp,%r14), %esi
	salq	$8, %rbx
	orq	%rbx, %rsi
	shlx	%rcx, %rsi, %rcx
	jmp	.L86
.L79:
	cmpq	$7, %r8
	jbe	.L81
	movzbl	-8(%rdx,%r8), %eax
	movzbl	-7(%rdx,%r8), %esi
	salq	$8, %rax
	orq	%rsi, %rax
	movzbl	-6(%rdx,%r8), %esi
	salq	$8, %rax
	orq	%rsi, %rax
	movzbl	-5(%rdx,%r8), %esi
	salq	$8, %rax
	orq	%rax, %rsi
	movzbl	-4(%rdx,%r8), %eax
	salq	$8, %rsi
	orq	%rsi, %rax
	movzbl	-3(%rdx,%r8), %esi
	salq	$8, %rax
	orq	%rax, %rsi
	movzbl	-2(%rdx,%r8), %eax
	salq	$8, %rsi
	orq	%rsi, %rax
	movzbl	-1(%rdx,%r8), %esi
	salq	$8, %rax
	orq	%rsi, %rax
	movq	%rcx, %rsi
	subq	%r8, %rsi
	leaq	64(,%rsi,8), %rsi
	shlx	%rsi, %rax, %rax
	jmp	.L80
.L103:
	xorl	%eax, %eax
	cmpq	%r14, %rcx
	jb	.L78
	cmpq	%r8, %r14
	jne	.L104
.L94:
	movl	$1, %eax
.L91:
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 48
	andl	$1, %eax
	popq	%rbp
	.cfi_def_cfa_offset 40
	movq	%r11, %rdx
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L81:
	.cfi_restore_state
	cmpq	$3, %r8
	ja	.L105
	cmpq	$1, %r8
	jne	.L106
	movzbl	(%rdx), %eax
	salq	$56, %rax
	jmp	.L83
	.p2align 4
	.p2align 3
.L87:
	cmpq	$3, %r14
	ja	.L107
	cmpq	$1, %r14
	jne	.L108
	movzbl	0(%rbp), %esi
	salq	$56, %rsi
	jmp	.L89
.L108:
	movzbl	-1(%rbp,%r14), %esi
	movl	$8, %ebx
	subq	%r14, %rbx
	salq	$3, %rbx
	shlx	%rbx, %rsi, %rsi
	movbew	0(%rbp), %bx
	salq	$48, %rbx
	orq	%rbx, %rsi
.L89:
	salq	$3, %rcx
	shlx	%rcx, %rsi, %rcx
	jmp	.L86
.L106:
	movzbl	-1(%rdx,%r8), %esi
	movl	$8, %eax
	subq	%r8, %rax
	salq	$3, %rax
	shlx	%rax, %rsi, %rax
	movbew	(%rdx), %si
	salq	$48, %rsi
	orq	%rsi, %rax
.L83:
	leaq	0(,%rcx,8), %rsi
	shlx	%rsi, %rax, %rax
	jmp	.L80
.L107:
	movzbl	-4(%rbp,%r14), %r13d
	movzbl	-3(%rbp,%r14), %esi
	movbel	0(%rbp), %ebx
	salq	$8, %r13
	orq	%r13, %rsi
	movzbl	-2(%rbp,%r14), %r13d
	salq	$8, %rsi
	salq	$32, %rbx
	orq	%r13, %rsi
	movzbl	-1(%rbp,%r14), %r13d
	salq	$8, %rsi
	orq	%rsi, %r13
	movl	$8, %esi
	subq	%r14, %rsi
	salq	$3, %rsi
	shlx	%rsi, %r13, %rsi
	orq	%rbx, %rsi
	jmp	.L89
.L105:
	movzbl	-4(%rdx,%r8), %eax
	movzbl	-3(%rdx,%r8), %ebx
	movbel	(%rdx), %esi
	salq	$8, %rax
	orq	%rbx, %rax
	salq	$8, %rax
	movq	%rax, %rbx
	movzbl	-2(%rdx,%r8), %eax
	salq	$32, %rsi
	orq	%rbx, %rax
	movzbl	-1(%rdx,%r8), %ebx
	salq	$8, %rax
	orq	%rax, %rbx
	movl	$8, %eax
	subq	%r8, %rax
	salq	$3, %rax
	shlx	%rax, %rbx, %rax
	orq	%rsi, %rax
	jmp	.L83
	.cfi_endproc
.LFE4999:
	.size	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE, .-_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	.section	.text._ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE,"axG",@progbits,_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE,comdat
	.align 2
	.p2align 4
	.weak	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	.type	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE, @function
_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE:
.LFB5073:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	movq	%rdx, %r11
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	movq	%rcx, %rbx
	movq	(%rdi), %rbp
	movzwl	4(%rbp), %r15d
	vmovq	%rbp, %xmm0
	leaq	8(%r15), %rax
	movq	%r15, %r13
	movq	%rax, -16(%rsp)
	cmpq	%rbx, %r11
	jnb	.L141
.L145:
	movq	(%rsi), %r12
	movq	8(%rsi), %r15
.L132:
	movq	%rbx, %r8
	vmovq	%xmm0, %rdx
	movq	%r12, %r10
	movq	-16(%rsp), %r9
	subq	%r11, %r8
	shrq	%r8
	addq	%r11, %r8
	leaq	(%r8,%r8,4), %rax
	leaq	224(%rdx,%rax,8), %rax
	leaq	(%r15,%r13), %rdx
	movq	8(%rax), %rbp
	movq	(%rax), %r14
	cmpq	%r12, %rbp
	leaq	(%r14,%r13), %rax
	vmovq	%r14, %xmm1
	cmovbe	%rbp, %r10
	jmp	.L111
	.p2align 4
	.p2align 3
.L143:
	movzbl	8(%rdx), %edi
	movzbl	9(%rdx), %ecx
	addq	$8, %rax
	addq	$8, %rdx
	salq	$8, %rdi
	orq	%rcx, %rdi
	movzbl	2(%rdx), %ecx
	salq	$8, %rdi
	orq	%rdi, %rcx
	movzbl	3(%rdx), %edi
	salq	$8, %rcx
	orq	%rcx, %rdi
	movzbl	4(%rdx), %ecx
	salq	$8, %rdi
	orq	%rdi, %rcx
	movzbl	5(%rdx), %edi
	salq	$8, %rcx
	orq	%rcx, %rdi
	movzbl	6(%rdx), %ecx
	salq	$8, %rdi
	orq	%rdi, %rcx
	movzbl	7(%rdx), %edi
	salq	$8, %rcx
	orq	%rcx, %rdi
	movzbl	(%rax), %ecx
	salq	$8, %rcx
	movq	%rcx, %r14
	movzbl	1(%rax), %ecx
	orq	%r14, %rcx
	movzbl	2(%rax), %r14d
	salq	$8, %rcx
	orq	%r14, %rcx
	movzbl	3(%rax), %r14d
	salq	$8, %rcx
	orq	%r14, %rcx
	movzbl	4(%rax), %r14d
	salq	$8, %rcx
	orq	%r14, %rcx
	movzbl	5(%rax), %r14d
	salq	$8, %rcx
	orq	%r14, %rcx
	movzbl	6(%rax), %r14d
	salq	$8, %rcx
	orq	%r14, %rcx
	movzbl	7(%rax), %r14d
	salq	$8, %rcx
	orq	%r14, %rcx
	cmpq	%rdi, %rcx
	jne	.L142
.L111:
	movq	%r9, %rcx
	addq	$8, %r9
	cmpq	%r9, %r10
	jnb	.L143
	vmovq	%xmm1, %r14
	cmpq	%r10, %rcx
	jnb	.L116
	cmpq	%r12, %rcx
	jnb	.L144
	movq	%r12, %rax
	subq	%rcx, %rax
	cmpq	$7, %rax
	jbe	.L119
	movzbl	(%r15,%rcx), %eax
	movzbl	1(%r15,%rcx), %edx
	salq	$8, %rax
	orq	%rdx, %rax
	movzbl	2(%r15,%rcx), %edx
	salq	$8, %rax
	orq	%rax, %rdx
	movzbl	3(%r15,%rcx), %eax
	salq	$8, %rdx
	orq	%rdx, %rax
	movzbl	4(%r15,%rcx), %edx
	salq	$8, %rax
	orq	%rax, %rdx
	movzbl	5(%r15,%rcx), %eax
	salq	$8, %rdx
	orq	%rdx, %rax
	movzbl	6(%r15,%rcx), %edx
	salq	$8, %rax
	orq	%rax, %rdx
	movzbl	7(%r15,%rcx), %eax
	salq	$8, %rdx
	orq	%rdx, %rax
.L120:
	cmpq	%rbp, %rcx
	jnb	.L113
.L118:
	movq	%rbp, %rdx
	subq	%rcx, %rdx
	cmpq	$7, %rdx
	jbe	.L125
	movzbl	(%r14,%rcx), %edi
	movzbl	1(%r14,%rcx), %edx
	salq	$8, %rdi
	orq	%rdi, %rdx
	movzbl	2(%r14,%rcx), %edi
	salq	$8, %rdx
	orq	%rdx, %rdi
	movzbl	3(%r14,%rcx), %edx
	salq	$8, %rdi
	orq	%rdi, %rdx
	movzbl	4(%r14,%rcx), %edi
	salq	$8, %rdx
	orq	%rdx, %rdi
	movzbl	5(%r14,%rcx), %edx
	salq	$8, %rdi
	orq	%rdi, %rdx
	movzbl	6(%r14,%rcx), %edi
	salq	$8, %rdx
	orq	%rdx, %rdi
	movzbl	7(%r14,%rcx), %edx
	salq	$8, %rdi
	orq	%rdi, %rdx
.L126:
	cmpq	%rdx, %rax
	jne	.L140
.L116:
	cmpq	%r12, %rbp
	je	.L133
.L146:
	cmpq	%rbp, %r12
.L140:
	jnb	.L113
.L112:
	cmpq	%r8, %r11
	jnb	.L141
	movq	%r8, %rbx
	jmp	.L132
.L142:
	cmpq	%rcx, %rdi
	jb	.L112
.L113:
	leaq	1(%r8), %r11
	cmpq	%rbx, %r11
	jb	.L145
.L141:
	movq	%r11, %r8
	xorl	%eax, %eax
	jmp	.L131
.L125:
	cmpq	$7, %rbp
	jbe	.L127
	movzbl	-8(%r14,%rbp), %edx
	movzbl	-7(%r14,%rbp), %edi
	subq	%rbp, %rcx
	leaq	64(,%rcx,8), %rcx
	salq	$8, %rdx
	orq	%rdi, %rdx
	movzbl	-6(%r14,%rbp), %edi
	salq	$8, %rdx
	orq	%rdx, %rdi
	movzbl	-5(%r14,%rbp), %edx
	salq	$8, %rdi
	orq	%rdi, %rdx
	movzbl	-4(%r14,%rbp), %edi
	salq	$8, %rdx
	orq	%rdx, %rdi
	movzbl	-3(%r14,%rbp), %edx
	salq	$8, %rdi
	orq	%rdi, %rdx
	movzbl	-2(%r14,%rbp), %edi
	salq	$8, %rdx
	orq	%rdx, %rdi
	movzbl	-1(%r14,%rbp), %edx
	salq	$8, %rdi
	orq	%rdi, %rdx
	shlx	%rcx, %rdx, %rdx
	jmp	.L126
.L119:
	cmpq	$7, %r12
	jbe	.L121
	movzbl	-8(%r15,%r12), %eax
	movzbl	-7(%r15,%r12), %edx
	salq	$8, %rax
	orq	%rdx, %rax
	movzbl	-6(%r15,%r12), %edx
	salq	$8, %rax
	orq	%rdx, %rax
	movzbl	-5(%r15,%r12), %edx
	salq	$8, %rax
	orq	%rax, %rdx
	movzbl	-4(%r15,%r12), %eax
	salq	$8, %rdx
	orq	%rdx, %rax
	movzbl	-3(%r15,%r12), %edx
	salq	$8, %rax
	orq	%rax, %rdx
	movzbl	-2(%r15,%r12), %eax
	salq	$8, %rdx
	orq	%rdx, %rax
	movzbl	-1(%r15,%r12), %edx
	salq	$8, %rax
	orq	%rdx, %rax
	movq	%rcx, %rdx
	subq	%r12, %rdx
	leaq	64(,%rdx,8), %rdx
	shlx	%rdx, %rax, %rax
	jmp	.L120
.L144:
	xorl	%eax, %eax
	cmpq	%rbp, %rcx
	jb	.L118
	cmpq	%r12, %rbp
	jne	.L146
.L133:
	movl	$1, %eax
.L131:
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 48
	andl	$1, %eax
	popq	%rbp
	.cfi_def_cfa_offset 40
	movq	%r8, %rdx
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L121:
	.cfi_restore_state
	cmpq	$3, %r12
	ja	.L147
	cmpq	$1, %r12
	jne	.L148
	movzbl	(%r15), %eax
	salq	$56, %rax
	jmp	.L123
	.p2align 4
	.p2align 3
.L127:
	cmpq	$3, %rbp
	ja	.L149
	cmpq	$1, %rbp
	jne	.L150
	movzbl	(%r14), %edx
	salq	$56, %rdx
	jmp	.L129
.L150:
	movzbl	-1(%r14,%rbp), %edx
	movl	$8, %edi
	subq	%rbp, %rdi
	salq	$3, %rdi
	shlx	%rdi, %rdx, %rdx
	movbew	(%r14), %di
	salq	$48, %rdi
	orq	%rdi, %rdx
.L129:
	salq	$3, %rcx
	shlx	%rcx, %rdx, %rdx
	jmp	.L126
.L148:
	movzbl	-1(%r15,%r12), %eax
	movl	$8, %edx
	subq	%r12, %rdx
	salq	$3, %rdx
	shlx	%rdx, %rax, %rax
	movbew	(%r15), %dx
	salq	$48, %rdx
	orq	%rdx, %rax
.L123:
	leaq	0(,%rcx,8), %rdx
	shlx	%rdx, %rax, %rax
	jmp	.L120
.L149:
	movzbl	-4(%r14,%rbp), %edx
	movzbl	-3(%r14,%rbp), %r9d
	movbel	(%r14), %edi
	salq	$8, %rdx
	orq	%r9, %rdx
	movzbl	-2(%r14,%rbp), %r9d
	salq	$8, %rdx
	salq	$32, %rdi
	orq	%rdx, %r9
	movzbl	-1(%r14,%rbp), %edx
	salq	$8, %r9
	orq	%r9, %rdx
	movl	$8, %r9d
	subq	%rbp, %r9
	salq	$3, %r9
	shlx	%r9, %rdx, %rdx
	orq	%rdi, %rdx
	jmp	.L129
.L147:
	movzbl	-4(%r15,%r12), %eax
	movzbl	-3(%r15,%r12), %edi
	movbel	(%r15), %edx
	salq	$8, %rax
	orq	%rdi, %rax
	movzbl	-2(%r15,%r12), %edi
	salq	$8, %rax
	salq	$32, %rdx
	orq	%rax, %rdi
	movzbl	-1(%r15,%r12), %eax
	salq	$8, %rdi
	orq	%rdi, %rax
	movl	$8, %edi
	subq	%r12, %rdi
	salq	$3, %rdi
	shlx	%rdi, %rax, %rax
	orq	%rdx, %rax
	jmp	.L123
	.cfi_endproc
.LFE5073:
	.size	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE, .-_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	.section	.text._ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm,"axG",@progbits,_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm,comdat
	.align 2
	.p2align 4
	.weak	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm
	.type	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm, @function
_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm:
.LFB5005:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	movq	%rdi, %r11
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	movq	%rcx, %rbx
	subq	$8, %rsp
	.cfi_def_cfa_offset 64
	movq	(%rsi), %r9
	movl	$255, %ecx
	movq	(%rdi), %r12
	movq	%rdx, %rbp
	cmpq	%rcx, %r9
	cmovbe	%r9, %rcx
	cmpq	%rbx, %rdx
	jnb	.L156
	movq	%rsi, %rdi
	movq	%rdx, %rax
	xorl	%r10d, %r10d
	xorl	%edx, %edx
	xorl	%esi, %esi
	.p2align 4
	.p2align 3
.L152:
	cmpb	160(%r12,%rax), %cl
	jne	.L154
	testq	%rsi, %rsi
	movq	%rax, %r10
	cmove	%rax, %rdx
	incq	%rsi
.L154:
	incq	%rax
	cmpq	%rax, %rbx
	jne	.L152
	testq	%rsi, %rsi
	je	.L156
	cmpq	$1, %rsi
	je	.L223
	cmpq	$2, %rsi
	je	.L224
	movq	%rdi, %rsi
	movq	%rbp, %rdx
	movq	%rbx, %rcx
	movq	%r11, %rdi
	call	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE17search_candidatesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	testb	%al, %al
	jne	.L153
.L156:
	movq	$-1, %rdx
.L153:
	addq	$8, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	movq	%rdx, %rax
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4
	.p2align 3
.L224:
	.cfi_restore_state
	leaq	(%r10,%r10,4), %rax
	movq	8(%rdi), %r14
	movq	%r8, %rdi
	leaq	224(%r12,%rax,8), %rax
	movq	8(%rax), %rbp
	movq	(%rax), %r15
	leaq	(%r14,%r8), %r11
	movq	%r11, %rax
	cmpq	%rbp, %r9
	movq	%rbp, %rbx
	leaq	(%r15,%r8), %rcx
	vmovq	%r15, %xmm0
	cmovbe	%r9, %rbx
	jmp	.L174
	.p2align 4
	.p2align 3
.L226:
	movzbl	(%rax), %esi
	movzbl	1(%rax), %r13d
	movzbl	1(%rcx), %r15d
	addq	$8, %rax
	addq	$8, %rcx
	salq	$8, %rsi
	orq	%r13, %rsi
	movzbl	-6(%rax), %r13d
	salq	$8, %rsi
	orq	%r13, %rsi
	movzbl	-5(%rax), %r13d
	salq	$8, %rsi
	orq	%rsi, %r13
	movzbl	-4(%rax), %esi
	salq	$8, %r13
	orq	%r13, %rsi
	movzbl	-3(%rax), %r13d
	salq	$8, %rsi
	orq	%rsi, %r13
	movzbl	-2(%rax), %esi
	salq	$8, %r13
	orq	%r13, %rsi
	movzbl	-1(%rax), %r13d
	salq	$8, %rsi
	orq	%rsi, %r13
	movzbl	-8(%rcx), %esi
	salq	$8, %rsi
	orq	%r15, %rsi
	salq	$8, %rsi
	movq	%rsi, %r15
	movzbl	-6(%rcx), %esi
	orq	%r15, %rsi
	salq	$8, %rsi
	movq	%rsi, %r15
	movzbl	-5(%rcx), %esi
	orq	%r15, %rsi
	salq	$8, %rsi
	movq	%rsi, %r15
	movzbl	-4(%rcx), %esi
	orq	%r15, %rsi
	salq	$8, %rsi
	movq	%rsi, %r15
	movzbl	-3(%rcx), %esi
	orq	%r15, %rsi
	salq	$8, %rsi
	movq	%rsi, %r15
	movzbl	-2(%rcx), %esi
	orq	%r15, %rsi
	movzbl	-1(%rcx), %r15d
	salq	$8, %rsi
	orq	%r15, %rsi
	cmpq	%r13, %rsi
	jne	.L225
.L174:
	movq	%rdi, %rsi
	addq	$8, %rdi
	cmpq	%rdi, %rbx
	jnb	.L226
	vmovq	%xmm0, %r15
	cmpq	%rbx, %rsi
	jnb	.L178
	cmpq	%r9, %rsi
	jnb	.L227
	movq	%r9, %rax
	subq	%rsi, %rax
	cmpq	$7, %rax
	jbe	.L181
	movzbl	(%r14,%rsi), %eax
	movzbl	1(%r14,%rsi), %ecx
	salq	$8, %rax
	orq	%rcx, %rax
	movzbl	2(%r14,%rsi), %ecx
	salq	$8, %rax
	orq	%rax, %rcx
	movzbl	3(%r14,%rsi), %eax
	salq	$8, %rcx
	orq	%rcx, %rax
	movzbl	4(%r14,%rsi), %ecx
	salq	$8, %rax
	orq	%rax, %rcx
	movzbl	5(%r14,%rsi), %eax
	salq	$8, %rcx
	orq	%rcx, %rax
	movzbl	6(%r14,%rsi), %ecx
	salq	$8, %rax
	orq	%rax, %rcx
	movzbl	7(%r14,%rsi), %eax
	salq	$8, %rcx
	orq	%rcx, %rax
.L182:
	cmpq	%rbp, %rsi
	jnb	.L156
.L180:
	movq	%rbp, %rcx
	subq	%rsi, %rcx
	cmpq	$7, %rcx
	jbe	.L187
	movzbl	(%r15,%rsi), %ecx
	movzbl	1(%r15,%rsi), %edi
	salq	$8, %rcx
	orq	%rdi, %rcx
	movzbl	2(%r15,%rsi), %edi
	salq	$8, %rcx
	orq	%rcx, %rdi
	movzbl	3(%r15,%rsi), %ecx
	salq	$8, %rdi
	orq	%rdi, %rcx
	movzbl	4(%r15,%rsi), %edi
	salq	$8, %rcx
	orq	%rcx, %rdi
	movzbl	5(%r15,%rsi), %ecx
	salq	$8, %rdi
	orq	%rdi, %rcx
	movzbl	6(%r15,%rsi), %edi
	salq	$8, %rcx
	orq	%rcx, %rdi
	movzbl	7(%r15,%rsi), %ecx
	salq	$8, %rdi
	orq	%rdi, %rcx
.L188:
	cmpq	%rax, %rcx
	je	.L178
	cmpq	%rcx, %rax
	jb	.L175
	jmp	.L156
	.p2align 4
	.p2align 3
.L223:
	leaq	(%rdx,%rdx,4), %rax
	leaq	224(%r12,%rax,8), %rax
	movq	8(%rax), %r10
	cmpq	%r10, %r9
	jne	.L156
	movq	(%rax), %r11
	movq	8(%rdi), %rdi
	leaq	(%r11,%r8), %rcx
	leaq	(%rdi,%r8), %rsi
	jmp	.L159
	.p2align 4
	.p2align 3
.L228:
	movzbl	(%rsi), %eax
	movzbl	1(%rsi), %ebp
	movzbl	1(%rcx), %r13d
	movq	%rcx, %r12
	movzbl	7(%r12), %r12d
	movq	%rsi, %rbx
	addq	$8, %rcx
	addq	$8, %rsi
	salq	$8, %rax
	orq	%rbp, %rax
	movzbl	-6(%rsi), %ebp
	salq	$8, %rax
	orq	%rax, %rbp
	movzbl	-5(%rsi), %eax
	salq	$8, %rbp
	orq	%rbp, %rax
	movzbl	-4(%rsi), %ebp
	salq	$8, %rax
	orq	%rax, %rbp
	movzbl	-3(%rsi), %eax
	salq	$8, %rbp
	orq	%rbp, %rax
	movzbl	-2(%rsi), %ebp
	salq	$8, %rax
	orq	%rax, %rbp
	movzbl	-8(%rcx), %eax
	salq	$8, %rbp
	salq	$8, %rax
	orq	%r13, %rax
	movzbl	-6(%rcx), %r13d
	salq	$8, %rax
	orq	%r13, %rax
	movzbl	-5(%rcx), %r13d
	salq	$8, %rax
	orq	%rax, %r13
	movzbl	-4(%rcx), %eax
	salq	$8, %r13
	orq	%r13, %rax
	movzbl	-3(%rcx), %r13d
	salq	$8, %rax
	orq	%rax, %r13
	movzbl	-2(%rcx), %eax
	salq	$8, %r13
	orq	%r13, %rax
	salq	$8, %rax
	orq	%rax, %r12
	movzbl	7(%rbx), %eax
	orq	%rbp, %rax
	cmpq	%rax, %r12
	jne	.L156
.L159:
	movq	%r8, %rax
	addq	$8, %r8
	cmpq	%r8, %r9
	jnb	.L228
	cmpq	%r9, %rax
	jnb	.L153
	movq	%r9, %rcx
	subq	%rax, %rcx
	cmpq	$7, %rcx
	jbe	.L160
	movzbl	(%rdi,%rax), %esi
	movzbl	1(%rdi,%rax), %ecx
	salq	$8, %rsi
	orq	%rsi, %rcx
	movzbl	2(%rdi,%rax), %esi
	salq	$8, %rcx
	orq	%rcx, %rsi
	movzbl	3(%rdi,%rax), %ecx
	salq	$8, %rsi
	orq	%rsi, %rcx
	movzbl	4(%rdi,%rax), %esi
	salq	$8, %rcx
	orq	%rcx, %rsi
	movzbl	5(%rdi,%rax), %ecx
	salq	$8, %rsi
	orq	%rsi, %rcx
	movzbl	6(%rdi,%rax), %esi
	salq	$8, %rcx
	orq	%rcx, %rsi
	movzbl	7(%rdi,%rax), %ecx
	salq	$8, %rsi
	orq	%rsi, %rcx
	movq	%r10, %rsi
	subq	%rax, %rsi
	cmpq	$7, %rsi
	ja	.L161
	leaq	0(,%rax,8), %rsi
	cmpq	$7, %r10
	jbe	.L168
.L164:
	movzbl	-8(%r11,%r10), %esi
	movzbl	-7(%r11,%r10), %edi
	subq	%r10, %rax
	leaq	64(,%rax,8), %rax
	salq	$8, %rsi
	orq	%rdi, %rsi
	movzbl	-6(%r11,%r10), %edi
	salq	$8, %rsi
	orq	%rsi, %rdi
	movzbl	-5(%r11,%r10), %esi
	salq	$8, %rdi
	orq	%rdi, %rsi
	movzbl	-4(%r11,%r10), %edi
	salq	$8, %rsi
	orq	%rsi, %rdi
	movzbl	-3(%r11,%r10), %esi
	salq	$8, %rdi
	orq	%rdi, %rsi
	movzbl	-2(%r11,%r10), %edi
	salq	$8, %rsi
	orq	%rsi, %rdi
	movzbl	-1(%r11,%r10), %esi
	salq	$8, %rdi
	orq	%rdi, %rsi
	shlx	%rax, %rsi, %rax
.L169:
	cmpq	%rcx, %rax
	jne	.L156
	jmp	.L153
	.p2align 4
	.p2align 3
.L225:
	cmpq	%rsi, %r13
	jnb	.L156
.L175:
	leaq	(%rdx,%rdx,4), %rax
	leaq	224(%r12,%rax,8), %rax
	movq	8(%rax), %rsi
	cmpq	%rsi, %r9
	jne	.L156
	movq	(%rax), %rdi
	leaq	(%rdi,%r8), %rax
	jmp	.L194
	.p2align 4
	.p2align 3
.L229:
	movzbl	(%r11), %ecx
	movzbl	1(%r11), %ebx
	movzbl	1(%rax), %r12d
	movq	%rax, %rbp
	movzbl	7(%rbp), %ebp
	movq	%r11, %r10
	addq	$8, %rax
	addq	$8, %r11
	salq	$8, %rcx
	orq	%rbx, %rcx
	movzbl	-6(%r11), %ebx
	salq	$8, %rcx
	orq	%rcx, %rbx
	movzbl	-5(%r11), %ecx
	salq	$8, %rbx
	orq	%rbx, %rcx
	movzbl	-4(%r11), %ebx
	salq	$8, %rcx
	orq	%rcx, %rbx
	movzbl	-3(%r11), %ecx
	salq	$8, %rbx
	orq	%rbx, %rcx
	movzbl	-2(%r11), %ebx
	salq	$8, %rcx
	orq	%rcx, %rbx
	movzbl	-8(%rax), %ecx
	salq	$8, %rbx
	salq	$8, %rcx
	orq	%r12, %rcx
	movzbl	-6(%rax), %r12d
	salq	$8, %rcx
	orq	%r12, %rcx
	movzbl	-5(%rax), %r12d
	salq	$8, %rcx
	orq	%rcx, %r12
	movzbl	-4(%rax), %ecx
	salq	$8, %r12
	orq	%r12, %rcx
	movzbl	-3(%rax), %r12d
	salq	$8, %rcx
	orq	%rcx, %r12
	movzbl	-2(%rax), %ecx
	salq	$8, %r12
	orq	%r12, %rcx
	salq	$8, %rcx
	orq	%rcx, %rbp
	movzbl	7(%r10), %ecx
	orq	%rbx, %rcx
	cmpq	%rcx, %rbp
	jne	.L156
.L194:
	movq	%r8, %rcx
	addq	$8, %r8
	cmpq	%r8, %r9
	jnb	.L229
	cmpq	%r9, %rcx
	jnb	.L153
	movq	%r9, %rax
	subq	%rcx, %rax
	cmpq	$7, %rax
	jbe	.L195
	movzbl	(%r14,%rcx), %eax
	movzbl	1(%r14,%rcx), %r8d
	salq	$8, %rax
	orq	%r8, %rax
	movzbl	2(%r14,%rcx), %r8d
	salq	$8, %rax
	orq	%rax, %r8
	movzbl	3(%r14,%rcx), %eax
	salq	$8, %r8
	orq	%r8, %rax
	movzbl	4(%r14,%rcx), %r8d
	salq	$8, %rax
	orq	%rax, %r8
	movzbl	5(%r14,%rcx), %eax
	salq	$8, %r8
	orq	%r8, %rax
	movzbl	6(%r14,%rcx), %r8d
	salq	$8, %rax
	orq	%rax, %r8
	movzbl	7(%r14,%rcx), %eax
	salq	$8, %r8
	orq	%r8, %rax
	movq	%rsi, %r8
	subq	%rcx, %r8
	cmpq	$7, %r8
	ja	.L196
	leaq	0(,%rcx,8), %r8
	cmpq	$7, %rsi
	jbe	.L203
.L199:
	movzbl	-8(%rdi,%rsi), %r8d
	movzbl	-7(%rdi,%rsi), %r9d
	subq	%rsi, %rcx
	leaq	64(,%rcx,8), %rcx
	salq	$8, %r8
	orq	%r9, %r8
	movzbl	-6(%rdi,%rsi), %r9d
	salq	$8, %r8
	orq	%r9, %r8
	movzbl	-5(%rdi,%rsi), %r9d
	salq	$8, %r8
	orq	%r8, %r9
	movzbl	-4(%rdi,%rsi), %r8d
	salq	$8, %r9
	orq	%r9, %r8
	movzbl	-3(%rdi,%rsi), %r9d
	salq	$8, %r8
	orq	%r8, %r9
	movzbl	-2(%rdi,%rsi), %r8d
	movzbl	-1(%rdi,%rsi), %edi
	salq	$8, %r9
	orq	%r9, %r8
	salq	$8, %r8
	orq	%r8, %rdi
	shlx	%rcx, %rdi, %rcx
.L204:
	cmpq	%rax, %rcx
	jne	.L156
	jmp	.L153
.L227:
	xorl	%eax, %eax
	cmpq	%rbp, %rsi
	jb	.L180
.L178:
	cmpq	%rbp, %r9
	je	.L210
	jb	.L175
	jmp	.L156
.L187:
	cmpq	$7, %rbp
	jbe	.L189
	movzbl	-8(%r15,%rbp), %ecx
	movzbl	-7(%r15,%rbp), %edi
	subq	%rbp, %rsi
	leaq	64(,%rsi,8), %rsi
	salq	$8, %rcx
	orq	%rdi, %rcx
	movzbl	-6(%r15,%rbp), %edi
	salq	$8, %rcx
	orq	%rcx, %rdi
	movzbl	-5(%r15,%rbp), %ecx
	salq	$8, %rdi
	orq	%rdi, %rcx
	movzbl	-4(%r15,%rbp), %edi
	salq	$8, %rcx
	orq	%rcx, %rdi
	movzbl	-3(%r15,%rbp), %ecx
	salq	$8, %rdi
	orq	%rdi, %rcx
	movzbl	-2(%r15,%rbp), %edi
	salq	$8, %rcx
	orq	%rcx, %rdi
	movzbl	-1(%r15,%rbp), %ecx
	salq	$8, %rdi
	orq	%rdi, %rcx
	shlx	%rsi, %rcx, %rcx
	jmp	.L188
.L181:
	cmpq	$7, %r9
	jbe	.L183
	movzbl	-8(%r14,%r9), %eax
	movzbl	-7(%r14,%r9), %ecx
	salq	$8, %rax
	orq	%rcx, %rax
	movzbl	-6(%r14,%r9), %ecx
	salq	$8, %rax
	orq	%rcx, %rax
	movzbl	-5(%r14,%r9), %ecx
	salq	$8, %rax
	orq	%rax, %rcx
	movzbl	-4(%r14,%r9), %eax
	salq	$8, %rcx
	orq	%rcx, %rax
	movzbl	-3(%r14,%r9), %ecx
	salq	$8, %rax
	orq	%rax, %rcx
	movzbl	-2(%r14,%r9), %eax
	salq	$8, %rcx
	orq	%rcx, %rax
	movzbl	-1(%r14,%r9), %ecx
	salq	$8, %rax
	orq	%rcx, %rax
	movq	%rsi, %rcx
	subq	%r9, %rcx
	leaq	64(,%rcx,8), %rcx
	shlx	%rcx, %rax, %rax
	jmp	.L182
.L210:
	movq	%r10, %rdx
	jmp	.L153
.L189:
	cmpq	$3, %rbp
	ja	.L230
	cmpq	$1, %rbp
	jne	.L231
	movzbl	(%r15), %ecx
	salq	$56, %rcx
.L191:
	salq	$3, %rsi
	shlx	%rsi, %rcx, %rcx
	jmp	.L188
.L183:
	cmpq	$3, %r9
	ja	.L232
	cmpq	$1, %r9
	jne	.L233
	movzbl	(%r14), %eax
	salq	$56, %rax
.L185:
	leaq	0(,%rsi,8), %rcx
	shlx	%rcx, %rax, %rax
	jmp	.L182
.L160:
	cmpq	$7, %r9
	jbe	.L163
	movzbl	-8(%rdi,%r9), %ecx
	movzbl	-7(%rdi,%r9), %esi
	salq	$8, %rcx
	orq	%rsi, %rcx
	movzbl	-6(%rdi,%r9), %esi
	salq	$8, %rcx
	orq	%rsi, %rcx
	movzbl	-5(%rdi,%r9), %esi
	salq	$8, %rcx
	orq	%rcx, %rsi
	movzbl	-4(%rdi,%r9), %ecx
	salq	$8, %rsi
	orq	%rsi, %rcx
	movzbl	-3(%rdi,%r9), %esi
	salq	$8, %rcx
	orq	%rcx, %rsi
	movzbl	-2(%rdi,%r9), %ecx
	salq	$8, %rsi
	orq	%rsi, %rcx
	movzbl	-1(%rdi,%r9), %esi
	salq	$8, %rcx
	orq	%rsi, %rcx
	movq	%rax, %rsi
	subq	%r9, %rsi
	leaq	64(,%rsi,8), %rsi
	shlx	%rsi, %rcx, %rcx
	movq	%r10, %rsi
	subq	%rax, %rsi
	cmpq	$7, %rsi
	jbe	.L164
.L161:
	movzbl	(%r11,%rax), %esi
	movzbl	1(%r11,%rax), %edi
	salq	$8, %rsi
	orq	%rdi, %rsi
	movzbl	2(%r11,%rax), %edi
	salq	$8, %rsi
	orq	%rdi, %rsi
	movzbl	3(%r11,%rax), %edi
	salq	$8, %rsi
	orq	%rsi, %rdi
	movzbl	4(%r11,%rax), %esi
	salq	$8, %rdi
	orq	%rdi, %rsi
	movzbl	5(%r11,%rax), %edi
	salq	$8, %rsi
	orq	%rsi, %rdi
	movzbl	6(%r11,%rax), %esi
	movzbl	7(%r11,%rax), %eax
	salq	$8, %rdi
	orq	%rdi, %rsi
	salq	$8, %rsi
	orq	%rsi, %rax
	jmp	.L169
.L230:
	movzbl	(%r15), %ecx
	movzbl	1(%r15), %edi
	movzbl	-3(%r15,%rbp), %ebx
	salq	$8, %rcx
	orq	%rdi, %rcx
	movzbl	2(%r15), %edi
	salq	$8, %rcx
	orq	%rcx, %rdi
	movzbl	-4(%r15,%rbp), %ecx
	salq	$8, %rdi
	salq	$8, %rcx
	orq	%rbx, %rcx
	movzbl	-2(%r15,%rbp), %ebx
	salq	$8, %rcx
	orq	%rcx, %rbx
	movzbl	-1(%r15,%rbp), %ecx
	salq	$8, %rbx
	orq	%rbx, %rcx
	movl	$8, %ebx
	subq	%rbp, %rbx
	salq	$3, %rbx
	shlx	%rbx, %rcx, %rcx
	movzbl	3(%r15), %ebx
	orq	%rbx, %rdi
	salq	$32, %rdi
	orq	%rdi, %rcx
	jmp	.L191
.L232:
	movzbl	(%r14), %eax
	movzbl	1(%r14), %ecx
	movzbl	-3(%r14,%r9), %edi
	salq	$8, %rax
	orq	%rcx, %rax
	movzbl	2(%r14), %ecx
	salq	$8, %rax
	orq	%rax, %rcx
	movzbl	-4(%r14,%r9), %eax
	salq	$8, %rcx
	salq	$8, %rax
	orq	%rdi, %rax
	movzbl	-2(%r14,%r9), %edi
	salq	$8, %rax
	orq	%rax, %rdi
	movzbl	-1(%r14,%r9), %eax
	salq	$8, %rdi
	orq	%rdi, %rax
	movl	$8, %edi
	subq	%r9, %rdi
	salq	$3, %rdi
	shlx	%rdi, %rax, %rax
	movzbl	3(%r14), %edi
	orq	%rdi, %rcx
	salq	$32, %rcx
	orq	%rcx, %rax
	jmp	.L185
.L233:
	movzbl	-1(%r14,%r9), %eax
	movl	$8, %ecx
	subq	%r9, %rcx
	salq	$3, %rcx
	shlx	%rcx, %rax, %rax
	movbew	(%r14), %cx
	salq	$48, %rcx
	orq	%rcx, %rax
	jmp	.L185
.L231:
	movzbl	-1(%r15,%rbp), %ecx
	movl	$8, %edi
	subq	%rbp, %rdi
	salq	$3, %rdi
	shlx	%rdi, %rcx, %rcx
	movbew	(%r15), %di
	salq	$48, %rdi
	orq	%rdi, %rcx
	jmp	.L191
.L163:
	cmpq	$3, %r9
	ja	.L234
	cmpq	$1, %r9
	jne	.L235
	movzbl	(%rdi), %ecx
	salq	$56, %rcx
.L166:
	movq	%r10, %rdi
	leaq	0(,%rax,8), %rsi
	subq	%rax, %rdi
	shlx	%rsi, %rcx, %rcx
	cmpq	$7, %rdi
	ja	.L161
.L168:
	cmpq	$3, %r10
	ja	.L236
	cmpq	$1, %r10
	jne	.L237
	movzbl	(%r11), %eax
	salq	$56, %rax
.L171:
	shlx	%rsi, %rax, %rax
	jmp	.L169
.L195:
	cmpq	$7, %r9
	jbe	.L198
	movzbl	-8(%r14,%r9), %eax
	movzbl	-7(%r14,%r9), %r8d
	salq	$8, %rax
	orq	%r8, %rax
	movzbl	-6(%r14,%r9), %r8d
	salq	$8, %rax
	orq	%r8, %rax
	movzbl	-5(%r14,%r9), %r8d
	salq	$8, %rax
	orq	%rax, %r8
	movzbl	-4(%r14,%r9), %eax
	salq	$8, %r8
	orq	%r8, %rax
	movzbl	-3(%r14,%r9), %r8d
	salq	$8, %rax
	orq	%rax, %r8
	movzbl	-2(%r14,%r9), %eax
	salq	$8, %r8
	orq	%r8, %rax
	movzbl	-1(%r14,%r9), %r8d
	salq	$8, %rax
	orq	%r8, %rax
	movq	%rcx, %r8
	subq	%r9, %r8
	leaq	64(,%r8,8), %r8
	shlx	%r8, %rax, %rax
	movq	%rsi, %r8
	subq	%rcx, %r8
	cmpq	$7, %r8
	jbe	.L199
.L196:
	movzbl	(%rdi,%rcx), %esi
	movzbl	1(%rdi,%rcx), %r8d
	salq	$8, %rsi
	orq	%rsi, %r8
	movzbl	2(%rdi,%rcx), %esi
	salq	$8, %r8
	orq	%r8, %rsi
	movzbl	3(%rdi,%rcx), %r8d
	salq	$8, %rsi
	orq	%rsi, %r8
	movzbl	4(%rdi,%rcx), %esi
	salq	$8, %r8
	orq	%r8, %rsi
	movzbl	5(%rdi,%rcx), %r8d
	salq	$8, %rsi
	orq	%rsi, %r8
	movzbl	6(%rdi,%rcx), %esi
	movzbl	7(%rdi,%rcx), %ecx
	salq	$8, %r8
	orq	%r8, %rsi
	salq	$8, %rsi
	orq	%rsi, %rcx
	jmp	.L204
.L198:
	cmpq	$3, %r9
	ja	.L238
	cmpq	$1, %r9
	jne	.L239
	movzbl	(%r14), %eax
	salq	$56, %rax
.L201:
	movq	%rsi, %r9
	leaq	0(,%rcx,8), %r8
	subq	%rcx, %r9
	shlx	%r8, %rax, %rax
	cmpq	$7, %r9
	ja	.L196
.L203:
	cmpq	$3, %rsi
	ja	.L240
	cmpq	$1, %rsi
	jne	.L241
	movzbl	(%rdi), %ecx
	salq	$56, %rcx
.L206:
	shlx	%r8, %rcx, %rcx
	jmp	.L204
.L241:
	movzbl	-1(%rdi,%rsi), %ecx
	movl	$8, %r9d
	subq	%rsi, %r9
	leaq	0(,%r9,8), %rsi
	shlx	%rsi, %rcx, %rcx
	movbew	(%rdi), %si
	salq	$48, %rsi
	orq	%rsi, %rcx
	jmp	.L206
.L240:
	movzbl	(%rdi), %ecx
	movzbl	1(%rdi), %r9d
	movzbl	-3(%rdi,%rsi), %r10d
	salq	$8, %rcx
	orq	%r9, %rcx
	movzbl	2(%rdi), %r9d
	salq	$8, %rcx
	orq	%rcx, %r9
	movzbl	-4(%rdi,%rsi), %ecx
	salq	$8, %r9
	salq	$8, %rcx
	orq	%r10, %rcx
	movzbl	-2(%rdi,%rsi), %r10d
	salq	$8, %rcx
	orq	%rcx, %r10
	movzbl	-1(%rdi,%rsi), %ecx
	salq	$8, %r10
	orq	%r10, %rcx
	movl	$8, %r10d
	subq	%rsi, %r10
	leaq	0(,%r10,8), %rsi
	shlx	%rsi, %rcx, %rcx
	movzbl	3(%rdi), %esi
	orq	%r9, %rsi
	salq	$32, %rsi
	orq	%rsi, %rcx
	jmp	.L206
.L239:
	movzbl	-1(%r14,%r9), %eax
	movl	$8, %r8d
	subq	%r9, %r8
	salq	$3, %r8
	shlx	%r8, %rax, %rax
	movbew	(%r14), %r8w
	salq	$48, %r8
	orq	%r8, %rax
	jmp	.L201
.L238:
	movzbl	(%r14), %eax
	movzbl	1(%r14), %r8d
	movzbl	2(%r14), %r10d
	salq	$8, %rax
	orq	%r8, %rax
	movzbl	-3(%r14,%r9), %r8d
	salq	$8, %rax
	orq	%rax, %r10
	movzbl	-4(%r14,%r9), %eax
	salq	$8, %r10
	salq	$8, %rax
	orq	%r8, %rax
	movzbl	-2(%r14,%r9), %r8d
	salq	$8, %rax
	orq	%rax, %r8
	movzbl	-1(%r14,%r9), %eax
	salq	$8, %r8
	orq	%r8, %rax
	movl	$8, %r8d
	subq	%r9, %r8
	salq	$3, %r8
	shlx	%r8, %rax, %rax
	movzbl	3(%r14), %r8d
	orq	%r10, %r8
	salq	$32, %r8
	orq	%r8, %rax
	jmp	.L201
.L235:
	movzbl	-1(%rdi,%r9), %ecx
	movl	$8, %esi
	subq	%r9, %rsi
	salq	$3, %rsi
	shlx	%rsi, %rcx, %rcx
	movbew	(%rdi), %si
	salq	$48, %rsi
	orq	%rsi, %rcx
	jmp	.L166
.L234:
	movzbl	(%rdi), %ecx
	movzbl	1(%rdi), %esi
	movzbl	2(%rdi), %r8d
	salq	$8, %rcx
	orq	%rsi, %rcx
	movzbl	-3(%rdi,%r9), %esi
	salq	$8, %rcx
	orq	%rcx, %r8
	movzbl	-4(%rdi,%r9), %ecx
	salq	$8, %r8
	salq	$8, %rcx
	orq	%rsi, %rcx
	movzbl	-2(%rdi,%r9), %esi
	salq	$8, %rcx
	orq	%rcx, %rsi
	movzbl	-1(%rdi,%r9), %ecx
	salq	$8, %rsi
	orq	%rsi, %rcx
	movl	$8, %esi
	subq	%r9, %rsi
	salq	$3, %rsi
	shlx	%rsi, %rcx, %rcx
	movzbl	3(%rdi), %esi
	orq	%r8, %rsi
	salq	$32, %rsi
	orq	%rsi, %rcx
	jmp	.L166
.L237:
	movzbl	-1(%r11,%r10), %eax
	movl	$8, %edi
	subq	%r10, %rdi
	salq	$3, %rdi
	shlx	%rdi, %rax, %rax
	movbew	(%r11), %di
	salq	$48, %rdi
	orq	%rdi, %rax
	jmp	.L171
.L236:
	movzbl	(%r11), %eax
	movzbl	1(%r11), %edi
	movzbl	2(%r11), %r8d
	salq	$8, %rax
	orq	%rdi, %rax
	movzbl	-3(%r11,%r10), %edi
	salq	$8, %rax
	orq	%rax, %r8
	movzbl	-4(%r11,%r10), %eax
	salq	$8, %r8
	salq	$8, %rax
	orq	%rdi, %rax
	movzbl	-2(%r11,%r10), %edi
	salq	$8, %rax
	orq	%rax, %rdi
	movzbl	-1(%r11,%r10), %eax
	salq	$8, %rdi
	orq	%rdi, %rax
	movl	$8, %edi
	subq	%r10, %rdi
	salq	$3, %rdi
	shlx	%rdi, %rax, %rax
	movzbl	3(%r11), %edi
	orq	%r8, %rdi
	salq	$32, %rdi
	orq	%rdi, %rax
	jmp	.L171
	.cfi_endproc
.LFE5005:
	.size	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm, .-_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm
	.section	.text._ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E,"axG",@progbits,_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E,comdat
	.align 2
	.p2align 4
	.weak	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E
	.type	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E, @function
_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E:
.LFB4779:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$40, %rsp
	.cfi_def_cfa_offset 96
	movq	(%rdi), %rbx
	movq	%fs:40, %rax
	movq	%rax, 24(%rsp)
	xorl	%eax, %eax
	testq	%rbx, %rbx
	je	.L266
	movq	%rbx, %rbp
	movq	%rsi, %r14
	andq	$-2, %rbp
	movzbl	1024(%rbp), %r12d
	testq	%r12, %r12
	je	.L244
	movq	(%rsi), %r13
	cmpq	%r13, %r12
	movq	%r13, %rdx
	cmovbe	%r12, %rdx
	testq	%rdx, %rdx
	je	.L245
	movq	8(%r14), %rdi
	leaq	1025(%rbp), %rsi
	movq	%rcx, 8(%rsp)
	call	memcmp@PLT
	movq	8(%rsp), %rcx
	testl	%eax, %eax
	jne	.L266
.L245:
	cmpq	%r12, %r13
	jb	.L266
.L244:
	movq	(%r14), %r13
	movq	8(%r14), %r15
	testb	$1, %bl
	jne	.L246
	movl	$8, %r12d
	movl	$-2147483648, %eax
	vmovdqa	.LC3(%rip), %xmm6
	vpxor	%xmm5, %xmm5, %xmm5
	subq	%r13, %r12
	vpbroadcastd	%eax, %xmm2
	leaq	16(%rsp), %rbp
	jmp	.L247
	.p2align 4
	.p2align 3
.L321:
	movzbl	(%r15,%rax), %edx
	movzbl	1(%r15,%rax), %esi
	salq	$8, %rdx
	orq	%rsi, %rdx
	movzbl	2(%r15,%rax), %esi
	salq	$8, %rdx
	orq	%rdx, %rsi
	movzbl	3(%r15,%rax), %edx
	salq	$8, %rsi
	orl	%esi, %edx
.L249:
	vmovdqu	8(%rbx), %xmm3
	vmovdqu	24(%rbx), %xmm4
	vpbroadcastd	%edx, %xmm0
	movzwl	(%rbx), %edi
	vpsubd	%xmm2, %xmm0, %xmm1
	vpsubd	%xmm2, %xmm3, %xmm7
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpsubd	%xmm2, %xmm4, %xmm8
	vpcmpeqd	%xmm4, %xmm0, %xmm4
	vpcmpgtd	%xmm8, %xmm1, %xmm8
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	40(%rbx), %xmm3
	vpcmpgtd	%xmm7, %xmm1, %xmm7
	vpaddd	%xmm8, %xmm7, %xmm7
	vpsubd	%xmm2, %xmm3, %xmm8
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	56(%rbx), %xmm3
	vpcmpgtd	%xmm8, %xmm1, %xmm8
	vpaddd	%xmm7, %xmm8, %xmm8
	vpsubd	%xmm2, %xmm3, %xmm7
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	72(%rbx), %xmm3
	vpcmpgtd	%xmm7, %xmm1, %xmm7
	vpaddd	%xmm8, %xmm7, %xmm7
	vpsubd	%xmm2, %xmm3, %xmm8
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	88(%rbx), %xmm3
	vpcmpgtd	%xmm8, %xmm1, %xmm8
	vpaddd	%xmm7, %xmm8, %xmm8
	vpsubd	%xmm2, %xmm3, %xmm7
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	104(%rbx), %xmm3
	vpcmpgtd	%xmm7, %xmm1, %xmm7
	vpaddd	%xmm8, %xmm7, %xmm7
	vpsubd	%xmm2, %xmm3, %xmm8
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	120(%rbx), %xmm3
	vpcmpgtd	%xmm8, %xmm1, %xmm8
	vpaddd	%xmm7, %xmm8, %xmm8
	vpsubd	%xmm2, %xmm3, %xmm7
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	136(%rbx), %xmm3
	vpcmpgtd	%xmm7, %xmm1, %xmm7
	vpaddd	%xmm8, %xmm7, %xmm7
	vpsubd	%xmm2, %xmm3, %xmm8
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm4
	vmovdqu	152(%rbx), %xmm3
	vpcmpgtd	%xmm8, %xmm1, %xmm8
	vpaddd	%xmm7, %xmm8, %xmm8
	vpsubd	%xmm2, %xmm3, %xmm7
	vpcmpeqd	%xmm3, %xmm0, %xmm3
	vpaddd	%xmm4, %xmm3, %xmm3
	vmovdqu	156(%rbx), %xmm4
	vpcmpgtd	%xmm7, %xmm1, %xmm7
	vpaddd	%xmm8, %xmm7, %xmm7
	vpsubd	%xmm2, %xmm4, %xmm8
	vpcmpeqd	%xmm4, %xmm0, %xmm0
	vpcmpgtd	%xmm8, %xmm1, %xmm1
	vpand	%xmm6, %xmm0, %xmm0
	vpand	%xmm6, %xmm1, %xmm1
	vpaddd	%xmm3, %xmm0, %xmm0
	vpaddd	%xmm7, %xmm1, %xmm1
	vpsubd	%xmm0, %xmm5, %xmm0
	vpsubd	%xmm1, %xmm5, %xmm1
	vpshufd	$85, %xmm1, %xmm4
	vpaddd	%xmm4, %xmm1, %xmm3
	vmovd	%xmm3, %edx
	vpshufd	$170, %xmm1, %xmm3
	vpshufd	$255, %xmm1, %xmm1
	vpaddd	%xmm1, %xmm3, %xmm1
	vmovd	%xmm1, %eax
	vpshufd	$85, %xmm0, %xmm3
	vpaddd	%xmm3, %xmm0, %xmm1
	addl	%edx, %eax
	vmovd	%xmm1, %esi
	vpshufd	$170, %xmm0, %xmm1
	vpshufd	$255, %xmm0, %xmm0
	movl	%eax, %eax
	vpaddd	%xmm0, %xmm1, %xmm0
	cmpq	%rdi, %rax
	vmovd	%xmm0, %edx
	cmova	%rdi, %rax
	addl	%esi, %edx
	movl	%edx, %edx
	vmovq	%rax, %xmm4
	addq	%rax, %rdx
	cmpq	%rdi, %rdx
	cmova	%rdi, %rdx
	xorl	%esi, %esi
	vpinsrq	$1, %rdx, %xmm4, %xmm0
	cmpq	%rdx, %rax
	je	.L255
	movq	%r14, %rsi
	vmovq	%xmm0, %rdx
	movq	%rbp, %rdi
	vpextrq	$1, %xmm0, %rcx
	call	_ZNK9stx_btree6detail12InternalNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE11search_tiesERKSt17basic_string_viewIcS6_ENS0_10EqualRangeE
	vmovdqa	.LC3(%rip), %xmm6
	vmovdqa	.LC2(%rip), %xmm2
	vpxor	%xmm5, %xmm5, %xmm5
	movq	%rax, %rcx
	movl	%eax, %esi
.L255:
	movb	%sil, %cl
	addq	$176, %rbx
	testb	%cl, %cl
	jne	.L319
	movq	(%rbx,%rdx,8), %rbx
	testb	$1, %bl
	jne	.L320
.L247:
	andq	$-2, %rbx
	xorl	%edx, %edx
	movzwl	4(%rbx), %eax
	movq	%rbx, 16(%rsp)
	cmpq	%r13, %rax
	jnb	.L249
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$7, %rdx
	ja	.L321
	cmpq	$7, %r13
	jbe	.L251
	movzbl	-8(%r15,%r13), %edx
	movzbl	-7(%r15,%r13), %esi
	addq	%r12, %rax
	salq	$3, %rax
	salq	$8, %rdx
	orq	%rsi, %rdx
	movzbl	-6(%r15,%r13), %esi
	salq	$8, %rdx
	orq	%rdx, %rsi
	movzbl	-5(%r15,%r13), %edx
	salq	$8, %rsi
	orq	%rsi, %rdx
	movzbl	-4(%r15,%r13), %esi
	salq	$8, %rdx
	orq	%rdx, %rsi
	movzbl	-3(%r15,%r13), %edx
	salq	$8, %rsi
	orq	%rsi, %rdx
	movzbl	-2(%r15,%r13), %esi
	salq	$8, %rdx
	orq	%rdx, %rsi
	movzbl	-1(%r15,%r13), %edx
	salq	$8, %rsi
	orq	%rsi, %rdx
	shlx	%rax, %rdx, %rdx
	shrq	$32, %rdx
	jmp	.L249
.L320:
	andq	$-2, %rbx
	movq	%rbx, %rbp
.L246:
	movzwl	4(%rbp), %eax
	xorl	%edx, %edx
	movq	%rbp, 16(%rsp)
	cmpq	%r13, %rax
	jnb	.L259
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$7, %rdx
	jbe	.L260
	movzbl	(%r15,%rax), %edx
	movzbl	1(%r15,%rax), %ecx
	salq	$8, %rdx
	orq	%rcx, %rdx
	movzbl	2(%r15,%rax), %ecx
	salq	$8, %rdx
	orq	%rdx, %rcx
	movzbl	3(%r15,%rax), %edx
	salq	$8, %rcx
	orq	%rcx, %rdx
	movzbl	4(%r15,%rax), %ecx
	salq	$8, %rdx
	orq	%rdx, %rcx
	movzbl	5(%r15,%rax), %edx
	salq	$8, %rcx
	orq	%rcx, %rdx
	movzbl	6(%r15,%rax), %ecx
	salq	$8, %rdx
	orq	%rdx, %rcx
	movzbl	7(%r15,%rax), %edx
	salq	$8, %rcx
	orq	%rcx, %rdx
.L259:
	vmovdqu	24(%rbp), %xmm7
	vmovdqu	40(%rbp), %xmm3
	vpbroadcastq	%rdx, %xmm0
	movabsq	$-9223372036854775808, %rdx
	vmovdqu	8(%rbp), %xmm6
	movzwl	0(%rbp), %eax
	vpbroadcastq	%rdx, %xmm2
	vpsubq	%xmm2, %xmm0, %xmm1
	vpsubq	%xmm2, %xmm7, %xmm9
	vpcmpeqq	%xmm7, %xmm0, %xmm7
	vmovq	%rax, %xmm5
	vpsubq	%xmm2, %xmm3, %xmm4
	vpcmpeqq	%xmm3, %xmm0, %xmm3
	vpcmpgtq	%xmm9, %xmm1, %xmm9
	vpsubq	%xmm2, %xmm6, %xmm8
	vpcmpeqq	%xmm6, %xmm0, %xmm6
	vpcmpgtq	%xmm4, %xmm1, %xmm4
	vpaddq	%xmm7, %xmm3, %xmm3
	vpaddq	%xmm6, %xmm3, %xmm3
	vmovdqu	56(%rbp), %xmm6
	vpcmpgtq	%xmm8, %xmm1, %xmm8
	vpaddq	%xmm9, %xmm4, %xmm4
	vpaddq	%xmm8, %xmm4, %xmm4
	vpsubq	%xmm2, %xmm6, %xmm7
	vpcmpgtq	%xmm7, %xmm1, %xmm7
	vpaddq	%xmm4, %xmm7, %xmm7
	vpcmpeqq	%xmm6, %xmm0, %xmm4
	vpaddq	%xmm3, %xmm4, %xmm4
	vmovdqu	72(%rbp), %xmm3
	vpsubq	%xmm2, %xmm3, %xmm6
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpaddq	%xmm4, %xmm3, %xmm4
	vmovdqu	88(%rbp), %xmm3
	vpcmpgtq	%xmm6, %xmm1, %xmm6
	vpaddq	%xmm7, %xmm6, %xmm6
	vpsubq	%xmm2, %xmm3, %xmm7
	vpcmpeqq	%xmm0, %xmm3, %xmm3
	vpaddq	%xmm4, %xmm3, %xmm4
	vmovdqu	104(%rbp), %xmm3
	vpcmpgtq	%xmm7, %xmm1, %xmm7
	vpaddq	%xmm6, %xmm7, %xmm7
	vpsubq	%xmm2, %xmm3, %xmm6
	vpcmpeqq	%xmm3, %xmm0, %xmm3
	vpaddq	%xmm4, %xmm3, %xmm4
	vmovdqu	120(%rbp), %xmm3
	vpcmpgtq	%xmm6, %xmm1, %xmm6
	vpaddq	%xmm7, %xmm6, %xmm6
	vpsubq	%xmm2, %xmm3, %xmm7
	vpcmpeqq	%xmm3, %xmm0, %xmm3
	vpaddq	%xmm4, %xmm3, %xmm4
	vmovdqu	136(%rbp), %xmm3
	vpcmpgtq	%xmm7, %xmm1, %xmm7
	vpaddq	%xmm6, %xmm7, %xmm7
	vpsubq	%xmm2, %xmm3, %xmm6
	vpcmpeqq	%xmm3, %xmm0, %xmm3
	vpcmpgtq	%xmm6, %xmm1, %xmm6
	vpaddq	%xmm4, %xmm3, %xmm3
	vmovdqa	.LC5(%rip), %xmm4
	vpaddq	%xmm7, %xmm6, %xmm6
	vmovdqu	144(%rbp), %xmm7
	vpsubq	%xmm2, %xmm7, %xmm2
	vpcmpeqq	%xmm7, %xmm0, %xmm0
	vpcmpgtq	%xmm2, %xmm1, %xmm1
	vpand	%xmm4, %xmm0, %xmm0
	vpxor	%xmm2, %xmm2, %xmm2
	vpand	%xmm4, %xmm1, %xmm1
	vpaddq	%xmm3, %xmm0, %xmm0
	vpaddq	%xmm6, %xmm1, %xmm1
	vpsubq	%xmm1, %xmm2, %xmm1
	vpsubq	%xmm0, %xmm2, %xmm2
	vpsrldq	$8, %xmm1, %xmm0
	vpaddq	%xmm1, %xmm0, %xmm1
	vpsrldq	$8, %xmm2, %xmm0
	vpaddq	%xmm2, %xmm0, %xmm0
	vpminuq	%xmm5, %xmm1, %xmm1
	vpaddq	%xmm1, %xmm0, %xmm0
	vmovq	%xmm1, %rdx
	vpminuq	%xmm5, %xmm0, %xmm0
	vmovq	%xmm0, %rcx
	movq	%rcx, %rsi
	subq	%rdx, %rsi
	je	.L266
	movzwl	4(%rbp), %eax
	leaq	8(%rax), %r8
	cmpq	$1, %rsi
	je	.L322
	leaq	16(%rsp), %rdi
	movq	%r14, %rsi
	call	_ZNK9stx_btree6detail8LeafNodeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEEE12find_by_tagsERKSt17basic_string_viewIcS6_ENS0_10EqualRangeEm
	cmpq	$-1, %rax
	jne	.L323
	.p2align 4
	.p2align 3
.L266:
	xorl	%ecx, %ecx
	xorl	%edx, %edx
.L248:
	movq	24(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L324
	addq	$40, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	movq	%rcx, %rax
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4
	.p2align 3
.L251:
	.cfi_restore_state
	cmpq	$3, %r13
	ja	.L325
	cmpq	$1, %r13
	jne	.L326
	movzbl	(%r15), %edx
	salq	$56, %rdx
	jmp	.L253
.L326:
	movzbl	-1(%r15,%r13), %edx
	movl	$8, %esi
	subq	%r13, %rsi
	salq	$3, %rsi
	shlx	%rsi, %rdx, %rdx
	movbew	(%r15), %si
	salq	$48, %rsi
	orq	%rsi, %rdx
.L253:
	salq	$3, %rax
	shlx	%rax, %rdx, %rdx
	shrq	$32, %rdx
	jmp	.L249
.L319:
	movq	8(%rbx,%rdx,8), %rax
	testb	$1, %al
	jne	.L257
	.p2align 4
	.p2align 3
.L258:
	andq	$-2, %rax
	movq	176(%rax), %rax
	testb	$1, %al
	je	.L258
.L257:
	andq	$-2, %rax
	leaq	184(%rax), %rcx
	leaq	216(%rax), %rdx
	jmp	.L248
.L325:
	movzbl	-4(%r15,%r13), %edx
	movzbl	-3(%r15,%r13), %edi
	movbel	(%r15), %esi
	salq	$8, %rdx
	orq	%rdi, %rdx
	movzbl	-2(%r15,%r13), %edi
	salq	$8, %rdx
	salq	$32, %rsi
	orq	%rdx, %rdi
	movzbl	-1(%r15,%r13), %edx
	salq	$8, %rdi
	orq	%rdi, %rdx
	movl	$8, %edi
	subq	%r13, %rdi
	salq	$3, %rdi
	shlx	%rdi, %rdx, %rdx
	orq	%rsi, %rdx
	jmp	.L253
.L323:
	leaq	(%rax,%rax,4), %rsi
	salq	$3, %rsi
	leaq	224(%rbp,%rsi), %rcx
.L289:
	leaq	256(%rbp,%rsi), %rdx
	jmp	.L248
.L260:
	cmpq	$7, %r13
	jbe	.L261
	movzbl	-8(%r15,%r13), %edx
	movzbl	-7(%r15,%r13), %ecx
	subq	%r13, %rax
	leaq	64(,%rax,8), %rax
	salq	$8, %rdx
	orq	%rcx, %rdx
	movzbl	-6(%r15,%r13), %ecx
	salq	$8, %rdx
	orq	%rdx, %rcx
	movzbl	-5(%r15,%r13), %edx
	salq	$8, %rcx
	orq	%rcx, %rdx
	movzbl	-4(%r15,%r13), %ecx
	salq	$8, %rdx
	orq	%rdx, %rcx
	movzbl	-3(%r15,%r13), %edx
	salq	$8, %rcx
	orq	%rcx, %rdx
	movzbl	-2(%r15,%r13), %ecx
	salq	$8, %rdx
	orq	%rdx, %rcx
	movzbl	-1(%r15,%r13), %edx
	salq	$8, %rcx
	orq	%rcx, %rdx
	shlx	%rax, %rdx, %rdx
	jmp	.L259
.L261:
	cmpq	$3, %r13
	ja	.L327
	cmpq	$1, %r13
	jne	.L328
	movzbl	(%r15), %edx
	salq	$56, %rdx
.L263:
	salq	$3, %rax
	shlx	%rax, %rdx, %rdx
	jmp	.L259
.L322:
	leaq	(%rdx,%rdx,4), %rsi
	salq	$3, %rsi
	leaq	224(%rbp,%rsi), %rcx
	movq	8(%rcx), %r9
	cmpq	%r13, %r9
	jne	.L266
	movq	(%rcx), %rdi
	leaq	(%r15,%rax), %r10
	leaq	(%rdi,%rax), %rdx
	jmp	.L270
.L329:
	movzbl	8(%r10), %eax
	movzbl	9(%r10), %r11d
	movzbl	9(%rdx), %r14d
	movq	%rdx, %r12
	movzbl	15(%r12), %r12d
	movq	%r10, %rbx
	addq	$8, %rdx
	addq	$8, %r10
	salq	$8, %rax
	orq	%r11, %rax
	movzbl	2(%r10), %r11d
	salq	$8, %rax
	orq	%rax, %r11
	movzbl	3(%r10), %eax
	salq	$8, %r11
	orq	%r11, %rax
	movzbl	4(%r10), %r11d
	salq	$8, %rax
	orq	%rax, %r11
	movzbl	5(%r10), %eax
	salq	$8, %r11
	orq	%r11, %rax
	movzbl	6(%r10), %r11d
	salq	$8, %rax
	orq	%rax, %r11
	movzbl	(%rdx), %eax
	salq	$8, %r11
	salq	$8, %rax
	orq	%r14, %rax
	movzbl	2(%rdx), %r14d
	salq	$8, %rax
	orq	%r14, %rax
	movzbl	3(%rdx), %r14d
	salq	$8, %rax
	orq	%rax, %r14
	movzbl	4(%rdx), %eax
	salq	$8, %r14
	orq	%r14, %rax
	movzbl	5(%rdx), %r14d
	salq	$8, %rax
	orq	%rax, %r14
	movzbl	6(%rdx), %eax
	salq	$8, %r14
	orq	%r14, %rax
	salq	$8, %rax
	orq	%rax, %r12
	movzbl	15(%rbx), %eax
	orq	%r11, %rax
	cmpq	%rax, %r12
	jne	.L266
.L270:
	movq	%r8, %rax
	addq	$8, %r8
	cmpq	%r8, %r9
	jnb	.L329
	cmpq	%r9, %rax
	jnb	.L289
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$7, %rdx
	jbe	.L272
	movzbl	(%r15,%rax), %r8d
	movzbl	1(%r15,%rax), %edx
	salq	$8, %r8
	orq	%r8, %rdx
	movzbl	2(%r15,%rax), %r8d
	salq	$8, %rdx
	orq	%rdx, %r8
	movzbl	3(%r15,%rax), %edx
	salq	$8, %r8
	orq	%r8, %rdx
	movzbl	4(%r15,%rax), %r8d
	salq	$8, %rdx
	orq	%rdx, %r8
	movzbl	5(%r15,%rax), %edx
	salq	$8, %r8
	orq	%r8, %rdx
	movzbl	6(%r15,%rax), %r8d
	salq	$8, %rdx
	orq	%rdx, %r8
	movzbl	7(%r15,%rax), %edx
	salq	$8, %r8
	orq	%r8, %rdx
	movq	%r9, %r8
	subq	%rax, %r8
	cmpq	$7, %r8
	ja	.L273
	cmpq	$7, %r9
	ja	.L276
	leaq	0(,%rax,8), %r8
.L282:
	cmpq	$3, %r9
	ja	.L330
	cmpq	$1, %r9
	jne	.L331
	movzbl	(%rdi), %eax
	salq	$56, %rax
.L287:
	shlx	%r8, %rax, %rax
.L283:
	cmpq	%rdx, %rax
	jne	.L266
	jmp	.L289
	.p2align 4
	.p2align 3
.L327:
	movzbl	(%r15), %edx
	movzbl	1(%r15), %ecx
	movzbl	2(%r15), %esi
	salq	$8, %rdx
	orq	%rcx, %rdx
	movzbl	-3(%r15,%r13), %ecx
	salq	$8, %rdx
	orq	%rdx, %rsi
	movzbl	-4(%r15,%r13), %edx
	salq	$8, %rsi
	salq	$8, %rdx
	orq	%rcx, %rdx
	movzbl	-2(%r15,%r13), %ecx
	salq	$8, %rdx
	orq	%rdx, %rcx
	movzbl	-1(%r15,%r13), %edx
	salq	$8, %rcx
	orq	%rcx, %rdx
	movl	$8, %ecx
	subq	%r13, %rcx
	salq	$3, %rcx
	shlx	%rcx, %rdx, %rdx
	movzbl	3(%r15), %ecx
	orq	%rsi, %rcx
	salq	$32, %rcx
	orq	%rcx, %rdx
	jmp	.L263
.L328:
	movzbl	-1(%r15,%r13), %edx
	movl	$8, %ecx
	subq	%r13, %rcx
	salq	$3, %rcx
	shlx	%rcx, %rdx, %rdx
	movbew	(%r15), %cx
	salq	$48, %rcx
	orq	%rcx, %rdx
	jmp	.L263
.L324:
	call	__stack_chk_fail@PLT
.L331:
	movzbl	-1(%rdi,%r9), %eax
	movbew	(%rdi), %di
	movl	$8, %r10d
	subq	%r9, %r10
	leaq	0(,%r10,8), %r9
	salq	$48, %rdi
	shlx	%r9, %rax, %rax
	orq	%rdi, %rax
	jmp	.L287
.L330:
	xorl	%eax, %eax
	xorl	%r10d, %r10d
.L285:
	movzbl	(%rdi,%rax), %r11d
	incq	%rax
	salq	$8, %r10
	orq	%r11, %r10
	cmpq	$4, %rax
	jne	.L285
	xorl	%r11d, %r11d
	xorl	%eax, %eax
	addq	%r9, %rdi
.L286:
	movzbl	-4(%rdi,%r11), %ebx
	incq	%r11
	salq	$8, %rax
	orq	%rbx, %rax
	cmpq	$4, %r11
	jne	.L286
	movl	$8, %edi
	subq	%r9, %rdi
	salq	$3, %rdi
	salq	$32, %r10
	shlx	%rdi, %rax, %rax
	orq	%r10, %rax
	jmp	.L287
.L272:
	cmpq	$7, %r13
	jbe	.L275
	movzbl	-8(%r15,%r13), %edx
	movzbl	-7(%r15,%r13), %r8d
	salq	$8, %rdx
	orq	%r8, %rdx
	movzbl	-6(%r15,%r13), %r8d
	salq	$8, %rdx
	orq	%r8, %rdx
	movzbl	-5(%r15,%r13), %r8d
	salq	$8, %rdx
	orq	%rdx, %r8
	movzbl	-4(%r15,%r13), %edx
	salq	$8, %r8
	orq	%r8, %rdx
	movzbl	-3(%r15,%r13), %r8d
	salq	$8, %rdx
	orq	%rdx, %r8
	movzbl	-2(%r15,%r13), %edx
	salq	$8, %r8
	orq	%r8, %rdx
	movzbl	-1(%r15,%r13), %r8d
	salq	$8, %rdx
	orq	%r8, %rdx
	movq	%rax, %r8
	subq	%r13, %r8
	leaq	64(,%r8,8), %r8
	shlx	%r8, %rdx, %rdx
	movq	%r9, %r8
	subq	%rax, %r8
	cmpq	$7, %r8
	ja	.L273
.L276:
	movzbl	-8(%rdi,%r9), %r8d
	movzbl	-7(%rdi,%r9), %r10d
	subq	%r9, %rax
	leaq	64(,%rax,8), %rax
	salq	$8, %r8
	orq	%r10, %r8
	movzbl	-6(%rdi,%r9), %r10d
	salq	$8, %r8
	orq	%r10, %r8
	movzbl	-5(%rdi,%r9), %r10d
	salq	$8, %r8
	orq	%r8, %r10
	movzbl	-4(%rdi,%r9), %r8d
	salq	$8, %r10
	orq	%r10, %r8
	movzbl	-3(%rdi,%r9), %r10d
	salq	$8, %r8
	orq	%r8, %r10
	movzbl	-2(%rdi,%r9), %r8d
	movzbl	-1(%rdi,%r9), %edi
	salq	$8, %r10
	orq	%r10, %r8
	salq	$8, %r8
	orq	%r8, %rdi
	shlx	%rax, %rdi, %rax
	jmp	.L283
.L275:
	cmpq	$3, %r13
	ja	.L332
	cmpq	$1, %r13
	jne	.L333
	movzbl	(%r15), %edx
	salq	$56, %rdx
.L280:
	movq	%r9, %r10
	leaq	0(,%rax,8), %r8
	subq	%rax, %r10
	shlx	%r8, %rdx, %rdx
	cmpq	$7, %r10
	jbe	.L282
.L273:
	movzbl	(%rdi,%rax), %r8d
	movzbl	1(%rdi,%rax), %r9d
	salq	$8, %r8
	orq	%r8, %r9
	movzbl	2(%rdi,%rax), %r8d
	salq	$8, %r9
	orq	%r9, %r8
	movzbl	3(%rdi,%rax), %r9d
	salq	$8, %r8
	orq	%r8, %r9
	movzbl	4(%rdi,%rax), %r8d
	salq	$8, %r9
	orq	%r9, %r8
	movzbl	5(%rdi,%rax), %r9d
	salq	$8, %r8
	orq	%r8, %r9
	movzbl	6(%rdi,%rax), %r8d
	movzbl	7(%rdi,%rax), %eax
	salq	$8, %r9
	orq	%r9, %r8
	salq	$8, %r8
	orq	%r8, %rax
	jmp	.L283
.L332:
	xorl	%edx, %edx
	xorl	%r8d, %r8d
.L278:
	movzbl	(%r15,%rdx), %r10d
	incq	%rdx
	salq	$8, %r8
	orq	%r10, %r8
	cmpq	$4, %rdx
	jne	.L278
	xorl	%r10d, %r10d
	xorl	%edx, %edx
	leaq	(%r15,%r13), %r11
.L279:
	movzbl	-4(%r11,%r10), %ebx
	incq	%r10
	salq	$8, %rdx
	orq	%rbx, %rdx
	cmpq	$4, %r10
	jne	.L279
	movl	$8, %r10d
	subq	%r13, %r10
	salq	$3, %r10
	salq	$32, %r8
	shlx	%r10, %rdx, %rdx
	orq	%r8, %rdx
	jmp	.L280
.L333:
	movzbl	-1(%r15,%r13), %edx
	movl	$8, %r8d
	subq	%r13, %r8
	salq	$3, %r8
	shlx	%r8, %rdx, %rdx
	movbew	(%r15), %r8w
	salq	$48, %r8
	orq	%r8, %rdx
	jmp	.L280
	.cfi_endproc
.LFE4779:
	.size	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E, .-_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E
	.text
	.p2align 4
	.globl	_Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E
	.type	_Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E, @function
_Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E:
.LFB4142:
	.cfi_startproc
	endbr64
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	%rsi, (%rsp)
	movq	%rsp, %rsi
	movq	%rdx, 8(%rsp)
	call	_ZNK9stx_btree6detail10UnsyncTreeINS0_9TreeShapeINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmLb0EEENS_19GlobalPageAllocatorEE4findERKSt17basic_string_viewIcS6_E
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	movq	%rdx, %rax
	ret
	.cfi_endproc
.LFE4142:
	.size	_Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E, .-_Z17probe_find_stringRKN9stx_btree6unsync9BBTreeMapINSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEmNS_19GlobalPageAllocatorEEESt17basic_string_viewIcS5_E
	.section	.rodata.cst16,"aM",@progbits,16
	.align 16
.LC0:
	.value	0
	.value	0
	.value	0
	.value	0
	.value	0
	.value	0
	.value	0
	.value	-1
	.align 16
.LC1:
	.value	0
	.value	-1
	.value	-1
	.value	-1
	.value	-1
	.value	-1
	.value	-1
	.value	-1
	.align 16
.LC2:
	.long	-2147483648
	.long	-2147483648
	.long	-2147483648
	.long	-2147483648
	.align 16
.LC3:
	.long	0
	.long	0
	.long	0
	.long	-1
	.align 16
.LC5:
	.quad	0
	.quad	-1
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
