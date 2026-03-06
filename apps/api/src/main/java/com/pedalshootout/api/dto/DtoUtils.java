package com.pedalshootout.api.dto;

public final class DtoUtils {

    private DtoUtils() {}

    public static String formatMsrp(Integer cents) {
        if (cents == null) return null;
        return String.format("$%d.%02d", cents / 100, cents % 100);
    }
}
