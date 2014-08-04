; ModuleID = 'pg4.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

@c2 = global i8 0, align 1
@w = global [3 x i8] c"\00\01\02", align 1
@w2 = global [5 x i8] c"\00\FF\80\01\7F", align 1
@c1 = common global i8 0, align 1

define void @f2() nounwind uwtable ssp {
  %1 = load i8* @c1, align 1
  %2 = add i8 %1, 1
  store i8 %2, i8* @c1, align 1
  ret void
}

define void @f3(i8* nocapture %v) nounwind uwtable ssp {
  %1 = load i8* getelementptr inbounds ([3 x i8]* @w, i64 0, i64 0), align 1
  %2 = add i8 %1, 1
  store i8 %2, i8* getelementptr inbounds ([3 x i8]* @w, i64 0, i64 0), align 1
  %3 = getelementptr inbounds i8* %v, i64 3
  %4 = load i8* %3, align 1
  store i8 %4, i8* @c2, align 1
  ret void
}
