; ModuleID = 'pg6.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

define i32 @fib(i32 %n) nounwind uwtable ssp {
  %1 = add i32 %n, 1
  %2 = zext i32 %1 to i64
  %3 = shl nuw nsw i64 %2, 2
  %4 = tail call i8* @malloc(i64 %3)
  %5 = bitcast i8* %4 to i32*
  store i32 0, i32* %5, align 4
  %6 = getelementptr inbounds i8* %4, i64 4
  %7 = bitcast i8* %6 to i32*
  store i32 1, i32* %7, align 4
  %8 = icmp ult i32 %n, 2
  br i1 %8, label %._crit_edge, label %.lr.ph

.lr.ph:                                           ; preds = %0, %._crit_edge2
  %9 = phi i32 [ %.pre, %._crit_edge2 ], [ 0, %0 ]
  %10 = phi i32 [ %11, %._crit_edge2 ], [ 1, %0 ]
  %indvars.iv = phi i64 [ %indvars.iv.next, %._crit_edge2 ], [ 2, %0 ]
  %11 = add i32 %9, %10
  %12 = getelementptr inbounds i32* %5, i64 %indvars.iv
  store i32 %11, i32* %12, align 4
  %indvars.iv.next = add i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %1
  br i1 %exitcond, label %._crit_edge, label %._crit_edge2

._crit_edge2:                                     ; preds = %.lr.ph
  %13 = add nsw i64 %indvars.iv, -1
  %14 = getelementptr inbounds i32* %5, i64 %13
  %.pre = load i32* %14, align 4
  br label %.lr.ph

._crit_edge:                                      ; preds = %.lr.ph, %0
  %15 = zext i32 %n to i64
  %16 = getelementptr inbounds i32* %5, i64 %15
  %17 = load i32* %16, align 4
  ret i32 %17
}

declare noalias i8* @malloc(i64) nounwind
