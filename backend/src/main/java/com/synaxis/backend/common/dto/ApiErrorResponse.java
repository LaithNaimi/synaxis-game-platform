package com.synaxis.backend.common.dto;

import java.time.Instant;
import java.util.List;

public class ApiErrorResponse {
    private boolean success;
    private String errorCode;
    private String message;
    private Instant timestamp;
    private List<String> details;

    public ApiErrorResponse() {
    }

    public ApiErrorResponse(boolean success, String errorCode, String message, Instant timestamp, List<String> details) {
        this.success = success;
        this.errorCode = errorCode;
        this.message = message;
        this.timestamp = timestamp;
        this.details = details;
    }

    public static ApiErrorResponse of(String errorCode, String message) {
        return new ApiErrorResponse(false, errorCode, message, Instant.now(), null);
    }

    public static ApiErrorResponse of(String errorCode, String message, List<String> details) {
        return new ApiErrorResponse(false, errorCode, message, Instant.now(), details);
    }

    public List<String> getDetails() {
        return details;
    }

    public void setDetails(List<String> details) {
        this.details = details;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public Instant getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Instant timestamp) {
        this.timestamp = timestamp;
    }
}
