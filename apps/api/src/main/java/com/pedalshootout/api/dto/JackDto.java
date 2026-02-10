package com.pedalshootout.api.dto;

import com.pedalshootout.api.entity.Jack;

/**
 * DTO for jack data. Excludes the product back-reference to avoid circular JSON.
 */
public record JackDto(
    Integer id,
    String category,
    String direction,
    String jackName,
    String position,
    String connectorType,
    Integer impedanceOhms,
    String voltage,
    Integer currentMa,
    String polarity,
    String function,
    Boolean powerOverConnector,
    Boolean isIsolated,
    Boolean isBuffered,
    Boolean bufferSwitchable,
    Boolean hasGroundLift,
    Boolean hasPhaseInvert,
    Integer normalledToJackId,
    String normallingType,
    String groupId
) {
    public static JackDto from(Jack j) {
        return new JackDto(
            j.getId(),
            j.getCategory(),
            j.getDirection(),
            j.getJackName(),
            j.getPosition(),
            j.getConnectorType(),
            j.getImpedanceOhms(),
            j.getVoltage(),
            j.getCurrentMa(),
            j.getPolarity(),
            j.getFunction(),
            j.getPowerOverConnector(),
            j.getIsIsolated(),
            j.getIsBuffered(),
            j.getBufferSwitchable(),
            j.getHasGroundLift(),
            j.getHasPhaseInvert(),
            j.getNormalledToJackId(),
            j.getNormallingType(),
            j.getGroupId()
        );
    }
}
