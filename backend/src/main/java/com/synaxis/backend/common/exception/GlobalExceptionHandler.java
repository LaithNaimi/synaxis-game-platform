package com.synaxis.backend.common.exception;

import com.synaxis.backend.common.dto.ApiErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.MethodArgumentNotValidException;

import java.util.List;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BaseBusinessException.class)
    public ResponseEntity<ApiErrorResponse> handleBusinessException(BaseBusinessException ex) {
        ApiErrorResponse response = ApiErrorResponse.of(
                ex.getErrorCode(),
                ex.getMessage()
        );

        return ResponseEntity
                .status(ex.getHttpStatus())
                .body(response);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiErrorResponse> handleGenericException(Exception ex) {
        ApiErrorResponse response = ApiErrorResponse.of(
                "INTERNAL_SERVER_ERROR",
                "An unexpected error occurred"
        );

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiErrorResponse> handleValidationException(MethodArgumentNotValidException ex) {
        List<String> details = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(error -> error.getField() + " " + error.getDefaultMessage())
                .toList();

        ApiErrorResponse response = ApiErrorResponse.of(
                "VALIDATION_ERROR",
                "Request validation failed",
                details
        );

        return ResponseEntity.badRequest().body(response);
    }
}