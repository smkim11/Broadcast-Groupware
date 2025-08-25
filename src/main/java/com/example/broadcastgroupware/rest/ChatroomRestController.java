package com.example.broadcastgroupware.rest;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.SessionAttribute;

import com.example.broadcastgroupware.dto.ChatroomDmDto;
import com.example.broadcastgroupware.dto.ChatroomDto;
import com.example.broadcastgroupware.dto.ChatroomGroupDto;
import com.example.broadcastgroupware.dto.ChatroomListDto;
import com.example.broadcastgroupware.dto.ChatroomUserDto;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.mapper.ChatroomUserMapper;
import com.example.broadcastgroupware.service.ChatService;
import com.example.broadcastgroupware.service.ChatroomService;

@RestController
@RequestMapping("/api/rooms")
public class ChatroomRestController {
	
	private final ChatService chatService;
	private final ChatroomService chatroomService;
	private final ChatroomUserMapper chatroomUserMapper;
	private final SimpMessagingTemplate messagingTemplate;
	
	public ChatroomRestController( ChatService chatService,
								  ChatroomService chatroomService,
								  ChatroomUserMapper chatroomUserMapper,
								  SimpMessagingTemplate messagingTemplate) {
		this.chatService = chatService;
		this.chatroomService = chatroomService;
		this.chatroomUserMapper = chatroomUserMapper;
		this.messagingTemplate = messagingTemplate;
	}
	
	// DM 목록(1:1대화)
	@GetMapping("/dm")
    public ResponseEntity<List<ChatroomListDto>> listDm(
            @SessionAttribute("loginUser") UserSessionDto loginUser) {
		
		 System.out.println(">>> DM API 호출됨");
        int userId = loginUser.getUserId();
        return ResponseEntity.ok(chatroomService.getDmList(userId));
    }

    // DM 생성 (조직도에서 초대 → 1:1 시작)
    @PostMapping("/dm")
    public ResponseEntity<ChatroomDto> createDm(@RequestBody ChatroomDmDto req,
                                                @SessionAttribute("loginUser") UserSessionDto loginUser) {
        int meUserId = loginUser.getUserId();
        ChatroomDto dto = chatroomService.createDm(meUserId, req.getTargetUserId());
        return ResponseEntity.ok(dto);
    }
    
    @GetMapping("/group")
    public ResponseEntity<List<ChatroomListDto>> getGroupList(
            @SessionAttribute("loginUser") UserSessionDto loginUser) {
    	int userId = loginUser.getUserId();
        return ResponseEntity.ok(chatroomService.getGroupList(userId));
    }
    
    // GROUP 생성(조직도에서 초대 1:M 시작)
    @PostMapping("/group")
    public ResponseEntity<Map<String, Object>> createGroup(@RequestBody ChatroomGroupDto req,
    													   @SessionAttribute("loginUser") UserSessionDto loginUser) {
    	// service에서 roomName null/공백을 "그룹채팅"으로 선언하므로 그대로 넘겨도 됨
    	List<Integer> members = (req.getMemberIds() == null) ? List.of() : req.getMemberIds();
    	int roomId = chatroomService.createGroupRoom(req.getRoomName(), loginUser.getUserId(), members);
    	
    	return ResponseEntity.ok(Map.of("roomId", roomId, "roomName",
    				(req.getRoomName() == null || req.getRoomName().isBlank()) ? "그룹채팅" : req.getRoomName()));
    }
    
    // 방 멤버 목록 (이름/직급/프로필)
    @GetMapping("/{roomId}/members")
    public ResponseEntity<List<ChatroomUserDto>> getRoomMembers(
            @PathVariable int roomId,
            @SessionAttribute("loginUser") UserSessionDto loginUser) {

        // (옵션) 보안: 내가 이 방 멤버인지 확인. 필요 없으면 아래 3줄 제거해도 됨.
        var me = chatroomUserMapper.findStatus(roomId, loginUser.getUserId());
        if (me == null) {
            return ResponseEntity.status(403).build();
        }

        var members = chatroomUserMapper.selectCurrentMembers(roomId);
        return ResponseEntity.ok(members);
    }
    
    // 채팅방 나가기
    @PostMapping("/{chatroomId}/leave")
    public ResponseEntity<Void> leaveRoom(
    		@PathVariable int chatroomId,
    		@SessionAttribute("loginUser") UserSessionDto loginUser) {
    	
		chatService.leaveRoom(chatroomId, loginUser.getUserId());
		

		    // 방 토픽으로 멤버수 갱신 이벤트
		    messagingTemplate.convertAndSend("/topic/rooms/" + chatroomId, Map.of(
		        "type",        "GROUP_MEMBER_LEFT",
		        "roomId",      chatroomId,
		        "userId",      loginUser.getUserId()
		    ));
		return ResponseEntity.noContent().build();	// 204
    }
}
	
	



















