; ModuleID = 'pg5.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

%struct.point = type { float, float }

define void @middle(<2 x float> %p1.coerce, <2 x float> %p2.coerce, %struct.point* nocapture %m) nounwind uwtable ssp {
  %1 = extractelement <2 x float> %p1.coerce, i32 0
  %2 = extractelement <2 x float> %p2.coerce, i32 0
  %3 = fadd float %1, %2
  %4 = fmul float %3, 5.000000e-01
  %5 = getelementptr inbounds %struct.point* %m, i64 0, i32 0
  store float %4, float* %5, align 4
  %6 = extractelement <2 x float> %p1.coerce, i32 1
  %7 = extractelement <2 x float> %p2.coerce, i32 1
  %8 = fadd float %6, %7
  %9 = fmul float %8, 5.000000e-01
  %10 = getelementptr inbounds %struct.point* %m, i64 0, i32 1
  store float %9, float* %10, align 4
  ret void
}
