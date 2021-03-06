#!/bin/sh

printf "Vim Keyboard Commands\n"
printf "\n"
printf "\n"

printf "FORMAT				    HELP					REPLACE\n"
printf "    operator [number] motion		main		:help			    mode	    R\n"
printf "					cmd		:help			    char	    r(newChar)\n"
printf "\n"
printf "\n"

# Modes
printf "Insert Mode			    NORMAL MODE					CHANGE\n"
printf "    inserted	    i			mode		R			    word	    ce\n"
printf "    appended	    a			char		r(newChar)		    endline	    c$\n"
printf "    apd endline     A\n"
printf "\n"
printf "COPY		    y		    SHELL		:!command\n"
printf "\n"
# Delete
printf "DELETE				    INSERT					UNDO\n"	
printf "    character	    x			put		p			    pervious	    u\n"
printf "    word	    dw			retreive	:r			    all line	    line\n"
printf "    end line	    d$			retrvDIR	:r !dir"
printf "    whole line	    dd			linebelow	o			REDO		    CTRL-r\n"
printf "					lineabove	O\n"
printf "\n"
printf "\n"
# Movement 
printf "MOVEMENT			    COPY		y			SEARCH		    /content\n"
printf "    up		    k								    backward	    /content?\n"
printf "    down	    j		    CHANGE					    next	    n\n"
printf "    left	    h			word		ce			    previous	    CTRL-O\n"
printf "    right	    l			end line	c$			    new		    CTRL-I\n"
printf "    next word\n"
printf "	start	    w		    SUBSTITUTE					EXITING/SAVING\n"
printf "	end	    e			new4old		:s/old/new		    saveQuit	    :wq\n"
printf "    begin line	    O			new4line	:s/old/new/g		    noSave	    :q!\n"
printf "    line #	    #G			btwlines	:#,#s/old/new/g		    window	    :close\n"
printf "    end file	    G			allfiles	:%s/old/new/g		    save	    :w filename\n"
printf "    begin file	    gg			confirmation	:%s/old/new/gc\n"
printf "    chng window	    CTRL-w\n"
printf "\n"
