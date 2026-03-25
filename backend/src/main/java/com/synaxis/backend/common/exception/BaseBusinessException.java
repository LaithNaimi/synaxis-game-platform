package com.synaxis.backend.common.exception;

import org.springframework.http.HttpStatus;

public abstract class BaseBusinessException extends RuntimeException {

    private final String errorCode;
    private final HttpStatus httpStatus;

    public BaseBusinessException(String errorCode, String message, HttpStatus httpStatus) {
        super(message);
        this.errorCode = errorCode;
        this.httpStatus = httpStatus;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public HttpStatus getHttpStatus() {
        return httpStatus;
    }
}