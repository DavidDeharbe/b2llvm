; ModuleID = 'extcons.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

@k1 = external constant i8
@k2 = external global i32

define void @f(i32* %pi) nounwind uwtable ssp {
  %1 = alloca i32*, align 8
  %v = alloca i32, align 4
  store i32* %pi, i32** %1, align 8
  %2 = load i32* %v, align 4
  %3 = icmp eq i32 %2, 0
  br i1 %3, label %4, label %5

; <label>:4                                       ; preds = %0
  store i32 1, i32* %v, align 4
  br label %16

; <label>:5                                       ; preds = %0
  %6 = load i32** %1, align 8
  %7 = load i32* %6
  %8 = load i8* @k1, align 1
  %9 = sext i8 %8 to i32
  %10 = add nsw i32 %7, %9
  %11 = load i32* @k2, align 4
  %12 = add nsw i32 %10, %11
  %13 = load i32** %1, align 8
  %14 = load i32* %13
  %15 = add nsw i32 %14, %12
  store i32 %15, i32* %13
  br label %16

; <label>:16                                      ; preds = %5, %4
  ret void
}
