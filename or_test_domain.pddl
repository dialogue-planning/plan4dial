(define
    (domain or_test)
    (:requirements :strips :typing :disjunctive-preconditions)
    (:types )
    (:constants )
    (:predicates
        (mexican)
        (italian)
        (dessert)
        (chinese)
        (test)
        (have_cuisine)
        (goal)
    )
    (:action get-cuisine
        :parameters ()
        :precondition (not (have_cuisine))
        :effect 
            (labeled-oneof set-cuisine
                (outcome valid
                    (and
                        (have_cuisine)
                    )
                )
            )
    )
    (:action set-cuisine
        :parameters ()
        :precondition (have_cuisine)
        :effect (and
                    (oneof
                        (mexican)
                        (italian)
                        (dessert)
                        (chinese)
                    )
        )
    )
    (:action test_or
        :parameters ()
        :precondition (or (italian) (mexican) (dessert) (chinese))
        :effect 
            (labeled-oneof done
                (outcome done
                    (and
                        (goal)
                    )
                )
            )
    )
    ; (:action test_or_2
    ;     :parameters ()
    ;     :precondition (or (dessert) (chinese))
    ;     :effect 
    ;         (labeled-oneof done2
    ;             (outcome done2
    ;                 (and
    ;                     (goal)
    ;                     (test)
    ;                 )
    ;             )
    ;         )
    ; )
)