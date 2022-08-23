(define
    (domain or_test)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_cuisine)
        (test)
        (goal)
        (have-message)
        (force-statement)
        (cuisine-value-mexican)
        (cuisine-value-italian)
        (cuisine-value-chinese)
        (cuisine-value-dessert)
    )
    (:action get-cuisine
        :parameters()
        :precondition
            (and
                (not (have_cuisine))
                (not (force-statement))
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
    (:action test_or-or-1
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (cuisine-value-italian)
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
    (:action test_or-or-2
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (cuisine-value-mexican)
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
    (:action test_or-or-3
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (test)
                (cuisine-value-dessert)
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
    (:action set-cuisine
        :parameters()
        :precondition
            (and
                (not (cuisine-value-chinese))
                (not (cuisine-value-mexican))
                (not (cuisine-value-italian))
                (not (cuisine-value-dessert))
                (have_cuisine)
            )
        :effect
            (labeled-oneof set-valid-value
                (outcome mexican
                    (and
                        (cuisine-value-mexican)
                    )
                )
                (outcome italian
                    (and
                        (cuisine-value-italian)
                    )
                )
                (outcome chinese
                    (and
                        (cuisine-value-chinese)
                    )
                )
                (outcome dessert
                    (and
                        (cuisine-value-dessert)
                    )
                )
            )
    )
)