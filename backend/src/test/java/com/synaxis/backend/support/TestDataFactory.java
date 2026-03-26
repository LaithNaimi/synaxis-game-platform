package com.synaxis.backend.support;

public final class TestDataFactory {

    private TestDataFactory() {
    }

    public static String validPlayerName() {
        return "Host";
    }

    public static String invalidBlankPlayerName() {
        return "";
    }
}