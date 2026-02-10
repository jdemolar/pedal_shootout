package com.pedalshootout.api.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "power_supply_details")
public class PowerSupplyDetail {

    @Id
    @Column(name = "product_id")
    private Integer productId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "supply_type")
    private String supplyType;

    private String topology;

    @Column(name = "input_voltage_range")
    private String inputVoltageRange;

    @Column(name = "input_frequency")
    private String inputFrequency;

    @Column(name = "total_output_count")
    private Integer totalOutputCount;

    @Column(name = "total_current_ma")
    private Integer totalCurrentMa;

    @Column(name = "isolated_output_count")
    private Integer isolatedOutputCount;

    @Column(name = "available_voltages")
    private String availableVoltages;

    @Column(name = "has_variable_voltage")
    private Boolean hasVariableVoltage;

    @Column(name = "voltage_range")
    private String voltageRange;

    @Column(name = "mounting_type")
    private String mountingType;

    @Column(name = "bracket_included")
    private Boolean bracketIncluded;

    @Column(name = "is_expandable")
    private Boolean isExpandable;

    @Column(name = "expansion_port_type")
    private String expansionPortType;

    @Column(name = "is_battery_powered")
    private Boolean isBatteryPowered;

    @Column(name = "battery_capacity_wh")
    private Double batteryCapacityWh;

    public PowerSupplyDetail() {}

    public Integer getProductId() { return productId; }
    public Product getProduct() { return product; }
    public String getSupplyType() { return supplyType; }
    public String getTopology() { return topology; }
    public String getInputVoltageRange() { return inputVoltageRange; }
    public String getInputFrequency() { return inputFrequency; }
    public Integer getTotalOutputCount() { return totalOutputCount; }
    public Integer getTotalCurrentMa() { return totalCurrentMa; }
    public Integer getIsolatedOutputCount() { return isolatedOutputCount; }
    public String getAvailableVoltages() { return availableVoltages; }
    public Boolean getHasVariableVoltage() { return hasVariableVoltage; }
    public String getVoltageRange() { return voltageRange; }
    public String getMountingType() { return mountingType; }
    public Boolean getBracketIncluded() { return bracketIncluded; }
    public Boolean getIsExpandable() { return isExpandable; }
    public String getExpansionPortType() { return expansionPortType; }
    public Boolean getIsBatteryPowered() { return isBatteryPowered; }
    public Double getBatteryCapacityWh() { return batteryCapacityWh; }
}
