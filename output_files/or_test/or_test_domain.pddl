(define
    (domain or_test)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_cuisine)
        (have_restaurant)
        (have_goal)
        (goal)
        (have-message)
        (force-statement)
    )
    (:action get-cuisine
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (have_cuisine))
            )
        :effect
            (labeled-oneof set-cuisine
                (outcome valid
                    (and
                        (have_cuisine)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action test_context_and_value_set
        :parameters()
        :precondition
            (and
                (not (have_restaurant))
                (not (force-statement))
                (have_cuisine)
            )
        :effect
            (labeled-oneof assign_restaurant
                (outcome set-mexican
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-italian
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-chinese
                    (and
                        (have_restaurant)
                    )
                )
                (outcome set-dessert
                    (and
                        (have_restaurant)
                    )
                )
            )
    )
    (:action test_and
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (have_restaurant)
            )
        :effect
            (labeled-oneof done
                (outcome done
                    (and
                        (have_goal)
                        (goal)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (force-statement)
                (have-message)
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
)