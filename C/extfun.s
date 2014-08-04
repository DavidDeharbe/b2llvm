; ModuleID = 'extfun.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

define i32 @g(i32 %a) nounwind uwtable ssp {
  %1 = alloca i32, align 4
  %b = alloca i32, align 4
  store i32 %a, i32* %1, align 4
  %2 = load i32* %1, align 4
  %3 = load i32* %1, align 4
  %4 = call i32 @f(i32 %2, i32 %3, i32* %1)
  store i32 %4, i32* %b, align 4
  %5 = load i32* %b, align 4
  ret i32 %5
}

declare i32 @f(i32, i32, i32*)
