(define
    (domain test)
    (:requirements :strips :typing :disjunctive-preconditions)
    (:types )
    (:constants )
    (:predicates
        (mexican)
        (italian)
        (dessert)
        (breakfast)
        (dairy-free)
        (gluten-free)
        (have-restaurant)
        (have_allergy)
        (set-cuisine)
        (goal)
    )
    (:action set-restaurant
        :parameters ()
        :precondition (and (have_allergy))
        :effect 
            (labeled-oneof validate
                (outcome valid
                    (and
                        (when (or (dairy-free) (gluten-free)) (and (dessert)))
                        (when (or (mexican) (italian)) (and (breakfast)))
                    )
                )
        
            )
    )
    
    ; (:action get-restaurant
    ;     :parameters()
    ;     :precondition
    ;         (and
    ;             (not (have-restaurant))
    ;         )
    ;     :effect
    ;         (labeled-oneof validate
    ;             (outcome valid
    ;                 (and
    ;                     (have-restaurant)
    ;                     (set-cuisine)
    ;                 )
    ;             )
    ;         )
    ; )

    ; (:action set-cuisine
    ;     :parameters ()
    ;     :precondition (and (set-cuisine))
    ;     :effect (and
    ;                 (oneof
    ;                     ; (mexican)
    ;                     ; (italian)
    ;                     (dessert)
    ;                     (breakfast)
    ;                 )
    ;                 (not (set-cuisine))
    ;     )
    ; )

    ; (:action dairy-free
    ;     :parameters ()
    ;     :precondition (or
    ;                     (dessert)
    ;                     (breakfast) 
    ;                 )
    ;     :effect
    ;         (when (dessert) (dairy-free))
    ; )
    
    
    (:action complete
        :parameters ()
        :precondition (or (dessert) (breakfast));(have-restaurant))
        :effect 
            (labeled-oneof done
                (outcome done
                    (and
                        (goal)
                    )
                )
            )
    )
)