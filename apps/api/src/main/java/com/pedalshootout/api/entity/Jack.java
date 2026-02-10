package com.pedalshootout.api.entity;

import jakarta.persistence.*;

/**
 * JPA Entity for the jacks table.
 *
 * Jacks represent physical connectors on any product — audio I/O, MIDI ports,
 * power inputs, expression jacks, USB ports, etc. One product can have many jacks.
 *
 * @ManyToOne on the product field means "many jacks belong to one product."
 * The @JoinColumn tells JPA which column in the jacks table holds the foreign key.
 */
@Entity
@Table(name = "jacks")
public class Jack {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false)
    private String category;

    @Column(nullable = false)
    private String direction;

    @Column(name = "jack_name")
    private String jackName;

    private String position;

    @Column(name = "connector_type", nullable = false)
    private String connectorType;

    @Column(name = "impedance_ohms")
    private Integer impedanceOhms;

    private String voltage;

    @Column(name = "current_ma")
    private Integer currentMa;

    private String polarity;
    private String function;

    @Column(name = "power_over_connector")
    private Boolean powerOverConnector;

    @Column(name = "is_isolated")
    private Boolean isIsolated;

    @Column(name = "is_buffered")
    private Boolean isBuffered;

    @Column(name = "buffer_switchable")
    private Boolean bufferSwitchable;

    @Column(name = "has_ground_lift")
    private Boolean hasGroundLift;

    @Column(name = "has_phase_invert")
    private Boolean hasPhaseInvert;

    @Column(name = "normalled_to_jack_id")
    private Integer normalledToJackId;

    @Column(name = "normalling_type")
    private String normallingType;

    @Column(name = "group_id")
    private String groupId;

    public Jack() {}

    // --- Getters ---
    public Integer getId() { return id; }
    public Product getProduct() { return product; }
    public String getCategory() { return category; }
    public String getDirection() { return direction; }
    public String getJackName() { return jackName; }
    public String getPosition() { return position; }
    public String getConnectorType() { return connectorType; }
    public Integer getImpedanceOhms() { return impedanceOhms; }
    public String getVoltage() { return voltage; }
    public Integer getCurrentMa() { return currentMa; }
    public String getPolarity() { return polarity; }
    public String getFunction() { return function; }
    public Boolean getPowerOverConnector() { return powerOverConnector; }
    public Boolean getIsIsolated() { return isIsolated; }
    public Boolean getIsBuffered() { return isBuffered; }
    public Boolean getBufferSwitchable() { return bufferSwitchable; }
    public Boolean getHasGroundLift() { return hasGroundLift; }
    public Boolean getHasPhaseInvert() { return hasPhaseInvert; }
    public Integer getNormalledToJackId() { return normalledToJackId; }
    public String getNormallingType() { return normallingType; }
    public String getGroupId() { return groupId; }
}
