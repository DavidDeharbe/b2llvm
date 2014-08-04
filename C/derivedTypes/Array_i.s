; ModuleID = 'Array_i.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.9.0"

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@Array3 = internal global [10 x [20 x [30 x i32]]] zeroinitializer, align 16
@Array__arr = internal global [100 x i32] zeroinitializer, align 16
@Array__arr_n = internal global [100 x [100 x i32]] zeroinitializer, align 16
@Array__tmp = internal global [100 x i32] zeroinitializer, align 16
@Array__setInitializing.values = private unnamed_addr constant [2 x [2 x [4 x i32]]] [[2 x [4 x i32]] [[4 x i32] [i32 1, i32 2, i32 3, i32 4], [4 x i32] [i32 1, i32 2, i32 3, i32 4]], [2 x [4 x i32]] [[4 x i32] [i32 1, i32 2, i32 3, i32 4], [4 x i32] [i32 1, i32 2, i32 3, i32 4]]], align 16

define i32 @main() nounwind ssp uwtable {
  %1 = alloca i32, align 4
  store i32 0, i32* %1
  call void @Array__setZero()
  %2 = load i32* getelementptr inbounds ([10 x [20 x [30 x i32]]]* @Array3, i32 0, i64 2, i64 3, i64 4), align 4
  %3 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @.str, i32 0, i32 0), i32 %2)
  ret i32 0
}

define void @Array__setZero() nounwind ssp uwtable {
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  %z = alloca i32, align 4
  store i32 2, i32* %x, align 4
  store i32 3, i32* %y, align 4
  store i32 4, i32* %z, align 4
  %1 = load i32* %z, align 4
  %2 = sext i32 %1 to i64
  %3 = load i32* %y, align 4
  %4 = sext i32 %3 to i64
  %5 = load i32* %x, align 4
  %6 = sext i32 %5 to i64
  %7 = getelementptr inbounds [10 x [20 x [30 x i32]]]* @Array3, i32 0, i64 %6
  %8 = getelementptr inbounds [20 x [30 x i32]]* %7, i32 0, i64 %4
  %9 = getelementptr inbounds [30 x i32]* %8, i32 0, i64 %2
  store i32 7, i32* %9, align 4
  ret void
}

declare i32 @printf(i8*, ...)

define void @Array__INITIALISATION() nounwind ssp uwtable {
  store i32 100, i32* getelementptr inbounds ([100 x i32]* @Array__arr, i32 0, i64 1), align 4
  store i32 10, i32* getelementptr inbounds ([100 x [100 x i32]]* @Array__arr_n, i32 0, i64 0, i64 0), align 4
  call void @llvm.memmove.p0i8.p0i8.i64(i8* bitcast ([100 x i32]* @Array__tmp to i8*), i8* bitcast ([100 x i32]* @Array__arr to i8*), i64 400, i32 16, i1 false)
  call void @Array__setZero()
  call void @Array__setInitializing()
  ret void
}

declare void @llvm.memmove.p0i8.p0i8.i64(i8* nocapture, i8* nocapture, i64, i32, i1) nounwind

