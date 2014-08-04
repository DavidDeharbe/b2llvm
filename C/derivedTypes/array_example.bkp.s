; ModuleID = 'array_example.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.9.0"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@vec = common global [10 x i32] zeroinitializer, align 16

define i32 @main() nounwind ssp uwtable {
  call void @test()
  %1 = load i32* getelementptr inbounds ([10 x i32]* @vec, i32 0, i64 0), align 4
  %2 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([3 x i8]* @.str, i32 0, i32 0), i32 %1)
  ret i32 0
}

declare i32 @printf(i8*, ...)

define void @test()  {
;;  store i32 5, i32* getelementptr  ([10 x i32]* @vec, i32 0, i64 0), align 4
  %1 = getelementptr  [10 x i32]* @vec, i32 0, i64 0
  store i32 5, i32 * %1, align 4
  ret void
}
