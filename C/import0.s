; ModuleID = 'import0.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.4"

%struct.counter_ = type { i32 }
%struct.wrap_ = type { %struct.counter_, %struct.counter_ }

define void @inc(%struct.counter_* %c) nounwind uwtable ssp {
  %1 = alloca %struct.counter_*, align 8
  store %struct.counter_* %c, %struct.counter_** %1, align 8
  %2 = load %struct.counter_** %1, align 8
  %3 = getelementptr inbounds %struct.counter_* %2, i32 0, i32 0
  %4 = load i32* %3, align 4
  %5 = add nsw i32 %4, 1
  store i32 %5, i32* %3, align 4
  ret void
}

define void @get(%struct.counter_* %c, i32* %Pint) nounwind uwtable ssp {
  %1 = alloca %struct.counter_*, align 8
  %2 = alloca i32*, align 8
  store %struct.counter_* %c, %struct.counter_** %1, align 8
  store i32* %Pint, i32** %2, align 8
  %3 = load %struct.counter_** %1, align 8
  %4 = getelementptr inbounds %struct.counter_* %3, i32 0, i32 0
  %5 = load i32* %4, align 4
  %6 = load i32** %2, align 8
  store i32 %5, i32* %6
  ret void
}

define void @tick(%struct.wrap_* %w) nounwind uwtable ssp {
  %1 = alloca %struct.wrap_*, align 8
  %elapsed = alloca i32, align 4
  store %struct.wrap_* %w, %struct.wrap_** %1, align 8
  %2 = load %struct.wrap_** %1, align 8
  %3 = getelementptr inbounds %struct.wrap_* %2, i32 0, i32 0
  call void @inc(%struct.counter_* %3)
  %4 = load %struct.wrap_** %1, align 8
  %5 = getelementptr inbounds %struct.wrap_* %4, i32 0, i32 0
  call void @get(%struct.counter_* %5, i32* %elapsed)
  %6 = load %struct.wrap_** %1, align 8
  %7 = getelementptr inbounds %struct.wrap_* %6, i32 0, i32 1
  call void @inc(%struct.counter_* %7)
  ret void
}
