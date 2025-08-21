package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/chat/rooms")
public class ChatroomController {
    @GetMapping("/{roomId}")
    public String chatroomPage(@PathVariable int roomId, Model model) {
        model.addAttribute("roomId", roomId);
        // /WEB-INF/views/chat/room.jsp 로 포워딩
        return "chat/room";
    }
}
