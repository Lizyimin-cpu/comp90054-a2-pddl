(define (domain UpdsideDown)

    (:requirements
        :typing
        :negative-preconditions
        :conditional-effects
    )

    (:types
        matches keys - items
        cells
        colour
    )

    (:predicates
        
        ;Indicates the number of uses left in a key
        (key-infinite-uses ?k - keys)

        (key-two-use ?k - keys)
        
        (key-one-use ?k - keys)
        
        (key-used-up ?k - keys)

        ;Add other predicates needed to model this domain 
        (at ?from - cells)
        (connected ?from ?to - cells)
        (existmonster ?from - cells)
        (invigilated ?from - cells)
        (lighted-match)
        (have-match ?m - matches)
        (existkey ?k - keys ?from - cells)
        (existmatch ?m - matches ?from - cells)
        (empty-hands)
        (have-key ?k - keys)
        (existdoor ?from - cells ?c - colour)
        (key-colour ?k - keys ?c - colour)
        (closed-door ?from - cells)
    )

    ;Hero can move if the
    ;    - hero is at current location
    ;    - cells are connected, 
    ;    - there is no monster in current loc and destination, and 
    ;    - destination is not invigilated
    ;Effects move the hero, and the original cell becomes invigilated.
    (:action move
        :parameters (?from ?to - cells)
        :precondition (and 
            (at ?from)                
            (or
            (connected ?from ?to)
            (connected ?to ?from)
            )
            (not (existmonster ?from))
            (not(existmonster ?to))
            (not (invigilated ?to))
        )
        :effect (and 
            (at ?to)
            (invigilated ?from)
            (not (at ?from))
            (not (lighted-match))
                )
    )
    
    ;When this action is executed, the hero leaves a location with a monster in it
    (:action move-out-of-monster
        :parameters (?from ?to - cells)
        :precondition (and 
            (at ?from)                
            (or
            (connected ?from ?to)
            (connected ?to ?from)
            )
            (existmonster ?from)
            (lighted-match)
            (not (invigilated ?to))
        )
        :effect (and 
            (at ?to)
            (invigilated ?from)
            (not (at ?from))
            (not (lighted-match))
                )
    )

    ;When this action is executed, the hero leaves a location without a monster and gets into a location with a monster
    (:action move-into-monster
        :parameters (?from ?to - cells ?m - matches)
        :precondition (and 
            (at ?from)                
            (or
            (connected ?from ?to)
            (connected ?to ?from)
            )
            (not (existmonster ?from))
            (existmonster ?to)
            (have-match ?m)
            (not (invigilated ?to))
        )
        :effect (and 
            (at ?to)
            (invigilated ?from)
            (not (at ?from))
            (not (lighted-match))
                )
    )
    
    ;Hero's picks a key if he's in the same location
    (:action pick-key
        :parameters (?loc - cells ?k - keys)
        :precondition (and 
            (existkey ?k ?loc)
            (empty-hands)
            (at ?loc)
                      )
        :effect (and
            (have-key ?k)
            (not (empty-hands))
            (not (existkey ?k ?loc))
                )
    )

    ;Hero's picks a match if he's in the same location
    (:action pick-match
        :parameters (?loc - cells ?m - matches)
        :precondition (and 
            (existmatch ?m ?loc)
            (empty-hands)
            (at ?loc)
                      )
        :effect (and
            (have-match ?m)
            (not (empty-hands))
            (not (existmatch ?m ?loc))
                )
    )
    
   ;Hero's drops his key. 
    (:action drop-key
        :parameters (?loc - cells ?k - keys)
        :precondition (and 
            (have-key ?k)
            (at ?loc)
                      )
        :effect (and
            (existkey ?k ?loc) 
            (empty-hands)
            (not (have-key ?k))
                )
    )

    ;Hero's drops his match. 
    (:action drop-match
        :parameters (?loc - cells ?m - matches)
        :precondition (and 
            (have-match ?m)
            (at ?loc)
                      )
        :effect (and
            (existmatch ?m ?loc) 
            (empty-hands)
            (not (have-match ?m))
                )
    )
    
    ;Hero's disarm the trap with his hand
    (:action close-gate
        :parameters (?from ?to - cells ?k - keys ?c - colour)
        :precondition (and 
            (at ?from)                
            (or
            (connected ?from ?to)
            (connected ?to ?from)
            )
            (existdoor ?to ?c)
            (have-key ?k)
            (key-colour ?k ?c)
            (or
            (key-infinite-uses ?k)
            (key-two-use ?k)
            (key-one-use ?k)
            )
            )
        :effect (and

                (closed-door ?to) 
                    ;When a key has two uses, then it becomes a single use
                    (when (key-two-use ?k) (key-one-use ?k))
                    ;When a key has a single use, it becomes used-up
                    (when (key-one-use ?k) (key-used-up ?k))       
                )
    )

    ;Hero strikes her match
    (:action strike-match
        :parameters (?m - matches)
        :precondition (and 
            (have-match ?m)                
        )
        :effect (and 
            (lighted-match)               
        )
    )
    
)
