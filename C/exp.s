; ModuleID = 'exp.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

define i32 @f(i32 %a, i32 %b) nounwind uwtable ssp {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %r = alloca i32, align 4
  store i32 %a, i32* %1, align 4
  store i32 %b, i32* %2, align 4
  %3 = load i32* %1, align 4
  %4 = call i32 @exp(i32 %3, i32 0)
  store i32 %4, i32* %r, align 4
  %5 = load i32* %1, align 4
  %6 = load i32* %r, align 4
  %7 = call i32 @exp(i32 %5, i32 %6)
  store i32 %7, i32* %r, align 4
  %8 = load i32* %r, align 4
  ret i32 %8
}

define internal i32 @exp(i32 %a, i32 %b) nounwind uwtable inlinehint ssp {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %r = alloca i32, align 4
  store i32 %a, i32* %1, align 4
  store i32 %b, i32* %2, align 4
  store i32 1, i32* %r, align 4
  br label %3

; <label>:3                                       ; preds = %6, %0
  %4 = load i32* %2, align 4
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %6, label %12

; <label>:6                                       ; preds = %3
  %7 = load i32* %1, align 4
  %8 = load i32* %r, align 4
  %9 = mul nsw i32 %8, %7
  store i32 %9, i32* %r, align 4
  %10 = load i32* %2, align 4
  %11 = add nsw i32 %10, -1
  store i32 %11, i32* %2, align 4
  br label %3

; <label>:12                                      ; preds = %3
  %13 = load i32* %r, align 4
  ret i32 %13
}
