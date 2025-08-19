package com.example.broadcastgroupware.domain;

public enum ApprovalStatus {
    APPROVED("승인"),
    REJECTED("반려"),
	PENDING("대기");

    private final String label;
    ApprovalStatus(String label) {
        this.label = label;
    }
    public String getLabel() {
        return label;
    }
}
