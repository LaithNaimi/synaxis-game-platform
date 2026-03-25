package com.synaxis.backend.common.dto;

public class ApiSuccessResponse<T> {
    private boolean success;
    private T data;

    public ApiSuccessResponse() {}

    public ApiSuccessResponse(boolean success, T data) {
        this.success = success;
    }

    public static <T> ApiSuccessResponse<T> success(T data) {
        return new ApiSuccessResponse<T>(true, data);
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }
    public T getData() {
        return data;
    }
    public void setData(T data) {
        this.data = data;
    }
}
