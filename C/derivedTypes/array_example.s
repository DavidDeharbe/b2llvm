; ModuleID = 'array_example.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.9.0"

%struct.tstruct = type { [99 x i32], i32, i32 }

@start_arr = constant i32 1, align 4
@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@ref = common global %struct.tstruct zeroinitializer, align 4

define i32 @main() nounwind ssp uwtable {
  call void @set()
  %1 = load i32* getelementptr inbounds (%struct.tstruct* @ref, i32 0, i32 0, i64 4), align 4
  %2 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([3 x i8]* @.str, i32 0, i32 0), i32 %1)
  ret i32 0
}

declare i32 @printf(i8*, ...)

define void @set() nounwind ssp uwtable {
  %ind = alloca i32, align 4
  %tmp = alloca i32, align 4
  store i32 7, i32* %ind, align 4
  store i32 3, i32* %tmp, align 4
  %1 = load i32* %tmp, align 4
  %2 = sext i32 %1 to i64
  %3 = getelementptr inbounds [99 x i32]* getelementptr inbounds (%struct.tstruct* @ref, i32 0, i32 0), i32 0, i64 %2
  store i32 5, i32* %3, align 4
  ret void
}

define void @get() nounwind ssp uwtable {
  %a = alloca i32, align 4
  %1 = load i32* getelementptr inbounds (%struct.tstruct* @ref, i32 0, i32 0, i64 4), align 4
  store i32 %1, i32* %a, align 4
  ret void
}
