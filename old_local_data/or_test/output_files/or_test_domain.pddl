(define
    (domain or_test)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_cuisine)
        (have_restaurant)
        (test)
        (have_goal)
        (goal)
        (have-message)
        (force-statement)
        (cuisine-value-mexican)
        (cuisine-value-italian)
        (cuisine-value-chinese)
        (cuisine-value-dessert)
        (cuisine-value-bar_food)
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
    (:action test_and
        :parameters()
        :precondition
            (and
                (have_cuisine)
                (cuisine-value-dessert)
                (not (force-statement))
            )
        :effect
            (labeled-oneof done
                (outcome done
                    (and
                        (test)
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
                (cuisine-value-italian)
                (not (force-statement))
            )
        :effect
            (labeled-oneof done
                (outcome done
                    (and
                        (not (cuisine-value-bar_food))
                        (not (cuisine-value-italian))
                        (not (cuisine-value-mexican))
                        (not (cuisine-value-dessert))
                        (not (have_cuisine))
                        (goal)
                        (not (cuisine-value-chinese))
                    )
                )
            )
    )
    (:action test_or-or-2
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
                        (not (cuisine-value-bar_food))
                        (not (cuisine-value-italian))
                        (not (cuisine-value-mexican))
                        (not (cuisine-value-dessert))
                        (not (have_cuisine))
                        (goal)
                        (not (cuisine-value-chinese))
                    )
                )
            )
    )
    (:action test_or-or-3
        :parameters()
        :precondition
            (and
                (cuisine-value-chinese)
                (not (force-statement))
            )
        :effect
            (labeled-oneof done
                (outcome done
                    (and
                        (not (cuisine-value-bar_food))
                        (not (cuisine-value-italian))
                        (not (cuisine-value-mexican))
                        (not (cuisine-value-dessert))
                        (not (have_cuisine))
                        (goal)
                        (not (cuisine-value-chinese))
                    )
                )
            )
    )
    (:action test_or-or-4
        :parameters()
        :precondition
            (and
                (cuisine-value-dessert)
                (test)
                (not (force-statement))
            )
        :effect
            (labeled-oneof done
                (outcome done
                    (and
                        (not (cuisine-value-bar_food))
                        (not (cuisine-value-italian))
                        (not (cuisine-value-mexican))
                        (not (cuisine-value-dessert))
                        (not (have_cuisine))
                        (goal)
                        (not (cuisine-value-chinese))
                    )
                )
            )
    )
    (:action test_or-or-5
        :parameters()
        :precondition
            (and
                (cuisine-value-bar_food)
                (not (force-statement))
            )
        :effect
            (labeled-oneof done
                (outcome done
                    (and
                        (not (cuisine-value-bar_food))
                        (not (cuisine-value-italian))
                        (not (cuisine-value-mexican))
                        (not (cuisine-value-dessert))
                        (not (have_cuisine))
                        (goal)
                        (not (cuisine-value-chinese))
                    )
                )
            )
    )
    (:action set-cuisine
        :parameters()
        :precondition
            (and
                (not (cuisine-value-bar_food))
                (not (cuisine-value-italian))
                (not (cuisine-value-mexican))
                (not (cuisine-value-dessert))
                (have_cuisine)
                (not (cuisine-value-chinese))
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
                (outcome bar_food
                    (and
                        (cuisine-value-bar_food)
                    )
                )
            )
    )
)