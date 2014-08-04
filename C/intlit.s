; ModuleID = 'intlit.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

define i32 @f(i32 %a, i32 %b) nounwind uwtable ssp {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %c = alloca i32, align 4
  store i32 %a, i32* %1, align 4
  store i32 %b, i32* %2, align 4
  %3 = load i32* %1, align 4
  %4 = add nsw i32 1, %3
  %5 = add nsw i32 %4, 2
  store i32 %5, i32* %c, align 4
  %6 = load i32* %c, align 4
  %7 = add nsw i32 %6, 3
  store i32 %7, i32* %1, align 4
  %8 = load i32* %1, align 4
  %9 = sub nsw i32 %8, 4
  store i32 %9, i32* %2, align 4
  ret i32 7
}