define void @Array__setInitializing() nounwind ssp uwtable {
  %values = alloca [2 x [2 x [4 x i32]]], align 16
  %1 = bitcast [2 x [2 x [4 x i32]]]* %values to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %1, i8* bitcast ([2 x [2 x [4 x i32]]]* @Array__setInitializing.values to i8*), i64 64, i32 16, i1 false)
  %2 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 0
  %3 = getelementptr inbounds [2 x [4 x i32]]* %2, i32 0, i64 0
  %4 = getelementptr inbounds [4 x i32]* %3, i32 0, i64 0
  store i32 1, i32* %4, align 4
  %5 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 0
  %6 = getelementptr inbounds [2 x [4 x i32]]* %5, i32 0, i64 0
  %7 = getelementptr inbounds [4 x i32]* %6, i32 0, i64 1
  store i32 2, i32* %7, align 4
  %8 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 0
  %9 = getelementptr inbounds [2 x [4 x i32]]* %8, i32 0, i64 0
  %10 = getelementptr inbounds [4 x i32]* %9, i32 0, i64 2
  store i32 3, i32* %10, align 4
  %11 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 0
  %12 = getelementptr inbounds [2 x [4 x i32]]* %11, i32 0, i64 0
  %13 = getelementptr inbounds [4 x i32]* %12, i32 0, i64 2
  store i32 4, i32* %13, align 4
  %14 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 0
  %15 = getelementptr inbounds [2 x [4 x i32]]* %14, i32 0, i64 1
  %16 = getelementptr inbounds [4 x i32]* %15, i32 0, i64 0
  store i32 1, i32* %16, align 4
  %17 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 0
  %18 = getelementptr inbounds [2 x [4 x i32]]* %17, i32 0, i64 1
  %19 = getelementptr inbounds [4 x i32]* %18, i32 0, i64 1
  store i32 2, i32* %19, align 4
  %20 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 0
  %21 = getelementptr inbounds [2 x [4 x i32]]* %20, i32 0, i64 1
  %22 = getelementptr inbounds [4 x i32]* %21, i32 0, i64 2
  store i32 3, i32* %22, align 4
  %23 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 0
  %24 = getelementptr inbounds [2 x [4 x i32]]* %23, i32 0, i64 1
  %25 = getelementptr inbounds [4 x i32]* %24, i32 0, i64 2
  store i32 4, i32* %25, align 4
  %26 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 1
  %27 = getelementptr inbounds [2 x [4 x i32]]* %26, i32 0, i64 0
  %28 = getelementptr inbounds [4 x i32]* %27, i32 0, i64 0
  store i32 1, i32* %28, align 4
  %29 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 1
  %30 = getelementptr inbounds [2 x [4 x i32]]* %29, i32 0, i64 0
  %31 = getelementptr inbounds [4 x i32]* %30, i32 0, i64 1
  store i32 2, i32* %31, align 4
  %32 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 1
  %33 = getelementptr inbounds [2 x [4 x i32]]* %32, i32 0, i64 0
  %34 = getelementptr inbounds [4 x i32]* %33, i32 0, i64 2
  store i32 3, i32* %34, align 4
  %35 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 1
  %36 = getelementptr inbounds [2 x [4 x i32]]* %35, i32 0, i64 0
  %37 = getelementptr inbounds [4 x i32]* %36, i32 0, i64 2
  store i32 4, i32* %37, align 4
  %38 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 1
  %39 = getelementptr inbounds [2 x [4 x i32]]* %38, i32 0, i64 1
  %40 = getelementptr inbounds [4 x i32]* %39, i32 0, i64 0
  store i32 1, i32* %40, align 4
  %41 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 1
  %42 = getelementptr inbounds [2 x [4 x i32]]* %41, i32 0, i64 1
  %43 = getelementptr inbounds [4 x i32]* %42, i32 0, i64 1
  store i32 2, i32* %43, align 4
  %44 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 1
  %45 = getelementptr inbounds [2 x [4 x i32]]* %44, i32 0, i64 1
  %46 = getelementptr inbounds [4 x i32]* %45, i32 0, i64 2
  store i32 3, i32* %46, align 4
  %47 = getelementptr inbounds [2 x [2 x [4 x i32]]]* %values, i32 0, i64 1
  %48 = getelementptr inbounds [2 x [4 x i32]]* %47, i32 0, i64 1
  %49 = getelementptr inbounds [4 x i32]* %48, i32 0, i64 2
  store i32 4, i32* %49, align 4
  ret void
}

declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture, i64, i32, i1) nounwind

define void @Array__setZeroSuggestedByDavid() nounwind ssp uwtable {
  %mid = alloca i32*, align 8
  store i32 4, i32* getelementptr inbounds ([100 x [100 x i32]]* @Array__arr_n, i32 0, i64 2, i64 5), align 4
  %1 = load i32* getelementptr inbounds ([100 x [100 x i32]]* @Array__arr_n, i32 0, i64 2, i64 5), align 4
  %2 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @.str, i32 0, i32 0), i32 %1)
  store i32* getelementptr inbounds ([100 x [100 x i32]]* @Array__arr_n, i32 0, i64 2, i32 0), i32** %mid, align 8
  %3 = load i32** %mid, align 8
  %4 = getelementptr inbounds i32* %3, i64 5
  %5 = load i32* %4, align 4
  %6 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([4 x i8]* @.str, i32 0, i32 0), i32 %5)
  ret void
}

