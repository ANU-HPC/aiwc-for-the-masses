; Function Attrs: nounwind
define void @Fan1(float* nocapture %m_dev, float* nocapture readonly %a_dev, float* nocapture readnone %b_dev, i32 %size, i32 %t) local_unnamed_addr #0 !kernel_arg_addr_space !1 !kernel_arg_access_qual !2 !kernel_arg_type !3 !kernel_arg_base_type !3 !kernel_arg_type_qual !4 {
  %call = tail call i32 (i32, ...) bitcast (i32 (...)* @get_local_id to i32 (i32, ...)*)(i32 0) #3
  %call1 = tail call i32 (i32, ...) bitcast (i32 (...)* @get_group_id to i32 (i32, ...)*)(i32 0) #3
  %call2 = tail call i32 (i32, ...) bitcast (i32 (...)* @get_local_size to i32 (i32, ...)*)(i32 0) #3
  %mul = mul nsw i32 %call2, %call1
  %add = add nsw i32 %mul, %call
  %sub = add nsw i32 %size, -1
  %sub3 = sub i32 %sub, %t
  %cmp = icmp slt i32 %add, %sub3
  br i1 %cmp, label %1, label %4

; <label>:1:                                      ; preds = %0
  %add4 = add i32 %t, 1
  %add5 = add i32 %add4, %add
  %mul6 = mul nsw i32 %add5, %size
  %idx.ext = sext i32 %mul6 to i64
  %add.ptr = getelementptr inbounds float, float* %a_dev, i64 %idx.ext
  %idx.ext7 = sext i32 %t to i64
  %add.ptr8 = getelementptr inbounds float, float* %add.ptr, i64 %idx.ext7
  %2 = load float, float* %add.ptr8, align 4, !tbaa !5
  %mul9 = mul nsw i32 %t, %size
  %idx.ext10 = sext i32 %mul9 to i64
  %add.ptr11 = getelementptr inbounds float, float* %a_dev, i64 %idx.ext10
  %add.ptr13 = getelementptr inbounds float, float* %add.ptr11, i64 %idx.ext7
  %3 = load float, float* %add.ptr13, align 4, !tbaa !5
  %div = fdiv float %2, %3, !fpmath !9
  %add.ptr18 = getelementptr inbounds float, float* %m_dev, i64 %idx.ext
  %add.ptr20 = getelementptr inbounds float, float* %add.ptr18, i64 %idx.ext7
  store float %div, float* %add.ptr20, align 4, !tbaa !5
  br label %4

; <label>:4:                                      ; preds = %1, %0
  ret void
}
