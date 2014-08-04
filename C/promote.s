; ModuleID = 'promote.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

define i32 @promote_f(i32 %p) nounwind uwtable ssp {
  %1 = tail call i32 @f(i32 %p) nounwind
  ret i32 %1
}

declare i32 @f(i32)