define void @Array__set(i32 %ix, i32 %tt) nounwind ssp uwtable {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 %ix, i32* %1, align 4
  store i32 %tt, i32* %2, align 4
  %3 = load i32* %1, align 4
  %4 = icmp sge i32 %3, 0
  br i1 %4, label %5, label %19

; <label>:5                                       ; preds = %0
  %6 = load i32* %1, align 4
  %7 = icmp sle i32 %6, 99
  br i1 %7, label %8, label %19

; <label>:8                                       ; preds = %5
  %9 = load i32* %2, align 4
  %10 = icmp sge i32 %9, 0
  br i1 %10, label %11, label %19

; <label>:11                                      ; preds = %8
  %12 = load i32* %2, align 4
  %13 = icmp sle i32 %12, 1000
  br i1 %13, label %14, label %19

; <label>:14                                      ; preds = %11
  %15 = load i32* %2, align 4
  %16 = load i32* %1, align 4
  %17 = sext i32 %16 to i64
  %18 = getelementptr inbounds [100 x i32]* @Array__arr, i32 0, i64 %17
  store i32 %15, i32* %18, align 4
  br label %19

; <label>:19                                      ; preds = %14, %11, %8, %5, %0
  ret void
}

define void @Array__read(i32 %ix, i32* %tt) nounwind ssp uwtable {
  %1 = alloca i32, align 4
  %2 = alloca i32*, align 8
  store i32 %ix, i32* %1, align 4
  store i32* %tt, i32** %2, align 8
  %3 = load i32* %1, align 4
  %4 = icmp sge i32 %3, 0
  br i1 %4, label %5, label %14

; <label>:5                                       ; preds = %0
  %6 = load i32* %1, align 4
  %7 = icmp sle i32 %6, 99
  br i1 %7, label %8, label %14

; <label>:8                                       ; preds = %5
  %9 = load i32* %1, align 4
  %10 = sext i32 %9 to i64
  %11 = getelementptr inbounds [100 x i32]* @Array__arr, i32 0, i64 %10
  %12 = load i32* %11, align 4
  %13 = load i32** %2, align 8
  store i32 %12, i32* %13, align 4
  br label %16

; <label>:14                                      ; preds = %5, %0
  %15 = load i32** %2, align 8
  store i32 0, i32* %15, align 4
  br label %16

; <label>:16                                      ; preds = %14, %8
  ret void
}

define void @Array__swap(i32 %ix, i32 %jx) nounwind ssp uwtable {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %temp = alloca i32, align 4
  store i32 %ix, i32* %1, align 4
  store i32 %jx, i32* %2, align 4
  %3 = load i32* %1, align 4
  %4 = icmp sge i32 %3, 0
  br i1 %4, label %5, label %30

; <label>:5                                       ; preds = %0
  %6 = load i32* %1, align 4
  %7 = icmp sle i32 %6, 99
  br i1 %7, label %8, label %30

; <label>:8                                       ; preds = %5
  %9 = load i32* %2, align 4
  %10 = icmp sge i32 %9, 0
  br i1 %10, label %11, label %30

; <label>:11                                      ; preds = %8
  %12 = load i32* %2, align 4
  %13 = icmp sle i32 %12, 99
  br i1 %13, label %14, label %30

; <label>:14                                      ; preds = %11
  %15 = load i32* %2, align 4
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds [100 x i32]* @Array__arr, i32 0, i64 %16
  %18 = load i32* %17, align 4
  store i32 %18, i32* %temp, align 4
  %19 = load i32* %1, align 4
  %20 = sext i32 %19 to i64
  %21 = getelementptr inbounds [100 x i32]* @Array__arr, i32 0, i64 %20
  %22 = load i32* %21, align 4
  %23 = load i32* %2, align 4
  %24 = sext i32 %23 to i64
  %25 = getelementptr inbounds [100 x i32]* @Array__arr, i32 0, i64 %24
  store i32 %22, i32* %25, align 4
  %26 = load i32* %temp, align 4
  %27 = load i32* %1, align 4
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds [100 x i32]* @Array__arr, i32 0, i64 %28
  store i32 %26, i32* %29, align 4
  br label %30

; <label>:30                                      ; preds = %14, %11, %8, %5, %0
  ret void
}
