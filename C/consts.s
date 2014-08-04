; ModuleID = 'consts.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

@v3 = constant i8 1, align 1
@v4 = constant [2 x [2 x i32]] [[2 x i32] [i32 0, i32 1], [2 x i32] [i32 1, i32 0]], align 16
@v2 = internal global i32 1, align 4

define i32 @f() nounwind uwtable ssp {
  %1 = alloca i32, align 4
  %2 = load i32* @v2, align 4
  %3 = icmp eq i32 %2, 2
  br i1 %3, label %4, label %5

; <label>:4                                       ; preds = %0
  store i32 42, i32* %1
  br label %10

; <label>:5                                       ; preds = %0
  %6 = load i32* @v2, align 4
  %7 = icmp eq i32 %6, 0
  br i1 %7, label %8, label %9

; <label>:8                                       ; preds = %5
  store i32 1, i32* %1
  br label %10

; <label>:9                                       ; preds = %5
  store i32 0, i32* %1
  br label %10

; <label>:10                                      ; preds = %9, %8, %4
  %11 = load i32* %1
  ret i32 %11
}
