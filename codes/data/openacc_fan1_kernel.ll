; Function Attrs: nounwind
define void @Fan1_kernel0(float* nocapture readonly %a, float* nocapture %m, i32 %Size, i32 %fan1_gangs, i32 %fan1_workers, i32 %t) local_unnamed_addr #0 !kernel_arg_addr_space !1 !kernel_arg_access_qual !2 !kernel_arg_type !3 !kernel_arg_base_type !3 !kernel_arg_type_qual !4 {
    %call = tail call i32 (i32, ...) bitcast (i32 (...)* @get_global_id to i32 (i32, ...)*)(i32 0) #3
    %call1 = tail call i32 (i32, ...) bitcast (i32 (...)* @get_num_groups to i32 (i32, ...)*)(i32 0) #3
    %mul = mul nsw i32 %call1, %fan1_workers
    %cmp = icmp slt i32 %call, %mul
    br i1 %cmp, label %.preheader, label %.loopexit

    .preheader:                                       ; preds = %0
    %sub = add nsw i32 %Size, -1
    %sub2 = sub i32 %sub, %t
    %cmp338 = icmp slt i32 %call, %sub2
    br i1 %cmp338, label %.lr.ph, label %.loopexit

    .lr.ph:                                           ; preds = %.preheader
    %add4 = add i32 %t, 1
    %mul8 = mul nsw i32 %t, %Size
    %add9 = add nsw i32 %mul8, %t
    %idxprom10 = sext i32 %add9 to i64
    %arrayidx11 = getelementptr inbounds float, float* %a, i64 %idxprom10
    br label %1

    ; <label>:1:                                      ; preds = %.lr.ph, %1
    %lwpriv__i.039 = phi i32 [ %call, %.lr.ph ], [ %add20, %1 ]
    %add5 = add i32 %add4, %lwpriv__i.039
    %mul6 = mul nsw i32 %add5, %Size
    %add7 = add nsw i32 %mul6, %t
    %idxprom = sext i32 %add7 to i64
    %arrayidx = getelementptr inbounds float, float* %a, i64 %idxprom
    %2 = load float, float* %arrayidx, align 4, !tbaa !5
    %3 = load float, float* %arrayidx11, align 4, !tbaa !5
    %div = fdiv float %2, %3, !fpmath !9
    %arrayidx17 = getelementptr inbounds float, float* %m, i64 %idxprom
    store float %div, float* %arrayidx17, align 4, !tbaa !5
    %call18 = tail call i32 (i32, ...) bitcast (i32 (...)* @get_num_groups to i32 (i32, ...)*)(i32 0) #3
    %mul19 = mul nsw i32 %call18, %fan1_workers
    %add20 = add nsw i32 %mul19, %lwpriv__i.039
    %cmp3 = icmp slt i32 %add20, %sub2
    br i1 %cmp3, label %1, label %.loopexit.loopexit

    .loopexit.loopexit:                               ; preds = %1
    br label %.loopexit

    .loopexit:                                        ; preds = %.loopexit.loopexit, %.preheader, %0
    ret void
}
