; Function Attrs: nounwind
define void @_Z4Fan1PfS_ii(float* nocapture, float* nocapture readonly, i32, i32) local_unnamed_addr #1 {
  %5 = tail call i32 @llvm.nvvm.read.ptx.sreg.tid.x() #3, !range !5 @thread_id
  %6 = tail call i32 @llvm.nvvm.read.ptx.sreg.ctaid.x() #3, !range !6 @block_id
  %7 = tail call i32 @llvm.nvvm.read.ptx.sreg.ntid.x() #3, !range !7 @block_dim
  %8 = mul i32 %7, %6
  %9 = add i32 %8, %5
  %10 = add nsw i32 %2, -1
  %11 = sub i32 %10, %3
  %12 = icmp slt i32 %9, %11
  br i1 %12, label %13, label %30

; <label>:13:                                     ; preds = %4
  %14 = add i32 %3, 1
  %15 = add i32 %14, %9
  %16 = mul nsw i32 %15, %2
  %17 = sext i32 %16 to i64
  %18 = getelementptr inbounds float, float* %1, i64 %17
  %19 = sext i32 %3 to i64
  %20 = getelementptr inbounds float, float* %18, i64 %19
  %21 = load float, float* %20, align 4, !tbaa !8
  %22 = mul nsw i32 %3, %2
  %23 = sext i32 %22 to i64
  %24 = getelementptr inbounds float, float* %1, i64 %23
  %25 = getelementptr inbounds float, float* %24, i64 %19
  %26 = load float, float* %25, align 4, !tbaa !8
  %27 = fdiv float %21, %26
  %28 = getelementptr inbounds float, float* %0, i64 %17
  %29 = getelementptr inbounds float, float* %28, i64 %19
  store float %27, float* %29, align 4, !tbaa !8
  br label %30

; <label>:30:                                     ; preds = %13, %4
  ret void
}
