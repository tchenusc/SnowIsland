package com.example.snowisland.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "player")
public class Player {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(name = "is_weak")
    private Boolean isWeak = false;

    @Column(name = "is_overworked")
    private Boolean isOverworked = false;

    @Column(name = "is_injured")
    private Integer isInjured = 0;

    @Column(name = "is_severely_injured")
    private Boolean isSeverelyInjured = false;

    @Column(name = "is_dead")
    private Boolean isDead = false;

    @Column(name = "job_id")
    private Integer jobId;

    @Transient
    @JsonProperty
    private String jobName;

    @Column(name = "skill_id")
    private Integer skillId;

    /** 当晚过夜地点；null = 默认在家（参考规则） */
    @Column(name = "overnight_location_id")
    private Integer overnightLocationId;

    @Enumerated(EnumType.STRING)
    private Faction faction;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "dm_notes", columnDefinition = "TEXT")
    private String dmNotes;

    @Column(name = "hidden_job_id")
    private Integer hiddenJobId;

    @Column(name = "trade_banned")
    private Boolean tradeBanned = false;

    @Column(name = "trade_ban_exempt")
    private Boolean tradeBanExempt = false;

    @Column(name = "is_bound")
    private Boolean isBound = false;

    public enum Faction {
        统治者, 反叛者, 冒险者, 天灾使者, 平民, 外来者, 原住民
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Boolean getIsWeak() { return isWeak; }
    public void setIsWeak(Boolean isWeak) { this.isWeak = isWeak; }

    public Boolean getIsOverworked() { return isOverworked; }
    public void setIsOverworked(Boolean isOverworked) { this.isOverworked = isOverworked; }

    public Integer getIsInjured() { return isInjured; }
    public void setIsInjured(Integer isInjured) { this.isInjured = isInjured; }

    public Boolean getIsSeverelyInjured() { return isSeverelyInjured; }
    public void setIsSeverelyInjured(Boolean isSeverelyInjured) { this.isSeverelyInjured = isSeverelyInjured; }

    public Boolean getIsDead() { return isDead; }
    public void setIsDead(Boolean isDead) { this.isDead = isDead; }

    public Integer getJobId() { return jobId; }
    public void setJobId(Integer jobId) { this.jobId = jobId; }

    public String getJobName() { return jobName; }
    public void setJobName(String jobName) { this.jobName = jobName; }

    public Integer getSkillId() { return skillId; }
    public void setSkillId(Integer skillId) { this.skillId = skillId; }

    public Integer getOvernightLocationId() { return overnightLocationId; }
    public void setOvernightLocationId(Integer overnightLocationId) { this.overnightLocationId = overnightLocationId; }

    public Faction getFaction() { return faction; }
    public void setFaction(Faction faction) { this.faction = faction; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    @JsonIgnore
    public String getDmNotes() { return dmNotes; }
    public void setDmNotes(String dmNotes) { this.dmNotes = dmNotes; }

    @JsonIgnore
    public Integer getHiddenJobId() { return hiddenJobId; }
    public void setHiddenJobId(Integer hiddenJobId) { this.hiddenJobId = hiddenJobId; }

    public Boolean getTradeBanned() { return tradeBanned; }
    public void setTradeBanned(Boolean tradeBanned) { this.tradeBanned = tradeBanned; }

    public Boolean getTradeBanExempt() { return tradeBanExempt; }
    public void setTradeBanExempt(Boolean tradeBanExempt) { this.tradeBanExempt = tradeBanExempt; }

    public Boolean getIsBound() { return isBound; }
    public void setIsBound(Boolean isBound) { this.isBound = isBound; }
}
