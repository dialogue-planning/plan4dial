(define
    (domain when_test)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_cuisine)
        (have_food_restriction)
        (have_allergy)
        (goal)
        (have-message)
        (force-statement)
    )
    (:action set-restaurant
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (have_allergy)
            )
        :effect
            (labeled-oneof validate
                (outcome valid
                    (and
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (have-message)
                (force-statement)
            )
        :effect
            (labeled-oneof reset
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action complete-or-1
        :parameters()
        :precondition
            (and
                (dessert)
                (not (force-statement))
            )
        :effect
            (labeled-oneof done
                (outcome done
                    (and
                        (goal)
                    )
                )
            )
    )
    (:action complete-or-2
        :parameters()
        :precondition
            (and
                (breakfast)
                (not (force-statement))
            )
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