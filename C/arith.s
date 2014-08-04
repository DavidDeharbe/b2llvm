; ModuleID = 'arith.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

define i32 @f(i32 %a, i32 %b) nounwind uwtable ssp {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %c = alloca i32, align 4
  store i32 %a, i32* %1, align 4
  store i32 %b, i32* %2, align 4
  %3 = load i32* %1, align 4
  %4 = load i32* %2, align 4
  %5 = add nsw i32 %3, %4
  store i32 %5, i32* %c, align 4
  %6 = load i32* %2, align 4
  %7 = load i32* %c, align 4
  %8 = sub nsw i32 %6, %7
  store i32 %8, i32* %1, align 4
  %9 = load i32* %c, align 4
  %10 = load i32* %1, align 4
  %11 = mul nsw i32 %9, %10
  store i32 %11, i32* %2, align 4
  %12 = load i32* %1, align 4
  %13 = load i32* %2, align 4
  %14 = sdiv i32 %12, %13
  store i32 %14, i32* %c, align 4
  %15 = load i32* %2, align 4
  %16 = load i32* %c, align 4
  %17 = srem i32 %15, %16
  store i32 %17, i32* %1, align 4
  %18 = load i32* %1, align 4
  %19 = sub nsw i32 0, %18
  store i32 %19, i32* %2, align 4
  %20 = load i32* %2, align 4
  ret i32 %20
}
