package com.pedalshootout.api.controller;

import com.pedalshootout.api.dto.BoardPlannerDto;
import com.pedalshootout.api.service.BoardPlannerService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Layer 2 controller: Board Planner.
 *
 *   GET /api/board-planner/components               — all boards, supplies, pedals for planning
 *   GET /api/board-planner/fit-check?boardId=X&pedalIds=1,2,3  — do these pedals fit on this board?
 */
@RestController
@RequestMapping("/api/board-planner")
public class BoardPlannerController {

    private final BoardPlannerService boardPlannerService;

    public BoardPlannerController(BoardPlannerService boardPlannerService) {
        this.boardPlannerService = boardPlannerService;
    }

    @GetMapping("/components")
    public BoardPlannerDto.Components getComponents() {
        return boardPlannerService.getComponents();
    }

    @GetMapping("/fit-check")
    public ResponseEntity<BoardPlannerDto.FitCheckResult> fitCheck(
            @RequestParam Integer boardId,
            @RequestParam List<Integer> pedalIds) {
        return boardPlannerService.fitCheck(boardId, pedalIds)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
