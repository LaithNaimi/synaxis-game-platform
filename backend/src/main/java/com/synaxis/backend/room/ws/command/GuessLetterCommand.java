package com.synaxis.backend.room.ws.command;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class GuessLetterCommand extends BaseCommand {

    private String letter;
}