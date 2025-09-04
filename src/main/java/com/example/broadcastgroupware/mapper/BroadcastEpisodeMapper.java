package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.BroadcastEpisode;

@Mapper
public interface BroadcastEpisodeMapper {
    // 해당 프로그램의 회차 수
    int countEpisodesByScheduleId(@Param("broadcastScheduleId") int broadcastScheduleId);

    // 회차 일괄 삽입 (코멘트 제외)
    int insertEpisodes(@Param("list") List<BroadcastEpisode> list);
    
    // 회차 목록 (페이징)
    List<BroadcastEpisode> selectEpisodesBySchedule(@Param("scheduleId") int scheduleId,
            										@Param("beginRow") int beginRow,
        											@Param("rowPerPage") int rowPerPage);

    // 회차 소제목 / 회차 설명 (코멘트) 수정
    int updateEpisodeComment(@Param("episodeId") int episodeId,
                             @Param("comment") String comment);

}
