(define
    (domain value_test)
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
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action test_value
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (cuisine-value-italian)
            )
        :effect
            (labeled-oneof test-value
                (outcome assign
                    (and
                        (test)
                    )
                )
            )
    )
    (:action goal1
        :parameters()
        :precondition
            (and
                (cuisine-value-mexican)
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
    (:action goal2
        :parameters()
        :precondition
            (and
                (test)
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
    (:action set-cuisine
        :parameters()
        :precondition
            (and
                (have_cuisine)
                (not (cuisine-value-italian))
                (not (cuisine-value-mexican))
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
            )
    )
)