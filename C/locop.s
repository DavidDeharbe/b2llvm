; ModuleID = 'locop.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

define void @op() nounwind uwtable ssp {
  call void @locop1()
  call void @locop2()
  call void @locop3()
  ret void
}

define internal void @locop1() nounwind uwtable ssp {
  call void @promop1()
  ret void
}

define internal void @locop2() nounwind uwtable ssp {
  call void @locop3()
  ret void
}

define internal void @locop3() nounwind uwtable ssp {
  ret void
}

declare void @promop1()
